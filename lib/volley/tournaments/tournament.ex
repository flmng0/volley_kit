defmodule Volley.Tournaments.Tournament do
  use Ecto.Schema
  import Ecto.Changeset

  alias Volley.Tournaments.{Fixture, Team}

  @derive Phoenix.Param

  schema "tournaments" do
    field :name, :string

    has_many :fixtures, Fixture
    has_many :teams, Team

    belongs_to :owner, Volley.Accounts.User

    timestamps()
  end

  def changeset(tournament, params \\ %{}) do
    tournament
    |> cast(params, [:name])
    |> cast_assoc(:fixtures, sort_param: :fixtures_sort, drop_param: :fixtures_drop)
    |> cast_assoc(:teams, sort_param: :teams_sort, drop_param: :teams_drop)
  end
end
