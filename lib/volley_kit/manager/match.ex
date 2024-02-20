defmodule VolleyKit.Manager.Match do
  use Ecto.Schema
  import Ecto.Changeset

  alias VolleyKit.Manager.Team

  schema "matches" do
    field :code, :string

    has_one :team_a, Team
    has_one :team_b, Team

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(match, attrs) do
    match
    |> cast(attrs, [])
    |> validate_required([])
    |> unique_constraint(:code)
  end
end
