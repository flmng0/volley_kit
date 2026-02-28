defmodule VolleyWeb.TournamentLive.Teams do
  use VolleyWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.tournament_view
      current_scope={@current_scope}
      flash={@flash}
      tournament={@tournament}
      view={__MODULE__}
    >
    </Layouts.tournament_view>
    """
  end
end
