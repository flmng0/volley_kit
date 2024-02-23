defmodule VolleyKitWeb.HomeLive do
  use VolleyKitWeb, :live_view

  alias VolleyKitWeb.HomeLive.NewMatchForm

  alias VolleyKit.Manager

  @impl true
  def mount(_params, %{"user_id" => user_id}, socket) do
    owned_match = Manager.get_owned_match(user_id)

    socket =
      socket
      |> assign(:page_title, "Home")
      |> assign(:user_id, user_id)
      |> assign(:owned_match, owned_match)

    {:ok, socket}
  end

  @impl true
  def handle_event("delete-current", _params, socket) do
    match = Manager.delete_match!(socket.assigns.owned_match)
    match_name = "#{match.team_a.name} vs. #{match.team_b.name}"

    {:noreply,
     socket
     |> put_flash(:info, "Successfully deleted match: #{match_name}")
     |> assign(:owned_match, nil)}
  end
end
