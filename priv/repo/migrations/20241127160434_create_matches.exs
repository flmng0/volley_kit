defmodule Volley.Repo.Migrations.CreateMatches do
  use Ecto.Migration

  def change do
    create table(:matches) do
      add :team_a_id, references(:teams)
      add :team_b_id, references(:teams)

      add :team_a_summary, :map
      add :team_b_summary, :map

      timestamps(type: :utc_datetime)
    end
  end
end
