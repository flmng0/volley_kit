defmodule VolleyKit.Manager do
  @moduledoc """
  The Manager context.
  """

  use Phoenix.VerifiedRoutes, endpoint: VolleyKitWeb.Endpoint, router: VolleyKitWeb.Router

  import Ecto.Query, warn: false

  alias VolleyKit.Repo
  alias VolleyKit.Manager.ScratchMatch

  def share_code(%ScratchMatch{} = match, :viewer) do
    url(~p"/scratch/#{match.id}")
  end

  def share_code(%ScratchMatch{} = match, :scorer) do
    token = Phoenix.Token.sign(VolleyKitWeb.Endpoint, "score code", match.id)
    params = %{"token" => token}

    url(~p"/scratch/#{match.id}?#{params}")
  end

  def verify_scratch_match_token(token) do
    Phoenix.Token.verify(VolleyKitWeb.Endpoint, "score code", token)
  end

  def list_scratch_matches do
    Repo.all(ScratchMatch)
  end

  def get_scratch_match(id), do: Repo.get(ScratchMatch, id)
  def get_scratch_match!(id), do: Repo.get!(ScratchMatch, id)

  def create_scratch_match(created_by, options \\ %{}) do
    %ScratchMatch{created_by: created_by, a_score: 0, b_score: 0}
    |> ScratchMatch.changeset(%{"options" => options})
    |> Repo.insert()
  end

  def update_scratch_match(%ScratchMatch{} = scratch_match, attrs) do
    scratch_match
    |> ScratchMatch.changeset(attrs)
    |> Repo.update()
  end

  defp topic(%ScratchMatch{id: id}), do: "scratch_match:#{id}"

  @doc """
  Give a point to team `a` or team `b`, and broadcast the `score` event.

  The broadcast is done to the "scratch_match:\<ID\>" topic.
  The event payload is a map of the changes made to the match.

  ## Example

      iex> match = %ScratchMatch{id: 2, a_score: 12, b_score: 13}

      iex> score_scratch_match(match, "a")
      {:ok, %ScratchMatch{...}}


  The above will broadcast a `score` event to the `scratch_match:2` topic
  with the following payload:

      %{a_score: 13}


  This can be used to merge with the current match in a LiveView.

  """
  def score_scratch_match(%ScratchMatch{} = scratch_match, team) when team in ~w(a b) do
    atom = String.to_atom(team <> "_score")
    current = Map.get(scratch_match, atom, 0)

    update_map = %{atom => current + 1}

    with {:ok, scratch_match} <- update_scratch_match(scratch_match, update_map) do
      VolleyKitWeb.Endpoint.broadcast(topic(scratch_match), "score", update_map)
      {:ok, scratch_match}
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
