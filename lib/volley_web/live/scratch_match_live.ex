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
    <.modal id="shareModal" class="flex flex-col items-center text-sm md:text-base">
      <hgroup>
        <h3 class="text-lg font-bold">Share Match</h3>
        <p>Scan the QR code below, or copy the sharing link, so other users to view this match.</p>
      </hgroup>

      <.qr_code class="my-6 rounded-md shadow-xl outline outline-base-300" target={@share_link} />

      <.copy_text id="shareLinkCopy" class="w-full max-w-md" value={@share_link} />
    </.modal>

    <.modal
      :if={@winning_team in [:a, :b]}
      id="setCompleteModal"
      allow_close={false}
      phx-mounted={show_modal("setCompleteModal")}
    >
      <hgroup>
        <h3 class="text-lg font-bold">Set Complete!</h3>
        <p>
          {if @winning_team == :a, do: @match.settings.a_name, else: @match.settings.b_name} has won this set.
        </p>
      </hgroup>

      <:action>
        <.button phx-click="undo">Undo</.button>
      </:action>
      <:action>
        <.button phx-click="next_set" variant="neutral">Continue To Next Set!</.button>
      </:action>
    </.modal>

    <Layouts.scorer flash={@flash}>
      <.score_container match={@match} can_score={@owner?} event="score" />
      <:actions>
        <.button class="p-2" phx-click={show_modal("shareModal")}>
          <span class="fullscreen:hidden">Share Match</span>
          <.icon class="fullscreen:size-6 size-4" name="hero-share" />
        </.button>
      </:actions>
    </Layouts.scorer>
    """
  end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{topic: "match:" <> id, payload: payload}, socket) do
    if id == socket.assigns.match.id do
      %Ash.Notifier.Notification{
        data: match
      } = payload

      {:noreply, assign(socket, :match, match)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event(event, params, socket) do
    %{owner?: true} = socket.assigns

    {:noreply, apply_event(socket, event, params)}
  end

  def apply_event(socket, "score", %{"team" => team}) do
    match = Scoring.score!(socket.assigns.match, team)

    assign_match(socket, match)
  end

  def apply_event(socket, "undo", _params) do
    match = Scoring.undo_event!(socket.assigns.match)

    assign_match(socket, match)
  end

  def apply_event(socket, "next_set", _params) do
    match =
      socket.assigns.match
      |> Ash.load!(:winning_team)
      |> Scoring.complete_set!()

    assign_match(socket, match)
  end

  defp assign_match(socket, match) do
    winning_team = Scoring.winning_team!(match)

    assign(socket, match: match, winning_team: winning_team)
  end

  defp assign_new_match(socket, match, owner?) do
    if old_match = socket.assigns[:match] do
      old_match
      |> Scoring.match_topic()
      |> VolleyWeb.Endpoint.unsubscribe()
    end

    unless owner? do
      match
      |> Scoring.match_topic()
      |> VolleyWeb.Endpoint.subscribe()
    end

    share_link = url(socket, ~p"/scratch/#{match.id}")

    socket
    |> assign(:page_title, "#{match.settings.a_name} vs. #{match.settings.b_name}")
    |> assign(:share_link, share_link)
    |> assign(:owner?, owner?)
    |> assign_match(match)
  end
end
