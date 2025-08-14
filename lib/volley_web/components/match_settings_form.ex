defmodule VolleyWeb.MatchSettingsForm do
  use VolleyWeb, :live_component

  alias Volley.Scoring

  attr :type, :atom, values: [:create, :update]
  attr :settings, :map, default: nil

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form
        :let={f}
        for={@form}
        id={@id}
        phx-change="validate"
        phx-submit="submit"
        phx-target={@myself}
      >
        <.input field={f[:a_name]} label="Team A's Name" />
        <.input field={f[:b_name]} label="Team B's Name" />

        <.input field={f[:set_limit]} label="Set Limit" />

        <div class="mt-6 flex justify-end">
          <%= if @type == :create do %>
            <.button type="submit" variant="primary" class="btn-block">
              Start Match <.icon name="hero-flag" class="size-4 ml-2" />
            </.button>
          <% else %>
            <.button type="submit" variant="primary">
              Save <.icon name="hero-beaker-solid" />
            </.button>
          <% end %>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{type: type} = assigns, socket) do
    settings = assigns[:settings] || %Scoring.Match.Settings{}

    changeset =
      Scoring.Match.settings_changeset(settings)

    {:ok,
     assign(socket, id: assigns.id, type: type, settings: settings) |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"settings" => params}, socket) do
    changeset =
      socket.assigns.settings
      |> Scoring.Match.settings_changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("submit", %{"settings" => params}, socket) do
    case Scoring.Match.settings_changeset(%Scoring.Match.Settings{}, params) do
      %Ecto.Changeset{valid?: true} ->
        send(self(), {:submit_settings, params})
        {:noreply, socket}

      changeset ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
