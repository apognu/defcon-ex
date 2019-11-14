defmodule DefconWeb.Helpers do
  @moduledoc false

  alias Defcon.Schemas.Check

  @date_format "%d %b %Y, %H:%M:%S"

  def check_name(%Check{} = check) do
    "#{check.group.title} / #{check.title}"
  end

  def format_date(date, format \\ @date_format) do
    date
    |> Timex.Timezone.convert("Europe/Paris")
    |> Timex.format!(format, :strftime)
  end
end
