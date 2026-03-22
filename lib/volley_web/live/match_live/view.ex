defmodule VolleyWeb.MatchLive.View do
  use VolleyWeb, :live_view

  alias Volley.Scoring
  alias Volley.Scoring.Match

  require Integer

  on_mount VolleyWeb.MatchLive.PutMatch

  @impl true
  def mount(params, _session, socket) do
    Volley.Scoring.subscribe(socket.assigns.match)

    {:ok, assign(socket, :include_scorer_link?, params["from_scorer"])}
  end

  @impl true
  def handle_info({:update, %Match{} = match}, socket) do
    {:noreply, assign(socket, :match, match)}
  end
end
