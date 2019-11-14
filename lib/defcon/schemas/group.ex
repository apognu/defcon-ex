defmodule Defcon.Schemas.Group do
  @moduledoc false

  use Ecto.Schema

  import Ecto.{Changeset, Query}

  alias Defcon.Repo
  alias Defcon.Schemas.{Group, Check, Outage}

  schema "groups" do
    has_many(:checks, Check)

    field(:uuid, :string)
    field(:title, :string)

    timestamps()
  end

  @required_fields ~w(title)a

  def changeset(%Group{} = group, attrs \\ %{}) do
    group
    |> cast(attrs, @required_fields)
    |> generate_uuid()
    |> validate_required(@required_fields)
  end

  def all do
    Repo.all(from(Group, preload: [:checks]))
  end

  def by(filter) do
    Repo.one(from(Group, where: ^filter))
  end

  def outages_for(%Group{} = group) do
    Repo.all(
      from(o in Outage,
        left_join: c in Check,
        on: [id: o.check_id],
        where:
          c.group_id == ^group.id and is_nil(o.ended_on) and
            o.failing_strikes >= c.failing_threshold
      )
    )
  end

  defp generate_uuid(%Ecto.Changeset{data: %Group{uuid: nil}} = changeset) do
    put_change(changeset, :uuid, UUID.uuid4())
  end

  defp generate_uuid(changeset), do: changeset
end
