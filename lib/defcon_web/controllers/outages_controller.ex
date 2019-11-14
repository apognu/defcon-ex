defmodule DefconWeb.OutagesController do
  use DefconWeb, :controller

  alias Defcon.Schemas.Outage

  def index(conn, _params) do
    outages = Outage.currents()

    live_render(conn, DefconWeb.OutageListLive, session: %{outages: outages})
  end
end
