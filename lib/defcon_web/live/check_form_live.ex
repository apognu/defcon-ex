defmodule DefconWeb.CheckFormLive do
  @moduledoc false

  use Phoenix.LiveView

  alias Defcon.Schemas.Check
  alias DefconWeb.ChecksView

  def mount(session, socket) do
    session = Map.put(session, :changeset, Check.changeset(session.check))

    socket =
      socket
      |> assign(session)
      |> maybe_assign(session.changeset.data, :title)
      |> maybe_assign(session.changeset.data, :kind)

    {:ok, socket}
  end

  def render(assigns) do
    ChecksView.render("form.html", assigns)
  end

  def handle_event("update", %{"check" => check}, socket) do
    socket =
      socket
      |> assign(changeset: Check.changeset(socket.assigns.check, check))
      |> maybe_assign(check, :title)
      |> maybe_assign(check, :kind)

    {:noreply, socket}
  end

  defp maybe_assign(%Phoenix.LiveView.Socket{} = socket, %Check{} = check, key) do
    if Map.get(check, key) != "",
      do: assign(socket, Keyword.put([], key, Map.get(check, key))),
      else: socket
  end

  defp maybe_assign(%Phoenix.LiveView.Socket{} = socket, check, key) when is_map(check) do
    key_string = to_string(key)

    if check[key_string] != "",
      do: assign(socket, Keyword.put([], key, check[key_string])),
      else: socket
  end
end
