use Mix.Config

config :defcon, DefconWeb.Endpoint,
  http: [port: 4000],
  load_from_system_env: true,
  server: true,
  root: ".",
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :info
