defmodule VolleyWeb.TournamentLive.Show do
  use VolleyWeb, :live_view

  alias Volley.Tournaments

  embed_templates "show/*"

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if tournament = Tournaments.get_tournament(socket.assigns.current_scope, id) do
      socket =
        socket
        |> assign(:tournament, tournament)

      {:ok, socket}
    else
      socket =
        socket
        |> put_flash(:error, "Tournament does not exist")
        |> push_navigate(to: ~p"/tournaments")

      {:ok, socket}
    end
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  attr :live_action, :atom
  attr :tournament, Tournaments.Tournament
  attr :editing, :boolean

  def view(assigns) do
    {live_action, assigns} = Map.pop(assigns, :live_action)

    apply(__MODULE__, live_action, [assigns])
  end

  attr :action, :atom
  attr :live_action, :atom

  attr :name, :string
  attr :patch, :string

  def menu_item(assigns) do
    ~H"""
    <li class={@live_action == @action && "menu-active"}>
      <.link patch={@patch} aria-current={@live_action == @action && "page"}>
        {@name}
      </.link>
    </li>
    """
  end
end
