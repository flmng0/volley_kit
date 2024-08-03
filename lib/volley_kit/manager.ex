defmodule VolleyKit.Manager do
  @moduledoc """
  The Manager context.
  """

  use Phoenix.VerifiedRoutes, endpoint: VolleyKitWeb.Endpoint, router: VolleyKitWeb.Router

  import Ecto.Query, warn: false

  alias VolleyKit.Repo
  alias VolleyKit.Manager.ScratchMatch

  def scratch_match_view_code(%ScratchMatch{} = match) do
    url(~p"/scratch/#{match.id}")
  end

  def scratch_match_score_code(%ScratchMatch{} = match, token) do
    params = %{"token" => token}
    url(~p"/scratch/#{match.id}?#{params}")
  end

  def sign_scratch_match_token(%ScratchMatch{id: id} = _match) do
    Phoenix.Token.sign(VolleyKitWeb.Endpoint, "score code", id)
  end

  def verify_scratch_match_token(token) do
    Phoenix.Token.verify(VolleyKitWeb.Endpoint, "score code", token)
  end

  def list_scratch_matches, do: list_scratch_matches(nil)

  def list_scratch_matches(nil) do
    Repo.all(ScratchMatch)
  end

  def list_scratch_matches(user_id) do
    query = from m in ScratchMatch, where: m.created_by == ^user_id
    Repo.all(query)
  end

  def get_scratch_match(id), do: Repo.get(ScratchMatch, id)
  def get_scratch_match!(id), do: Repo.get!(ScratchMatch, id)

  def create_scratch_match(created_by, options \\ %{}) do
    %ScratchMatch{created_by: created_by}
    |> ScratchMatch.changeset(%{"options" => options})
    |> Repo.insert()
  end

  def update_scratch_match(%ScratchMatch{} = scratch_match, attrs) do
    scratch_match
    |> ScratchMatch.changeset(attrs)
    |> Repo.update()
  end

  def as_score_action("add"), do: :add
  def as_score_action("retract"), do: :retract
  def as_score_action("reset"), do: :reset

  defp topic(%ScratchMatch{id: id}), do: "scratch_match:#{id}"

  @doc """
  Give a point to team `a` or team `b`, and broadcast the `score` event.

  The broadcast is done to the `scratch_match:\<ID\>` topic.
  The event payload is a map of the changes made to the match.

  Can also be used with :retract to remove a point.

  ## Example

      iex> match = %ScratchMatch{id: 2, a_score: 12, b_score: 13}

      iex> score_scratch_match(match, "a")
      {:ok, %ScratchMatch{...}}


  The above will broadcast a `score` event to the `scratch_match:2` topic
  with the following payload:

      %{a_score: 13}


  This can be used to merge with the current match in a LiveView.

  """
  def score_scratch_match(%ScratchMatch{} = scratch_match, team, action \\ :add)
      when team in ~w(a b) do
    atom = String.to_atom(team <> "_score")
    current = Map.get(scratch_match, atom, 0)

    delta =
      case action do
        :add ->
          1

        :retract ->
          -1

        :reset ->
          -current
      end

    update_map = %{atom => max(0, current + delta)}

    with {:ok, scratch_match} <- update_scratch_match(scratch_match, update_map) do
      VolleyKitWeb.Endpoint.broadcast(topic(scratch_match), "score", update_map)

      {:ok, scratch_match}
    end
  end

  def would_complete_set?(%ScratchMatch{a_score: a, b_score: b}, team) when team in ~w(a b) do
    {winner_score, opponent_score} =
      case team do
        "a" ->
          {a, b}

        "b" ->
          {b, a}
      end

    winner_score >= 24 && winner_score >= opponent_score + 1
  end

  def next_set(%ScratchMatch{a_score: a, b_score: b} = match) do
    winner = if a > b, do: :a, else: :b

    update_map =
      case winner do
        :a ->
          %{a_sets: match.a_sets + 1}

        :b ->
          %{b_sets: match.b_sets + 1}
      end
      |> Map.merge(%{a_score: 0, b_score: 0})

    with {:ok, match} <- update_scratch_match(match, update_map) do
      VolleyKitWeb.Endpoint.broadcast(topic(match), "set_won", winner)
      VolleyKitWeb.Endpoint.broadcast(topic(match), "score", update_map)

      {:ok, match}
    end
  end

  def subscribe_scratch_match(scratch_match) do
    VolleyKitWeb.Endpoint.subscribe(topic(scratch_match))
  end

  def unsubscribe_scratch_match(scratch_match) do
    VolleyKitWeb.Endpoint.unsubscribe(topic(scratch_match))
  end

  def delete_scratch_match(%ScratchMatch{} = scratch_match) do
    Repo.delete(scratch_match)
  end

  def change_scratch_match(%ScratchMatch{} = scratch_match, attrs \\ %{}) do
    ScratchMatch.changeset(scratch_match, attrs)
  end
end
