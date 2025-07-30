defmodule Volley.Scoring.EventType do
  @valid_types [:score, :substitution, :timeout]

  use Ash.Type.NewType,
    subtype_of: :atom,
    constraints: [one_of: @valid_types]

  def types(), do: @valid_types
end
