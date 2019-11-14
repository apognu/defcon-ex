defmodule DefconWeb.DashboardLive do
  @moduledoc false

  use Phoenix.LiveView

  alias Defcon.Schemas.Outage
  alias DefconWeb.DashboardView

  def mount(session, socket) do
    if connected?(socket) do
      DefconWeb.Endpoint.subscribe("checker")
    end

    socket =
      socket
      |> assign(session)

    {:ok, socket}
  end

  def render(assigns) do
    DashboardView.render("index.html", assigns)
  end

  def handle_info(%{topic: "checker", event: "tick"}, socket) do
    {:noreply, update(socket)}
  end

  defp update(socket) do
    outages = Outage.currents()
    stats_1w = Outage.stats(7, :days)
    stats_72h = Outage.stats(72, :hours)
    stats_1y = Outage.stats(12, :months)

    socket
    |> assign(outages: outages, stats_1y: stats_1y, stats_1w: stats_1w, stats_72h: stats_72h)
  end
end
