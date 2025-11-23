defmodule Volley.Tournaments.Player do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Phoenix.Param

  embedded_schema do
    field :name, :string
    field :number, :integer

    field :libero?, :boolean, default: false
    field :captain?, :boolean, default: false
    field :coach?, :boolean, default: false
  end

  def changeset(player, params \\ %{}) do
    player
    |> cast(params, [:name, :number, :libero?, :captain?, :coach?])
    |> validate_required([:name])
    |> validate_number(:number, greater_than_or_equal_to: 0)
  end
end
