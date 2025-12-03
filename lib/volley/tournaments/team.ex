defmodule Volley.Tournaments.Team do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Phoenix.Param

  alias Volley.Tournaments.{Player, Tournament}

  schema "teams" do
    field :name, :string, default: ""
    embeds_many :players, Player, on_replace: :delete

    belongs_to :tournament, Tournament

    timestamps()
  end

  def changeset(team, params \\ %{}) do
    team
    |> cast(params, [:name])
    |> validate_required([:name])
    |> cast_embed(:players, sort_param: :players_sort, drop_param: :players_drop)
  end
end
