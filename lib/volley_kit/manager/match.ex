defmodule VolleyKit.Manager.Match do
  use Ecto.Schema
  import Ecto.Changeset

  alias VolleyKit.Manager.Team

  schema "matches" do
    belongs_to :team_a, Team
    belongs_to :team_b, Team

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(match, attrs) do
    match
    |> cast(attrs, [])
    |> cast_assoc(:team_a, with: &Team.changeset/2, required: true)
    |> cast_assoc(:team_b, with: &Team.changeset/2, required: true)
  end
end
