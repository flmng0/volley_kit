defmodule VolleyWeb.TournamentLive.Teams do
  use VolleyWeb, :live_view
  on_mount VolleyWeb.TournamentLive.PutTournament

  alias Volley.Tournaments
  alias Volley.Tournaments.Team

  @impl true
  def mount(_params, _session, socket) do
    tournament = socket.assigns.tournament

    socket =
      socket
      |> stream(:teams, Tournaments.list_teams(socket.assigns.current_scope, tournament))
      |> assign(:delete, nil)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, params, socket.assigns.live_action)}
  end

  defp apply_action(socket, _params, :new) do
    assign(socket, :team, %Team{})
  end

  defp apply_action(socket, %{"team_id" => team_id}, :edit) do
    if team = Tournaments.get_team(socket.assigns.current_scope, team_id) do
      assign(socket, :team, team)
    else
      socket
      |> put_flash(:error, "Team with that ID was not found")
      |> push_patch(to: ~p"/tournaments/#{socket.assigns.tournament}/teams")
    end
  end

  defp apply_action(socket, _params, _action) do
    socket
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    if t = Tournaments.get_team(socket.assigns.current_scope, id) do
      {:noreply, assign(socket, :delete, t)}
    else
      socket
      |> put_flash(:error, "Team with that ID no longer exists")
      |> push_patch(to: ~p"/tournaments/#{socket.assigns.tournament}/teams")

      {:noreply, socket}
    end
  end

  def handle_event("confirm_delete", _params, socket) do
    {:ok, team} = Tournaments.delete_team(socket.assigns.current_scope, socket.assigns.delete)

    {:noreply, stream_delete(socket, :teams, team)}
  end

  def handle_event("cancel_delete", _params, socket) do
    {:noreply, assign(socket, :delete, nil)}
  end

  @impl true
  def handle_info({:submit_team, %Team{} = team}, socket) do
    IO.inspect(team)

    socket =
      socket
      |> stream_insert(:teams, team)
      |> push_patch(to: ~p"/tournaments/#{socket.assigns.tournament}/teams")

    {:noreply, socket}
  end
end
