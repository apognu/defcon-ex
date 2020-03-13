defmodule Defcon.Checker do
  @moduledoc false

  use GenServer

  alias Defcon.Schemas.{Check, Outage}
  alias Defcon.{Repo, Stash, Checks, Alerter}

  def start_link(_opts \\ []), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def init(_args) do
    send(self(), :tick)

    {:ok, %{}}
  end

  def handle_info(:tick, _state) do
    Process.send_after(self(), :tick, Application.get_env(:defcon, :check_interval))

    Check.outdated()
    |> Enum.each(fn check ->
      stash = Stash.load_for(check.uuid)

      checker =
        case check.kind do
          "http" -> Checks.HTTP
          "app_store" -> Checks.AppStore
          "play_store" -> Checks.PlayStore
          "tls" -> Checks.TLS
          "crt" -> Checks.CRT
          "tcp" -> Checks.TCP
        end

      {status, messages, stash} = checker.check(check, stash)

      if stash != :empty do
        Stash.save_for(check.uuid, stash)
      end

      event = Check.create_result(check, Checks.Base.to_int(status), Enum.join(messages, " / "))

      {is_outage, outage} =
        case Outage.current_for(check, :transient) do
          %Outage{} = outage -> {:found, outage}
          nil -> {:not_found, %Outage{}}
        end

      case status do
        :ok ->
          if is_outage == :found do
            strikes = outage.passing_strikes + 1

            params = %{
              event_id: event.id,
              passing_strikes: outage.passing_strikes + 1,
              failing_strikes:
                if(outage.failing_strikes >= outage.check.failing_threshold,
                  do: outage.check.failing_threshold,
                  else: 0
                )
            }

            {params, recovered} =
              if strikes >= outage.check.passing_threshold do
                recovered =
                  if outage.failing_strikes >= outage.check.failing_threshold,
                    do: true,
                    else: false

                {Map.put(params, :ended_on, DateTime.truncate(Timex.now(), :second)), recovered}
              else
                {params, false}
              end

            {:ok, outage} =
              Outage.changeset(outage, params)
              |> Repo.update()

            if recovered do
              Alerter.notify(Repo.preload(check, [:alerter]), outage, checker, event.message)
            end
          end

        :critical ->
          {before, outage} =
            case is_outage do
              :not_found ->
                {:ok, outage} =
                  Outage.changeset(outage, %{
                    check_id: check.id,
                    event_id: event.id,
                    started_on:
                      event.inserted_at
                      |> Timex.to_datetime("UTC")
                      |> DateTime.truncate(:second)
                  })
                  |> Repo.insert()

                {0, outage}

              :found ->
                strikes =
                  if outage.failing_strikes >= outage.check.failing_threshold,
                    do: outage.check.failing_threshold,
                    else: outage.failing_strikes + 1

                Outage.changeset(outage, %{
                  event_id: event.id,
                  passing_strikes: 0,
                  failing_strikes: strikes
                })
                |> Repo.update()

                {outage.failing_strikes, outage}
            end

          if before + 1 == check.failing_threshold do
            Alerter.notify(Repo.preload(check, [:alerter]), outage, checker, event.message)
          end

        :notice ->
          Alerter.notice(
            Repo.preload(check, [:alerter]),
            checker,
            Enum.join(messages, " / ")
          )
      end
    end)

    DefconWeb.Endpoint.broadcast("checker", "tick", %{time: "#{Timex.now()}"})

    {:noreply, %{}}
  end

  def handle_info(:tick, state) do
    {:noreply, state}
  end
end
