defmodule VolleyWeb.TournamentLive.OverviewView do
  use VolleyWeb, :live_component

  alias Volley.Tournaments.Tournament

  @impl true
  def render(assigns) do
    ~H"""
    <div phx-mounted={JS.focus(to: "#tournament_name_input")}>
      <.form
        :let={f}
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

        <fieldset class="fieldset">
          <legend class="fieldset-legend text-lg">Basic Details</legend>

          <.input field={f[:name]} label="Tournament Name" id="tournament_name_input" />

          <div class="alert alert-info mt-2">
            <.icon name="hero-information-circle" class="size-6" />
            <div>
              <p>All time-related settings will be in the timezone you have set below.</p>
              <p>Visitors will see the time as-is, listed alongside the timezone.</p>
            </div>
          </div>
          <.input field={f[:timezone]} label="Timezone" options={@valid_time_zones} type="select" />

          <.input field={f[:location]} label="Location" />

          <.input field={f[:start]} label="Tournament Start" type="datetime-local" />
          <.input field={f[:end]} label="Tournament End" type="datetime-local" />
        </fieldset>

        <fieldset class="fieldset">
          <legend class="fieldset-legend text-lg">Registration Settings</legend>

          <div class="grid gap-4 lg:grid-cols-2"></div>

          <.datetime_input label="Registration Open Time" field={f[:registration_opened_at]} />
          <.datetime_input label="Registration Close Time" field={f[:registration_closed_at]} />

          <.input field={f[:registration_price]} label="Registration Price" type="money" />
        </fieldset>
      </.form>
    </div>
    """
  end

  attr :field, Phoenix.HTML.FormField, required: true
  attr :label, :string, required: true

  def datetime_input(assigns) do
    ~H"""
    <.input
      field={@field}
      label={@label}
      type="datetime-local"
    >
      <:actions>
        <.button
          type="button"
          phx-click={JS.dispatch("vk:filldate", to: "##{@field.id}")}
        >
          Set to Now
        </.button>
        <.button
          variant="neutral"
          type="button"
          phx-click={JS.dispatch("vk:clear", to: "##{@field.id}")}
        >
          Clear
        </.button>
      </:actions>
    </.input>
    """
  end

  @impl true
  def mount(socket) do
    time_zones =
      TimeZoneInfo.time_zones()
      |> Enum.group_by(fn tz ->
        case String.split(tz, "/", parts: 2) do
          [prefix, _] -> prefix
          prefix -> prefix
        end
      end)
      |> Enum.sort_by(&elem(&1, 1))

    {:ok, assign(socket, :valid_time_zones, time_zones)}
  end

  @impl true
  def update(%{tournament: tournament}, socket) do
    socket =
      socket
      |> assign(:tournament, tournament)
      |> assign_form(%{})

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"tournament" => params}, socket) do
    {:noreply, assign_form(socket, params, action: :validate)}
  end

  def handle_event("submit", %{"tournament" => params}, socket) do
    case Tournament.overview_changeset(socket.assigns.tournament, params) do
      %Ecto.Changeset{valid?: true} = changeset ->
        send(self(), {:update_tournament, changeset})
        {:noreply, socket}

      changeset ->
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

    assign(socket, :form, to_form(changeset, opts ++ [as: "tournament"]))
  end

  defp assign_form(socket, params, opts) do
    changeset = Tournament.overview_changeset(socket.assigns.tournament, params)
    assign_form(socket, changeset, opts)
  end
end
