defmodule DefconWeb.Api.ChecksController do
  use DefconWeb, :controller

  alias Defcon.Repo
  alias Defcon.Schemas.{Check, Group, Outage}

  def kinds(conn, _params) do
    kinds =
      Check.kinds()
      |> Map.new()

    conn
    |> put_view(DefconWeb.ApiView)
    |> render("ok.json", payload: kinds)
  end

  def index(conn, params) do
    checks =
      Check.by_filters(
        %{
          "group_id" => Map.get(params, "filter_group_id", nil),
          "check_title" => Map.get(params, "filter_check_title", nil)
        },
        :simple
      )
      |> Enum.map(fn check -> Check.current_outage(check) end)
      |> Enum.sort_by(fn check -> Enum.empty?(check.outages) end, fn x, _ -> !x end)

    groups = Group.all()

    payload = %{
      checks: checks,
      groups: groups
    }

    conn
    |> put_view(DefconWeb.ApiView)
    |> render("ok.json", payload: payload)
  end

  def show(conn, %{"id" => uuid}) do
    case Check.by(uuid: uuid) do
      %Check{} = check ->
        outages = Outage.current_for(check)

        stats_72h = Outage.stats(82, :hours, check)
        stats_1w = Outage.stats(7, :days, check)
        stats_30d = Outage.stats(30, :days, check)

        payload = %{
          check: check,
          outages: outages,
          stats_72h: stats_72h,
          stats_1w: stats_1w,
          stats_30d: stats_30d
        }

        conn
        |> put_view(DefconWeb.ApiView)
        |> render("ok.json", payload: payload)

      nil ->
        conn
        |> put_status(:not_found)
        |> put_view(DefconWeb.ApiView)
        |> render("ok.json", message: "check does not exist")
    end
  end

  def create(conn, %{"check" => params}) do
    changeset = Check.changeset(%Check{}, params)

    case Repo.insert(changeset) do
      {:ok, _} ->
        send_resp(conn, :created, "")

      {:error, changeset} ->
        conn
        |> put_status(:internal_server_error)
        |> put_view(DefconWeb.ApiView)
        |> render("ok.json", message: "could not delete this check")
    end
  end

  def update(conn, %{"id" => uuid, "check" => params}) do
    check = Check.by(uuid: uuid)
    changeset = Check.changeset(check, params)

    case Repo.update(changeset) do
      {:ok, _} ->
        send_resp(conn, :no_content, "")

      {:error, changeset} ->
        action = Routes.checks_path(conn, :update, uuid)

        conn
        |> put_status(:internal_server_error)
        |> put_view(DefconWeb.ApiView)
        |> render("ok.json", message: "could not save this check")
    end
  end

  def delete(conn, %{"id" => uuid}) do
    check = Check.by(uuid: uuid)

    case Repo.delete(check) do
      {:ok, _} ->
        send_resp(conn, :no_content, "")

      {:error, _} ->
        conn
        |> put_status(:internal_server_error)
        |> put_view(DefconWeb.ApiView)
        |> render("ok.json", message: "could not delete this check")
    end
  end
end
