defmodule VolleyKit.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string
      add :sets, :integer
      add :points, :integer
      add :players, :map

      timestamps(type: :utc_datetime)
    end
  end
end
