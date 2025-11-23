defmodule Volley.Tournaments.Tournament do
  use Ecto.Schema
  import Ecto.Changeset

  alias Volley.Tournaments.Fixture

  @derive Phoenix.Param

  schema "tournaments" do
    field :name, :string
    has_many :fixtures, Fixture

    belongs_to :owner, Volley.Accounts.User

    timestamps()
  end

  def changeset(tournament, params \\ %{}) do
    tournament
    |> cast(params, [:name])
    |> cast_assoc(:fixtures, sort_param: :fixtures_sort, drop_param: :fixtures_drop)
  end
end
