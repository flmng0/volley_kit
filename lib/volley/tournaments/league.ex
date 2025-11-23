defmodule Volley.Tournaments.League do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Phoenix.Param

  alias Volley.Tournaments.Team

  schema "leagues" do
    field :name, :string
    has_many :teams, Team

    belongs_to :owner, Volley.Accounts.User

    timestamps()
  end

  def changeset(league, params \\ %{}) do
    league
    |> cast(params, [:name])
    |> cast_assoc(:teams, sort_param: :teams_sort, drop_param: :teams_drop)
  end
end
