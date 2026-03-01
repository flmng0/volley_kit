defmodule Volley.Tournaments.Team do
  use Ecto.Schema
  import Ecto.Changeset

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

  def changeset(team, params \\ %{}) do
    team
    |> cast(params, [:name])
    |> validate_required([:name])
    |> cast_embed(:players, sort_param: :sort_players, drop_param: :drop_players)
    |> cast_assoc(:division)
  end
end
