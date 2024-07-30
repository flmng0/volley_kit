defmodule VolleyKitWeb.ScratchMatchLive do
  use VolleyKitWeb, :live_view

  alias VolleyKit.Manager
  alias VolleyKit.Manager.ScratchMatch

  def mount(_params, %{"user_id" => user_id} = _session, socket) do
    {:ok, assign(socket, user_id: user_id), layout: false}
  end

  def handle_params(%{"id" => id}, uri, socket) do
    %URI{query: query} = URI.parse(uri)

    match = Manager.get_scratch_match!(id)

    owner? = match.created_by == socket.assigns.user_id
    IO.puts("AM I NOT THE OWNER???????? #{owner?}")

    has_token? =
      with %{"token" => token} <- URI.decode_query(query || ""),
           {:ok, id} <- Manager.verify_scratch_match_token(token) do
        IO.puts("User has joined with valid scorer token")
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

    socket =
      socket
      |> assign(match: match, owner?: owner?, scorer?: scorer?)
      |> assign(view_code: Manager.share_code(match, :viewer))
      |> assign(score_code: Manager.share_code(match, :scorer))
      |> assign(showing_scorer_code: false)

    {:noreply, assign(socket, match: match, owner?: owner?, scorer?: scorer?)}
  end

  def handle_info(%{event: "score", payload: update_map}, %{assigns: %{match: match}} = socket) do
    {:noreply, assign(socket, match: Map.merge(match, update_map))}
  end

  def handle_event("score", %{"team" => team}, socket) do
    {:noreply, score(socket, socket.assigns.match, team)}
  end

  def handle_event("toggle_scorer_code", _params, socket) do
    %{score_code: score_code, showing_scorer_code: current, match: match} = socket.assigns

    score_code = if current, do: score_code, else: Manager.share_code(match, :scorer)

    {:noreply, assign(socket, score_code: score_code, showing_scorer_code: !current)}
  end

  def score(socket, %ScratchMatch{} = match, team) do
    {:ok, match} = Manager.score_scratch_match(match, team)

    assign(socket, match: match)
  end

  attr :content, :string
  attr :link?, :boolean, default: true
  attr :class, :string, default: nil

  attr :rest, :global

  def qr_code(assigns) do
    {:ok, qr_svg} =
      assigns.content
      |> QRCode.create(:medium)
      |> QRCode.render(:svg, %QRCode.Render.SvgSettings{scale: 6})

    assigns = assign(assigns, qr_svg: qr_svg)

    ~H"""
    <div class={["w-min h-min mx-auto p-8 bg-white", @class]} {@rest}>
      <%= raw(@qr_svg) %>
    </div>
    """
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
