defmodule VolleyWeb.TournamentLive.Overview do
  use VolleyWeb, :live_view

  alias Volley.Tournaments

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.tournament_view
      current_scope={@current_scope}
      flash={@flash}
      tournament={@tournament}
      view={__MODULE__}
    >
      <div :if={@stale_divisions?} class="alert alert-warning mb-4">
        <.icon name="hero-exclamation-triangle" />
        <p>Some teams no longer have an associated division!</p>
      </div>

      <.live_component
        :let={f}
        module={VolleyWeb.LiveForm}
        id="overview_form"
        changeset_fn={&Tournaments.Tournament.overview_changeset(@tournament, &1)}
        submit_fn={&Tournaments.update_tournament_overview(@current_scope, @tournament, &1)}
        message_fn={&{:updated_tournament, &1}}
        class="flex flex-col gap-8"
      >
        <.header>
          Overview
          <:subtitle>Adjust basic settings for your tournament.</:subtitle>
          <:actions>
            <.button
              variant="save"
              disabled={f.clean?}
            >
              Save
            </.button>
            <.button
              type="button"
              variant="cancel"
              phx-click={f.cancel}
              disabled={f.clean?}
            >
              Revert Changes
            </.button>
          </:actions>
        </.header>

        <.section_card title="Basic Details">
          <FormComponents.Tournament.details form={f.form} time_zone_options={@valid_time_zones} />
        </.section_card>
        <.section_card title="Divisions">
          <FormComponents.Tournament.divisions form={f.form} disable_focus? />
        </.section_card>
        <.section_card title="Registration Settings">
          <FormComponents.Tournament.registration form={f.form} />
        </.section_card>
      </.live_component>
    </Layouts.tournament_view>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    time_zone_opts = VolleyWeb.Util.collect_timezone_options()

    {:ok, assign(socket, valid_time_zones: time_zone_opts, stale_divisions?: false)}
  end

  @impl true
  def handle_info({:updated_tournament, tournament}, socket) do
    {:noreply,
     assign(socket, tournament: tournament, stale_divisions?: has_stale_divisions?(tournament))}
  end

  defp has_stale_divisions?(tournament) do
    tournament_division_ids = tournament.divisions |> Enum.map(& &1.id) |> MapSet.new()

    team_div_ids =
      tournament.teams
      |> Enum.map(& &1.division_id)
      |> MapSet.new()

    MapSet.difference(tournament_division_ids, team_div_ids)
  end
end
