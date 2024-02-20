defmodule VolleyKit.Manager.Team do
  use Ecto.Schema
  import Ecto.Changeset

  alias VolleyKit.Manager.Match
  alias VolleyKit.Manager.Player

  schema "teams" do
    field :name, :string
    field :sets, :integer
    field :points, :integer

    embeds_many :players, Player

    belongs_to :match, Match

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :sets, :points, :players])
    |> validate_required([:name, :sets, :points])
  end
end
