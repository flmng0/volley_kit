defmodule VolleyWeb.TournamentLive.View do
  use VolleyWeb, :live_view

  alias Volley.Tournaments
  alias VolleyWeb.TournamentLive.FormComponent

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.tabbed
      current_scope={@current_scope}
      flash={@flash}
      title={@tournament.name || "Unnamed Tournament"}
    >
      <:tab name="Overview" link={~p"/tournament/#{@tournament}"} active={@live_action == :overview}>
        <.live_component
          :let={form}
          module={FormComponent}
          id="overview_tab"
          title="Overview"
          subtitle="Adjust basic settings for your tournament."
          changeset_fn={&Tournaments.Tournament.overview_changeset(@tournament, &1)}
          submit_fn={&Tournaments.update_tournament_overview(@current_scope, @tournament, &1)}
        >
          <.section_card title="Basic Details">
            <FormComponent.details form={form} time_zone_options={@valid_time_zones} />
          </.section_card>
          <.section_card title="Registration Settings">
            <FormComponent.registration form={form} />
          </.section_card>
          <.section_card title="Divisions">
            <FormComponent.divisions form={form} disable_focus? />
          </.section_card>
        </.live_component>
      </:tab>
      <:tab
        name="Manage Teams"
        link={~p"/tournament/#{@tournament}/teams"}
        active={@live_action == :teams}
      >
        <%!-- <.live_component --%>
        <%!--   :let={form} --%>
        <%!--   module={FormComponent} --%>
        <%!--   id="teams_tab" --%>
        <%!--   title="Teams & Divisions" --%>
        <%!--   subtitle="Modify teams and divisions for your tournament." --%>
        <%!--   changeset_fn={&Tournaments.Tournament.teams_changeset(@tournament, &1)} --%>
        <%!--   submit_fn={&Tournaments.update_tournament_teams(@current_scope, @tournament, &1)} --%>
        <%!-- > --%>
        <%!--   <.section_card title="Teams"> --%>
        <%!--     <FormComponent.teams form={form} /> --%>
        <%!--   </.section_card> --%>
        <%!-- </.live_component> --%>
      </:tab>
    </Layouts.tabbed>
    """
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    cond do
      socket.assigns[:tournament] && socket.assigns.tournament == id ->
        {:noreply, apply_action(socket, socket.assigns.live_action)}

      tournament = Tournaments.get_tournament(socket.assigns.current_scope, id) ->
        socket =
          socket
          |> assign(:tournament, tournament)
          |> apply_action(socket.assigns.live_action)

        {:noreply, socket}

      true ->
        redirect = if socket.assigns.current_scope, do: ~p"/tournament/", else: ~p"/"

        socket =
          socket
          |> put_flash(:error, "Tournament with that ID does not exist, or you can't access it")
          |> push_navigate(to: redirect)

        {:noreply, socket}
    end
  end

  defp apply_action(socket, :overview) do
    assign(socket, :valid_time_zones, VolleyWeb.Util.collect_timezone_options())
  end

  defp apply_action(socket, _), do: socket

  @impl true
  def handle_info({:updated_tournament, tournament}, socket) do
    {:noreply, assign(socket, :tournament, tournament)}
  end
end
