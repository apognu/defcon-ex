defmodule Defcon.Checks.PlayStore do
  @moduledoc false

  use Tesla

  import Defcon.Checks.Base

  alias Defcon.Schemas.Check

  def check(%Check{} = check, _stash) do
    try do
      url = "https://play.google.com/store/apps/details?id=#{check.play_store_spec.app_id}"
      response = get(url)

      {result, messages} =
        case response do
          {:ok, %Tesla.Env{status: 200}} ->
            {ok(), []}

          _ ->
            {error(), ["App `#{check.play_store_spec.app_id}` was not found"]}
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
        value: "Play Store",
        short: true
      },
      %{
        title: "App ID",
        value: check.play_store_spec.app_id,
        short: true
      }
    ]
  end
end
