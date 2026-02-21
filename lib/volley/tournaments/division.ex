defmodule Volley.Tournaments.Division do
  use Ecto.Schema
  import Ecto.Changeset

  alias Volley.Tournaments.Tournament

  @types [:mixed, :men, :women]

  def types_list(), do: @types

  schema "divisions" do
    field :name, :string

    field :type, Ecto.Enum, values: @types
    field :max_age, :integer

    belongs_to :tournament, Tournament
  end

  def changeset(division, params \\ %{}) do
    division
    |> cast(params, [:name, :type, :max_age])
    |> validate_required([:name, :type])
    |> validate_number(:max_age, greater_than: 0)
  end
end
