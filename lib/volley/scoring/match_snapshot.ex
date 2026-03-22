defmodule Volley.Scoring.MatchSnapshot do
  use Ecto.Schema

  @primary_key false

  embedded_schema do
    field :a_score, :integer, default: 0
    field :b_score, :integer, default: 0

    field :a_sets, :integer, default: 0
    field :b_sets, :integer, default: 0

    field :current_set, :integer, default: 0
  end
end
