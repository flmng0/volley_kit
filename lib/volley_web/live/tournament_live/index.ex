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
          <.create_tournament_button />
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
    </Layouts.app>
    """
  end

  defp create_tournament_button(assigns) do
    ~H"""
    <form phx-submit="create_new">
      <.button variant="create">Create New Tournament</.button>
      <input
        type="hidden"
        name="tournament[timezone]"
        id="timezone_input"
        phx-hook="AutofillTimezone"
      />
    </form>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    tournaments = Volley.Tournaments.list_tournaments(socket.assigns.current_scope)

    {:ok, stream(socket, :tournaments, tournaments)}
  end

  @impl true
  def handle_event("create_new", %{"tournament" => params}, socket) do
    case Tournaments.create_tournament_draft(socket.assigns.current_scope, params) do
      {:ok, tournament} ->
        socket =
          socket
          |> put_flash(:info, "Successfully created new tournament!")
          |> push_navigate(to: ~p"/tournament/#{tournament}")

        {:noreply, socket}

      {:error, _changeset} ->
        socket =
          socket
          |> put_flash(:error, "Failed to create tournament!")
          |> push_navigate(to: ~p"/tournament/")

        {:noreply, socket}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    if t = Tournaments.get_tournament(socket.assigns.current_scope, id) do
      {:ok, t} = Tournaments.delete_tournament(socket.assigns.current_scope, t)

      {:noreply, stream_delete(socket, :tournaments, t)}
    else
      socket =
        socket
        |> put_flash(:error, "Requested tournament no longer exists!")
        |> push_navigate(to: ~p"/tournament/")

      {:noreply, socket}
    end
  end
end
