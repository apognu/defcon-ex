use Mix.Config

config :defcon,
  ecto_repos: [Defcon.Repo]

config :defcon, DefconWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "AmoD2vrjqp2EcVN6NyqujfC72ShZTxc9/2Z7InIxfmSvNPyTrMNy2DgSK/P+IjPh",
  render_errors: [view: DefconWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Defcon.PubSub, adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :phoenix, :template_engines,
  slim: PhoenixSlime.Engine,
  slime: PhoenixSlime.Engine,
  slimleex: PhoenixSlime.LiveViewEngine,
  leex: Phoenix.LiveView.Engine

config :defcon,
  check_interval: 60 * 1000,
  cleaner_interval: 3600 * 1000,
  event_history: 24

import_config "#{Mix.env()}.exs"
