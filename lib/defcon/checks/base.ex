defmodule Defcon.Checks.Base do
  @moduledoc false

  def ok, do: :ok
  def notice, do: :notice
  def error, do: :critical

  def status(result, message, stash \\ :empty)

  def status(result, message, stash) when is_atom(result) and is_binary(message) do
    status(result, [message], stash)
  end

  def status(result, messages, stash) when is_atom(result) and is_list(messages) do
    {result, messages, stash}
  end

  def to_int(status) when is_atom(status) do
    case status do
      :ok -> 0
      :error -> 1
      _ -> 1
    end
  end
end
