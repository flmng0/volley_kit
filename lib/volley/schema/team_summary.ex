defmodule Volley.Schema.TeamSummary do
  use Ecto.Schema

  embedded_schema do
    field :score, :integer, default: 0
    field :sets, :integer, default: 0

    ## Eventually add this
    # field :remaining_timeouts, :integer
    # field :remaining_substitutions, :integer
  end
end
