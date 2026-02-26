defmodule VolleyWeb.TournamentLive.TeamsView do
  use VolleyWeb, :live_component

  alias Volley.Tournaments.Tournament

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Teams & Divisions
      </.header>
    </div>
    """
  end

  @impl true
  def update(%{tournament: _, scope: _} = assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_form(%{})

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"tournament" => params}, socket) do
    {:noreply, assign_form(socket, params, action: :validate)}
  end

  def handle_event("submit", %{"tournament" => params}, socket) do
    %{scope: scope, tournament: tournament} = socket.assigns

    case Volley.Tournaments.update_tournament_teams(scope, tournament, params) do
      {:ok, tournament} ->
        send(self(), {:updated_tournament, tournament})
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, params, opts \\ [])

  defp assign_form(socket, %Ecto.Changeset{} = changeset, opts) do
    assign(socket, :form, to_form(changeset, opts ++ [as: "tournament"]))
  end

  defp assign_form(socket, params, opts) do
    changeset = Tournament.teams_changeset(socket.assigns.tournament, params)
    assign_form(socket, changeset, opts)
  end

  defp div_type_text(:mixed), do: "Mixed"
  defp div_type_text(:men), do: "Men's"
  defp div_type_text(:women), do: "Women's"
end
