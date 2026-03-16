defmodule Volley.Tournaments.Team do
  use Ecto.Schema
  import Ecto.Changeset

  alias Volley.Tournaments.Division
  alias Volley.Tournaments.Player
  alias Volley.Tournaments.Tournament
  alias Volley.Tournaments.Registration

  schema "teams" do
    field :name, :string

    field :contact_email, :string

    # Additional names listed on a scoresheet
    field :coach_name, :string
    field :assistant_coach_name, :string
    field :trainer_name, :string
    field :medical_doctor_name, :string

    embeds_many :players, Player

    has_one :registration, Registration

    belongs_to :division, Division, on_replace: :nilify
    belongs_to :tournament, Tournament, on_replace: :delete

    timestamps()
  end

  def changeset(team, params \\ %{}, opts \\ []) do
    required =
      [
        :name,
        opts[:division_required] && :division_id,
        opts[:email_required] && :contact_email
      ]
      |> Enum.reject(&is_nil/1)

    team
    |> cast(params, [:name, :division_id, :contact_email])
    |> validate_required(required)
    |> cast_embed(:players, sort_param: :sort_players, drop_param: :drop_players)
  end
end
