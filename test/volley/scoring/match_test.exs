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

            assert expected == winner

          {expected, a_score, b_score, set_limit} ->
            winner =
              match(a_score: a_score, b_score: b_score, settings: [set_limit: set_limit])
              |> generate()
              |> Scoring.winning_team!()

            assert expected == winner
        end
      end
    end

    test "final set limit applies" do
      match =
        match(
          a_score: 15,
          b_score: 13,
          a_sets: 0,
          b_sets: 1,
          settings: [total_sets: 3, final_set_limit: 15]
        )
        |> generate()

      assert nil == Scoring.winning_team!(match)

      Ash.Seed.update!(match, %{a_sets: 1})
      assert :a == Scoring.winning_team!(match)

      Ash.Seed.update!(match, %{b_score: 16})
      assert nil == Scoring.winning_team!(match)
    end
  end
end
