defmodule VolleyKit.Manager.Team do
  use Ecto.Schema
  import Ecto.Changeset

  alias VolleyKit.Manager.Player

  schema "teams" do
    field :name, :string
    field :sets, :integer, default: 0
    field :points, :integer, default: 0

    embeds_many :players, Player

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :sets, :points])
    |> cast_embed(:players, with: &Player.changeset/2, required: false)
    |> validate_required([:name, :sets, :points])
  end
end
