defmodule VolleyKitWeb.MatchLive do
  use VolleyKitWeb, :live_view

  alias VolleyKitWeb.MatchLive.ScoreCard

  alias VolleyKit.Manager

  @impl true
  def mount(%{"id" => id}, %{ "user_id" => user_id }, socket) do
    VolleyKitWeb.Endpoint.subscribe("match:#{id}")

    match = Manager.get_match!(id)

    is_owner = Ecto.UUID.equal?(Ecto.UUID.dump!(match.owner), user_id)
    
    socket =
      socket
      |> assign(:page_title, "Showing Match")
      |> assign(:match, match)
      |> assign(:is_owner, is_owner)

    {:ok, socket}
  end

  @impl true
  def handle_event("reset", _params, socket) do
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
end
