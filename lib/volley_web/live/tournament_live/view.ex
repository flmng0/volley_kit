defmodule VolleyWeb.TournamentLive.View do
  use VolleyWeb, :live_view

  alias Volley.Tournaments
  alias VolleyWeb.TournamentLive.{OverviewView, TeamsView}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.tabbed current_scope={@current_scope} flash={@flash} title={@tournament.name}>
      <:tab name="Overview" link={~p"/tournament/#{@tournament}"} active={@live_action == :overview}>
        <.live_component id="overview_view" module={OverviewView} tournament={@tournament} />
      </:tab>
      <:tab
        name="Teams"
        link={~p"/tournament/#{@tournament}/teams"}
        active={@live_action == :teams}
        warning={@tournament.divisions == [] && "No divisions have been setup"}
      >
        <.live_component id="teams_view" module={TeamsView} tournament={@tournament} />
      </:tab>
    </Layouts.tabbed>
    """
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    cond do
      socket.assigns[:tournament] && socket.assigns.tournament == id ->
        {:noreply, socket}

      tournament = Tournaments.get_tournament(socket.assigns.current_scope, id) ->
        {:noreply, assign(socket, :tournament, tournament)}

      true ->
        redirect = if socket.assigns.current_scope, do: ~p"/tournament/", else: ~p"/"

        socket =
          socket
          |> put_flash(:error, "Tournament with that ID does not exist, or you can't access it")
          |> push_navigate(redirect)

        {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:update_tournament, %Ecto.Changeset{} = changeset}, socket) do
    tournament = Volley.Repo.update!(changeset)

    {:noreply, assign(socket, :tournament, tournament)}
  end
end
