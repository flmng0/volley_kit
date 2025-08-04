defmodule Volley.ScoringGenerator do
  use Ash.Generator

  alias Volley.Scoring

  def match(opts \\ []) do
    seed_generator(
      %Scoring.Match{
        settings: %Scoring.Settings{
          a_name: "Team A",
          b_name: "Team B",
          set_limit: 25
        },
        a_score: 0,
        b_score: 0
      },
      overrides: opts
    )
  end
end
