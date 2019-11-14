defmodule Defcon.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      Defcon.Repo,
      DefconWeb.Endpoint,
      supervisor(Defcon.Checker, []),
      supervisor(Defcon.Cleaner, [])
    ]

    opts = [strategy: :one_for_one, name: Defcon.Supervisor]

    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    DefconWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
