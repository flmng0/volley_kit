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

    token = Manager.sign_scratch_match_token(match)

    socket
    |> assign(match: match, owner?: owner?, scorer?: scorer?)
    |> assign(view_code: Manager.scratch_match_view_code(match))
    |> assign(set_finishing?: false)
    |> assign_score_token(token, match)
  end

  def assign_score_token(socket, token, match) do
    assign(socket, score_token: token, score_code: Manager.scratch_match_score_code(match, token))
  end

  def handle_info(%{event: "score", payload: update_map}, %{assigns: %{match: match}} = socket) do
    match = Map.merge(match, update_map)

    socket =
      if socket.assigns.set_finishing? do
        put_flash(socket, :info, "Cancelled prompt because somebody else scored")
      else
        socket
      end

    socket = assign(socket, match: match, set_finishing?: false)

    {:noreply, socket}
  end

  def handle_info(%{event: "set_won", payload: winner}, socket) do
    {:noreply, assign(socket, set_finishing?: false, winner: winner)}
  end

  def handle_event("score", %{"team" => team}, socket) do
    %{match: match} = socket.assigns

    if Manager.would_complete_set?(match, team) do
      {:noreply, assign(socket, set_finishing?: true)}
    else
      {:ok, match} = Manager.score_scratch_match(match, team)
      {:noreply, assign(socket, match: match)}
    end
  end

  def handle_event("retract", %{"team" => team}, socket) do
    %{match: match} = socket.assigns

    {:ok, match} = Manager.score_scratch_match(match, team, :retract)
    {:noreply, assign(socket, match: match)}
  end

  def handle_event("put_copy_flash", _params, socket) do
    {:noreply, put_flash(socket, :success, "Copied")}
  end

  def handle_event("cancel_set_finish", _params, socket) do
    {:noreply, assign(socket, set_finishing?: false)}
  end

  def handle_event("next_set", _params, socket) do
    {:ok, match} = Manager.next_set(socket.assigns.match)

    {:noreply, assign(socket, match: match, set_finishing?: false)}
  end

  def handle_event("maybe_refresh_score_code", _params, socket) do
    %{score_token: token, match: match} = socket.assigns

    id = match.id

    case Manager.verify_scratch_match_token(token) do
      {:ok, ^id} ->
        {:noreply, socket}

      {:error, :expired} ->
        token = Manager.sign_scratch_match_token(match)

        {:noreply, assign_score_token(socket, token, match)}

      _ ->
        {:noreply, put_flash(socket, :error, "Unable to refresh scorer token!")}
    end
  end

  attr :scorer?, :boolean
  attr :team, :string, values: ~w(a b)
  attr :match, ScratchMatch
  # attr :team_name, :string
  # attr :score, :integer
  # attr :sets, :integer
  # attr :id, :string

  # attr :class, :string, default: nil

  defp score_card(%{team: team, match: match} = assigns) do
    {sets, score, team_name} =
      case team do
        "a" ->
          {match.a_sets, match.a_score, match.options.a_name}

        "b" ->
          {match.b_sets, match.b_score, match.options.b_name}
      end

    assigns = assign(assigns, sets: sets, score: score, team_name: team_name)

    ~H"""
    <.dynamic_tag
      name={if @scorer?, do: "a", else: "div"}
      phx-click={@scorer? && "score"}
      phx-value-team={@team}
      role={@scorer? && "button"}
      class={[
        "block select-none w-full h-full md:aspect-square text-center outline text-white flex flex-col justify-center gap-4",
        "bg-" <> @team
      ]}
    >
      <span class="text-[1.25em]">
        <%= @sets %>
      </span>
      <span class="text-[2.5em]">
        <%= @score %>
      </span>
      <span class="text-[1em]">
        <%= @team_name %>
      </span>
      <div :if={@scorer?} class="flex flex-row justify-center gap-2">
        <.button
          colors="hover:backdrop-brightness-90 backdrop-brightness-95"
          phx-click="retract"
          phx-value-team={@team}
        >
          <.icon name="hero-minus-mini" />
        </.button>
      </div>
    </.dynamic_tag>
    """
  end

  attr :id, :string, required: true
  attr :href, :string, required: true
  attr :label, :string, required: true

  defp copy_link_button(assigns) do
    ~H"""
    <.button
      class="block mx-auto outline outline-1"
      colors="bg-zinc-300 hover:bg-zinc-400 text-gray-800 active:text-white/80"
      phx-click={JS.dispatch("vk:clipcopy") |> JS.push("put_copy_flash")}
      data-href={@href}
    >
      <.icon name="hero-link-micro" />
      <%= @label %>
    </.button>
    """
  end
end
