defmodule DefconWeb.CheckListLive do
  @moduledoc false

  use Phoenix.LiveView

  alias Defcon.Schemas.Check
  alias DefconWeb.ChecksView

  def mount(session, socket) do
    if connected?(socket), do: DefconWeb.Endpoint.subscribe("checker")

    socket =
      socket
      |> assign(session)

    {:ok, socket}
  end

  def render(assigns) do
    ChecksView.render("index.html", assigns)
  end

  def handle_info(%{topic: "checker", event: "tick"}, socket) do
    checks =
      Check.by_filters(%{
        "group_id" => socket.assigns[:filter_group_id],
        "check_title" => socket.assigns[:filter_check_title]
      })
      |> Enum.map(fn check -> Check.current_outage(check) end)

    socket = assign(socket, checks: checks)

    {:noreply, socket}
  end

  def handle_event("filter-group", %{"filters" => filters}, socket) do
    checks =
      Check.by_filters(filters)
      |> Enum.map(fn check -> Check.current_outage(check) end)

    socket =
      assign(socket,
        filter_group_id: filters["group_id"],
        filter_check_title: filters["check_title"],
        checks: checks
      )

    {:noreply, socket}
  end
end
