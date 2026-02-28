defmodule VolleyWeb.TournamentLive.PutTournament do
  use VolleyWeb, :live_component

  alias Volley.Tournaments

  def on_mount(:default, params, _session, socket) do
    id = params["id"]

    socket =
      cond do
        id == nil ->
          socket

        socket.assigns[:tournament] && socket.assigns.tournament.id == id ->
          socket

        tournament = Tournaments.get_tournament(socket.assigns.current_scope, id) ->
          assign(socket, :tournament, tournament)

        true ->
          socket
          |> put_flash(:error, "Tournament with that ID does not exist, or you can't access it")
          |> push_navigate(to: ~p"/tournaments")
      end

    {:cont, socket}
  end
end
