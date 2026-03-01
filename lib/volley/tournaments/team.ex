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

    belongs_to :division, Division, on_replace: :nilify
    belongs_to :tournament, Tournament, on_replace: :delete
  end

  def changeset(team, params \\ %{}, opts \\ []) do
    required =
      if Keyword.get(opts, :division_required, false) do
        [:name, :division_id]
      else
        [:name]
      end

    team
    |> cast(params, [:name, :division_id])
    |> validate_required(required)
    |> cast_embed(:players, sort_param: :sort_players, drop_param: :drop_players)
  end
end
