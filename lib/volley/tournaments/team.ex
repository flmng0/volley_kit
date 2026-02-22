defmodule Volley.Tournaments.Team do
  use Ecto.Schema

  alias Volley.Tournaments.{Division, Player, Tournament}

  schema "teams" do
    field :name, :string

    # Additional names listed on a scoresheet
    field :coach_name, :string
    field :assistant_coach_name, :string
    field :trainer_name, :string
    field :medical_doctor_name, :string

    embeds_many :players, Player

    belongs_to :division, Division
    belongs_to :tournament, Tournament
  end
end
