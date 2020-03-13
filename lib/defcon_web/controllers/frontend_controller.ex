defmodule DefconWeb.FrontendController do
  use DefconWeb, :controller

  def index(conn, _params) do
    conn
    |> put_view(DefconWeb.LayoutView)
    |> render("empty.html")
  end
end
