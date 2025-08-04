defmodule VolleyWeb.ScratchMatchCard do
  use VolleyWeb, :live_component

  alias Volley.Scoring

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form
        :let={f}
        for={@form}
        id={@id}
        action={~p"/scratch/new"}
        phx-change="validate"
        phx-submit="start"
        phx-target={@myself}
        phx-trigger-action={@trigger_submit}
      >
        <.input field={f[:a_name]} label="Team A's Name" />
        <.input field={f[:b_name]} label="Team B's Name" />

        <.input field={f[:total_sets]} label="Set Count" placeholder="Leave empty for unlimited sets" />

        <.input field={f[:set_limit]} label="Set Limit" />

        <.input field={f[:final_set_limit]} label="Final Set Limit" placeholder={f[:set_limit].value} />

        <div class="mt-6 flex justify-end">
          <.button type="submit" variant="primary" class="">
            Start <.icon name="hero-chevron-right" />
          </.button>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    form =
      Scoring.Settings
      |> AshPhoenix.Form.for_create(:create)
      |> to_form()

    {:ok, assign(socket, form: form, trigger_submit: false)}
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("start", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    IO.inspect(form)

    if form.errors == [] do
      {:noreply, assign(socket, form: form, trigger_submit: true)}
    else
      {:noreply, assign(socket, :form, form)}
    end
  end
end
