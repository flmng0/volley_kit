defmodule VolleyWeb.TournamentLive.Show do
  use VolleyWeb, :live_view

  alias Volley.Tournaments

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if tournament = Tournaments.get_tournament(socket.assigns.current_scope, id) do
      socket =
        socket
        |> assign(:tournament, tournament)

      {:ok, socket}
    else
      socket =
        socket
        |> put_flash(:error, "Tournament does not exist")
        |> push_navigate(to: ~p"/tournaments")

      {:ok, socket}
    end
  end
end
