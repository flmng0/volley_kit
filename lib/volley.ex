defmodule Volley do
  @moduledoc """
  Volley keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias Volley.Accounts.User
  alias Volley.Repo
  alias Volley.Query
  alias Volley.Schema.{Event, Match, MatchOptions, MatchUser}

  import Ecto.Query, only: [from: 2]

  import Ecto.Changeset

  defguardp is_team?(team) when team in [:a, :b]

  defp pick_team(:a, when_a, _when_b), do: when_a
  defp pick_team(:b, _when_a, when_b), do: when_b

  @doc """
  Summarize a match from the events table. 

  This can be used for error-correction, and potentially 
  useful for undo-redo in the future.
  """
  def team_summary_from_events(%Match{} = match, team) when is_team?(team) do
    # May need to revisit this style of implementation since it queries
    # once for each team.
    Query.team_summary_from_events(match, team) |> Repo.one()
  end

  # Don't want to use this outside of quick-fixes.
  @doc false
  def fix_match_with_events(%Match{} = match) do
    team_a_summary = team_summary_from_events(match, :a)
    team_b_summary = team_summary_from_events(match, :b)

    match
    |> change(%{team_a_summary: team_a_summary, team_b_summary: team_b_summary})
    |> Repo.update()
  end

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

  def put_match_owner(%Match{} = match, %User{} = owner) do
    %MatchUser{}
    |> change(%{match_id: match.id, user_id: owner.id, level: :owner})
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

  @doc """
  Create changeset for a `MatchOptions` struct.

  Includes validations.
  """
  def change_match_options(%MatchOptions{} = options, attrs \\ %{}) do
    options
    |> cast(attrs, [:team_a_name, :team_b_name, :set_count, :set_point_limit, :final_set_limit])
    |> validate_required([:team_a_name, :team_b_name, :set_point_limit])
    |> validate_number(:set_count, greater_than_or_equal_to: 0, message: "must not be negative")
    |> validate_number(:set_point_limit, greater_than: 0)
    |> validate_number(:final_set_limit, greater_than: 0)
  end

  @doc """
  Get a match with the given ID.

  Like `Ecto.Repo.get/2`, returns `nil` when ID not found.
  """
  def get_match(id) do
    query =
      from m in Match,
        preload: [:users]

    Repo.get(query, id)
  end

  def get_match_owner(%Match{} = match) do
    query =
      from u in User,
        join: mu in MatchUser,
        on: mu.match_id == ^match.id and mu.level == ^:owner

    Repo.one(query)
  end

  def get_user_matches(%User{} = user) do
    user
    |> Ecto.assoc(:matches)
    |> Repo.all()
  end

  @doc """
  Listen to event messages for a given match.
  """
  def subscribe_events(%Match{} = match) do
    Phoenix.PubSub.subscribe(Volley.PubSub, "events:#{match.id}")
  end

  @doc """
  Stop listening to event messages for a given match.
  """
  def unsubscribe_events(%Match{} = match) do
    Phoenix.PubSub.unsubscribe(Volley.PubSub, "events:#{match.id}")
  end

  # Helper to push new events of a given type to the `events` table.
  defp push_event(type, %Match{} = match, team) when is_team?(team) do
    event = %Event{
      type: type,
      team: team,
      match: match
    }

    Phoenix.PubSub.broadcast(Volley.PubSub, "events:#{match.id}", event)

    event
    |> change()
    |> Repo.insert()
  end

  @doc """
  Score a point for a match. This does not check whether a team has
  won the current set.

  See `Volley.set_complete?/2`.
  """
  def score_match(%Match{} = match, team) when is_team?(team) do
    summary_atom = pick_team(team, :team_a_summary, :team_b_summary)
    summary = Map.get(match, summary_atom)

    changeset = change(match, %{summary_atom => %{score: summary.score + 1}})

    with {:ok, match} <- Repo.update(changeset),
         {:ok, _event} <- push_event(:score, match, team) do
      {:ok, match}
    end
  end

  @doc """
  Get boolean indicating if the set is complete.

  i.e. one team's score is higher than the current set limit, and there's
  advantage of at least two between (deuce).
  """
  def set_complete?(%Match{} = match) do
    %Match{
      team_a_summary: %{
        score: a_score,
        sets: a_sets
      },
      team_b_summary: %{
        score: b_score,
        sets: b_sets
      },
      options: %{
        set_count: set_count,
        set_point_limit: set_point_limit,
        final_set_limit: final_set_limit
      }
    } = match

    is_final? = set_count && a_sets + b_sets == set_count - 1

    set_limit = if is_final?, do: final_set_limit, else: set_point_limit

    {higher, lower} = {max(a_score, b_score), min(a_score, b_score)}

    higher >= set_limit && higher >= lower + 2
  end

  @doc """
  Transition to the next set.

  This function does not check whether it the set is complete first, it
  expects that it has already been checked via `set_complete?/1`.
  """
  def finish_set(%Match{} = match) do
    a_score = match.team_a_summary.score
    b_score = match.team_b_summary.score

    winner = if a_score > b_score, do: :a, else: :b

    changeset =
      change(match, %{
        team_a_summary: %{score: 0, sets: match.team_a_summary.sets + pick_team(winner, 1, 0)},
        team_b_summary: %{score: 0, sets: match.team_b_summary.sets + pick_team(winner, 0, 1)}
      })

    with {:ok, match} <- Repo.update(changeset),
         {:ok, _event} <- push_event(:set_win, match, winner) do
      {:ok, match}
    end
  end
end
