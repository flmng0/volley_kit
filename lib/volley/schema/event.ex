defmodule Volley.Schema.Event do
  use Ecto.Schema

  alias Volley.Schema

  schema "events" do
    field :type, Ecto.Enum, values: [score: 1, set_win: 2, substitution: 3, timeout: 4]

    belongs_to :match, Schema.Match
    belongs_to :team, Schema.Team
  end
end
