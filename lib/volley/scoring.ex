defmodule Volley.Scoring do
  alias Volley.Accounts.AnonymousUser
  alias Volley.Accounts.User
  alias Volley.Accounts.Scope

  alias Volley.Scoring.MatchSnapshot
  alias Volley.Scoring.Query
  alias Volley.Scoring.Match
  alias Volley.Scoring.Event

  alias Volley.Repo

  alias Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  @moduledoc """
  Context related to scoring. The main responsibility of this context is to 
  coordinate events on a match when necessary.

  For example, `Volley.Scoring.score_match/3` will increment the necessary 
  score, but will also create a new `Volley.Scoring.Event` with type `:score`
  for the match.
  """

  @doc """
  Subscribes to a given resource, and determines the correct topic.

  This module dispatches reource update events with the format:

    {:update, resource}
  """
  def subscribe(%Match{} = match) do
    Phoenix.PubSub.subscribe(Volley.PubSub, "match:#{match.public_id}")
  end

  @doc "Unsubscribe to updates for a given resource."
  def unsubscribe(%Match{} = match) do
    Phoenix.PubSub.unsubscribe(Volley.PubSub, "match:#{match.public_id}")
  end

  # Broadcast an {:update, resource} message.
  defp broadcast(%Match{} = match) do
    Phoenix.PubSub.broadcast(Volley.PubSub, "match:#{match.public_id}", {:update, match})
  end

  # Used in piping for only broadcasting successful `Repo.update`s
  defp maybe_broadcast({:ok, resource}) do
    broadcast(resource)
    {:ok, resource}
  end

  defp maybe_broadcast(result) do
    result
  end

  @doc "Start a new match, and associate it with the given scope."
  def start_match(%Scope{} = scope, settings \\ %{}) do
    associate_owner =
      if scope.anonymous do
        &Changeset.put_change(&1, :anonymous_owner_id, scope.user.id)
      else
        &Changeset.put_assoc(&1, :owner, scope.user)
      end

    %Match{}
    |> Match.start_changeset(%{"settings" => settings})
    |> then(associate_owner)
    |> Repo.insert()
  end

  # Helper to check if a given Scope owns a given Match.
  defp is_match_owner?(%Scope{} = scope, %Match{} = match), do: is_match_owner?(scope.user, match)

  defp is_match_owner?(%AnonymousUser{} = user, %Match{} = match),
    do: match.anonymous_owner_id == user.id

  defp is_match_owner?(%User{} = user, %Match{} = match), do: match.owner_id == user.id
  defp is_match_owner?(_, %Match{} = _), do: false

  # Factory to generate a new Event for a given match
  defp event(%Match{} = match, type, team) do
    %Event{match_id: match.id, type: type, team: team}
  end

  @doc """
  Does the given scope have permissions to score the given match?
  """
  def can_score_match?(%Scope{} = scope, %Match{} = match) do
    is_match_owner?(scope, match)
  end

  def get_match(%Scope{} = scope) do
    owner_key = if scope.anonymous, do: :anonymous_owner_id, else: :owner_id

    Repo.get_by(Match, [{owner_key, scope.user.id}])
  end

  def get_match_by_public_id(%Scope{} = _, public_id) do
    Repo.get_by(Match, public_id: public_id)
  end

  defp commit_match_settings(%Scope{} = scope, %Ecto.Changeset{} = changeset, reset?) do
    Repo.transact(fn ->
      with {:ok, match} <- Repo.update(changeset) do
        if reset? do
          reset_match_scores(scope, match, true)
        else
          broadcast(match)
          {:ok, match}
        end
      end
    end)
  end

  @doc """
  Update a match's settings.

  Will reset the state of the given match if the `:set_limit` is changed.

  This is due to a change of `:set_limit` invalidating previous `:set_won`
  events.
  """
  def update_match_settings(%Scope{} = scope, %Match{} = match, settings) do
    true = is_match_owner?(scope, match)

    changeset = Match.update_settings_changeset(match, %{"settings" => settings})

    if settings_changeset = Changeset.get_change(changeset, :settings) do
      reset? = Changeset.changed?(settings_changeset, :set_limit)

      commit_match_settings(scope, changeset, reset?)
    else
      {:ok, match}
    end
  end

  @doc "Score a match, if allowed"
  def score_match(%Scope{} = scope, %Match{} = match, team) when is_binary(team) do
    score_match(scope, match, String.to_existing_atom(team))
  end

  def score_match(%Scope{} = scope, %Match{} = match, team) do
    true = can_score_match?(scope, match)

    change =
      case team do
        :a -> {:a_score, match.a_score + 1}
        :b -> {:b_score, match.b_score + 1}
      end

    Repo.transact(fn ->
      with {:ok, _} <- event(match, :score, team) |> Repo.insert() do
        Changeset.change(match, [change])
        |> Repo.update()
      end
    end)
    |> maybe_broadcast()
  end

  # Changeset helper to put an increment on a field with `key` by a given `delta`
  defp put_increment(%Changeset{} = changeset, key, delta \\ 1) do
    value = Changeset.fetch_field!(changeset, key)
    Changeset.put_change(changeset, key, value + delta)
  end

  def complete_set(%Scope{} = scope, %Match{} = match, team) do
    true = can_score_match?(scope, match)

    set_key =
      case team do
        :a -> :a_sets
        :b -> :b_sets
      end

    Repo.transact(fn ->
      with {:ok, _} <- event(match, :set_won, team) |> Repo.insert() do
        match
        |> Changeset.change(%{a_score: 0, b_score: 0})
        |> put_increment(set_key)
        |> Repo.update()
      end
    end)
    |> maybe_broadcast()
  end

  # Helper to reconstruct a match from it's associated events. This is used to 
  # support undo functionality, and can be used to fix broken match states.
  defp reset_match_with_events(%Match{} = match) do
    query = match |> Query.score_timeline() |> Ecto.Query.limit(1)

    snapshot =
      case Repo.one(query) do
        %{snapshot: snapshot} -> snapshot
        nil -> %MatchSnapshot{a_score: 0, b_score: 0, a_sets: 0, b_sets: 0}
      end

    changes = Map.take(snapshot, [:a_score, :b_score, :a_sets, :b_sets])

    match
    |> Changeset.change(changes)
    |> Repo.update()
    |> maybe_broadcast()
  end

  @doc "Undo the scoring event on a match"
  def undo_match_event(%Scope{} = scope, %Match{} = match) do
    true = can_score_match?(scope, match)

    query = match |> Query.match_events() |> Ecto.Query.limit(1)

    if event = Repo.one(query) do
      with {:ok, _} <- Repo.delete(event) do
        reset_match_with_events(match)
      end
    else
      {:ok, match}
    end
  end

  @doc """
  Reset the scores for a match.

  When `reset_sets?` is not provided, it will wipe the events for the current
  set and only set scores to 0.

  If `reset_sets?` is true, then it will wipe all events.
  """
  def reset_match_scores(%Scope{} = scope, %Match{} = match, reset_sets? \\ false) do
    true = can_score_match?(scope, match)

    set = Match.current_set(match)

    query =
      if reset_sets? do
        Query.match_events(match)
      else
        from e in Query.match_events(match),
          join: se in subquery(Query.events_with_set()),
          on: e.id == se.id,
          where: se.set == ^set and e.type != :set_won
      end

    Repo.transact(fn ->
      query
      |> Ecto.Query.exclude(:order_by)
      |> Repo.delete_all()

      reset_match_with_events(match)
    end)
  end

  @doc "Delete a match, if allowed"
  def delete_match(%Scope{} = scope, %Match{} = match) do
    true = is_match_owner?(scope, match)

    Repo.delete(match)
  end
end
