defmodule Defcon.Schemas.Event do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Query

  alias Defcon.Repo
  alias Defcon.Schemas.{Check, Event, Outage}

  @derive {Jason.Encoder, only: ~w(status message inserted_at)a}
  schema "events" do
    belongs_to(:check, Check)
    has_one(:outage, Outage)

    field(:status, :integer)
    field(:message, :string)

    timestamps()

    field(:rn, :integer, virtual: true)
  end

  def failed_for_outage(%Outage{} = outage) do
    Repo.all(
      from(e in Event,
        where:
          e.check_id == ^outage.check_id and e.status == 1 and e.inserted_at >= ^outage.started_on
      )
    )
  end

  def passed_for_outage(%Outage{} = outage) do
    Repo.all(
      from(e in Event,
        where:
          e.check_id == ^outage.check_id and e.status == 0 and e.inserted_at >= ^outage.started_on
      )
    )
  end
end
