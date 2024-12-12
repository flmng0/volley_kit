defmodule Volley.Repo.Migrations.CreateMatchUsers do
  use Ecto.Migration

  def change do
    create table(:match_users, primary_key: false) do
      add :match_id, references(:matches)
      add :user_id, references(:users)

      # Ecto.Enum in schema
      add :level, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
