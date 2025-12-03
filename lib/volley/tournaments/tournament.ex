defmodule Volley.Tournaments.Tournament do
  use Ecto.Schema
  import Ecto.Changeset

  alias Volley.Tournaments.{Fixture, Team}

  @derive Phoenix.Param

  schema "tournaments" do
    field :name, :string, default: ""

    field :date_start, :date
    field :date_end, :date

    has_many :fixtures, Fixture
    has_many :teams, Team

    belongs_to :owner, Volley.Accounts.User

    timestamps()
  end

  def changeset(tournament, params \\ %{}) do
    changeset =
      tournament
      |> cast(params, [:name, :date_start, :date_end])
      |> validate_required([:name])
      |> cast_assoc(:fixtures, sort_param: :fixtures_sort, drop_param: :fixtures_drop)
      |> cast_assoc(:teams, sort_param: :teams_sort, drop_param: :teams_drop)

    start_changed? = changed?(changeset, :date_start)
    end_changed? = changed?(changeset, :date_end)

    if start_changed? or end_changed? do
      validate_required(changeset, [:date_start, :date_end],
        message: "start and end both required if either are selected"
      )
    else
      changeset
    end
  end
end
