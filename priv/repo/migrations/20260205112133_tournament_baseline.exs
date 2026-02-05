defmodule Volley.Repo.Migrations.TournamentBaseline do
  use Ecto.Migration

  def change do
    create table(:tournaments) do
      add :name, :string

      add :draft, :boolean
      add :timezone, :string

      add :location, :string

      add :start, :naive_datetime
      add :end, :naive_datetime

      # Consider adding currency for registration. Currently AUD is assumed.
      add :registration_opened_at, :naive_datetime
      add :registration_closed_at, :naive_datetime
      add :registration_price, :integer

      add :divisions, :map
      add :teams, :map

      add :owner_id, references(:users)

      timestamps()
    end
  end
end
