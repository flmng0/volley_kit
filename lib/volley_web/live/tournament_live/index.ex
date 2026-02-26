defmodule VolleyWeb.TournamentLive.Index do
  use VolleyWeb, :live_view

  alias Volley.Tournaments

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app current_scope={@current_scope} flash={@flash}>
      <.header>
        Tournaments
        <:actions>
          <.button navigate={~p"/tournament/setup"} variant="create">Create New Tournament</.button>
        </:actions>
      </.header>

      <ul id="tournaments_list" phx-update="stream" class="peer list">
        <li
          :for={{id, tournament} <- @streams.tournaments}
          id={id}
          class="list-row items-center"
        >
          <div class="list-col-grow">
            <span class={[tournament.name == nil && "italic"]}>
              {tournament.name || "Unnamed Tournament"}
            </span>
          </div>
          <.button
            variant="delete"
            aria-title="Delete Tournament"
            phx-click="delete"
            phx-value-id={tournament.id}
          >
            <.icon name="hero-trash" />
          </.button>
          <.button
            variant="neutral"
            aria-title="Edit Tournament"
            phx-click={JS.navigate(~p"/tournament/#{tournament}")}
          >
            <.icon name="hero-pencil" />
          </.button>
        </li>
      </ul>

      <div class="hidden peer-empty:block">
        <p class="text-center">You currently have no tournaments.</p>
      </div>

      <.modal :if={@delete} id="delete_confirm" auto_open={true} close={JS.push("cancel_delete")}>
        <.header>Are you sure?</.header>
        <p>Are you sure you want to delete the tournament {@delete.name}?</p>

        <:action>
          <.button variant="delete" phx-click="confirm_delete">Yes</.button>
          <.button>No</.button>
        </:action>
      </.modal>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    tournaments = Volley.Tournaments.list_tournaments(socket.assigns.current_scope)

    socket =
      socket
      |> assign(:delete, nil)
      |> stream(:tournaments, tournaments)

    {:ok, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    if t = Tournaments.get_tournament(socket.assigns.current_scope, id) do
      {:noreply, assign(socket, :delete, t)}
    else
      socket =
        socket
        |> put_flash(:error, "Requested tournament no longer exists!")
        |> push_navigate(to: ~p"/tournament/")

      {:noreply, socket}
    end
  end

  def handle_event("confirm_delete", _params, socket) do
    {:ok, tournament} =
      Tournaments.delete_tournament(socket.assigns.current_scope, socket.assigns.delete)

    {:noreply, stream_delete(socket, :tournaments, tournament)}
  end

  def handle_event("cancel_delete", _params, socket) do
    {:noreply, assign(socket, :delete, nil)}
  end
end
