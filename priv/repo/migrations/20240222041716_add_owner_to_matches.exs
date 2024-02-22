defmodule VolleyKit.Repo.Migrations.AddOwnerToMatches do
  use Ecto.Migration

  def change do
    alter table(:matches) do
      add :owner, :uuid
    end
  end
end
