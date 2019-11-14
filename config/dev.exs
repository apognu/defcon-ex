use Mix.Config

config :defcon, Defcon.Repo,
  username: "postgres",
  password: "sigipsr",
  database: "defcon_dev",
  hostname: "postgres.local",
  show_sensitive_data_on_connection_error: false,
  pool_size: 10

config :defcon, DefconWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  pubsub: [
    adapter: Phoenix.PubSub.PG2,
    pool_size: 1,
    name: Defcon.Pubsub
  ],
  live_view: [
    signing_salt:
      "NThmZmEyYzM3ZTVlZjM0NjIyZjMwYTBjYzZmZjU5YThhNGM0M2U4ZjhhYzNiNmNkMGMwNWI0NGRiODFkM2ZlZQo="
  ],
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

config :defcon, DefconWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/defcon_web/{live,views}/.*(ex)$",
      ~r"lib/defcon_web/templates/.*(eex|slim|slime|leex)$"
    ]
  ]

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime
