defmodule VolleyWeb.TournamentLive.View do
  use VolleyWeb, :live_view

  alias Volley.Tournaments
  alias VolleyWeb.TournamentLive.{OverviewView, TeamsView}

  defp views(),
    do: [
      %{
        action: :overview,
        route: &~p"/tournament/#{&1}/",
        title: "Overview",
        module: OverviewView
      },
      %{action: :teams, route: &~p"/tournament/#{&1}/teams", title: "Teams", module: TeamsView}
    ]

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app current_scope={@current_scope} flash={@flash}>
      <div class="grid lg:grid-cols-subgrid lg:col-span-2 gap-6">
        <ul class="menu bg-base-200 border border-base-300 shadow-sm menu-horizontal lg:menu-vertical lg:justify-self-end lg:self-start">
          <li class="menu-title">{@tournament.name}</li>
          <li :for={view <- views()} class={@live_action == view.action && "menu-active"}>
            <.link patch={view.route.(@tournament)}>{view.title}</.link>
          </li>
        </ul>

        <.live_component
          :for={view <- views()}
          :if={@live_action == view.action}
          id={Atom.to_string(view.action) <> "_view"}
          module={view.module}
          tournament={@tournament}
        />
      </div>
    </Layouts.app>
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
end
