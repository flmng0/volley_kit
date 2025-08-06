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
    if socket.assigns[:settings] do
      {:ok, socket}
    else
      socket =
        socket
        |> assign(id: assigns.id, type: type)
        |> apply_update(assigns, type)

      {:ok, socket}
    end
  end

  def apply_update(socket, _assigns, :create) do
    form =
      Scoring.Settings
      |> AshPhoenix.Form.for_create(:create)
      |> to_form()

    assign(socket, form: form, trigger_submit: false)
  end

  def apply_update(socket, assigns, :update) do
    form =
      assigns.settings
      |> AshPhoenix.Form.for_update(:update)
      |> to_form()

    assign(socket, form: form)
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("submit", %{"form" => form}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: form) do
      {:ok, settings} ->
        send(self(), {:submit_settings, settings})
        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
    end
  end
end
