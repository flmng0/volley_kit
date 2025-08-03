defmodule VolleyWeb.ScratchMatchLive do
  use VolleyWeb, :live_view
  import VolleyWeb.MatchComponents
  alias Volley.Scoring

  @impl true
  def mount(_params, session, socket) do
    with %{"match_id" => match_id} <- session,
         {:ok, match} <- Scoring.get_match(match_id) do
      owner? = match?(%{"owns_match_id" => ^match_id}, session)

      {:ok, assign_new_match(socket, match, owner?)}
    else
      _ ->
        socket =
          socket
          |> put_flash(:error, "Match with saved ID no longer exists")
          |> redirect(to: ~p"/")

        {:ok, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.scorer flash={@flash}>
      <.score_container match={@match} can_score={@owner?} event="score" />
    </Layouts.scorer>
    """
  end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "score", payload: payload}, socket) do
    %Ash.Notifier.Notification{
      data: match
    } = payload

    {:noreply, assign(socket, :match, match)}
  end

  @impl true
  def handle_event("score", %{"team" => team}, socket) do
    %{owner?: true} = socket.assigns

    match = Scoring.score!(socket.assigns.match, team)

    {:noreply, assign(socket, :match, match)}
  end

  defp assign_new_match(socket, match, owner?) do
    if old_match = socket.assigns[:match] do
      old_match
      |> Scoring.match_topic()
      |> VolleyWeb.Endpoint.unsubscribe()
    end

    match
    |> Scoring.match_topic()
    |> VolleyWeb.Endpoint.subscribe()

    socket
    |> assign(:match, match)
    |> assign(:owner?, owner?)
  end
end
