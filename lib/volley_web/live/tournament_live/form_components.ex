defmodule VolleyWeb.TournamentLive.FormComponents do
  use VolleyWeb, :html

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
