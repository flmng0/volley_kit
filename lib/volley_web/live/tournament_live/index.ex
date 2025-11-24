defmodule VolleyWeb.TournamentLive.Index do
  use VolleyWeb, :live_view

  alias Volley.Tournaments

  @impl true
  def mount(_params, _session, socket) do
    tournaments = Tournaments.list_tournaments(socket.assigns.current_scope)

    if Enum.empty?(tournaments) do
      {:ok, push_navigate(socket, to: ~p"/tournaments/setup")}
    else
      {:ok, stream(socket, :tournaments, tournaments)}
    end
  end
end
