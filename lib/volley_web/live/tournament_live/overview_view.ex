defmodule VolleyWeb.TournamentLive.OverviewView do
  use VolleyWeb, :live_component

  alias Volley.Tournaments.Tournament

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form :let={f} for={@form} phx-change="validate" phx-submit="submit" phx-target={@myself}>
        <.input field={f[:name]} label="Tournament Name" />

        <.input field={f[:timezone]} label="Timezone" options={@valid_time_zones} type="select" />

        <.input field={f[:location]} label="Location" />

        <.input field={f[:start]} label="Tournament Start" type="datetime-local" />
        <.input field={f[:end]} label="Tournament End" type="datetime-local" />

        <fieldset class="fieldset">
          <legend class="fieldset-legend">Registration Settings</legend>
          <.button phx-click="open_registration_now" disabled={@tournament.registration_opened_at}>
            Open Registration Now
          </.button>
          <.button phx-click="close_registration_now" disabled={@tournament.registration_closed_at}>
            Close Registration Now
          </.button>

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

  defp assign_form(socket, params_or_changeset, opts \\ [])

  defp assign_form(socket, %Ecto.Changeset{} = changeset, opts) do
    assign(socket, :form, to_form(changeset, opts ++ [as: "tournament"]))
  end

  defp assign_form(socket, params, opts) do
    changeset = Tournament.overview_changeset(socket.assigns.tournament, params)
    assign_form(socket, changeset, opts)
  end
end
