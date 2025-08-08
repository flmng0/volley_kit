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
          phx-click={show_modal("resetConfirmModal")}
          label="Open Reset Menu"
          icon_name="hero-stop-solid"
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
      <hgroup class="prose">
        <h3>Share Match</h3>
        <p>Scan the QR code below, or copy the sharing link, so other users to view this match.</p>
      </hgroup>

      <.qr_code class="my-6 rounded-md shadow-xl outline outline-base-300" target={@share_link} />

      <.copy_text id="shareLinkCopy" class="w-full max-w-md" value={@share_link} />
    </.modal>

    <.modal :if={@scorer?} id="resetConfirmModal">
      <hgroup class="prose">
        <h3>Are you sure?</h3>
        <p>
          Ressetting scores will clear the history for the current set. You can also reset the set counts as well, but this will clear all history.
        </p>
      </hgroup>

      <:action>
        <.button variant="delete" phx-click="reset" phx-value-clear_sets={true}>
          Also Reset Sets
        </.button>
      </:action>
      <:action>
        <.button variant="primary" phx-click="reset" phx-value-clear_sets={false}>
          Only Reset Scores
        </.button>
      </:action>
      <:action>
        <.button>Cancel</.button>
      </:action>
    </.modal>

    <.modal
      :if={@scorer? and @winning_team in [:a, :b]}
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
  def handle_event("score", %{"team" => team}, socket) do
    if socket.assigns.winning_team in [:a, :b] do
      socket = assign_match(socket, socket.assigns.match, true)
      {:reply, %{wait: true}, socket}
    else
      match = Scoring.score!(socket.assigns.match, team, actor: socket.assigns.current_scope)
      socket = assign_match(socket, match)

      wait = match.winning_team in [:a, :b]

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

  def apply_event(socket, "edit", _params) do
    assign(socket, :editing?, not socket.assigns.editing?)
  end

  def apply_event(socket, "undo", _params) do
    match = Scoring.undo_event!(socket.assigns.match, 1, actor: socket.assigns.current_scope)

    assign_match(socket, match, true)
  end

  def apply_event(socket, "reset", params) do
    clear_sets? = Map.has_key?(params, "clear_sets")

    match =
      Scoring.reset_scores!(socket.assigns.match, clear_sets?,
        actor: socket.assigns.current_scope
      )

    assign_match(socket, match, true)
  end

  def apply_event(socket, "next_set", _params) do
    %{match: match, winning_team: winning_team} = socket.assigns

    match = Scoring.complete_set!(match, winning_team, actor: socket.assigns.current_scope)

    assign_match(socket, match, true)
  end

  defp assign_match(socket, match, reset? \\ false) do
    winning_team = Scoring.winning_team!(match, actor: socket.assigns.current_scope)
    current_set = Scoring.current_set!(match, actor: socket.assigns.current_scope)

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
      current_set: current_set
    )
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
