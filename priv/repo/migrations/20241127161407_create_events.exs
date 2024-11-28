defmodule Volley.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      # Ecto.Enum in schema
      add :type, :integer

      add :match_id, references(:matches)
      add :team_id, references(:teams)
    end

    create index(:events, [:match_id])
  end
end
