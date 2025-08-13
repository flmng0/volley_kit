defmodule Volley.Repo.Migrations.ScoringBaseline do
  use Ecto.Migration

  def change do
    create table(:matches) do
      add :a_score, :integer, null: false
      add :b_score, :integer, null: false

      add :a_sets, :integer, null: false
      add :b_sets, :integer, null: false

      add :settings, :map, null: false

      add :owner_id, references(:users)
      add :anonymous_owner_id, :id

      timestamps()
    end

    create table(:events, primary_key: [name: :id, type: :id]) do
      add :type, :string, null: false
      add :team, :string, null: false

      add :match_id, references(:matches, on_delete: :delete_all), null: false
    end
  end
end
