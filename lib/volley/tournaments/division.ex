defmodule Volley.Tournaments.Division do
  use Ecto.Schema
  import Ecto.Changeset

  alias Volley.Tournaments.Tournament

  @types [:mixed, :men, :women]

  def types_list(), do: @types

  schema "divisions" do
    field :name, :string

    belongs_to :tournament, Tournament
  end

  def changeset(division, params \\ %{}) do
    division
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end
