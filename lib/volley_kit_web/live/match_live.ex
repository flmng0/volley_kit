defmodule VolleyKitWeb.MatchLive do
  alias VolleyKit.Policy
  use VolleyKitWeb, :live_view

  alias VolleyKitWeb.MatchLive.ScoreCard

  alias VolleyKit.Manager

  @impl true
  def mount(_params, %{"user_id" => user_id}, socket) do
    {:ok, assign(socket, :user_id, user_id)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(params, socket.assigns.live_action, socket)}
  end

  def apply_action(_params, :current, socket) do
    case Manager.get_owned_match(socket.assigns.user_id) do
      nil ->
        socket
        |> put_flash(:error, "Could not find current match!")
        |> push_navigate(to: ~p"/")

      match ->
        apply_match(match, true, socket)
    end
  end

  def apply_action(%{"code" => code}, :code, socket) do
    case Manager.get_shared_match(code) do
      nil ->
        socket
        |> put_flash(:error, "Could not find match with given code!")
        |> push_navigate(to: ~p"/")

      match ->
        can_score = Policy.authorize?(:match_score, code, match)
        # is_owner = match.owner == Ecto.UUID.cast!(socket.assigns.user_id)
        apply_match(match, can_score, socket)
    end
  end

  def apply_match(%Manager.Match{} = match, is_owner, socket) do
    if Map.get(socket.assigns, :match) do
      VolleyKitWeb.Endpoint.unsubscribe("match:#{socket.assigns.match.id}")
    end

    VolleyKitWeb.Endpoint.subscribe("match:#{match.id}")
    
    socket
    |> assign(:page_title, "#{match.team_a.name} vs. #{match.team_b.name}")
    |> assign(:match, match)
    |> assign(:is_owner, is_owner)
  end

  @impl true
  def handle_event(event, params, socket) do
    if socket.assigns.is_owner do
      apply_event(event, params, socket)
    else
      socket =
        put_flash(socket, :error, "You are not the owner of this match. Action not allowed.")

      {:noreply, socket}
    end
  end

  def apply_event("reset", _params, socket) do
    match = socket.assigns.match

    case Manager.update_match(match, %{
           "team_a" => %{points: 0, sets: 0},
           "team_b" => %{points: 0, sets: 0}
         }) do
      {:ok, match} ->
        VolleyKitWeb.Endpoint.broadcast!("match:#{match.id}", "reset", nil)

        {:noreply, assign(socket, :match, match)}
    end
  end

  @impl true
  def handle_info({ScoreCard, {:increment, variant, points}}, socket) do
    match = socket.assigns.match

    VolleyKitWeb.Endpoint.broadcast!("match:#{match.id}", "point", variant)

    other_points =
      case variant do
        :a ->
          match.team_b.points

        :b ->
          match.team_a.points
      end

    if points >= 25 and abs(points - other_points) >= 2 do
      {winner, loser} =
        case variant do
          :a ->
            {match.team_a, match.team_b}

          :b ->
            {match.team_b, match.team_a}
        end

      {:ok, _} = Manager.update_team(winner, %{sets: winner.sets + 1, points: 0})
      {:ok, _} = Manager.update_team(loser, %{points: 0})

      VolleyKitWeb.Endpoint.broadcast!("match:#{match.id}", "set_change", nil)
    end

    {:noreply, socket}
  end

  def handle_info(%Phoenix.Socket.Broadcast{} = msg, socket) do
    case msg.event do
      event when event in ["reset", "set_change"] ->
        socket = update(socket, :match, &Manager.reload_match(&1))

        {:noreply, socket}

      "point" ->
        variant = msg.payload

        socket =
          update(socket, :match, fn match ->
            case variant do
              :a ->
                %{match | team_a: VolleyKit.Repo.reload(match.team_a)}

              :b ->
                %{match | team_b: VolleyKit.Repo.reload(match.team_b)}
            end
          end)

        {:noreply, socket}
    end
  end

  def share_code_qr(match) do
    share_code = Manager.get_share_code(match)
    share_url = VolleyKitWeb.Endpoint.struct_url()
      |> URI.append_path(~p"/#{share_code}")
      |> URI.to_string()

    {:ok, qr_svg} = QRCode.create(share_url)
      |> QRCode.render()

    raw(qr_svg)
  end
end
