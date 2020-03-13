defmodule DefconWeb.Api.AlertersController do
  use DefconWeb, :controller

  alias Defcon.Repo
  alias Defcon.Schemas.Alerter

  def index(conn, _params) do
    alerters = Alerter.all()

    conn
    |> put_view(DefconWeb.ApiView)
    |> render("ok.json", payload: alerters)
  end

  def show(conn, %{"id" => uuid}) do
    case Alerter.by(uuid: uuid) do
      %Alerter{} = alerter ->
        conn
        |> put_view(DefconWeb.ApiView)
        |> render("ok.json", payload: alerter)

      nil ->
        conn
        |> put_status(:not_found)
        |> put_view(DefconWeb.ApiView)
        |> render("ok.json", message: "alerter does not exist")
    end
  end

  def create(conn, %{"alerter" => params}) do
    changeset = Alerter.changeset(%Alerter{}, params)

    case Repo.insert(changeset) do
      {:ok, _} ->
        send_resp(conn, :created, "")

      {:error, changeset} ->
        conn
        |> put_status(:internal_server_error)
        |> put_view(DefconWeb.ApiView)
        |> render("ok.json", message: "could not delete this alerter")
    end
  end

  def update(conn, %{"id" => uuid, "alerter" => params}) do
    alerter = Alerter.by(uuid: uuid)
    changeset = Alerter.changeset(alerter, params)

    case Repo.update(changeset) do
      {:ok, _} ->
        send_resp(conn, :no_content, "")

      {:error, changeset} ->
        action = Routes.alerters_path(conn, :update, uuid)

        conn
        |> put_status(:internal_server_error)
        |> put_view(DefconWeb.ApiView)
        |> render("ok.json", message: "could not save this alerter")
    end
  end

  def delete(conn, %{"id" => uuid}) do
    alerter = Alerter.by(uuid: uuid)

    case Repo.delete(alerter) do
      {:ok, _} ->
        send_resp(conn, :no_content, "")

      {:error, _} ->
        conn
        |> put_status(:internal_server_error)
        |> put_view(DefconWeb.ApiView)
        |> render("ok.json", message: "could not delete this alerter")
    end
  end
end
