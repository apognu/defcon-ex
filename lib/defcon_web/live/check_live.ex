defmodule DefconWeb.CheckLive do
  @moduledoc false

  use Phoenix.LiveView

  alias Defcon.Schemas.{Check, Outage}
  alias DefconWeb.ChecksView

  def mount(session, socket) do
    if connected?(socket), do: DefconWeb.Endpoint.subscribe("checker")

    socket =
      socket
      |> assign(session)

    {:ok, socket}
  end

  def render(assigns) do
    ChecksView.render("show.html", assigns)
  end

  def handle_info(%{topic: "checker", event: "tick"}, %{assigns: %{check: check}} = socket) do
    check = Check.by(uuid: check.uuid)
    outages = Outage.current_for(check)

    stats_72h = Outage.stats(72, :hours, check)
    stats_1w = Outage.stats(7, :days, check)
    stats_30d = Outage.stats(30, :days, check)

    socket =
      assign(socket,
        check: check,
        outages: outages,
        stats_72h: stats_72h,
        stats_1w: stats_1w,
        stats_30d: stats_30d
      )

    {:noreply, socket}
  end
end
