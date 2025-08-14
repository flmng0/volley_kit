defmodule Volley.Scoring do
  alias Volley.Scoring.Query
  alias Volley.Accounts.AnonymousUser
  alias Volley.Accounts.User
  alias Volley.Accounts.Scope

  alias Volley.Repo
  alias Volley.Scoring.{Match, Event}

  alias Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  def subscribe(%Match{} = match) do
    Phoenix.PubSub.subscribe(Volley.PubSub, "match:#{match.public_id}")
  end

  def unsubscribe(%Match{} = match) do
    Phoenix.PubSub.unsubscribe(Volley.PubSub, "match:#{match.public_id}")
  end

  def broadcast(%Match{} = match, message) do
    Phoenix.PubSub.broadcast(Volley.PubSub, "match:#{match.public_id}", message)
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
  end

  def undo_match_event(%Scope{} = scope, %Match{} = match) do
    true = can_score_match?(scope, match)

    with event when not is_nil(event) <- Query.latest_event(match) |> Repo.one(),
         {:ok, _} <- Repo.delete(event) do
      query =
        from s in Query.score_timeline(match),
          order_by: [desc: s.event_id],
          limit: 1

      if snapshot = Repo.one(query) do
        changes = Map.take(snapshot, [:a_score, :b_score, :a_sets, :b_sets])

        match
        |> Changeset.change(changes)
        |> Repo.update()
      else
        reset_match_scores(scope, match, true)
      end
    end
  end

  defp reset_match_sets(%Changeset{} = changeset, true) do
    Changeset.change(changeset, %{a_sets: 0, b_sets: 0})
  end

  defp reset_match_sets(%Changeset{} = changeset, false) do
    changeset
  end

  def reset_match_scores(%Scope{} = scope, %Match{} = match, reset_sets? \\ false) do
    true = can_score_match?(scope, match)

    match
    |> Changeset.change(%{a_score: 0, b_score: 0})
    |> reset_match_sets(reset_sets?)
    |> Repo.update()
  end

  def delete_match(%Scope{} = scope, %Match{} = match) do
    true = is_match_owner?(scope.user, match)

    Repo.delete(match)
  end
end
