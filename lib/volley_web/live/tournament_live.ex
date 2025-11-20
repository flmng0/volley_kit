defmodule VolleyWeb.TournamentLive do
  use VolleyWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div> </div>
    """
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    IO.inspect(_params)
    {:noreply, socket}
  end
end
