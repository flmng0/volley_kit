defmodule VolleyWeb.ScratchMatchLive do
  use VolleyWeb, :live_view

  import VolleyWeb.MatchComponents
  alias Volley.Scoring
  alias Volley.Scoring.Match

  require Integer

  @impl true
  def handle_params(%{"id" => match_id}, _uri, socket) do
    if match = Scoring.get_match_by_public_id(socket.assigns.current_scope, match_id) do
      scorer? = Scoring.can_score_match?(socket.assigns.current_scope, match)

      {:noreply, assign_new_match(socket, match, scorer?)}
    else
      socket =
        socket
        |> put_flash(:error, "Match with saved ID no longer exists")
        |> redirect(to: ~p"/")

      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:update, %Match{} = match}, socket) do
    if match.id == socket.assigns.match.id do
      {:noreply, assign_match(socket, match)}
    else
      {:noreply, socket}
    end
  end

  def handle_info({:submit_settings, settings}, socket) do
    {:ok, match} =
      Scoring.update_match_settings(socket.assigns.current_scope, socket.assigns.match, settings)

    socket =
      socket
      |> assign(:editing?, false)
      |> assign_match(match, true)
      |> push_patch(to: ~p"/scratch/#{match}")

    {:noreply, socket}
  end

  @impl true
  def handle_event("score", %{"team" => team}, socket) do
    if socket.assigns.winning_team in [:a, :b] do
      socket = assign_match(socket, socket.assigns.match, true)
      {:reply, %{wait: true}, socket}
    else
      {:ok, match} = Scoring.score_match(socket.assigns.current_scope, socket.assigns.match, team)
      socket = assign_match(socket, match)

      wait = Match.winning_team(match) != nil

      score =
        case team do
          "a" -> socket.assigns.match.a_score
          "b" -> socket.assigns.match.b_score
        end

      {:reply, %{wait: wait, score: score}, socket}
    end
  end

  def handle_event(event, params, socket) do
    {:noreply, apply_event(socket, event, params)}
  end

  def apply_event(socket, "undo", _params) do
    {:ok, match} = Scoring.undo_match_event(socket.assigns.current_scope, socket.assigns.match)

    assign_match(socket, match, true)
  end

  def apply_event(socket, "reset", params) do
    clear_sets? = Map.has_key?(params, "clear_sets")

    {:ok, match} =
      Scoring.reset_match_scores(socket.assigns.current_scope, socket.assigns.match, clear_sets?)

    assign_match(socket, match, true)
  end

  def apply_event(socket, "next_set", _params) do
    %{match: match, winning_team: winning_team} = socket.assigns

    {:ok, match} = Scoring.complete_set(socket.assigns.current_scope, match, winning_team)

    assign_match(socket, match, true)
  end

  defp assign_match(socket, match, reset? \\ false) do
    winning_team = Match.winning_team(match)
    current_set = Match.current_set(match)

    socket =
      if reset? do
        wait = not is_nil(winning_team)
        push_event(socket, "reset_score", %{a: match.a_score, b: match.b_score, wait: wait})
      else
        socket
      end

    assign(socket,
      match: match,
      winning_team: winning_team,
      current_set: current_set,
      page_title: "#{match.settings.a_name} vs. #{match.settings.b_name}"
    )
  end

  defp assign_new_match(socket, %Match{} = match, scorer?) do
    if connected?(socket) do
      if old_match = socket.assigns[:match] do
        Scoring.unsubscribe(old_match)
      end

      Scoring.subscribe(match)
    end

    share_link = url(socket, ~p"/scratch/#{match}")

    socket
    |> assign(:share_link, share_link)
    |> assign(:scorer?, scorer?)
    |> assign(:editing?, false)
    |> assign_match(match)
  end
end
