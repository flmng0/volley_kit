defmodule VolleyWeb.ScratchMatchLive do
  use VolleyWeb, :live_view
  import VolleyWeb.MatchComponents

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:a_score, 0)
      |> assign(:b_score, 0)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.scorer>
      <.score_container a_score={@a_score} b_score={@b_score} event="score" />
    </Layouts.scorer>
    """
  end

  @impl true
  def handle_event("score", %{"team" => team}, socket) do
    team_score = String.to_existing_atom("#{team}_score")
    socket = assign(socket, team_score, socket.assigns[team_score] + 1)

    {:noreply, socket}
  end
end
