defmodule VolleyKitWeb.ScratchMatchLive do
  use VolleyKitWeb, :live_view

  alias VolleyKit.Manager
  alias VolleyKit.Manager.ScratchMatch

  def mount(_params, %{"user_id" => user_id} = _session, socket) do
    {:ok, assign(socket, user_id: user_id), layout: false}
  end

  def handle_params(%{"id" => id} = _params, _uri, socket) do
    match = Manager.get_scratch_match!(id)
    scorer? = match.created_by == socket.assigns.user_id

    if connected?(socket) do
      if old_match = socket.assigns[:match] do
        Manager.unsubscribe_scratch_match(old_match)
      end

      Manager.subscribe_scratch_match(match)
    end

    {:noreply, assign(socket, match: match, scorer?: scorer?)}
  end

  def handle_info(%{event: "score", payload: update_map}, %{assigns: %{match: match}} = socket) do
    {:noreply, assign(socket, match: Map.merge(match, update_map))}
  end

  def handle_event("score", %{"team" => team}, socket) do
    {:noreply, score(socket, socket.assigns.match, team)}
  end

  def score(socket, %ScratchMatch{} = match, team) do
    {:ok, match} = Manager.score_scratch_match(match, team)

    assign(socket, match: match)
  end

  attr :team_name, :string
  attr :score, :integer

  attr :class, :string, default: nil

  defp score_card(assigns) do
    ~H"""
    <div class={[
      "w-full h-full md:aspect-square text-center outline text-white flex flex-col justify-center gap-4",
      @class
    ]}>
      <span class="text-[2.5em]">
        <%= @score %>
      </span>
      <span class="text-[1em]">
        <%= @team_name %>
      </span>
    </div>
    """
  end

  attr :scorer?, :boolean
  attr :team, :string, values: ~w(a b)

  slot :inner_block, required: true

  defp wrapper(assigns) do
    ~H"""
    <%= if @scorer? do %>
      <button phx-click="score" phx-value-team={@team} class="unset-all">
        <%= render_slot(@inner_block) %>
      </button>
    <% else %>
      <%= render_slot(@inner_block) %>
    <% end %>
    """
  end
end
