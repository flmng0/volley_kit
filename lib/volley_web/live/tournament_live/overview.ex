defmodule VolleyWeb.TournamentLive.Overview do
  use VolleyWeb, :live_view

  alias Volley.Tournaments
  alias VolleyWeb.TournamentLive.FormComponents

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.tournament_view
      current_scope={@current_scope}
      flash={@flash}
      tournament={@tournament}
      view={__MODULE__}
    >
      <.form
        for={@form}
        phx-change="validate"
        phx-submit="submit"
        class="flex flex-col gap-8"
      >
        <.header>
          Overview
          <:subtitle>Adjust basic settings for your tournament.</:subtitle>
          <:actions>
            <.button variant="save" disabled={@clean?}>Save</.button>
            <.button
              type="button"
              variant="cancel"
              phx-click="cancel"
              disabled={@clean?}
            >
              Revert Changes
            </.button>
          </:actions>
        </.header>

        <.section_card title="Basic Details">
          <FormComponents.details form={@form} time_zone_options={@valid_time_zones} />
        </.section_card>
        <.section_card title="Registration Settings">
          <FormComponents.registration form={@form} />
        </.section_card>
        <.section_card title="Divisions">
          <FormComponents.divisions form={@form} disable_focus? />
        </.section_card>
      </.form>
    </Layouts.tournament_view>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:valid_time_zones, VolleyWeb.Util.collect_timezone_options())
      |> assign_form(%{})

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"tournament" => params}, socket) do
    {:noreply, assign_form(socket, params, action: :validate)}
  end

  def handle_event("submit", %{"tournament" => params}, socket) do
    case Tournaments.update_tournament_overview(
           socket.assigns.current_scope,
           socket.assigns.tournament,
           params
         ) do
      {:ok, tournament} ->
        socket =
          socket
          |> assign(:tournament, tournament)
          |> assign_form(%{})

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("cancel", _params, socket) do
    {:noreply, assign_form(socket, %{})}
  end

  defp assign_form(socket, params_or_changeset, opts \\ [])

  defp assign_form(socket, %Ecto.Changeset{} = changeset, opts) do
    clean? = Enum.empty?(changeset.changes)

    socket
    |> assign(:clean?, clean?)
    |> assign(:form, to_form(changeset, opts ++ [as: "tournament"]))
  end

  defp assign_form(socket, params, opts) do
    changeset = Tournaments.Tournament.overview_changeset(socket.assigns.tournament, params)
    assign_form(socket, changeset, opts)
  end
end
