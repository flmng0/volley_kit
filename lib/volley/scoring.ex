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

  def subscribe(%Match{} = match) do
    Phoenix.PubSub.subscribe(Volley.PubSub, "match:#{match.public_id}")
  end

  def unsubscribe(%Match{} = match) do
    Phoenix.PubSub.unsubscribe(Volley.PubSub, "match:#{match.public_id}")
  end

  defp maybe_broadcast({:ok, %Match{} = match}) do
    Phoenix.PubSub.broadcast(Volley.PubSub, "match:#{match.public_id}", {:match_update, match})
    {:ok, match}
  end

  defp maybe_broadcast(result) do
    result
  end

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

  defp is_match_owner?(%AnonymousUser{} = user, %Match{} = match),
    do: match.anonymous_owner_id == user.id

  defp is_match_owner?(%User{} = user, %Match{} = match), do: match.owner_id == user.id
  defp is_match_owner?(_, %Match{} = _), do: false

  defp event(%Match{} = match, type, team) do
    %Event{match_id: match.id, type: type, team: team}
  end

  def can_score_match?(%Scope{} = scope, %Match{} = match) do
    is_match_owner?(scope.user, match)
  end

  def get_match(%Scope{} = scope) do
    owner_key = if scope.anonymous, do: :anonymous_owner_id, else: :owner_id

    Repo.get_by(Match, [{owner_key, scope.user.id}])
  end

  def get_match_by_public_id(%Scope{} = _, public_id) do
    Repo.get_by(Match, public_id: public_id)
  end

  def update_match_settings(%Scope{} = scope, %Match{} = match, settings) do
    true = is_match_owner?(scope.user, match)

    match
    |> Match.update_settings_changeset(%{"settings" => settings})
    |> Repo.update()
    |> maybe_broadcast()
  end

  def score_match(scope, match, team) when is_binary(team) do
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

    query
    |> Ecto.Query.exclude(:order_by)
    |> Repo.delete_all()

    reset_match_with_events(match)
  end

  def delete_match(%Scope{} = scope, %Match{} = match) do
    true = is_match_owner?(scope.user, match)

    Repo.delete(match)
  end
end
