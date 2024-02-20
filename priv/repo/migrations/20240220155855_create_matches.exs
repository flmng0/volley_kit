defmodule VolleyKit.Repo.Migrations.CreateMatches do
  use Ecto.Migration

  def change do
    create table(:matches) do
      add :team_a_id, references(:teams, on_delete: :delete_all)
      add :team_b_id, references(:teams, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:matches, [:team_a_id])
    create index(:matches, [:team_b_id])
  end
end
