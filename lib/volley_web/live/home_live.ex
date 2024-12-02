defmodule VolleyWeb.HomeLive do
  use VolleyWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_event("test", _params, socket) do
    {:noreply, put_flash(socket, :info, "THis is a test")}
  end
end
