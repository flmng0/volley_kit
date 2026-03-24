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
          class="grid grid-cols-[1fr_auto_1fr] border border-base-300 bg-base-200 rounded-lg p-4 gap-x-2"
        >
          <span class="text-center tracking-wide">{match.settings.a_name}</span>
          <span class="text-base-content/50">vs.</span>
          <span class="text-center tracking-wide">{match.settings.b_name}</span>

          <footer class="grid grid-cols-[auto_1fr_auto] items-center col-span-3 border-t mt-4 pt-4 border-base-content/25 text-sm">
            <span class="text-base-content/50 me-2">Last Updated:</span>
            <span
              phx-hook="LocalTimeDisplay"
              data-time={match.updated_at}
              id={"matchUpdated#{match.id}"}
            />
            <.link class="link" navigate={~p"/match/#{match}/score"}>Open Match</.link>
          </footer>
        </li>
      </ul>
    </div>
    """
  end
end
