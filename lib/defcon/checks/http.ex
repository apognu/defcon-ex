defmodule Defcon.Checks.HTTP do
  @moduledoc false

  use Tesla

  import Defcon.Checks.Base

  alias Defcon.Schemas.Check

  adapter(Tesla.Adapter.Hackney, recv_timeout: 5000)

  def check(%Check{} = check, _stash) do
    try do
      response = get(check.http_spec.url)

      expected_code = check.http_spec.expected_code
      expected_content = check.http_spec.expected_content

      messages = []

      {result, messages} =
        case response do
          {:ok, %Tesla.Env{status: code}}
          when not is_nil(expected_code) ->
            {code == expected_code, messages ++ ["Status code was #{code}"]}

          {:ok, %Tesla.Env{status: code}} when code in 200..399 ->
            {true, messages}

          {_, %Tesla.Env{status: code}} ->
            {false, messages ++ ["Status code was #{code}"]}

          {:error, error} ->
            {false, messages ++ [to_string(error)]}
        end

      {result, messages} =
        case response do
          {:ok, %Tesla.Env{body: body}} when not is_nil(expected_content) ->
            if String.contains?(body, expected_content) do
              {result and true, messages}
            else
              {result and false, messages ++ ["Could not find content `#{expected_content}`"]}
            end

          _ ->
            {result and true, messages}
        end

      if result do
        status(ok(), messages)
      else
        status(error(), messages)
      end
    rescue
      e in Protocol.UndefinedError ->
        {_, {_, value}} = e.value
        status(error(), to_string(value))

      e ->
        status(error(), "Unknown error: #{{to_string(e)}}")
    end
  end

  def alert_attachments(%Check{} = check) do
    [
      %{
        title: "Service URL",
        value: check.http_spec.url,
        short: true
      }
    ]
  end
end
