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

  scope "/api", DefconWeb.Api do
    pipe_through :api

    get "/dashboard", DashboardController, :status
    get "/outages", OutagesController, :currents
    get "/outages/history", OutagesController, :history
    get "/outages/range/:from/:range", OutagesController, :range

    resources "/groups", GroupsController, only: ~w(index show create update delete)a
    resources "/alerters", AlertersController, only: ~w(index show create update delete)a
    get "/checks/kinds", ChecksController, :kinds
    resources "/checks", ChecksController, only: ~w(index show create update delete)a
  end

  scope "/", DefconWeb do
    pipe_through :browser

    get "/*path", FrontendController, :index
  end
end
