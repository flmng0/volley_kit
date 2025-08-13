defmodule Volley.Scoring.Event do
  use Volley.Schema

  @primary_key {:id, :id, autogenerate: true}

  schema "events" do
    field :type, Ecto.Enum, values: [:score, :set_won]
    field :team, Ecto.Enum, values: [:a, :b]

    belongs_to :match, Volley.Scoring.Match

    timestamps()
  end
end
