defmodule Defcon.Schemas.Alerter do
  @moduledoc false

  use Ecto.Schema

  import Ecto.{Changeset, Query}

  alias Defcon.Repo
  alias Defcon.Schemas.Alerter

  schema "alerters" do
    field(:uuid, :string)
    field(:title, :string)
    field(:api_key, :string)
    field(:channel, :string)

    timestamps()
  end

  @required_fields ~w(title api_key channel)a

  def changeset(%Alerter{} = alerter, attrs \\ %{}) do
    alerter
    |> cast(attrs, @required_fields)
    |> generate_uuid()
    |> validate_required(@required_fields)
  end

  def all do
    Repo.all(from(Alerter, order_by: [:id]))
  end

  def by(filters) do
    Repo.one(from(a in Alerter, where: ^filters))
  end

  defp generate_uuid(%Ecto.Changeset{data: %Alerter{uuid: nil}} = changeset) do
    put_change(changeset, :uuid, UUID.uuid4())
  end

  defp generate_uuid(changeset), do: changeset
end
