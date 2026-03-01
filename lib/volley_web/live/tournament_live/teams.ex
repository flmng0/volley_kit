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

      <div class="flex flex-col gap-2 mb-8">
        <.table id="teams" rows={@streams.teams}>
          <:col :let={{_, team}} label="Team Name">{team.name}</:col>
          <:col :let={{_, team}} :if={not Enum.empty?(@tournament.divisions)} label="Division">
            <span :if={team.division}>{team.division.name}</span>
            <span :if={is_nil(team.division)} class="badge badge-warning">
              <.icon name="hero-exclamation-triangle" /> No Division
            </span>
          </:col>
          <:action :let={{_, team}}>
            <.button
              variant="delete"
              aria-label="Delete Team"
              phx-click="delete"
              phx-value-id={team.id}
            >
              <.icon name="hero-trash" />
            </.button>
            <.button
              variant="neutral"
              aria-label="Edit Team"
              phx-click={JS.navigate(~p"/tournaments/#{@tournament}/teams/#{team}")}
            >
              <.icon name="hero-pencil" />
            </.button>
          </:action>
        </.table>

        <.button patch={~p"/tournaments/#{@tournament}/teams/new"} class="self-end" variant="create">
          <.icon name="hero-plus" /> Create New Team...
        </.button>
      </div>

      <.modal
        :if={@live_action == :new}
        id="team_create_form_modal"
        auto_open
        close={JS.patch(~p"/tournaments/#{@tournament}/teams")}
      >
        <.header header_tag="h2">Create New Team</.header>

        <.live_component
          :let={f}
          module={VolleyWeb.LiveForm}
          id="team_create_form"
          changeset_fn={&Team.changeset(%Team{}, &1)}
          submit_fn={&Tournaments.create_team(@current_scope, @tournament, &1)}
          message_fn={&{:submit_team, &1}}
          class="space-y-8"
        >
          <FormComponents.Tournament.team form={f.form} tournament={@tournament} />

          <div class="flex justify-end gap-4">
            <.button patch={~p"/tournaments/#{@tournament}/teams"}>Cancel</.button>
            <.button variant="create">Create Team</.button>
          </div>
        </.live_component>
      </.modal>

      <.modal
        :if={@live_action == :edit}
        id="team_edit_form_modal"
        auto_open
        close={JS.patch(~p"/tournaments/#{@tournament}/teams")}
      >
        <.header header_tag="h2">
          Edit Team
          <:subtitle>Editing team: {@team.name}</:subtitle>
        </.header>

        <.live_component
          :let={f}
          module={VolleyWeb.LiveForm}
          id="team_create_form"
          changeset_fn={&Team.changeset(@team, &1)}
          submit_fn={&Tournaments.update_team(@current_scope, @team, &1)}
          message_fn={&{:submit_team, &1}}
          class="space-y-8"
        >
          <FormComponents.Tournament.team form={f.form} tournament={@tournament} />
          <div class="flex justify-end gap-4">
            <.button patch={~p"/tournaments/#{@tournament}/teams"}>Cancel</.button>
            <.button variant="create">Save Team</.button>
          </div>
        </.live_component>
      </.modal>

      <.modal :if={@delete} id="delete_confirm" auto_open={true} close={JS.push("cancel_delete")}>
        <.header>Are you sure?</.header>
        <p>Are you sure you want to delete the team {@delete.name}?</p>

        <:action>
          <.button variant="delete" phx-click="confirm_delete">Yes</.button>
          <.button>No</.button>
        </:action>
      </.modal>
    </Layouts.tournament_view>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    tournament = socket.assigns.tournament

    socket =
      socket
      |> stream(:teams, Tournaments.list_teams(socket.assigns.current_scope, tournament))
      |> assign(:delete, nil)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, params, socket.assigns.live_action)}
  end

  defp apply_action(socket, _params, :new) do
    assign(socket, :team, %Team{})
  end

  defp apply_action(socket, %{"team_id" => team_id}, :edit) do
    if team = Tournaments.get_team(socket.assigns.current_scope, team_id) do
      assign(socket, :team, team)
    else
      socket
      |> put_flash(:error, "Team with that ID was not found")
      |> push_patch(to: ~p"/tournaments/#{socket.assigns.tournament}/teams")
    end
  end

  defp apply_action(socket, _params, _action) do
    socket
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    if t = Tournaments.get_team(socket.assigns.current_scope, id) do
      {:noreply, assign(socket, :delete, t)}
    else
      socket
      |> put_flash(:error, "Team with that ID no longer exists")
      |> push_patch(to: ~p"/tournaments/#{socket.assigns.tournament}/teams")

      {:noreply, socket}
    end
  end

  def handle_event("confirm_delete", _params, socket) do
    {:ok, team} = Tournaments.delete_team(socket.assigns.current_scope, socket.assigns.delete)

    {:noreply, stream_delete(socket, :teams, team)}
  end

  def handle_event("cancel_delete", _params, socket) do
    {:noreply, assign(socket, :delete, nil)}
  end

  @impl true
  def handle_info({:submit_team, %Team{} = team}, socket) do
    IO.inspect(team)

    socket =
      socket
      |> stream_insert(:teams, team)
      |> push_patch(to: ~p"/tournaments/#{socket.assigns.tournament}/teams")

    {:noreply, socket}
  end
end
