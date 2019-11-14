defmodule DefconWeb.GlobalStatusLive do
  @moduledoc false

  use Phoenix.LiveView

  alias Defcon.Schemas.Outage
  alias DefconWeb.LayoutView

  def mount(session, socket) do
    if connected?(socket), do: DefconWeb.Endpoint.subscribe("checker")

    socket =
      socket
      |> assign(session)
      |> assign(current_time: Timex.now())

    {:ok, socket}
  end

  def render(assigns) do
    LayoutView.render("_status.html", assigns)
  end

  def handle_info(%{topic: "checker", event: "tick"}, socket) do
    has_outages = !Enum.empty?(Outage.currents())

    socket = assign(socket, has_outages: has_outages, current_time: Timex.now())

    {:noreply, socket}
  end
end
