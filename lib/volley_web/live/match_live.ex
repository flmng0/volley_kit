defmodule VolleyWeb.MatchLive do
  use VolleyWeb, :live_view

  alias Volley.Schema.{Match, TeamSummary, Event}

  def mount(%{"sqid" => sqid}, _session, socket) do
    with {:ok, id} <- Volley.Sqids.decode(:match, sqid),
         %Match{} = match <- Volley.get_match(id) do
      {:ok, assign_match(socket, match)}
    else
      _ ->
        socket =
          socket
          |> put_flash(:error, "Match with ID \"#{sqid}\" does not exist!")
          |> push_navigate(to: ~p"/")

        {:ok, socket}
    end
  end

  attr :name, :string
  attr :summary, TeamSummary

  defp team_card(assigns) do
    ~H"""
    <div class="">
      <p>{@name}</p>
      <p>{@summary.score}</p>
      <p>{@summary.sets}</p>
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
