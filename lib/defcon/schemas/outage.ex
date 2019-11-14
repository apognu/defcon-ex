defmodule Defcon.Schemas.Outage do
  @moduledoc false

  use Ecto.Schema

  import Ecto.{Query, Changeset}

  alias Defcon.Repo
  alias Defcon.Schemas.{Check, Event, Outage}

  schema "outages" do
    belongs_to(:check, Check)
    belongs_to(:event, Event)

    field(:uuid, :string)
    field(:passing_strikes, :integer)
    field(:failing_strikes, :integer)
    field(:started_on, :utc_datetime)
    field(:ended_on, :utc_datetime)
  end

  @required_fields ~w(check_id event_id started_on)a
  @optional_fields ~w(passing_strikes failing_strikes ended_on)a

  def changeset(%Outage{} = outage, attrs \\ %{}) do
    outage
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> generate_uuid()
  end

  def currents do
    Repo.all(
      from(o in Outage,
        join: c in Check,
        on: c.id == o.check_id,
        where: c.enabled and o.failing_strikes >= c.failing_threshold and is_nil(o.ended_on),
        preload: [:event, check: [:group]]
      )
    )
  end

  def current_for(%Check{} = check, state \\ :confirmed) do
    where =
      case state do
        :confirmed ->
          dynamic(
            [o],
            o.check_id == ^check.id and o.failing_strikes >= ^check.failing_threshold and
              is_nil(o.ended_on)
          )

        :transient ->
          dynamic(
            [o],
            o.check_id == ^check.id and
              is_nil(o.ended_on)
          )
      end

    if check.enabled do
      Repo.one(
        from(o in Outage,
          where: ^where,
          preload: [check: [:group]]
        )
      )
    else
      []
    end
  end

  def stats(backlog, unit, check \\ nil) do
    now = Timex.now()

    {end_time, bucket} =
      case unit do
        :minutes ->
          {now |> Timex.set(second: 0), %Postgrex.Interval{secs: 60}}

        :hours ->
          {now |> Timex.set(minute: 0, second: 0), %Postgrex.Interval{secs: 3600}}

        :days ->
          {now |> Timex.set(hour: 0, minute: 0, second: 0), %Postgrex.Interval{days: 1}}

        :weeks ->
          {now
           |> Timex.end_of_week(:mon), %Postgrex.Interval{days: 7}}

        :months ->
          {now
           |> Timex.end_of_month(), %Postgrex.Interval{months: 1}}
      end

    start_time = Timex.shift(end_time, Keyword.put([], unit, -backlog))
    start_time = if unit == :months, do: Timex.beginning_of_month(start_time), else: start_time

    on =
      if is_nil(check) do
        dynamic(
          [o, range],
          (o.started_on >= range.start and o.started_on < range.end) or
            (o.ended_on >= range.start and o.ended_on < range.end) or
            (o.started_on < range.start and o.ended_on >= range.end) or
            (o.started_on < range.end and is_nil(o.ended_on))
        )
      else
        dynamic(
          [o, range],
          o.check_id == ^check.id and
            ((o.started_on >= range.start and o.started_on < range.end) or
               (o.ended_on >= range.start and o.ended_on < range.end) or
               (o.started_on < range.start and o.ended_on >= range.end) or
               (o.started_on < range.end and is_nil(o.ended_on)))
        )
      end

    Repo.all(
      from(o in Outage,
        right_join:
          range in fragment(
            ~s[SELECT range.start AS start, range.start + ? AS end FROM GENERATE_SERIES(?, ?, ?::INTERVAL) range (start)],
            ^bucket,
            ^start_time,
            ^end_time,
            ^bucket
          ),
        on: ^on,
        select: [range.start, count(o.id)],
        group_by: range.start,
        order_by: range.start
      )
    )
  end

  defp generate_uuid(%Ecto.Changeset{data: %Outage{uuid: nil}} = changeset) do
    put_change(changeset, :uuid, UUID.uuid4())
  end

  defp generate_uuid(changeset), do: changeset
end
