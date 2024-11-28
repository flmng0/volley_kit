defmodule Volley do
  @moduledoc """
  Volley keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias Volley.Repo
  alias Volley.Schema.{Event, Match, Team}

  import Ecto.Changeset

  defguardp is_team?(team) when team in [:a, :b]

  defp pick_team(:a, when_a, _when_b), do: when_a
  defp pick_team(:b, _when_a, when_b), do: when_b

  defp create_team(name) do
    %Team{name: name}
    |> change()
    |> Repo.insert()
  end

  @doc """
  Start a new match with the given team names.
  """
  def create_match(team_a_name, team_b_name) do
    with {:ok, team_a} <- create_team(team_a_name),
         {:ok, team_b} <- create_team(team_b_name) do
      %Match{}
      |> change()
      |> put_assoc(:team_a, team_a)
      |> put_embed(:team_a_summary, %{})
      |> put_assoc(:team_b, team_b)
      |> put_embed(:team_b_summary, %{})
      |> Repo.insert()
    end
  end

  @doc """
  Get a match with the given ID, and preload associations.
  """
  def get_match!(id) do
    Repo.get!(Match, id) |> Repo.preload([:team_a, :team_b])
  end

  # Helper to push new events of a given type to the `events` table.
  defp push_event(type, %Match{} = match, team) when is_team?(team) do
    %Event{
      type: type
    }
    |> change()
    |> put_assoc(:match, match)
    |> put_assoc(:team, pick_team(team, match.team_a, match.team_b))
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

    team = pick_team(winner, match.team_a, match.team_b)

    with {:ok, _} <- push_event(:set_win, match, team) do
      match
      |> change(%{
        team_a_summary: %{score: 0, sets: match.team_a_summary.sets + pick_team(winner, 1, 0)},
        team_b_summary: %{score: 0, sets: match.team_b_summary.sets + pick_team(winner, 0, 1)}
      })
      |> Repo.update()
    end
  end
end
