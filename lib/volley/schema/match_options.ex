defmodule Volley.Schema.MatchOptions do
  use Ecto.Schema

  embedded_schema do
    field :team_a_name, :string
    field :team_b_name, :string

    # Total number of sets
    field :set_count, :integer

    # Point limit per set
    field :set_point_limit, :integer

    # Optional separate point limit for the final set
    field :final_set_limit, :integer
  end
end
