defmodule Volley.Scoring.MatchSnapshot do
  use Ecto.Schema

  @primary_key false

  embedded_schema do
    field :event_id, :integer
    field :a_score, :integer
    field :b_score, :integer

    field :a_sets, :integer
    field :b_sets, :integer

    field :current_set, :integer
  end
end
