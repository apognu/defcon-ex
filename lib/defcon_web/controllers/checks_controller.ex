defmodule DefconWeb.ChecksController do
  use DefconWeb, :controller

  alias Defcon.Repo
  alias Defcon.Schemas.{Group, Check, Outage, Alerter}

  def index(conn, _params) do
    checks =
      Check.all()
      |> Enum.map(fn check -> Check.current_outage(check) end)
      |> Enum.sort_by(fn check -> Enum.empty?(check.outages) end, fn x, _ -> !x end)

    groups = Group.all()

    live_render(conn, DefconWeb.CheckListLive,
      session: [
        checks: checks,
        groups: groups,
        csrf_token: Phoenix.Controller.get_csrf_token()
      ]
    )
  end

  def show(conn, %{"id" => uuid}) do
    check = Check.by(uuid: uuid)
    outages = Outage.current_for(check)

    stats_72h = Outage.stats(72, :hours, check)
    stats_1w = Outage.stats(7, :days, check)
    stats_30d = Outage.stats(30, :days, check)

    live_render(conn, DefconWeb.CheckLive,
      session: %{
        check: check,
        outages: outages,
        stats_72h: stats_72h,
        stats_1w: stats_1w,
        stats_30d: stats_30d
      }
    )
  end

  def new(conn, _params) do
    action = Routes.checks_path(conn, :create)

    changeset =
      Check.changeset(%Check{
        enabled: true,
        failing_threshold: 3,
        passing_threshold: 3,
        interval: 60
      })

    groups = Group.all()
    alerters = Alerter.all()
    kinds = Check.kinds()

    live_render(conn, DefconWeb.CheckFormLive,
      session: %{
        action: action,
        check: %Check{},
        changeset: changeset,
        groups: groups,
        alerters: alerters,
        kinds: kinds,
        csrf_token: Phoenix.Controller.get_csrf_token()
      }
    )
  end

  def create(conn, %{"check" => params}) do
    changeset = Check.changeset(%Check{}, params)

    case Repo.insert(changeset) do
      {:ok, _} ->
        DefconWeb.Endpoint.broadcast("model", "checks", %{})

        conn
        |> put_flash(:flash, {:success, "Your new check were created successfully."})
        |> redirect(to: Routes.checks_path(conn, :index))

      {:error, changeset} ->
        action = Routes.checks_path(conn, :create)

        groups = Group.all()
        kinds = Check.kinds()
        alerters = Alerter.all()

        conn
        |> put_flash(:flash, {:danger, "Your new check could not be created."})
        |> live_render(DefconWeb.CheckFormLive,
          session: %{
            action: action,
            check: %Check{},
            changeset: changeset,
            groups: groups,
            alerters: alerters,
            kind: params["kind"],
            kinds: kinds,
            csrf_token: Phoenix.Controller.get_csrf_token()
          }
        )
    end
  end

  def edit(conn, %{"id" => uuid}) do
    case Check.by(uuid: uuid) do
      %Check{} = check ->
        action = Routes.checks_path(conn, :update, uuid)

        groups = Group.all()
        alerters = Alerter.all()
        kinds = Check.kinds()

        live_render(conn, DefconWeb.CheckFormLive,
          session: %{
            action: action,
            check: check,
            groups: groups,
            alerters: alerters,
            kinds: kinds,
            csrf_token: Phoenix.Controller.get_csrf_token()
          }
        )

      nil ->
        conn
        |> put_flash(:flash, {:danger, "The check you are trying to edit does not exist."})
        |> redirect(to: Routes.checks_path(conn, :index))
    end
  end

  def update(conn, %{"id" => uuid, "check" => params}) do
    check = Check.by(uuid: uuid)
    changeset = Check.changeset(check, params)

    case Repo.update(changeset) do
      {:ok, _} ->
        DefconWeb.Endpoint.broadcast("model", "checks", %{})

        conn
        |> put_flash(:flash, {:success, "Your changes to this check were saved successfully."})
        |> redirect(to: Routes.checks_path(conn, :index))

      {:error, changeset} ->
        action = Routes.checks_path(conn, :update, uuid)

        groups = Group.all()
        alerters = Alerter.all()
        kinds = Check.kinds()

        conn
        |> put_flash(:flash, {:danger, "Your changes to this check could not be saved."})
        |> render("form.html",
          action: action,
          check: check,
          changeset: changeset,
          groups: groups,
          alerters: alerters,
          kind: params["kind"],
          kinds: kinds
        )
    end
  end

  def delete(conn, %{"id" => uuid}) do
    check = Check.by(uuid: uuid)

    case Repo.delete(check) do
      {:ok, _} ->
        DefconWeb.Endpoint.broadcast("model", "checks", %{})

        conn
        |> put_flash(:flash, {:success, "This check was deleted successfully."})
        |> redirect(to: Routes.checks_path(conn, :index))

      {:error, _} ->
        conn
        |> put_flash(:flash, {:danger, "This check could not be deleted."})
        |> redirect(to: Routes.checks_path(conn, :index))
    end
  end
end
