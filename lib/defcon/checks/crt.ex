defmodule Defcon.Checks.CRT do
  @moduledoc false

  use Tesla

  import Defcon.Checks.Base

  alias Defcon.Schemas.Check

  plug(Tesla.Middleware.JSON)

  def check(%Check{} = check, stash) do
    stash = if stash == :empty, do: %{"latest_cert_id" => 0}, else: stash

    try do
      domain = URI.encode_www_form(check.crt_spec.domain)
      url = "https://crt.sh?q=#{domain}&output=json&exclude=expired"
      response = get(url)

      case response do
        {:ok, %Tesla.Env{status: 200, body: body}} ->
          new_certs =
            body
            |> Enum.filter(fn cert -> cert["min_cert_id"] > stash["latest_cert_id"] end)
            |> Enum.map(fn cert -> cert["name_value"] end)
            |> Enum.uniq()

          latest_cert_id =
            body
            |> Enum.map(fn cert -> cert["min_cert_id"] end)
            |> Enum.max()

          case Enum.empty?(new_certs) do
            true ->
              status(ok(), [], %{latest_cert_id: latest_cert_id})

            false ->
              status(notice(), ["New certificates issued for #{Enum.join(new_certs, ", ")}"], %{
                "latest_cert_id" => latest_cert_id
              })
          end

        _ ->
          status(ok(), ["Could not retrieve certificates from crt.sh"])
      end
    rescue
      e -> status(error(), "Unknown error: #{to_string(e)}")
    end
  end

  def alert_attachments(%Check{} = _check) do
    []
  end
end
