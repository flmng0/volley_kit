defmodule VolleyWeb.TournamentLive.Setup do
  use VolleyWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_info({:submit_tournament, params}, socket) do
    {:ok, tournament} = Volley.Tournaments.create_tournament(socket.assigns.current_scope, params)

    socket =
      socket
      |> push_navigate(to: ~p"/tournaments/#{tournament}")

    {:noreply, socket}
  end
end
