defmodule Volley.Repo.Migrations.AddTournaments do
  use Ecto.Migration

  def change do
    create table(:leagues) do
      add :name, :string, null: false

      add :owner_id, references(:users), null: false

      timestamps()
    end

    create table(:teams) do
      add :name, :string, null: false
      add :players, :map, null: false

      add :league_id, references(:leagues), null: false

      timestamps()
    end

    create table(:tournaments) do
      add :name, :string, null: false

      add :owner_id, references(:users), null: false

      timestamps()
    end

    create table(:fixtures) do
      add :date, :date, null: false
      add :time, :time, null: false

      add :team_a, references(:teams), null: false
      add :team_b, references(:teams), null: false

      add :tournament_id, references(:tournaments)

      timestamps()
    end

    alter table(:matches) do
      add :fixture_id, references(:fixtures)
    end
  end
end
