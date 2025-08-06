defmodule VolleyWeb.ScratchMatchLive do
  use VolleyWeb, :live_view

  on_mount {VolleyWeb.UserAuth, :mount_current_scope}

  import VolleyWeb.MatchComponents
  alias Volley.Scoring

  require Integer

  @impl true
  def mount(%{"id" => match_id}, _session, socket) do
    if match = Scoring.get_match!(match_id, actor: socket.assigns.current_scope) do
      scorer? = Scoring.can_score?(socket.assigns.current_scope, match, nil)

      {:ok, assign_new_match(socket, match, scorer?)}
    else
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
      <.score_container
        match={@match}
        can_score={@scorer?}
        event="score"
        swap={Integer.is_odd(@current_set)}
      />
      <:action>
        <Layouts.toggle_fullscreen_button />
      </:action>
      <:action>
        <Layouts.scorer_action_button
          phx-click={show_modal("shareModal")}
          label="Share Match"
          icon_name="hero-share"
        />
      </:action>
      <:action :if={@scorer?}>
        <Layouts.scorer_action_button
          phx-click="undo"
          label="Undo Score"
          icon_name="hero-arrow-uturn-left"
        />
      </:action>
      <:action :if={@scorer?}>
        <Layouts.scorer_action_button
          phx-click="edit"
          show_in_fullscreen?={false}
          label={if @editing?, do: "Close Settings", else: "Edit Settings"}
          icon_name={if @editing?, do: "hero-x-mark", else: "hero-adjustments-vertical"}
        />
      </:action>

      <:footer :if={@editing?}>
        <div class="card">
          <div class="card-body bg-base-200">
            <h3 class="card-title">
              <span class="grow">Edit Match Settings</span>
              <.icon class="size-6" name="hero-adjustments-vertical" />
            </h3>
            <.live_component
              id="settingsEditForm"
              module={VolleyWeb.MatchSettingsForm}
              type={:update}
              settings={@match.settings}
            >
            </.live_component>
          </div>
        </div>
      </:footer>
    </Layouts.scorer>

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
    """
  end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{topic: "match:" <> id, payload: payload}, socket) do
    if id == socket.assigns.match.id do
      %Ash.Notifier.Notification{
        data: match
      } = payload

      {:noreply, assign_match(socket, match)}
    else
      {:noreply, socket}
    end
  end

  def handle_info({:submit_settings, settings}, socket) do
    match =
      Scoring.update_settings!(socket.assigns.match, settings,
        actor: socket.assigns.current_scope
      )

    socket =
      socket
      |> assign(:editing?, false)
      |> assign_match(match)

    {:noreply, socket}
  end

  @impl true
  def handle_event(event, params, socket) do
    {:noreply, apply_event(socket, event, params)}
  end

  def apply_event(socket, "edit", _params) do
    assign(socket, :editing?, not socket.assigns.editing?)
  end

  def apply_event(socket, "score", %{"team" => team}) do
    match = Scoring.score!(socket.assigns.match, team, actor: socket.assigns.current_scope)

    assign_match(socket, match)
  end

  def apply_event(socket, "undo", _params) do
    match = Scoring.undo_event!(socket.assigns.match, 1, actor: socket.assigns.current_scope)

    assign_match(socket, match)
  end

  def apply_event(socket, "next_set", _params) do
    %{match: match, winning_team: winning_team} = socket.assigns

    match = Scoring.complete_set!(match, winning_team, actor: socket.assigns.current_scope)

    assign_match(socket, match)
  end

  defp assign_match(socket, match) do
    winning_team = Scoring.winning_team!(match, actor: socket.assigns.current_scope)
    current_set = Scoring.current_set!(match, actor: socket.assigns.current_scope)

    assign(socket, match: match, winning_team: winning_team, current_set: current_set)
  end

  defp assign_new_match(socket, match, scorer?) do
    if old_match = socket.assigns[:match] do
      old_match
      |> Scoring.match_topic()
      |> VolleyWeb.Endpoint.unsubscribe()
    end

    unless scorer? do
      match
      |> Scoring.match_topic()
      |> VolleyWeb.Endpoint.subscribe()
    end

    share_link = url(socket, ~p"/scratch/#{match.id}")

    socket
    |> assign(:page_title, "#{match.settings.a_name} vs. #{match.settings.b_name}")
    |> assign(:share_link, share_link)
    |> assign(:scorer?, scorer?)
    |> assign(:editing?, false)
    |> assign_match(match)
  end
end
