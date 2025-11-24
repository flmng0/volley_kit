defmodule VolleyWeb.TournamentLive.Index do
  use VolleyWeb, :live_view

  alias Volley.Tournaments

  @impl true
  def mount(_params, _session, socket) do
    tournaments = Tournaments.list_tournaments(socket.assigns.current_scope)

    if Enum.empty?(tournaments) do
      {:ok, push_navigate(socket, to: ~p"/tournaments/setup")}
    else
      {:ok, stream(socket, :tournaments, tournaments)}
    end
  end

  attr :tournament, Tournaments.Tournament

  defp tournament_card(assigns) do
    ~H"""
    <div class="card bg-base-200">
      <div class="card-body">
        <span class="card-title">{@tournament.name}</span>

        <div class="card-actions justify-end">
          <.button variant="primary" navigate={~p"/tournaments/#{@tournament}"}>
            View
          </.button>
        </div>
      </div>
    </div>
    """
  end
end
