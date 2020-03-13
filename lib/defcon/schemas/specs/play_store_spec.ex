defmodule Defcon.Schemas.PlayStoreSpec do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Defcon.Schemas.{Check, PlayStoreSpec}

  @derive {Jason.Encoder, only: ~w(id app_id)a}
  schema "play_store_specs" do
    belongs_to(:check, Check)

    field(:app_id, :string)

    timestamps()
  end

  @required_fields ~w(app_id)a

  def changeset(%PlayStoreSpec{} = check, attrs \\ %{}) do
    check
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
