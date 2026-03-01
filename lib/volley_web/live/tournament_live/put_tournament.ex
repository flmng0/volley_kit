defmodule VolleyWeb.TournamentLive.PutTournament do
  use VolleyWeb, :live_component

  alias Volley.Tournaments

  def on_mount(:default, params, _session, socket) do
    id = params["id"]

    cond do
      id == nil ->
        {:cont, socket}

      socket.assigns[:tournament] && socket.assigns.tournament.id == id ->
        {:cont, socket}

      tournament = Tournaments.get_tournament(socket.assigns.current_scope, id) ->
        {:cont, assign(socket, :tournament, tournament)}

      true ->
        socket =
          socket
          |> put_flash(:error, "Tournament with that ID does not exist, or you can't access it")
          |> push_navigate(to: ~p"/tournaments")

        {:halt, socket}
    end
  end
end
