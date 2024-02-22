defmodule VolleyKit.Manager.Match do
  use Ecto.Schema
  import Ecto.Changeset

  alias VolleyKit.Manager.Team

  schema "matches" do
    field :owner, Ecto.UUID
    belongs_to :team_a, Team, on_replace: :update
    belongs_to :team_b, Team, on_replace: :update

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(match, attrs) do
    match
    |> cast(attrs, [:owner])
    |> cast_assoc(:team_a, with: &Team.changeset/2, required: true)
    |> cast_assoc(:team_b, with: &Team.changeset/2, required: true)
    |> validate_required(:owner)
  end
end
