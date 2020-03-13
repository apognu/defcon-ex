defmodule DefconWeb.Api.GroupsController do
  use DefconWeb, :controller

  alias Defcon.Repo
  alias Defcon.Schemas.Group

  def index(conn, _params) do
    groups = Group.all()

    outages =
      groups
      |> Enum.into(%{}, fn group -> {group.id, length(Group.outages_for(group))} end)

    payload = %{
      groups: groups,
      outages: outages
    }

    conn
    |> put_view(DefconWeb.ApiView)
    |> render("ok.json", payload: payload)
  end

  def show(conn, %{"id" => uuid}) do
    case Group.by(uuid: uuid) do
      %Group{} = group ->
        conn
        |> put_view(DefconWeb.ApiView)
        |> render("ok.json", payload: group)

      nil ->
        conn
        |> put_status(:not_found)
        |> put_view(DefconWeb.ApiView)
        |> render("ok.json", message: "group does not exist")
    end
  end

  def create(conn, %{"group" => params}) do
    changeset = Group.changeset(%Group{}, params)

    case Repo.insert(changeset) do
      {:ok, _} ->
        send_resp(conn, :created, "")

      {:error, changeset} ->
        conn
        |> put_status(:internal_server_error)
        |> put_view(DefconWeb.ApiView)
        |> render("ok.json", message: "could not delete this group")
    end
  end

  def update(conn, %{"id" => uuid, "group" => params}) do
    group = Group.by(uuid: uuid)
    changeset = Group.changeset(group, params)

    case Repo.update(changeset) do
      {:ok, _} ->
        send_resp(conn, :no_content, "")

      {:error, changeset} ->
        action = Routes.groups_path(conn, :update, uuid)

        conn
        |> put_status(:internal_server_error)
        |> put_view(DefconWeb.ApiView)
        |> render("ok.json", message: "could not save this group")
    end
  end

  def delete(conn, %{"id" => uuid}) do
    group = Group.by(uuid: uuid)

    case Repo.delete(group) do
      {:ok, _} ->
        send_resp(conn, :no_content, "")

      {:error, _} ->
        conn
        |> put_status(:internal_server_error)
        |> put_view(DefconWeb.ApiView)
        |> render("ok.json", message: "could not delete this group")
    end
  end
end
