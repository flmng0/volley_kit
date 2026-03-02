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

    {:ok, assign(socket, valid_time_zones: time_zone_opts)}
  end

  @impl true
  def handle_info({:updated_tournament, tournament}, socket) do
    {:noreply, assign(socket, tournament: tournament)}
  end
end
