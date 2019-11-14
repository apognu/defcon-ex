defmodule DefconWeb.GroupsController do
  use DefconWeb, :controller

  alias Defcon.Repo
  alias Defcon.Schemas.Group

  def index(conn, _params) do
    groups = Group.all()

    group_outages =
      groups
      |> Enum.into(%{}, fn group -> {group.id, length(Group.outages_for(group))} end)

    live_render(conn, DefconWeb.GroupListLive,
      session: %{
        groups: groups,
        group_outages: group_outages,
        csrf_token: Phoenix.Controller.get_csrf_token()
      }
    )
  end

  def new(conn, _params) do
    action = Routes.groups_path(conn, :create)
    changeset = Group.changeset(%Group{})

    render(conn, "form.html",
      action: action,
      group: %Group{},
      changeset: changeset,
      csrf_token: Phoenix.Controller.get_csrf_token()
    )
  end

  def create(conn, %{"group" => params}) do
    changeset = Group.changeset(%Group{}, params)

    case Repo.insert(changeset) do
      {:ok, _} ->
        DefconWeb.Endpoint.broadcast("model", "groups", %{})

        conn
        |> put_flash(:flash, {:success, "Your new group were created successfully."})
        |> redirect(to: Routes.groups_path(conn, :index))

      {:error, changeset} ->
        action = Routes.groups_path(conn, :create)

        conn
        |> put_flash(:flash, {:danger, "Your new group could not be created."})
        |> render("form.html",
          action: action,
          group: %Group{},
          changeset: changeset,
          csrf_token: Phoenix.Controller.get_csrf_token()
        )
    end
  end

  def edit(conn, %{"id" => uuid}) do
    case Group.by(uuid: uuid) do
      %Group{} = group ->
        action = Routes.groups_path(conn, :update, uuid)
        changeset = Group.changeset(group)

        render(conn, "form.html",
          action: action,
          group: group,
          changeset: changeset,
          csrf_token: Phoenix.Controller.get_csrf_token()
        )

      nil ->
        conn
        |> put_flash(:flash, {:danger, "The group you are trying to edit does not exist."})
        |> redirect(to: Routes.groups_path(conn, :index))
    end
  end

  def update(conn, %{"id" => uuid, "group" => params}) do
    group = Group.by(uuid: uuid)
    changeset = Group.changeset(group, params)

    case Repo.update(changeset) do
      {:ok, _} ->
        DefconWeb.Endpoint.broadcast("model", "groups", %{})

        conn
        |> put_flash(:flash, {:success, "Your changes to this group were saved successfully."})
        |> redirect(to: Routes.groups_path(conn, :index))

      {:error, changeset} ->
        action = Routes.groups_path(conn, :update, uuid)

        conn
        |> put_flash(:flash, {:danger, "Your changes to this group could not be saved."})
        |> render("form.html",
          action: action,
          group: group,
          changeset: changeset,
          csrf_token: Phoenix.Controller.get_csrf_token()
        )
    end
  end

  def delete(conn, %{"id" => uuid}) do
    group = Group.by(uuid: uuid)

    case Repo.delete(group) do
      {:ok, _} ->
        DefconWeb.Endpoint.broadcast("model", "groups", %{})

        conn
        |> put_flash(:flash, {:success, "This group was deleted successfully."})
        |> redirect(to: Routes.groups_path(conn, :index))

      {:error, _} ->
        conn
        |> put_flash(:flash, {:danger, "This group could not be deleted."})
        |> redirect(to: Routes.groups_path(conn, :index))
    end
  end
end
