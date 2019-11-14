defmodule Defcon.Schemas.TCPSpec do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Defcon.Schemas.{Check, TCPSpec}

  schema "tcp_specs" do
    belongs_to(:check, Check)

    field(:host, :string)
    field(:port, :integer)

    timestamps()
  end

  @required_fields ~w(host port)a

  def changeset(%TCPSpec{} = check, attrs \\ %{}) do
    check
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
