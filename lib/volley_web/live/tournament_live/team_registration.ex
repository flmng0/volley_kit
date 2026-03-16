defmodule VolleyWeb.TournamentLive.TeamRegistration do
  use VolleyWeb, :live_view

  alias Volley.Tournaments
  alias Volley.Tournaments.Team

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if tournament = Tournaments.get_tournament(nil, id) do
      socket =
        socket
        |> assign(:tournament, tournament)
        |> assign(:team, %Team{})

      {:ok, socket}
    else
      raise VolleyWeb.NotFoundError, "Tournament does not exist"
    end
  end
end
