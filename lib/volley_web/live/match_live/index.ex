defmodule VolleyWeb.MatchLive.Index do
  use VolleyWeb, :live_view

  alias Volley.Scoring

  @impl true
  def mount(_params, _session, socket) do
    matches = Scoring.list_matches(socket.assigns.current_scope)

    {:ok, assign(socket, :matches, matches)}
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
          <main class="grid grid-cols-[1fr_auto_1fr] gap-x-2 pt-2">
            <span class="text-lg text-center tracking-wide">{match.settings.a_name}</span>
            <span class="text-base-content/50">vs.</span>
            <span class="text-lg text-center tracking-wide">{match.settings.b_name}</span>
          </main>
          <div class="divider my-4"></div>
          <footer class="grid grid-cols-[auto_1fr_auto] items-center px-2 border-base-content/25 text-sm">
            <span class="text-base-content/50 me-2">Last Updated:</span>
            <span
              phx-hook="LocalTimeDisplay"
              data-time={match.updated_at}
              id={"matchUpdated#{match.id}"}
            />
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
    find_fn = fn match -> "#{match.id}" == id end

    if match = Enum.find(socket.assigns.matches, find_fn) do
      {:ok, _match} = Scoring.delete_match(socket.assigns.current_scope, match)
      matches = Enum.reject(socket.assigns.matches, find_fn)

      socket =
        socket
        |> assign(:matches, matches)
        |> put_flash(:info, "Delete Match Successfully")

      {:noreply, socket}
    else
      {:noreply, put_flash(socket, :error, "Match Not Found!")}
    end
  end
end
