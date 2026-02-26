defmodule VolleyWeb.TournamentLive.OverviewView do
  use VolleyWeb, :live_component

  alias Volley.Tournaments.Tournament
  alias VolleyWeb.TournamentLive.FormComponents

  @impl true
  def render(assigns) do
    ~H"""
    <div phx-mounted={JS.focus(to: "#tournament_name_input")}>
      <.form
        for={@form}
        phx-change="validate"
        phx-submit="submit"
        phx-target={@myself}
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
              phx-target={@myself}
              disabled={@clean?}
            >
              Revert Changes
            </.button>
          </:actions>
        </.header>

        <.section_card title="Basic Details" collapsible>
          <FormComponents.details form={@form} time_zone_options={@valid_time_zones} />
        </.section_card>
        <.section_card title="Registration Settings">
          <FormComponents.registration form={@form} />
        </.section_card>
      </.form>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    time_zones = VolleyWeb.Util.collect_timezone_options()

    {:ok, assign(socket, :valid_time_zones, time_zones)}
  end

  @impl true
  def update(%{tournament: tournament, scope: scope}, socket) do
    socket =
      socket
      |> assign(:tournament, tournament)
      |> assign(:scope, scope)
      |> assign_form(%{})

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"tournament" => params}, socket) do
    {:noreply, assign_form(socket, params, action: :validate)}
  end

  def handle_event("submit", %{"tournament" => params}, socket) do
    %{scope: scope, tournament: tournament} = socket.assigns

    case Volley.Tournaments.update_tournament_overview(scope, tournament, params) do
      {:ok, tournament} ->
        send(self(), {:updated_tournament, tournament})
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

    socket =
      socket
      |> assign(:clean?, clean?)
      |> assign(:form, to_form(changeset, opts ++ [as: "tournament"]))

    socket
  end

  defp assign_form(socket, params, opts) do
    changeset = Tournament.overview_changeset(socket.assigns.tournament, params)
    assign_form(socket, changeset, opts)
  end
end
