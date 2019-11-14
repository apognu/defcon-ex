defmodule Defcon.MixProject do
  use Mix.Project

  def project do
    [
      app: :defcon,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      releases: [
        default_release: :default,
        default: [
          include_executables_for: [:unix]
        ]
      ]
    ]
  end

  def application do
    [
      mod: {Defcon.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.4.10"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.1"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, git: "https://github.com/phoenixframework/phoenix_live_view"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:poison, "~> 3.1", override: true},
      {:plug_cowboy, "~> 2.0"},
      {:credo, "~> 1.1", only: :dev, runtime: false}
    ] ++ libs()
  end

  defp libs do
    [
      {:phoenix_slime, git: "https://github.com/slime-lang/phoenix_slime"},
      {:uuid, "~> 1.1"},
      {:tesla, "~> 1.3.0"},
      {:timex, "~> 3.5"},
      {:socket, "~> 0.3"},
      {:slack, "~> 0.19.0"}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"]
    ]
  end
end
