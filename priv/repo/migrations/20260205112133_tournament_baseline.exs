defmodule Volley.Repo.Migrations.TournamentBaseline do
  use Ecto.Migration

  def change do
    create table(:tournaments) do
      add :name, :string

      add :draft, :boolean, null: false
      add :timezone, :string

      add :location, :string

      add :start, :naive_datetime
      add :end, :naive_datetime

      # Consider adding currency for registration. Currently AUD is assumed.
      add :registration_opened_at, :naive_datetime
      add :registration_closed_at, :naive_datetime
      add :registration_price, :integer

      add :use_divisions?, :boolean

      add :owner_id, references(:users)

      timestamps()
    end

    create table(:divisions) do
      add :name, :string

      add :tournament_id, references(:tournaments), null: false
    end

    create table(:teams) do
      add :name, :string

      add :coach_name, :string
      add :assistant_coach_name, :string
      add :trainer_name, :string
      add :medical_doctor_name, :string

      add :players, :map

      add :division_id, references(:divisions)
      add :tournament_id, references(:tournaments)
    end
  end
end
