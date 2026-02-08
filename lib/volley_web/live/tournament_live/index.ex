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
          <.button variant="create" phx-click="create_new">Create New Tournament</.button>
        </:actions>
      </.header>

      <ul id="tournaments_list" phx-update="stream" class="peer list">
        <li :if={assigns[:new_form]} id="new_tournament_item">
          <.inline_tournament_form form={@new_form} />
        </li>
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

  attr :form, :map, required: true

  defp inline_tournament_form(assigns) do
    ~H"""
    <.form
      :let={f}
      for={@form}
      class="list-row"
      phx-change="validate_new"
      phx-submit="submit_new"
      phx-mounted={JS.focus(to: {:inner, "input"})}
    >
      <div class="list-col-grow">
        <.input field={f[:name]} type="text" placeholder="Tournament Name" />
      </div>

      <.button variant="create" class="mb-2 mt-1"><.icon name="hero-check" /></.button>

      <input
        type="hidden"
        phx-update="ignore"
        name={f[:timezone].name}
        id={f[:timezone].id}
        phx-hook=".AutofillTimezone"
      />
    </.form>
    <script :type={Phoenix.LiveView.ColocatedHook} name=".AutofillTimezone">
      export default {
        mounted() {
          const format = Intl.DateTimeFormat();
          const options = format.resolvedOptions();
          this.el.value = options.timeZone;
        }
      }
    </script>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    tournaments = Volley.Tournaments.list_tournaments(socket.assigns.current_scope)

    {:ok, stream(socket, :tournaments, tournaments)}
  end

  @impl true
  def handle_event("create_new", _params, socket) do
    {:noreply, assign_new_form(socket)}
  end

  def handle_event("validate_new", %{"tournament" => params}, socket) do
    {:noreply, assign_new_form(socket, params, action: :validate)}
  end

  def handle_event("submit_new", %{"tournament" => params}, socket) do
    case Tournaments.create_tournament_draft(socket.assigns.current_scope, params) do
      {:ok, tournament} ->
        socket =
          socket
          |> stream_insert(:tournaments, tournament)
          |> assign(:tournaments_empty?, false)
          |> assign(:new_form, nil)
          # Janky workaround for deleting the inline item
          |> stream_delete_by_dom_id(:tournaments, "new_tournament_item")

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

  defp assign_new_form(socket, params \\ %{}, opts \\ []) do
    data = %{}
    types = %{name: :string, timezone: :string}

    changeset = Tournaments.Tournament.create_changeset({data, types}, params)
    form = to_form(changeset, opts ++ [as: "tournament"])

    assign(socket, :new_form, form)
  end
end
