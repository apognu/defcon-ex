defmodule Defcon.Schemas.AppStoreSpec do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Defcon.Schemas.{Check, AppStoreSpec}

  schema "app_store_specs" do
    belongs_to(:check, Check)

    field(:bundle_id, :string)

    timestamps()
  end

  @required_fields ~w(bundle_id)a

  def changeset(%AppStoreSpec{} = check, attrs \\ %{}) do
    check
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
