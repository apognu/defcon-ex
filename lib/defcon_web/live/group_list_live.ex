defmodule DefconWeb.GroupListLive do
  @moduledoc false

  use Phoenix.LiveView

  alias Defcon.Schemas.Group
  alias DefconWeb.GroupsView

  def mount(session, socket) do
    if connected?(socket), do: DefconWeb.Endpoint.subscribe("checker")

    socket =
      socket
      |> assign(session)

    {:ok, socket}
  end

  def render(assigns) do
    GroupsView.render("index.html", assigns)
  end

  def handle_info(%{topic: "checker", event: "tick"}, socket) do
    groups = Group.all()

    group_outages =
      Enum.into(groups, %{}, fn group -> {group.id, length(Group.outages_for(group))} end)

    socket = assign(socket, groups: groups, group_outages: group_outages)

    {:noreply, socket}
  end
end
