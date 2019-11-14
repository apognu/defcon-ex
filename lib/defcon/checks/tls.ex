defmodule Defcon.Checks.TLS do
  @moduledoc false

  use Tesla

  import Defcon.Checks.Base

  alias Defcon.Schemas.Check

  @validity_format "%y%m%d%H%M%S%Z"

  def check(%Check{} = check, _stash) do
    try do
      domains = check.tls_spec.domains
      expiration = [days: -check.tls_spec.window]

      {result, messages} =
        domains
        |> String.split(",")
        |> Enum.reduce({true, []}, fn domain, {result, messages} ->
          with {:ok, socket} <- Socket.SSL.connect(domain, 443),
               {:ok, cert} <- Socket.SSL.certificate(socket),
               {:Validity, _, {:utcTime, not_after}} <-
                 cert
                 |> :public_key.pkix_decode_cert(:otp)
                 |> elem(1)
                 |> elem(5),
               {:ok, not_after} <- Timex.parse(to_string(not_after), @validity_format, :strftime) do
            if Timex.after?(Timex.shift(not_after, expiration), Timex.now()) do
              {result and true, messages ++ []}
            else
              offset = Timex.diff(not_after, Timex.now(), :days)

              {false, ["TLS certificate for `#{domain}` expires in #{offset} days"]}
            end
          end
        end)

      if result do
        status(ok(), messages)
      else
        status(notice(), messages)
      end
    rescue
      e -> status(error(), "Unknown error: #{to_string(e)}")
    end
  end

  def alert_attachments(%Check{} = check) do
    [
      %{
        title: "Domains",
        value: String.replace(check.tls_spec.domains, ",", "\n"),
        short: true
      }
    ]
  end
end
