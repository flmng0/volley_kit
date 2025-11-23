defmodule Volley.Tournaments.Fixture do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Phoenix.Param

  alias Volley.Tournaments.{Team, Tournament}

  schema "fixtures" do
    field :date, :date
    field :time, :time

    belongs_to :team_a, Team
    belongs_to :team_b, Team

    belongs_to :tournament, Tournament

    timestamps()
  end

  def changeset(fixture, params \\ %{}) do
    fixture
    |> cast(params, [:date, :time])
    |> validate_required([:date, :time])
  end
end
