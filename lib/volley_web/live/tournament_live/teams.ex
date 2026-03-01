defmodule VolleyWeb.TournamentLive.Teams do
  use VolleyWeb, :live_view

  alias Volley.Tournaments
  alias Volley.Tournaments.Team

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.tournament_view
      current_scope={@current_scope}
      flash={@flash}
      tournament={@tournament}
      view={__MODULE__}
    >
      <.header>
        Manage Teams
        <:subtitle>
          View, accept, and edit teams that have registered for your tournament. You may also add your own teams if you'd like from here.
        </:subtitle>
      </.header>

      <.table id="teams" rows={@streams.teams}>
        <:col :let={{_, team}} label="Team Name">{team.name}</:col>
      </.table>

      <.button patch={~p"/tournaments/#{@tournament}/teams/new"}>
        <.icon name="hero-plus" /> Create New Team
      </.button>

      <.modal
        :if={@live_action == :new}
        id="team_create_form_modal"
        auto_open
        close={JS.patch(~p"/tournaments/#{@tournament}/teams")}
      >
        <.header header_tag="h2">Create New Team</.header>
        <.team_form {assigns} />
      </.modal>
    </Layouts.tournament_view>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> stream(:teams, socket.assigns.tournament.teams)

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({:submit_team, %Team{} = team}, socket) do
    socket =
      socket
      |> stream_insert(:teams, team)
      |> push_patch(to: ~p"/tournaments/#{socket.assigns.tournament}/teams")

    {:noreply, socket}
  end

  defp team_form(assigns) do
    ~H"""
    <.live_component
      :let={f}
      module={VolleyWeb.LiveForm}
      id="team_create_form"
      changeset_fn={&Team.changeset(%Team{}, &1)}
      submit_fn={&Tournaments.create_tournament_team(@current_scope, @tournament, &1)}
      message_fn={&{:submit_team, &1}}
      class="fieldset gap-y-8"
    >
      <.input field={f.form[:name]} type="text" label="Team Name" />

      <div class="bg-base-200 border border-base-300 p-4">
        <div class="flex justify-between gap-x-4 items-center">
          <span class="font-semibold text-lg">Players</span>
          <.button
            type="button"
            name="team[sort_players][]"
            variant="create"
            value="new"
            phx-click={JS.dispatch("change")}
          >
            <.icon name="hero-plus" /> Add Player
          </.button>
        </div>

        <ul class="grid gap-x-2 grid-cols-[1fr_1fr_auto]">
          <li class="grid grid-cols-subgrid col-span-2 only:hidden mt-4">
            <span class="fieldset-label">Name</span>
            <span class="fieldset-label">DOB</span>
          </li>
          <.inputs_for :let={player} field={f.form[:players]}>
            <li class="grid grid-cols-subgrid col-span-3">
              <.input
                type="text"
                field={player[:name]}
                placeholder="Player's name"
                phx-mounted={JS.focus()}
              />
              <.input
                type="date"
                field={player[:dob]}
                placeholder="Player's date of birth"
              />
              <.button
                type="button"
                name="team[drop_players][]"
                value={player.index}
                phx-click={JS.dispatch("change")}
              >
                <.icon name="hero-trash" />
              </.button>
              <input type="hidden" name="team[sort_players][]" value={player.index} />
            </li>
          </.inputs_for>
        </ul>

        <input type="hidden" name="team[drop_players][]" />
      </div>

      <details
        class="collapse collapse-plus bg-base-200 border-base-300 group"
        phx-mounted={JS.ignore_attributes("open")}
      >
        <summary class="collapse-title">
          <p class="font-semibold text-lg">Additional Persons</p>
          <p class="group-open:hidden text-base-content/50">
            Coach, assistant coach, trainer, etc...
          </p>
        </summary>
        <div class="collapse-content">
          <.input field={f.form[:coach_name]} type="text" label="Coach" />
          <.input field={f.form[:assistant_coach_name]} type="text" label="Assistant Coach" />
          <.input field={f.form[:trainer_name]} type="text" label="Trainer Name" />
          <.input field={f.form[:medical_doctor_name]} type="text" label="Medical Doctor Name" />
        </div>
      </details>

      <div class="flex justify-end gap-4">
        <.button patch={~p"/tournaments/#{@tournament}/teams"}>Cancel</.button>
        <.button variant="create">Create Team</.button>
      </div>
    </.live_component>
    """
  end
end
