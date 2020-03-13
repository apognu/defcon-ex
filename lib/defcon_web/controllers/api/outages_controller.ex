defmodule DefconWeb.Api.OutagesController do
  use DefconWeb, :controller

  alias Defcon.Schemas.Outage

  def currents(conn, _params) do
    outages = Outage.currents()

    conn
    |> put_view(DefconWeb.ApiView)
    |> render("ok.json", payload: outages)
  end

  def history(conn, _params) do
    outages = Outage.history()

    conn
    |> put_view(DefconWeb.ApiView)
    |> render("ok.json", payload: outages)
  end

  def range(conn, params) do
    with {:ok, from} <- Map.fetch(params, "from"),
         {from, ""} <- Integer.parse(from) do
      from = Timex.from_unix(from)

      to =
        case Map.get(params, "range") do
          "hour" -> {:ok, Timex.shift(from, hours: 1)}
          "day" -> {:ok, Timex.end_of_day(from)}
          "month" -> {:ok, Timex.end_of_month(from)}
          _ -> :error
        end

      case to do
        {:ok, to} ->
          outages = Outage.range(from, to)

          conn
          |> put_view(DefconWeb.ApiView)
          |> render("ok.json", payload: outages)

        _ ->
          conn
          |> put_status(:bad_request)
          |> put_view(DefconWeb.ApiView)
          |> render("ok.json", message: "invalid date range specification")
      end
    else
      _ ->
        conn
        |> put_status(:bad_request)
        |> put_view(DefconWeb.ApiView)
        |> render("ok.json", message: "invalid date range specification")
    end
  end
end
