defmodule Volley.Repo.Migrations.CreateMatches do
  use Ecto.Migration

  def change do
    create table(:matches) do
      add :team_a_summary, :map
      add :team_b_summary, :map

      add :options, :map

      timestamps(type: :utc_datetime)
    end
  end
end
