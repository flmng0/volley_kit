defmodule VolleyWeb.TournamentLive.Show do
  use VolleyWeb, :live_view

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, params, socket.assigns.live_action)}
  end

  defp apply_action(socket, _params, :new) do
    socket
  end

  defp apply_action(socket, %{"id" => id}, :view) do
    socket
  end
end
