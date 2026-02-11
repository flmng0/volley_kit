defmodule VolleyWeb.TournamentLive.OverviewView do
  use VolleyWeb, :live_component

  alias Volley.Tournaments.Tournament

  @impl true
  def render(assigns) do
    ~H"""
    <div>
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
            <.button variant="cancel" phx-click="cancel" phx-target={@myself}>Cancel</.button>
          </:actions>
        </.header>

        <fieldset class="fieldset">
          <legend class="fieldset-legend text-lg">Basic Details</legend>

          <.input field={f[:name]} label="Tournament Name" />

          <.input field={f[:timezone]} label="Timezone" options={@valid_time_zones} type="select" />

          <.input field={f[:location]} label="Location" />

          <.input field={f[:start]} label="Tournament Start" type="datetime-local" />
          <.input field={f[:end]} label="Tournament End" type="datetime-local" />
        </fieldset>

        <fieldset class="fieldset">
          <legend class="fieldset-legend text-lg">Registration Settings</legend>

          <div class="grid gap-4 lg:grid-cols-2">
            <.button
              variant="create"
              type="button"
              phx-click={JS.dispatch("vk:filldate", to: "##{f[:registration_opened_at].id}")}
              disabled={@tournament.registration_opened_at}
            >
              Set Open Time to Now
            </.button>
            <.button
              variant="delete"
              type="button"
              phx-click={JS.dispatch("vk:filldate", to: "##{f[:registration_closed_at].id}")}
              disabled={@tournament.registration_closed_at}
            >
              Set Close Time to Now
            </.button>
          </div>

          <.input
            field={f[:registration_opened_at]}
            label="Registration Close Time"
            type="datetime-local"
          />
          <.input
            field={f[:registration_closed_at]}
            label="Registration Close Time"
            type="datetime-local"
          />

          <.input field={f[:registration_price]} label="Registration Price" type="money" />
        </fieldset>
      </.form>
    </div>
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
        send(self(), {:submit_overview_update, changeset})
        {:noreply, socket}

      changeset ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("cancel", _params, socket) do
    {:noreply, assign_form(socket, %{})}
  end

  def handle_event("close_registration_now", params, socket) do
    IO.inspect(params, label: "Params for close")
    {:noreply, socket}
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
