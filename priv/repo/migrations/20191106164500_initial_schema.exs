defmodule InitialSchema do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add(:uuid, :string, length: 37, null: false)
      add(:title, :string, null: false)

      timestamps()
    end

    create table(:alerters) do
      add(:uuid, :string, length: 37, null: false)
      add(:title, :string, null: false)
      add(:api_key, :string, null: false)
      add(:channel, :string, null: false)

      timestamps()
    end

    create table(:checks) do
      add(:uuid, :string, length: 37, null: false)
      add(:group_id, references(:groups, on_delete: :nilify_all))
      add(:alerter_id, references(:alerters, on_delete: :nilify_all))
      add(:title, :string, null: false)
      add(:enabled, :boolean, null: false, default: true)
      add(:kind, :string, null: false)
      add(:interval, :integer, null: false)
      add(:passing_threshold, :integer, null: false)
      add(:failing_threshold, :integer, null: false)

      timestamps()
    end

    create table(:http_specs) do
      add(:check_id, references(:checks, on_delete: :delete_all))
      add(:url, :string, null: false)
      add(:expected_code, :integer)
      add(:expected_content, :string)

      timestamps()
    end

    create table(:play_store_specs) do
      add(:check_id, references(:checks, on_delete: :delete_all))
      add(:app_id, :string, null: false)

      timestamps()
    end

    create table(:app_store_specs) do
      add(:check_id, references(:checks, on_delete: :delete_all))
      add(:bundle_id, :string, null: false)

      timestamps()
    end

    create table(:tls_specs) do
      add(:check_id, references(:checks, on_delete: :delete_all))
      add(:domains, :string, null: false)
      add(:window, :integer, null: false)

      timestamps()
    end

    create table(:crt_specs) do
      add(:check_id, references(:checks, on_delete: :delete_all))
      add(:domain, :string, null: false)

      timestamps()
    end

    create table(:tcp_specs) do
      add(:check_id, references(:checks, on_delete: :delete_all))
      add(:host, :string, null: false)
      add(:port, :integer, null: false)

      timestamps()
    end

    create table(:events) do
      add(:check_id, references(:checks, on_delete: :delete_all))
      add(:status, :integer, null: false)
      add(:message, :text)

      timestamps()
    end

    create table(:outages) do
      add(:uuid, :string, length: 37, null: false)
      add(:check_id, references(:checks, on_delete: :delete_all))
      add(:event_id, references(:events, on_delete: :delete_all))
      add(:passing_strikes, :integer, default: 0)
      add(:failing_strikes, :integer, default: 1)
      add(:started_on, :utc_datetime, null: false)
      add(:ended_on, :utc_datetime)
    end
  end
end
