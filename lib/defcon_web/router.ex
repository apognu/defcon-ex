defmodule DefconWeb.Router do
  @moduledoc false

  use DefconWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    plug(DefconWeb.LayoutPlug)
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DefconWeb do
    pipe_through :browser

    get "/", DashboardController, :index

    get "/outages", OutagesController, :index

    resources "/groups", GroupsController, except: ~w(show)a
    resources "/checks", ChecksController
    resources "/alerters", AlertersController, except: ~w(show)a
  end
end
