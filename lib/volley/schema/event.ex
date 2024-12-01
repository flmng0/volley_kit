defmodule Volley.Schema.Event do
  use Ecto.Schema

  alias Volley.Schema

  schema "events" do
    field :type, Ecto.Enum, values: [score: 1, set_win: 2, substitution: 3, timeout: 4]

    # Which team did the event?
    field :team, Ecto.Enum, values: [a: 1, b: 2]

    belongs_to :match, Schema.Match
  end
end
