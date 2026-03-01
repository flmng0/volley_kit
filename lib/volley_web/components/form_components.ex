defmodule VolleyWeb.FormComponents do
  @moduledoc """
  Collection of form fieldsets to stay consistent across 
  different parts of the project.
  """

  defmodule Match do
    @moduledoc "Field layouts relating to matches."
    use VolleyWeb, :live_component

    attr :form, Phoenix.HTML.Form
    attr :type, :string, values: ~w(create update)

    def settings(assigns) do
      ~H"""
      <.input field={@form[:a_name]} label="Team A's Name" placeholder="Team A" />
      <.input field={@form[:b_name]} label="Team B's Name" placeholder="Team B" />

      <.input field={@form[:set_limit]} label="Set Limit" type="text" inputmode="numeric" />

      <div class="mt-6 flex justify-end items-center gap-4">
        <%= if @type == "create" do %>
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
      """
    end
  end

  defmodule Tournament do
    @moduledoc "Field layouts relating to tournaments."
    use VolleyWeb, :live_component

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
          <li>
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
          </li>
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
            <li class="list-item group">
              <div class="group-data-editing:block hidden">Test 1</div>
              <div class="group-data-editing:hidden">Test 2</div>
              <span>{team.name}</span>
              <.button
                type="button"
                phx-click={JS.toggle_attribute({"data-editing", "true"}, to: {:closest, "li"})}
              >
                Edit
              </.button>
            </li>
          </.inputs_for>
        </ul>
        <.button
          type="button"
          name="tournament[sort_teams][]"
          value="new"
          phx-click={JS.dispatch("change")}
          class="dark:btn-soft btn-block"
        >
          Add Team
        </.button>
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
end
