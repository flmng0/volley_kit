defmodule Volley do
  @moduledoc """
  Volley keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias Volley.Repo
  alias Volley.Schema.{Event, Match, MatchOptions}

  import Ecto.Changeset

  defguardp is_team?(team) when team in [:a, :b]

  defp pick_team(:a, when_a, _when_b), do: when_a
  defp pick_team(:b, _when_a, when_b), do: when_b

  @doc """
  Start a new match with the given team names.
  """
  def create_match(options \\ %{}) do
    %Match{}
    |> cast(%{options: options}, [])
    |> cast_embed(:options, with: &change_match_options/2)
    |> put_embed(:team_a_summary, %{})
    |> put_embed(:team_b_summary, %{})
    |> Repo.insert()
  end

  @doc """
  Get the default options for a new match.

  These are not defined in the schema, so that the validation
  messages will show successfully.
  """
  def default_match_options,
    do: %MatchOptions{
      team_a_name: "Team A",
      team_b_name: "Team B",
      set_point_limit: 25
    }

  def change_match_options(%MatchOptions{} = options, attrs \\ %{}) do
    options
    |> cast(attrs, [:team_a_name, :team_b_name, :set_count, :set_point_limit, :final_set_limit])
    |> validate_required([:team_a_name, :team_b_name, :set_point_limit])
    |> validate_number(:set_count, greater_than_or_equal_to: 0, message: "must not be negative")
    |> validate_number(:set_point_limit, greater_than: 0)
    |> validate_number(:final_set_limit, greater_than: 0)
  end

  @doc """
  Get a match with the given ID, and preload associations.
  """
  def get_match!(id) do
    Repo.get!(Match, id)
  end

  # Helper to push new events of a given type to the `events` table.
  defp push_event(type, %Match{} = match, team) when is_team?(team) do
    %Event{
      type: type,
      team: team
    }
    |> change()
    |> put_assoc(:match, match)
    |> Repo.insert()
  end

  @doc """
  Score a point for a match. This does not check whether a team has
  won the current set.

  See `Volley.set_complete?/2`.
  """
  def score_match(%Match{} = match, team) when is_team?(team) do
    with {:ok, _} <- push_event(:score, match, team) do
      summary_atom = pick_team(team, :team_a_summary, :team_b_summary)
      summary = Map.get(match, summary_atom)

      match
      |> change(%{summary_atom => %{score: summary.score + 1}})
      |> Repo.update()
    end
  end

  @doc """
  Get boolean indicating if the set is complete.

  Defaults to 25 for the set limit, but can be configured by passing
  the second parameter.
  """
  def set_complete?(%Match{} = match, set_limit \\ 25) do
    a_score = match.team_a_summary.score
    b_score = match.team_b_summary.score

    {higher, lower} = {max(a_score, b_score), min(a_score, b_score)}

    higher >= set_limit && higher > lower + 2
  end

  def finish_set(%Match{} = match) do
    a_score = match.team_a_summary.score
    b_score = match.team_b_summary.score

    winner = if a_score > b_score, do: :a, else: :b

    with {:ok, _} <- push_event(:set_win, match, winner) do
      match
      |> change(%{
        team_a_summary: %{score: 0, sets: match.team_a_summary.sets + pick_team(winner, 1, 0)},
        team_b_summary: %{score: 0, sets: match.team_b_summary.sets + pick_team(winner, 0, 1)}
      })
      |> Repo.update()
    end
  end
end
