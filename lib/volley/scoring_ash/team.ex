defmodule Volley.ScoringAsh.Team do
  use Ash.Type.NewType,
    subtype_of: :atom,
    constraints: [one_of: [:a, :b]]
end
