defmodule VolleyWeb.ScratchMatchLive do
  use VolleyWeb, :live_view
  import VolleyWeb.MatchComponents

  def render(assigns) do
    ~H"""
    <Layouts.app current_scope={@current_scope} flash={@flash}>
      <.score_card score={0} team={:a} />
      <.score_card score={0} team={:b} />
    </Layouts.app>
    """
  end
end
