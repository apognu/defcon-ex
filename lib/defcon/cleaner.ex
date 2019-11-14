defmodule Defcon.Cleaner do
  @moduledoc false

  use GenServer

  import Ecto.Query

  alias Defcon.Repo
  alias Defcon.Schemas.Event

  def start_link(_opts \\ []), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def init(_args) do
    send(self(), :tick)

    {:ok, %{}}
  end

  def handle_info(:tick, _state) do
    from(e in Event,
      where:
        fragment("? NOT IN ( SELECT event_id FROM outages )", e.id) and
          e.inserted_at <
            ^Timex.shift(Timex.now(), hours: -Application.get_env(:defcon, :event_history))
    )
    |> Repo.delete_all()

    Process.send_after(self(), :tick, Application.get_env(:defcon, :cleaner_interval))

    {:noreply, %{}}
  end
end
