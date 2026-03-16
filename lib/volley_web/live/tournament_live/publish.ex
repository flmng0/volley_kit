defmodule VolleyWeb.TournamentLive.Publish do
  use VolleyWeb, :live_view
  on_mount VolleyWeb.TournamentLive.PutTournament

  alias Volley.Tournaments
  alias Volley.Tournaments.Tournament

  @impl true
  def mount(_params, _session, socket) do
    tournament = socket.assigns.tournament

    if tournament.draft do
      {:ok, socket}
    else
      {:ok, push_navigate(socket, to: ~p"/tournaments/#{tournament}")}
    end
  end

  @impl true
  def handle_info(:publish_tournament, socket) do
    tournament = socket.assigns.tournament

    Tournaments.publish_tournament!(socket.assigns.current_scope, tournament)

    socket =
      socket
      |> push_navigate(to: ~p"/tournaments/#{tournament}/")
      |> put_flash(:info, "Successfully published tournament \"#{tournament.name}\"")

    {:noreply, socket}
  end
end
