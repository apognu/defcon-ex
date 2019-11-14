defmodule Defcon.Schemas.CRTSpec do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Defcon.Schemas.{Check, CRTSpec}

  schema "crt_specs" do
    belongs_to(:check, Check)

    field(:domain, :string)

    timestamps()
  end

  @required_fields ~w(domain)a

  def changeset(%CRTSpec{} = check, attrs \\ %{}) do
    check
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
