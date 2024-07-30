defmodule VolleyKitWeb.ScratchMatchLive do
  use VolleyKitWeb, :live_view

  alias VolleyKit.Manager
  alias VolleyKit.Manager.ScratchMatch

  def mount(_params, %{"user_id" => user_id} = _session, socket) do
    {:ok, assign(socket, user_id: user_id), layout: false}
  end

  def handle_params(%{"id" => id}, uri, socket) do
    case Manager.get_scratch_match(id) do
      nil ->
        socket =
          socket
          |> put_flash(:error, "Match with ID #{id} was not found")
          |> push_navigate(to: ~p"/")

        {:noreply, socket}

      match ->
        {:noreply, apply_match(match, uri, socket)}
    end
  end

  def apply_match(%ScratchMatch{} = match, uri, socket) do
    %URI{query: query} = URI.parse(uri)

    owner? = match.created_by == socket.assigns.user_id

    has_token? =
      with %{"token" => token} <- URI.decode_query(query || ""),
           {:ok, id} <- Manager.verify_scratch_match_token(token) do
        match.id == id
      else
        _ -> false
      end

    scorer? = owner? || has_token?

    if connected?(socket) do
      if old_match = socket.assigns[:match] do
        Manager.unsubscribe_scratch_match(old_match)
      end

      Manager.subscribe_scratch_match(match)
    end

    socket
    |> assign(match: match, owner?: owner?, scorer?: scorer?)
    |> assign(view_code: Manager.share_code(match, :viewer))
    |> assign(score_code: Manager.share_code(match, :scorer))
    |> assign(show_score_code?: false)
  end

  def handle_info(%{event: "score", payload: update_map}, %{assigns: %{match: match}} = socket) do
    {:noreply, assign(socket, match: Map.merge(match, update_map))}
  end

  def handle_event("score", %{"team" => team}, socket) do
    {:noreply, score(socket, socket.assigns.match, team)}
  end

  def handle_event("toggle_scorer_code", _params, socket) do
    %{score_code: score_code, show_score_code?: current, match: match} = socket.assigns

    score_code = if current, do: score_code, else: Manager.share_code(match, :scorer)

    {:noreply, assign(socket, score_code: score_code, show_score_code?: !current)}
  end

  def score(socket, %ScratchMatch{} = match, team) do
    {:ok, match} = Manager.score_scratch_match(match, team)

    assign(socket, match: match)
  end

  attr :team_name, :string
  attr :score, :integer
  attr :sets, :integer

  attr :class, :string, default: nil

  defp score_card(assigns) do
    ~H"""
    <div class={[
      "w-full h-full md:aspect-square text-center outline text-white flex flex-col justify-center gap-4",
      @class
    ]}>
      <span class="text-[1.25em]">
        <%= @sets %>
      </span>
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
