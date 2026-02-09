defmodule VolleyWeb.TournamentLive.OverviewView do
  use VolleyWeb, :live_component

  alias Volley.Tournaments.Tournament

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form :let={f} for={@form} phx-update="validate" phx-submit="submit" phx-target={@myself}>
        <.input field={f[:name]} label="Tournament Name" />

        <.input field={f[:timezone]} label="Timezone" options={@valid_time_zones} type="select" />

        <.input field={f[:location]} label="Location" />

        <.input field={f[:start]} label="Tournament Start" type="datetime-local" />
        <.input field={f[:end]} label="Tournament End" type="datetime-local" />
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

  defp assign_form(socket, params, opts \\ []) do
    form =
      socket.assigns.tournament
      |> Tournament.overview_changeset(params)
      |> to_form(opts ++ [as: "tournament"])

    assign(socket, :form, form)
  end
end
