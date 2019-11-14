defmodule Defcon.Checks.TCP do
  @moduledoc false

  import Defcon.Checks.Base

  alias Defcon.Schemas.Check

  def check(%Check{} = check, _stash) do
    try do
      host = String.to_charlist(check.tcp_spec.host)

      case :gen_tcp.connect(host, check.tcp_spec.port, []) do
        {:ok, _} -> status(ok(), [])
        {:error, error} -> status(error(), to_string(error))
      end
    rescue
      e -> status(error(), "Unknown error: #{to_string(e)}")
    end
  end

  def alert_attachments(%Check{} = check) do
    [
      %{
        title: "Host",
        value: check.tcp_spec.host,
        short: true
      },
      %{
        title: "Port",
        value: check.tcp_spec.port,
        short: true
      }
    ]
  end
end
