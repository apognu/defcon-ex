defmodule DefconWeb.OutageListLive do
  @moduledoc false

  use Phoenix.LiveView

  alias Defcon.Schemas.Outage
  alias DefconWeb.OutagesView

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
    OutagesView.render("index.html", assigns)
  end

  def handle_info(%{topic: "checker", event: "tick"}, socket) do
    {:noreply, update(socket)}
  end

  defp update(socket) do
    outages = Outage.currents()

    socket
    |> assign(outages: outages)
  end
end
