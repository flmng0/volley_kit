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
      class="fieldset"
    >
      <.input field={f.form[:name]} type="text" label="Team Name" />

      <details
        class="collapse collapse-plus bg-base-200 border-base-300 group"
        phx-mounted={JS.ignore_attributes("open")}
      >
        <summary class="collapse-title">
          <span class="font-semibold">Additional Persons</span>
          <span class="group-open:hidden ">Coach, assistant coach, trainer, etc...</span>
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
