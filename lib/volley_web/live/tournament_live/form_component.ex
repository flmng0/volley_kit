defmodule VolleyWeb.TournamentLive.FormComponent do
  @moduledoc """
  Live component to render and validate a tournament forms.

  This also has some function-components that unify the layout
  of different sections across pages, for example:

  - `details/1`
  - `divisions/1`
  """
  use VolleyWeb, :live_component

  attr :changeset_fn, {:fun, 1}
  attr :submit_fn, {:fun, 1}

  attr :title, :string, default: nil
  attr :subtitle, :string, default: nil

  slot :inner_block, required: true

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form
        for={@form}
        phx-change="validate"
        phx-submit="submit"
        phx-target={@myself}
        class="flex flex-col gap-8"
      >
        <.header>
          {@title}
          <:subtitle :if={@subtitle}>{@subtitle}</:subtitle>
          <:actions>
            <.button variant="save" disabled={@clean?}>Save</.button>
            <.button
              type="button"
              variant="cancel"
              phx-click="cancel"
              phx-target={@myself}
              disabled={@clean?}
            >
              Revert Changes
            </.button>
          </:actions>
        </.header>

        {render_slot(@inner_block, @form)}
      </.form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
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
    case socket.assigns.submit_fn.(params) do
      {:ok, tournament} ->
        send(self(), {:updated_tournament, tournament})
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("cancel", _params, socket) do
    {:noreply, assign_form(socket, %{})}
  end

  defp assign_form(socket, params_or_changeset, opts \\ [])

  defp assign_form(socket, %Ecto.Changeset{} = changeset, opts) do
    clean? = Enum.empty?(changeset.changes)

    socket
    |> assign(:clean?, clean?)
    |> assign(:form, to_form(changeset, opts ++ [as: "tournament"]))
  end

  defp assign_form(socket, params, opts) do
    changeset = socket.assigns.changeset_fn.(params)
    assign_form(socket, changeset, opts)
  end

  attr :form, Phoenix.HTML.Form, required: true
  attr :time_zone_options, :list, required: true

  def details(assigns) do
    ~H"""
    <fieldset class="fieldset">
      <.input field={@form[:name]} label="Tournament Name*" id="tournament_name_input" />
      <.input field={@form[:location]} label="Location" />

      <div class="alert alert-info mt-4">
        <.icon name="hero-information-circle" class="size-6" />
        <div>
          <p>All time-related settings will be in the timezone you have set below.</p>
          <p>Visitors will see this listed next to any times.</p>
        </div>
      </div>
      <.input
        field={@form[:timezone]}
        label="Timezone"
        options={@time_zone_options}
        type="select"
        id="timezone_select"
        phx-hook="AutofillTimezone"
      />

      <.input
        field={@form[:start]}
        label="Tournament Start"
        type="datetime-local"
        wrapper_class="mb-2 mt-4"
      />
      <.input field={@form[:end]} label="Tournament End" type="datetime-local" />
    </fieldset>
    """
  end

  attr :form, Phoenix.HTML.Form, required: true
  attr :disable_focus?, :boolean, default: false

  def divisions(assigns) do
    ~H"""
    <ul>
      <.inputs_for :let={div} field={@form[:divisions]}>
        <.input
          type="text"
          field={div[:name]}
          placeholder="Name of division"
          phx-hook="HijackEnter"
          phx-mounted={not @disable_focus? && JS.focus()}
          data-onenter={JS.exec("phx-click", to: "#add_division")}
        >
          <:actions>
            <.button
              type="button"
              name="tournament[drop_divisions][]"
              value={div.index}
              phx-click={JS.dispatch("change")}
            >
              <.icon name="hero-trash" />
            </.button>
          </:actions>
        </.input>
        <input type="hidden" name="tournament[sort_divisions][]" value={div.index} />
      </.inputs_for>
    </ul>

    <input type="hidden" name="tournament[drop_divisions][]" />

    <.button
      type="button"
      name="tournament[sort_divisions][]"
      value="new"
      phx-click={JS.dispatch("change")}
      class="dark:btn-soft btn-block"
      id="add_division"
    >
      Add Division
    </.button>
    """
  end

  attr :form, Phoenix.HTML.Form, required: true

  def teams(assigns) do
    ~H"""
    <fieldset class="fieldset">
      <ul class="list">
        <.inputs_for :let={team} field={@form[:teams]}>
          <li class="list-item">
            <span>{team.name}</span>
          </li>
        </.inputs_for>
      </ul>
    </fieldset>
    """
  end

  attr :form, Phoenix.HTML.Form, required: true

  def registration(assigns) do
    ~H"""
    <fieldset class="fieldset">
      <.input field={@form[:registration_price]} label="Registration Price" type="money" />
      <.datetime_input field={@form[:registration_opened_at]} label="Registration Open Date" />
      <.datetime_input field={@form[:registration_closed_at]} label="Registration Close Date" />
    </fieldset>
    """
  end

  attr :field, Phoenix.HTML.FormField, required: true
  attr :label, :string, required: true

  defp datetime_input(assigns) do
    ~H"""
    <.input
      field={@field}
      label={@label}
      type="datetime-local"
    >
      <:actions>
        <.button
          type="button"
          phx-click={JS.dispatch("vk:filldate", to: "##{@field.id}")}
        >
          Set to Now
        </.button>
        <.button
          variant="neutral"
          type="button"
          phx-click={JS.dispatch("vk:clear", to: "##{@field.id}")}
        >
          Clear
        </.button>
      </:actions>
    </.input>
    """
  end
end
