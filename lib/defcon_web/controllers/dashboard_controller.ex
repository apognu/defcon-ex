defmodule DefconWeb.DashboardController do
  use DefconWeb, :controller

  alias Defcon.Schemas.Outage

  def index(conn, _params) do
    outages = Outage.currents()
    stats_1w = Outage.stats(7, :days)
    stats_72h = Outage.stats(72, :hours)
    stats_1y = Outage.stats(12, :months)

    live_render(conn, DefconWeb.DashboardLive,
      session: %{outages: outages, stats_1y: stats_1y, stats_1w: stats_1w, stats_72h: stats_72h}
    )
  end
end
