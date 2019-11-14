defmodule Defcon.Repo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :defcon,
    adapter: Ecto.Adapters.Postgres
end
