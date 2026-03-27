defmodule VolleyWeb.MatchLive.Index do
  use VolleyWeb, :live_view

  alias Volley.Scoring

  @impl true
  def mount(_params, _session, socket) do
    matches = Scoring.list_matches(socket.assigns.current_scope)

    {:ok, assign(socket, matches: matches, delete: nil)}
  end

  defp create_button(assigns) do
    ~H"""
    <.button variant="create" navigate={~p"/match/create?return_to=/match"}>Create A Match</.button>
    """
  end

  defp no_matches_display(assigns) do
    ~H"""
    <div class="text-center">
      <p class="mb-4">You have no matches yet!</p>
      <p class="mb-8">Create one now with the button below.</p>
      <.create_button />
    </div>
    """
  end

  attr :match, Match

  defp delete_modal(assigns) do
    ~H"""
    <.modal auto_open id="deleteConfirmation" close={JS.push("cancel_delete")}>
      <.header header_tag="h3">
        Are you sure?
        <:subtitle>
          Are you want to delete your match between {@match.settings.a_name} and {@match.settings.b_name}?
        </:subtitle>
      </.header>
      <:action>
        <.button type="dialog">Cancel</.button>
        <.button variant="delete" phx-click="confirm_delete">
          Yes, Delete My Match
        </.button>
      </:action>
    </.modal>
    """
  end

  defp match_list(assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <div class="flex justify-between flex-wrap gap-2">
        <span class="font-semibold">Your Matches</span>
        <.create_button />
      </div>
      <ul class="flex flex-col gap-4">
        <li
          :for={match <- @matches}
          class="border border-base-300 bg-base-200 rounded-lg p-4"
        >
          <aside class="flex justify-end">
            <span class={["badge", match.status == :in_progress && "badge-info"]}>In progress</span>
          </aside>
          <main class="grid grid-cols-[1fr_auto_1fr] gap-x-2 pt-2">
            <span class="text-lg text-center tracking-wide">{match.settings.a_name}</span>
            <span class="text-base-content/50">vs.</span>
            <span class="text-lg text-center tracking-wide">{match.settings.b_name}</span>
          </main>
          <div class="divider my-4"></div>
          <footer class="flex items-center px-2 border-base-content/25 text-sm">
            <div class="flex-grow grid grid-cols-[auto_1fr] gap-x-2">
              <span class="text-base-content/50 justify-self-end">Status:</span>
              <span>In Progress</span>

              <span class="text-base-content/50 justify-self-end">Last Updated:</span>
              <span
                phx-hook="LocalTimeDisplay"
                data-time={match.updated_at}
                id={"matchUpdated#{match.id}"}
              />
            </div>

            <div class="flex gap-2 items-center">
              <.button variant="neutral" navigate={~p"/match/#{match}/score"}>
                Score Match
              </.button>
              <.button
                variant="delete"
                class="btn-square btn-sm"
                phx-click="delete_match"
                phx-value-id={match.id}
              >
                <.icon name="hero-trash" class="size-4" />
              </.button>
            </div>
          </footer>
        </li>
      </ul>
    </div>
    """
  end

  @impl true
  def handle_event("delete_match", %{"id" => id}, socket) do
    to_delete =
      Enum.find(socket.assigns.matches, fn match ->
        "#{match.id}" == id
      end)

    {:noreply, assign(socket, :delete, to_delete)}
  end

  def handle_event("cancel_delete", _params, socket) do
    {:noreply, assign(socket, :delete, nil)}
  end

  def handle_event("confirm_delete", _params, socket) do
    {:ok, _match} = Scoring.delete_match(socket.assigns.current_scope, socket.assigns.delete)
    matches = List.delete(socket.assigns.matches, socket.assigns.delete)

    socket =
      socket
      |> assign(:matches, matches)
      |> put_flash(:info, "Delete Match Successfully")

    {:noreply, socket}
  end
end
