defmodule VolleyWeb.MatchLive do
  use VolleyWeb, :live_view

  def mount(%{"id" => id}, _session, socket) do
    case Volley.get_match(id) do
      nil ->
        socket =
          socket
          |> put_flash(:error, "Flash with that ID does not exist!")
          |> push_navigate(to: ~p"/")

        {:ok, socket}

      match ->
        {:ok, assign(socket, :match, match)}
    end
  end

  def render(assigns) do
    ~H"""
    <span><%= @match.options.team_a_name %></span>
    <span><%= @match.options.team_b_name %></span>
    """
  end
end
