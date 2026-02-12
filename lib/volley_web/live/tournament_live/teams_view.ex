defmodule VolleyWeb.TournamentLive.TeamsView do
  use VolleyWeb, :live_component

  alias Volley.Tournaments.Tournament

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form :let={f} for={@form} phx-update="validate" phx-submit="submit" phx-target={@myself}>
        <div :if={Phoenix.HTML.Form.input_value(f, :divisions) == []} class="alert alert-warning mb-4">
          <.icon name="hero-exclamation-triangle" class="size-6" />
          <div>
            <p class="font-bold">No divisions!</p>
            <p>There are currently no divisions set up for your tournament.</p>
            <p>Create your first one below.</p>
          </div>
        </div>
        <fieldset class="fieldset">
          <div class="flex justify-between">
            <legend class="fieldset-legend text-lg">
              Divisions
            </legend>
            <.button
              variant="create"
              type="button"
              phx-click="create_division"
            >
              Create Division
            </.button>
          </div>

          <.table id="divisions" rows={@streams.divisions}>
            <:col :let={{_, division}} label="Name">{division.name}</:col>
            <:col :let={{_, division}} label="Type">{div_type_text(division.type)}</:col>
            <:col :let={{_, division}} label="Max Age">{division.max_age}</:col>

            <:action>
              <.button>Edit</.button>
            </:action>
          </.table>
        </fieldset>
      </.form>
    </div>
    """
  end

  defp div_type_text(:mixed), do: "Mixed"
  defp div_type_text(:men), do: "Men's"
  defp div_type_text(:women), do: "Women's"

  @impl true
  def update(%{tournament: tournament}, socket) do
    socket =
      socket
      |> assign(:tournament, tournament)
      |> stream(:divisions, [])
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
