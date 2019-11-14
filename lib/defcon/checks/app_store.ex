defmodule Defcon.Checks.AppStore do
  @moduledoc false

  use Tesla

  import Defcon.Checks.Base

  alias Defcon.Schemas.Check

  plug(Tesla.Middleware.JSON)

  def check(%Check{} = check, _stash) do
    try do
      url = "https://itunes.apple.com/lookup?bundleId=#{check.app_store_spec.bundle_id}"
      response = get(url)

      {result, messages} =
        case response do
          {:ok, %Tesla.Env{status: 200, body: body}} ->
            if body["resultCount"] > 0 do
              {ok(), []}
            else
              {error(), ["App `#{check.app_store_spec.bundle_id}` was not found"]}
            end

          _ ->
            {error(), ["App `#{check.app_store_spec.bundle_id}` was not found"]}
        end

      status(result, messages)
    rescue
      e -> status(error(), "Unknown error: #{to_string(e)}")
    end
  end

  def alert_attachments(%Check{} = check) do
    [
      %{
        title: "Store",
        value: "AppStore",
        short: true
      },
      %{
        title: "Bundle ID",
        value: check.app_store_spec.bundle_id,
        short: true
      }
    ]
  end
end
