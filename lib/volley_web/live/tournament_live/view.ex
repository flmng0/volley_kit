defmodule VolleyWeb.TournamentLive.View do
  use VolleyWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app current_scope={@current_scope} flash={@flash}>
      <ul class="menu">
        <li>Test</li>
      </ul>
    </Layouts.app>
    """
  end
end
