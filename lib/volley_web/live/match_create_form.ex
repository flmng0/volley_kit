defmodule VolleyWeb.MatchCreateForm do
  use VolleyWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form for={@form} phx-target={@myself} phx-change="validate" phx-submit="start">
        <h2 class="text-lg text-center">
          Start a New Match
        </h2>
        <div class="grid grid-cols-2 w-full gap-2">
          <.input label="Team A Name" field={@form[:team_a_name]} />
          <.input label="Team B Name" field={@form[:team_b_name]} />
        </div>

        <.input
          field={@form[:set_count]}
          label="Set Count"
          description="Leave empty for no set limit."
          placeholder="No limit"
        />

        <.input label="Point Limit Per Set" field={@form[:set_point_limit]} />

        <.input
          field={@form[:final_set_limit]}
          label="Final Set Limit"
          description="Leave empty to keep the same as other sets."
          placeholder={@form[:set_point_limit].value}
          pattern="[0-9]+"
        />

        <:actions>
          <.button>Start Match</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    options = Volley.default_match_options()
    changeset = Volley.change_match_options(options)

    socket =
      socket
      |> assign(:options, options)
      |> assign_form(changeset)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"match_options" => options}, socket) do
    changeset =
      socket.assigns.options
      |> Volley.change_match_options(options)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("start", %{"match_options" => options}, socket) do
    case Volley.create_match(options) do
      {:ok, match} ->
        sqid = Volley.Sqids.encode!(:match, match.id)

        {:noreply, push_navigate(socket, to: ~p"/match/#{sqid}")}

      {:error, %Ecto.Changeset{changes: %{options: changeset}}} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
