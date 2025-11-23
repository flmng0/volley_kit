defmodule Volley.Tournaments.Team do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Phoenix.Param

  alias Volley.Tournaments.{Player, League}

  schema "teams" do
    field :name, :string
    embeds_many :players, Player, on_replace: :delete

    belongs_to :league, League

    timestamps()
  end

  def changeset(team, params \\ %{}) do
    team
    |> cast(params, [:name])
    |> cast_embed(:players, sort_param: :players_sort, drop_param: :players_drop)
  end
end
