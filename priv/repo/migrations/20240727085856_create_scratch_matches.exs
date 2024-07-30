defmodule VolleyKit.Repo.Migrations.CreateScratchMatches do
  use Ecto.Migration

  def change do
    create table(:scratch_matches) do
      add :a_score, :integer
      add :a_sets, :integer

      add :b_score, :integer
      add :b_sets, :integer

      add :options, :map

      add :created_by, :uuid

      timestamps(type: :utc_datetime)
    end
  end
end
