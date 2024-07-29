defmodule VolleyKitWeb.ScratchMatchLive do
  alias VolleyKit.Manager.ScratchMatch
  use VolleyKitWeb, :live_view

  alias VolleyKit.Manager

  def mount(%{"id" => id} = _params, %{"user_id" => user_id} = _session, socket) do
    match = Manager.get_scratch_match!(id)
    scorer? = match.created_by == user_id

    socket = socket |> assign(match: match, scorer?: scorer?)

    {:ok, socket, layout: false}
  end

  def handle_event("score", %{"team" => team}, socket) do
    {:noreply, score(socket, socket.assigns.match, team)}
  end

  def score(socket, %ScratchMatch{} = match, team) when team in ~w(a b) do
    atom = String.to_atom(team <> "_score")
    current_score = Map.get(match, atom, 0)

    {:ok, match} = Manager.update_scratch_match(match, %{atom => current_score + 1})

    assign(socket, match: match)
  end

  attr :team_name, :string
  attr :score, :integer

  defp score_card(assigns) do
    ~H"""
    <%= @team_name %>
    <%= @score %>
    """
  end
end
