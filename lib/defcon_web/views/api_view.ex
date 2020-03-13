defmodule DefconWeb.ApiView do
  use DefconWeb, :view

  def render("ok.json", %{payload: payload}) do
    payload
  end

  def render("ok.json", %{message: message}) do
    %{message: message}
  end
end
