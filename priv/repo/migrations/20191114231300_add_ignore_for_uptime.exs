defmodule InitialSchema do
  use Ecto.Migration

  def change do
    alter table(:checks) do
      add(:ignore, :boolean, null: false, default: false)
    end
  end
end
