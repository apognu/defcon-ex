defmodule DefconWeb.Api.DashboardController do
  use DefconWeb, :controller

  alias Defcon.Schemas.Outage

  def status(conn, _params) do
    outages = Outage.currents(false)
    stats_1w = Outage.stats(7, :days)
    stats_72h = Outage.stats(72, :hours)
    stats_1y = Outage.stats(12, :months)

    payload = %{
      outages: length(outages),
      stats_1w: stats_1w,
      stats_72h: stats_72h,
      stats_1y: stats_1y
    }

    conn
    |> put_view(DefconWeb.ApiView)
    |> render("ok.json", payload: payload)
  end
end
