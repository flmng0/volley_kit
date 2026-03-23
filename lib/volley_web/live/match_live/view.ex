defmodule VolleyWeb.MatchLive.View do
  use VolleyWeb, :live_view

  alias Volley.Scoring
  alias Volley.Scoring.Match

  require Integer

  on_mount VolleyWeb.MatchLive.PutMatch

  @impl true
  def mount(_params, _session, socket) do
    Scoring.subscribe(socket.assigns.match)
    scorer? = Scoring.can_score_match?(socket.assigns.current_scope, socket.assigns.match)

    {:ok, assign(socket, :scorer?, scorer?)}
  end

  @impl true
  def handle_info({:update, %Match{} = match}, socket) do
    {:noreply, assign(socket, :match, match)}
  end
end
