defmodule Volley.Tournaments.Player do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :name, :string
    field :dob, :date
    field :association_id, :string
  end

  def changeset(player, params \\ %{}) do
    player
    |> cast(params, [:name, :dob, :association_id])
    |> validate_required([:name])
  end
end
