defmodule VolleyWeb.TournamentLive.TeamsView do
  use VolleyWeb, :live_component

  alias Volley.Tournaments.Division

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
  def update(%{tournament: tournament, scope: scope}, socket) do
    socket =
      socket
      |> assign(:scope, scope)
      |> assign(:tournament_id, tournament.id)
      |> assign(:division, %Division{})
      |> assign(:divisions_empty?, tournament.divisions == [])
      |> stream(:divisions, tournament.divisions)
      |> assign_form(%{})

    {:ok, socket}
  end

  @impl true
  def handle_event("validate_division", %{"division" => params}, socket) do
    {:noreply, assign_form(socket, params, action: :validate)}
  end

  def handle_event("submit_division", %{"division" => params}, socket) do
    %{scope: scope, tournament_id: tournament_id} = socket.assigns

    case Volley.Tournaments.create_tournament_division(scope, tournament_id, params) do
      {:ok, division} ->
        socket =
          socket
          |> stream_insert(:divisions, division)
          |> assign(:divisions_empty?, false)
          |> assign_form(%{})

        send(self(), :created_division)

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, params, opts \\ [])

  defp assign_form(socket, %Ecto.Changeset{} = changeset, opts) do
    assign(socket, :form, to_form(changeset, opts ++ [as: "division"]))
  end

  defp assign_form(socket, params, opts) do
    changeset = Division.changeset(socket.assigns.division, params)
    assign_form(socket, changeset, opts)
  end

  attr :form, Phoenix.HTML.Form
  attr :variant, :string, default: "block", values: ~w(block inline)
  attr :target, :any

  defp div_type_text(:mixed), do: "Mixed"
  defp div_type_text(:men), do: "Men's"
  defp div_type_text(:women), do: "Women's"
end
