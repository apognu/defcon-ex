defmodule DefconWeb.LayoutPlug do
  @moduledoc false

  import Plug.Conn

  alias Defcon.Schemas.Outage

  def init(options), do: options

  def call(conn, _opts) do
    has_outages = !Enum.empty?(Outage.currents())

    conn
    |> assign(:has_outages, has_outages)
  end
end
