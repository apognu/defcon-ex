defmodule DefconWeb do
  @moduledoc false

  def controller do
    quote do
      use Phoenix.Controller, namespace: DefconWeb

      import Plug.Conn
      import DefconWeb.Gettext

      alias DefconWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        namespace: DefconWeb,
        root: "lib/defcon_web/templates",
        pattern: "**/*"

      use Phoenix.HTML

      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]
      import DefconWeb.Helpers
      import DefconWeb.ErrorHelpers
      import DefconWeb.Gettext

      alias DefconWeb.Router.Helpers, as: Routes
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      import DefconWeb.Gettext
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
