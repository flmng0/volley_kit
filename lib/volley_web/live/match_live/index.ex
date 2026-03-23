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
      <ul>
        <li :for={match <- @matches}>{match.settings.a_name} vs. {match.settings.b_name}</li>
      </ul>
    </div>
    """
  end
end
