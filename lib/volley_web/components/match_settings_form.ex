defmodule VolleyWeb.MatchSettingsForm do
  use VolleyWeb, :live_component

  alias Volley.Scoring.Settings

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form
        for={@form}
        id={@id}
        phx-change="validate"
        phx-submit="submit"
        phx-target={@myself}
      >
        <.input field={@form[:a_name]} label="Team A's Name" placeholder="Team A" />
        <.input field={@form[:b_name]} label="Team B's Name" placeholder="Team B" />

        <.input
          field={@form[:set_limit]}
          label="Set Limit"
          type="text"
          inputmode="numeric"
          placeholder="25"
        />

        <.input field={@form[:total_sets]} label="Total Sets" />
        <.input field={@form[:final_set_limit]} label="Final Set Limit" />

        <div class="mt-6 flex justify-end items-center gap-4">
          <%= if @type == :create do %>
            <.button type="submit" variant="primary" class="btn-block">
              Start Match <.icon name="hero-flag" class="size-4 ml-2" />
            </.button>
          <% else %>
            <div
              :if={used_input?(@form[:set_limit])}
              class="alert alert-warning grow py-2"
            >
              <.icon name="hero-exclamation-triangle" />
              <span>Warning: changing set limit will reset scores and sets as well!</span>
            </div>
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
  def update(assigns, socket) do
    settings = assigns[:settings] || %Settings{}

    changeset = Settings.changeset(settings)

    socket =
      socket
      |> assign(assigns)
      |> assign(:settings, settings)
      |> assign_form(changeset)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"settings" => params}, socket) do
    changeset =
      socket.assigns.settings
      |> Settings.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("submit", %{"settings" => params}, socket) do
    case Settings.changeset(socket.assigns.settings, params) do
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
