defmodule VolleyWeb.MatchLive do
  use VolleyWeb, :live_view

  alias Volley.Schema.{Match, TeamSummary, Event}

  def mount(%{"id" => id}, _session, socket) do
    case Volley.get_match(id) do
      nil ->
        socket =
          socket
          |> put_flash(:error, "Flash with that ID does not exist!")
          |> push_navigate(to: ~p"/")

        {:ok, socket}

      match ->
        {:ok, assign_match(socket, match)}
    end
  end

  attr :name, :string
  attr :summary, TeamSummary

  defp team_card(assigns) do
    ~H"""
    <div class="">
      <p><%= @name %></p>
      <p><%= @summary.score %></p>
      <p><%= @summary.sets %></p>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <.team_card name={@match.options.team_a_name} summary={@match.team_a_summary} />
    <.team_card name={@match.options.team_b_name} summary={@match.team_b_summary} />
    """
  end

  def handle_info(%Event{} = event, socket) do
    {:noreply, assign_match(socket, event.match)}
  end

  defp assign_match(socket, %Match{} = match) do
    if socket.assigns[:match] do
      Volley.unsubscribe_events(socket.assigns.match)
    end

    Volley.subscribe_events(match)

    assign(socket, :match, match)
  end
end
