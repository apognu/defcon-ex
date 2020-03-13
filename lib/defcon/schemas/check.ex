defmodule Defcon.Schemas.Check do
  @moduledoc false

  @kinds [
    {"http", "HTTP request"},
    {"app_store", "Apple App Store"},
    {"play_store", "Google Play Store"},
    {"tls", "Certificates expiration"},
    {"crt", "Certificates issuance"},
    {"tcp", "TCP port"}
  ]

  @specs ~w(http_spec play_store_spec app_store_spec tls_spec crt_spec tcp_spec)a
  @serialize ~w(uuid title kind enabled interval failing_threshold passing_threshold ignore group alerter outages events)a

  use Ecto.Schema
  use Defcon.Schemas.FilterNotLoaded, attrs: @serialize ++ @specs

  import Ecto.{Changeset, Query}

  alias Defcon.Repo
  alias Defcon.Schemas.{Group, Check, Outage, Event, Alerter}
  alias Defcon.Schemas.{HTTPSpec, PlayStoreSpec, AppStoreSpec, TLSSpec, CRTSpec, TCPSpec}

  schema "checks" do
    belongs_to(:group, Group)
    belongs_to(:alerter, Alerter)

    has_many(:events, Event)
    has_many(:outages, Outage)

    has_one(:http_spec, HTTPSpec)
    has_one(:play_store_spec, PlayStoreSpec)
    has_one(:app_store_spec, AppStoreSpec)
    has_one(:tls_spec, TLSSpec)
    has_one(:crt_spec, CRTSpec)
    has_one(:tcp_spec, TCPSpec)

    field(:uuid, :string)
    field(:title, :string)
    field(:enabled, :boolean)
    field(:kind, :string)
    field(:interval, :integer)
    field(:passing_threshold, :integer)
    field(:failing_threshold, :integer)
    field(:ignore, :boolean)

    timestamps()
  end

  @required_fields ~w(title enabled interval passing_threshold failing_threshold kind ignore)a
  @optional_fields ~w(group_id alerter_id)a

  def changeset(%Check{} = check, attrs \\ %{}) do
    check
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> cast_spec()
    |> generate_uuid()
    |> validate_required(@required_fields)
  end

  def all(detail \\ :full) do
    Repo.all(
      from(c in Check,
        order_by: [desc: c.title],
        preload: ^build_preload_list(detail)
      )
    )
  end

  def by(filter, detail \\ :full) do
    Repo.one(
      from(Check,
        where: ^filter,
        preload: ^build_preload_list(detail)
      )
    )
  end

  def all_by(filter, detail \\ :full) do
    Repo.all(
      from(c in Check,
        where: ^filter,
        order_by: [desc: c.title],
        preload: ^build_preload_list(detail)
      )
    )
  end

  def by_filters(filters, detail \\ :full) do
    filters =
      filters
      |> Enum.reduce(dynamic(true), fn {filter, value}, acc ->
        if is_nil(value) || value == "" do
          acc
        else
          case filter do
            "group_id" ->
              dynamic([c], ^acc and c.group_id == ^value)

            "check_title" ->
              dynamic(
                [c],
                ^acc and fragment("LOWER(?) LIKE ?", c.title, ^"%#{String.downcase(value)}%")
              )
          end
        end
      end)

    all_by(filters, detail)
  end

  def outdated do
    Repo.all(
      from(c in Check,
        preload: [:group, ^@specs],
        left_join:
          r in subquery(
            from(
              e in Event,
              distinct: e.check_id,
              select: struct(e, [:check_id, :inserted_at]),
              order_by: [desc: e.inserted_at]
            )
          ),
        on: [check_id: c.id],
        where:
          c.enabled and
            (is_nil(r.inserted_at) or
               r.inserted_at <
                 fragment("NOW() AT TIME ZONE 'UTC' - ? * INTERVAL '1 second'", c.interval))
      )
    )
  end

  def outages do
    Repo.all(
      from(c in Check,
        left_join:
          r in subquery(
            from(
              e in Event,
              distinct: e.check_id,
              select: struct(e, [:check_id, :status, :inserted_at]),
              order_by: [desc: e.inserted_at]
            )
          ),
        on: [check_id: c.id],
        preload: [events: ^from(e in Event, order_by: [desc: e.inserted_at])],
        where: not is_nil(r.inserted_at) and r.status != 0
      )
    )
  end

  def current_outage(%Check{} = check) do
    Repo.preload(check,
      outages:
        from(o in Outage,
          where:
            ^check.enabled and o.failing_strikes >= ^check.failing_threshold and
              is_nil(o.ended_on)
        )
    )
  end

  def create_result(%Check{} = check, status, message \\ nil) do
    Repo.insert!(%Event{
      check: check,
      status: status,
      message: message
    })
  end

  def kinds, do: @kinds

  defp generate_uuid(%Ecto.Changeset{data: %Check{uuid: nil}} = changeset) do
    put_change(changeset, :uuid, UUID.uuid4())
  end

  defp generate_uuid(changeset), do: changeset

  defp cast_spec(%Ecto.Changeset{} = changeset) do
    case Ecto.Changeset.get_change(changeset, :kind, changeset.data.kind) do
      "http" -> cast_assoc(changeset, :http_spec, required: true)
      "play_store" -> cast_assoc(changeset, :play_store_spec, required: true)
      "app_store" -> cast_assoc(changeset, :app_store_spec, required: true)
      "tls" -> cast_assoc(changeset, :tls_spec, required: true)
      "crt" -> cast_assoc(changeset, :crt_spec, required: true)
      "tcp" -> cast_assoc(changeset, :tcp_spec, required: true)
      _ -> changeset
    end
  end

  defp build_preload_list(detail) do
    events =
      from(
        x in subquery(
          from(e in Event,
            select: %Event{e | rn: over(row_number(), :check)},
            windows: [check: [partition_by: e.check_id, order_by: [desc: e.inserted_at]]]
          )
        ),
        where: fragment("rn < 30")
      )

    case detail do
      :simple ->
        [
          :group,
          events: events
        ]

      _ ->
        [
          @specs,
          :group,
          :alerter,
          events: events
        ]
    end
  end
end
