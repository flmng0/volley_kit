defmodule VolleyWeb.TournamentLive.Setup do
  use VolleyWeb, :live_view

  alias Volley.Tournaments.Tournament

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:tournament, %Tournament{divisions: []})
      |> assign(:completed_steps, [])

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    if socket.assigns.live_action != :details && socket.assigns.completed_steps == [] do
      {:noreply, push_patch(socket, to: ~p"/tournaments/setup/details", replace: true)}
    else
      {:noreply, apply_action(socket, socket.assigns.live_action)}
    end
  end

  defp apply_action(socket, :details) do
    assign(socket, :valid_time_zones, VolleyWeb.Util.collect_timezone_options())
  end

  defp apply_action(socket, _action), do: socket

  @impl true
  def handle_info({:submit_step, tournament}, socket) do
    socket =
      socket
      |> assign(:tournament, tournament)
      |> apply_next(socket.assigns.live_action)

    {:noreply, socket}
  end

  defp apply_next(socket, :registration) do
    tournament =
      Volley.Tournaments.complete_tournament_setup!(
        socket.assigns.current_scope,
        socket.assigns.tournament
      )

    push_navigate(socket, to: ~p"/tournaments/#{tournament}")
  end

  defp apply_next(socket, action) do
    socket
    |> update(:completed_steps, &(&1 ++ [action]))
    |> push_patch(to: next_route(action))
  end

  defp next_route(:details), do: ~p"/tournaments/setup/divisions"
  defp next_route(:divisions), do: ~p"/tournaments/setup/registration"
end
