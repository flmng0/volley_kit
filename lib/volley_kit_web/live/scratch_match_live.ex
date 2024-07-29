defmodule VolleyKitWeb.ScratchMatchLive do
  use VolleyKitWeb, :live_view

  alias VolleyKit.Manager
  alias VolleyKit.Manager.ScratchMatch

  def mount(_params, %{"user_id" => user_id} = _session, socket) do
    {:ok, assign(socket, user_id: user_id), layout: false}
  end

  def handle_params(%{"id" => id} = _params, _uri, socket) do
    match = Manager.get_scratch_match!(id)
    scorer? = match.created_by == socket.assigns.user_id

    if connected?(socket) do
      if old_match = socket.assigns[:match] do
        Manager.unsubscribe_scratch_match(old_match)
      end

      Manager.subscribe_scratch_match(match)
    end

    {:noreply, assign(socket, match: match, scorer?: scorer?)}
  end

  def handle_info(%{event: "score", payload: update_map}, %{assigns: %{match: match}} = socket) do
    {:noreply, assign(socket, match: Map.merge(match, update_map))}
  end

  def handle_event("score", %{"team" => team}, socket) do
    {:noreply, score(socket, socket.assigns.match, team)}
  end

  def score(socket, %ScratchMatch{} = match, team) do
    {:ok, match} = Manager.score_scratch_match(match, team)

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
