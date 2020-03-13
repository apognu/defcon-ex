defmodule Defcon.Schemas.HTTPSpec do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Defcon.Schemas.{Check, HTTPSpec}

  @derive {Jason.Encoder, only: ~w(id url expected_code expected_content)a}
  schema "http_specs" do
    belongs_to(:check, Check)

    field(:url, :string)
    field(:expected_code, :integer)
    field(:expected_content, :string)

    timestamps()
  end

  @required_fields ~w(url)a
  @optional_fields ~w(expected_code expected_content)a

  def changeset(%HTTPSpec{} = check, attrs \\ %{}) do
    check
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
