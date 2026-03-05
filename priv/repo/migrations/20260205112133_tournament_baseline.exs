defmodule Volley.Repo.Migrations.TournamentBaseline do
  use Ecto.Migration

  def change do
    create table(:tournaments) do
      add :public_id, :uuid, null: false

      add :name, :string, null: false

      add :draft, :boolean, null: false
      add :timezone, :string, null: false

      add :location, :string

      add :start, :naive_datetime
      add :end, :naive_datetime

      # Consider adding currency for registration. Currently AUD is assumed.
      add :registration_opened_at, :naive_datetime
      add :registration_closed_at, :naive_datetime
      add :registration_price, :integer

      add :owner_id, references(:users), null: false

      timestamps()
    end

    create table(:divisions) do
      add :name, :string

      add :tournament_id, references(:tournaments), null: false
    end

    create table(:teams) do
      add :name, :string, null: false

      add :coach_name, :string
      add :assistant_coach_name, :string
      add :trainer_name, :string
      add :medical_doctor_name, :string

      add :players, :map

      add :accepted_at, :utc_datetime

      add :division_id, references(:divisions, on_delete: :nilify_all)
      add :tournament_id, references(:tournaments), null: false

      timestamps()
    end
  end
end
