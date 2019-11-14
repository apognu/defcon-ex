defmodule DefconWeb.AlertersController do
  use DefconWeb, :controller

  alias Defcon.Repo
  alias Defcon.Schemas.Alerter

  def index(conn, _params) do
    alerters = Alerter.all()

    render(conn, "index.html", alerters: alerters)
  end

  def new(conn, _params) do
    action = Routes.alerters_path(conn, :create)
    changeset = Alerter.changeset(%Alerter{})

    render(conn, "form.html", action: action, alerter: %Alerter{}, changeset: changeset)
  end

  def create(conn, %{"alerter" => params}) do
    changeset = Alerter.changeset(%Alerter{}, params)

    case Repo.insert(changeset) do
      {:ok, _} ->
        DefconWeb.Endpoint.broadcast("model", "alerters", %{})

        conn
        |> put_flash(:flash, {:success, "Your new alerter was created successfully."})
        |> redirect(to: Routes.alerters_path(conn, :index))

      {:error, changeset} ->
        action = Routes.alerters_path(conn, :create)

        conn
        |> put_flash(:flash, {:danger, "Your new alerter could not be created."})
        |> render("form.html",
          action: action,
          alerter: %Alerter{},
          changeset: changeset,
          csrf_token: Phoenix.Controller.get_csrf_token()
        )
    end
  end

  def edit(conn, %{"id" => uuid}) do
    case Alerter.by(uuid: uuid) do
      %Alerter{} = alerter ->
        action = Routes.alerters_path(conn, :update, uuid)
        changeset = Alerter.changeset(alerter)

        render(conn, "form.html", action: action, changeset: changeset)

      nil ->
        conn
        |> put_flash(:flash, {:danger, "The alerter you are trying to edit does not exist."})
        |> redirect(to: Routes.alerters_path(conn, :index))
    end
  end

  def update(conn, %{"id" => uuid, "alerter" => params}) do
    alerter = Alerter.by(uuid: uuid)
    changeset = Alerter.changeset(alerter, params)

    case Repo.update(changeset) do
      {:ok, _} ->
        DefconWeb.Endpoint.broadcast("model", "alerters", %{})

        conn
        |> put_flash(:flash, {:success, "Your changes to this alerter were saved successfully."})
        |> redirect(to: Routes.alerters_path(conn, :index))

      {:error, changeset} ->
        action = Routes.alerters_path(conn, :update, uuid)

        conn
        |> put_flash(:flash, {:danger, "Your changes to this group could not be saved."})
        |> render("form.html",
          action: action,
          changeset: changeset,
          csrf_token: Phoenix.Controller.get_csrf_token()
        )
    end
  end

  def delete(conn, %{"id" => uuid}) do
    alerter = Alerter.by(uuid: uuid)

    case Repo.delete(alerter) do
      {:ok, _} ->
        DefconWeb.Endpoint.broadcast("model", "alerters", %{})

        conn
        |> put_flash(:flash, {:success, "This alerter was deleted successfully."})
        |> redirect(to: Routes.alerters_path(conn, :index))

      {:error, _} ->
        conn
        |> put_flash(:flash, {:danger, "This alerter could not be deleted."})
        |> redirect(to: Routes.alerters_path(conn, :index))
    end
  end
end
