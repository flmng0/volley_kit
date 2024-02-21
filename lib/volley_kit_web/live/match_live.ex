defmodule VolleyKitWeb.MatchLive do
  use VolleyKitWeb, :live_view

  alias VolleyKitWeb.MatchLive.ScoreCard

  alias VolleyKit.Manager

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Showing Match")
      |> assign(:match, Manager.get_match!(id))

    {:ok, socket}
  end

  @impl true
  def handle_info({ScoreCard, :increment}, socket) do
    match = socket.assigns.match
    team_a = VolleyKit.Repo.reload(match.team_a)
    team_b = VolleyKit.Repo.reload(match.team_b)

    if (team_a.points >= 25 or team_b.points >= 25) and abs(team_b.points - team_a.points) >= 2 do
      {winner, loser} =
        if team_a.points > team_b.points do
          {team_a, team_b}
        else
          {team_b, team_a}
        end

      socket =
        with {:ok, _} = Manager.update_team(winner, %{sets: winner.sets + 1, points: 0}),
             {:ok, _} = Manager.update_team(loser, %{points: 0}),
             match = VolleyKit.Repo.reload(match) do
          assign(socket, :match, VolleyKit.Repo.preload(match, [:team_a, :team_b]))
        end

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end
end
