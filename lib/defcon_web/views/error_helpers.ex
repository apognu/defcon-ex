defmodule DefconWeb.ErrorHelpers do
  @moduledoc false

  use Phoenix.HTML

  def error_tag(form, field) do
    Enum.map(Keyword.get_values(form.errors, field), fn error ->
      content_tag(:span, translate_error(error), class: "help-block")
    end)
  end

  def translate_error({msg, opts}) do
    if count = opts[:count] do
      Gettext.dngettext(DefconWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(DefconWeb.Gettext, "errors", msg, opts)
    end
  end
end
