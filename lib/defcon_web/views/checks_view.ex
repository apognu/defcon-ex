defmodule DefconWeb.ChecksView do
  use DefconWeb, :view

  import Ecto.Changeset

  alias Timex.Duration
  alias Defcon.Schemas.Check
  alias DefconWeb.Helpers

  def last_check_at(%Check{} = check) do
    if Enum.empty?(check.events) do
      "N/A"
    else
      Enum.at(check.events, 0).inserted_at
      |> Helpers.format_date()
    end
  end

  def next_check_at(%Check{} = check) do
    base =
      if Enum.empty?(check.events) do
        nil
      else
        Enum.at(check.events, 0).inserted_at
      end

    if is_nil(base) do
      "N/A"
    else
      Timex.add(base, Duration.from_seconds(check.interval))
      |> Helpers.format_date()
    end
  end

  def last_check_status(%Check{} = check) do
    Enum.empty?(check.outages)
  end

  def last_check_message(%Check{} = check) do
    if Enum.empty?(check.events) do
      "?"
    else
      Enum.at(check.events, 0).message
    end
  end

  def uptime_rate(buckets) do
    result =
      buckets
      |> Enum.group_by(fn [_, x] -> x > 0 end)
      |> Enum.into(%{}, fn {has_outages, occurences} -> {has_outages, length(occurences)} end)

    {ok, ko} = {Map.get(result, false, 0), Map.get(result, true, 0)}

    (100 - ko / ok * 100)
    |> trunc()
  end

  def is_enabled?(%Ecto.Changeset{} = changeset) do
    get_change(changeset, :enabled)
  end
end
