defmodule DefconWeb.Endpoint do
  @moduledoc false

  use Phoenix.Endpoint, otp_app: :defcon

  socket "/live", Phoenix.LiveView.Socket

  plug Plug.Static,
    at: "/",
    from: :defcon,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket

    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_defcon_key",
    signing_salt: "pzZ1MmgV"

  plug DefconWeb.Router
end
