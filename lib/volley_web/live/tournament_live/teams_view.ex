defmodule VolleyWeb.TournamentLive.TeamsView do
  use VolleyWeb, :live_component

  alias Volley.Tournaments.Tournament

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form :let={f} for={@form} phx-update="validate" phx-submit="submit" phx-target={@myself}>
        <.input field={f[:name]} />
      </.form>
    </div>
    """
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
      |> Tournament.teams_changeset(params)
      |> to_form(opts ++ [as: "tournament"])

    assign(socket, :form, form)
  end
end
