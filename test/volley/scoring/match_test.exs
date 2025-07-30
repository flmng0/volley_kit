defmodule Volley.Scoring.MatchTest do
  use Volley.DataCase
  import Volley.ScoringGenerator
  alias Volley.Scoring

  describe "events correctly generated" do
    test "scoring events" do
      match = generate(match())

      match =
        match
        |> Scoring.score!(:a)
        |> Scoring.score!(:b)
        |> Scoring.score!(:a)
        |> Scoring.score!(:a)
        |> Scoring.score!(:b)

      assert Enum.count(match.events, &(&1.team == :a)) == 3
      assert Enum.count(match.events, &(&1.team == :b)) == 2
    end
  end

  describe "match calculations" do
    test "winning team calculates correctly" do
      cases = [
        {:a, 25, 23},
        {:b, 23, 25},
        {nil, 25, 24},
        {nil, 24, 25},
        {:a, 15, 13, 15},
        {:b, 13, 15, 15}
      ]

      for c <- cases do
        case c do
          {expected, a_score, b_score} ->
            winner =
              match(a_score: a_score, b_score: b_score)
              |> generate()
              |> Scoring.winning_team!()

            # match = generate(match(a_score: a_score, b_score: b_score))
            assert expected == winner

          {expected, a_score, b_score, set_limit} ->
            winner =
              match(a_score: a_score, b_score: b_score)
              |> generate()
              |> Scoring.winning_team!(set_limit)

            assert expected == winner
        end
      end
    end
  end
end
