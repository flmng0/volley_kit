defmodule Volley.MatchTest do
  use Volley.DataCase

  describe "match" do
    alias Volley.Schema.{Match, MatchOptions, Event}

    import Volley.MatchFixtures

    test "create_match/1 with default options succeeds" do
      options = Volley.default_match_options() |> Map.from_struct()

      assert {:ok, %Match{} = match} = Volley.create_match(options)
      assert %MatchOptions{} = match.options

      assert match.options.team_a_name == options.team_a_name
      assert match.options.team_b_name == options.team_b_name
      assert match.options.set_point_limit == options.set_point_limit
    end

    test "create_match/1 with invalid options fails" do
      assert {:error, %Ecto.Changeset{}} = Volley.create_match(%{})
    end

    test "score_match/2 broadcasts scored event" do
      match = match_fixture()

      assert :ok = Volley.subscribe_events(match)
      assert {:ok, %Match{} = match} = Volley.score_match(match, :a)

      assert_received %Event{} = event, "Did not receive"
      assert event.type == :score
      assert event.team == :a
      # Asser the match in the event is up-to-date.
      assert event.match == match
    end

    test "score_match/2 updates appropriate team summary" do
      a_score = 10
      b_score = 14

      %Match{} =
        match =
        for _ <- 1..a_score, reduce: match_fixture() do
          m ->
            assert {:ok, %Match{} = m} = Volley.score_match(m, :a)
            m
        end

      assert match.team_a_summary.score == a_score
      assert match.team_b_summary.score == 0

      %Match{} =
        match =
        for _ <- 1..b_score, reduce: match do
          m ->
            assert {:ok, %Match{} = m} = Volley.score_match(m, :b)
            m
        end

      assert match.team_a_summary.score == a_score
      assert match.team_b_summary.score == b_score
    end

    test "set_complete?/1 handles deuce" do
      match = match_fixture(a_score: 25, b_score: 24)

      refute Volley.set_complete?(match)

      assert {:ok, match} = Volley.score_match(match, :a)

      assert Volley.set_complete?(match)
    end

    test "set_complete?/1 handles final set limit" do
      match =
        match_fixture(
          options: %{final_set_limit: 10, set_count: 2},
          a_score: 9,
          b_score: 8,
          a_sets: 1
        )

      refute Volley.set_complete?(match)

      assert {:ok, match} = Volley.score_match(match, :a)

      assert Volley.set_complete?(match)
    end

    test "finish_set/1 correctly resets score and updates summary" do
      match = match_fixture(a_score: 25, b_score: 23)

      assert {:ok, match} = Volley.finish_set(match)

      assert match.team_a_summary.score == 0
      assert match.team_b_summary.score == 0
      assert match.team_a_summary.sets == 1
      assert match.team_b_summary.sets == 0
    end

    test "finish_set/1 correctly broadcasts event" do
      match = match_fixture(a_score: 25, b_score: 23)

      assert :ok = Volley.subscribe_events(match)
      assert {:ok, match} = Volley.finish_set(match)

      assert_received %Event{} = event
      assert event.type == :set_win
      assert event.team == :a
      # Asser the match in the event is up-to-date.
      assert event.match == match
    end
  end
end
