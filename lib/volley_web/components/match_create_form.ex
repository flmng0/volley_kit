defmodule VolleyWeb.MatchCreateForm do
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

        <details
          class="collapse collapse-plus bg-base-300 mt-4"
          phx-mounted={JS.ignore_attributes("open")}
        >
          <summary class="collapse-title">Match Configuration</summary>

          <div class="collapse-content">
            <p class="label text-sm">Want to apply a preset?</p>
            <div class="flex flex-row flex-wrap gap-1 justify-between mb-2">
              <.button
                :for={{key, preset} <- Settings.presets()}
                variant="neutral"
                type="button"
                class="flex-grow"
                phx-click="select_preset"
                phx-value-key={key}
                phx-target={@myself}
              >
                {preset.title}
              </.button>
            </div>

            <.input
              field={@form[:set_limit]}
              label="Set Limit"
              type="text"
              inputmode="numeric"
              placeholder="25"
            />

            <.input field={@form[:total_sets]} label="Total Sets" placeholder="Unlimited" />
            <.input
              field={@form[:final_set_limit]}
              label="Final Set Limit"
              placeholder="Same as other sets"
              disabled={final_set_disabled(@form)}
            />
          </div>
        </details>

        <div class="mt-6 flex justify-end items-center gap-4">
          <.button type="submit" variant="primary" class="btn-block">
            Start Match <.icon name="hero-flag" class="size-4 ml-2" />
          </.button>
        </div>
      </.form>
    </div>
    """
  end

  defp final_set_disabled(form) do
    total_sets = Phoenix.HTML.Form.input_value(form, :total_sets)
    not is_integer(total_sets) || total_sets < 2
  end

  @impl true
  def update(assigns, socket) do
    settings = %Settings{}
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

  def handle_event("select_preset", %{"key" => key}, socket) do
    key_atom = String.to_existing_atom(key)
    preset = Settings.presets()[key_atom]
    changeset = Settings.changeset(socket.assigns.settings, preset)

    {:noreply, assign_form(socket, changeset)}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
