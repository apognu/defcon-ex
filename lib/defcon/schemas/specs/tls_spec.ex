defmodule Defcon.Schemas.TLSSpec do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Defcon.Schemas.{Check, TLSSpec}

  @derive {Jason.Encoder, only: ~w(id domains window)a}
  schema "tls_specs" do
    belongs_to(:check, Check)

    field(:domains, :string)
    field(:window, :integer)

    timestamps()
  end

  @required_fields ~w(domains window)a

  def changeset(%TLSSpec{} = check, attrs \\ %{}) do
    check
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
