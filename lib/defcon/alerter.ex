defmodule Defcon.Alerter do
  @moduledoc false

  alias Defcon.Schemas.{Check, Alerter}

  def notify(%Check{alerter: nil}, _, _, _) do
  end

  def notify(%Check{alerter: %Alerter{} = alerter} = check, outage, checker, message) do
    state = is_nil(outage.ended_on)

    check_title = "#{check.group.title} / #{check.title}"
    color = if state, do: "#e17055", else: "#00b894"

    {title, description} =
      if state do
        {"#{check_title}: Outage started 🚨",
        "An uptime check for the following service failed:\n```#{message}```"}
      else
        {"#{check_title}: Outage recovered 👍", "Everything seems to be back to normal"}
      end

    {:ok, attachments} =
      [
        %{
          title: title,
          text: description,
          color: color,
          fields:
            [
              %{
                title: "Check name",
                value: check.title,
                short: true
              }
            ] ++ checker.alert_attachments(check),
          mrkdwn_in: ["text"],
          ts: Timex.to_unix(Timex.now())
        }
      ]
      |> Jason.encode()

    Slack.Web.Chat.post_message(alerter.channel, "", %{
      token: alerter.api_key,
      username: "Defcon",
      attachments: attachments
    })
  end

  def notice(%Check{alerter: %Alerter{} = alerter} = check, checker, message) do
    check_title = "#{check.group.title} / #{check.title}"

    {title, description} =
      {"#{check_title}: Monitoring notice ⚠️",
      "An uptime check for the following service sent a notice:\n```#{message}```"}

    {:ok, attachments} =
      [
        %{
          title: title,
          text: description,
          color: "#fdcb6e",
          fields:
            [
              %{
                title: "Check name",
                value: check.title,
                short: true
              }
            ] ++ checker.alert_attachments(check),
          mrkdwn_in: ["text"],
          ts: Timex.to_unix(Timex.now())
        }
      ]
      |> Jason.encode()

    Slack.Web.Chat.post_message(alerter.channel, "", %{
      token: alerter.api_key,
      username: "Defcon",
      attachments: attachments
    })
  end
end
