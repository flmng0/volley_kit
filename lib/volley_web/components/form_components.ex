defmodule VolleyWeb.FormComponents do
  defmodule Match do
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
end
