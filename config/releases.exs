import Config

defmodule Helper do
  def required_envs do
    ~w(
      HOST
      SIGNING_SALT
      DB_HOST DB_USER DB_PASSWORD DB_DATABASE
    )
  end

  def get(key, default \\ "") do
    case System.fetch_env(key) do
      {:ok, value} -> value
      _ -> default
    end
  end

  def parse_duration(string, to \\ :seconds) do
    duration =
      case Integer.parse(string) do
        {d, "d"} -> Timex.Duration.from_days(d)
        {d, "h"} -> Timex.Duration.from_hours(d)
        {d, "m"} -> Timex.Duration.from_minutes(d)
        {d, "s"} -> Timex.Duration.from_seconds(d)
      end

    case to do
      :milliseconds -> Timex.Duration.to_milliseconds(duration)
      :seconds -> Timex.Duration.to_seconds(duration)
      :minutes -> Timex.Duration.to_minutes(duration)
      :hours -> Timex.Duration.to_hours(duration)
      :days -> Timex.Duration.to_days(duration)
    end
    |> trunc()
  end
end

missing_envs =
  Helper.required_envs()
  |> Enum.reduce([], fn env, acc ->
    case System.fetch_env(env) do
      {:ok, _} -> acc
      _ -> acc ++ [env]
    end
  end)

unless Enum.empty?(missing_envs) do
  IO.puts(
    :stderr,
    "ERROR: the following environment variables are mandatory: #{Enum.join(missing_envs, ", ")}"
  )

  System.halt(1)
end

config :defcon, DefconWeb.Endpoint,
  url: [host: Helper.get("HOST")],
  live_view: [
    signing_salt: Helper.get("SIGNING_SALT")
  ]

config :defcon, Defcon.Repo,
  hostname: Helper.get("DB_HOST"),
  username: Helper.get("DB_USER"),
  password: Helper.get("DB_PASSWORD"),
  database: Helper.get("DB_DATABASE")

config :defcon,
  check_interval: Helper.get("CHECK_INTERVAL", "1m") |> Helper.parse_duration(:milliseconds),
  cleaner_interval: Helper.get("CLEANER_INTERVAL", "12h") |> Helper.parse_duration(:milliseconds),
  event_history: Helper.get("EVENT_HISTORY", "24h") |> Helper.parse_duration(:hours)
