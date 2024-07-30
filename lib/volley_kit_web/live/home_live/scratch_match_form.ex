defmodule VolleyKitWeb.HomeLive.ScratchMatchForm do
  alias VolleyKitWeb.HomeLive
  alias VolleyKit.Manager
  use VolleyKitWeb, :live_component

  alias VolleyKit.Manager.ScratchMatchOptions

  @form_name "scratch_match_options"

  def mount(socket) do
    changeset =
      %ScratchMatchOptions{a_name: "Team A", b_name: "Team B", set_count: 3}
      |> ScratchMatchOptions.changeset()

    {:ok, assign_form(socket, changeset)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <HomeLive.section_card
        title="Create Scratch Match"
        subtitle="A quick way to start a match without worrying about configuration. Also currently the only way to start a match..."
      >
        <.form
          for={@form}
          id={@form.id}
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
          class="flex flex-col gap-10"
        >
          <div id={@form.id <> "-options"} class="group bg-gray-100 rounded-md">
            <button
              type="button"
              class="text-center px-4 py-3 font-bold tracking-wide w-full"
              phx-click={
                JS.toggle_attribute({"aria-expanded", "true"}, to: "#" <> @form.id <> "-options")
              }
            >
              <.icon
                name="hero-chevron-right"
                class="w-4 h-4 group-aria-expanded:rotate-90 transition-transform"
              /> More Options
            </button>
            <div class="hidden group-aria-expanded:flex border-t border-gray-200 px-4 py-3 flex-col gap-y-4">
              <fieldset class="flex flex-row flex-wrap gap-x-6">
                <.input class="grow basis-32" field={@form[:a_name]} type="text" label="Team A Name:" />
                <.input class="grow basis-32" field={@form[:b_name]} type="text" label="Team B Name:" />
              </fieldset>

              <%!-- Note to self: re-add set count in when you can be bothered to implement it --%>
              <%!-- <.input --%>
              <%!--   field={@form[:set_count]} --%>
              <%!--   type="number" --%>
              <%!--   min={1} --%>
              <%!--   max={99} --%>
              <%!--   step={1} --%>
              <%!--   label="Set Count:" --%>
              <%!-- /> --%>
            </div>
          </div>

          <.button class="self-center tracking-wider uppercase px-12">Start Match</.button>
        </.form>
      </HomeLive.section_card>
    </div>
    """
  end

  def handle_event("validate", %{@form_name => options}, socket) do
    changeset =
      %ScratchMatchOptions{}
      |> ScratchMatchOptions.changeset(options)

    {:noreply, assign_form(socket, changeset, action: :validate)}
  end

  def handle_event("save", %{@form_name => options}, socket) do
    case Manager.create_scratch_match(socket.assigns.user_id, options) do
      {:ok, scratch_match} ->
        %{"a_name" => a_name, "b_name" => b_name} = options

        socket =
          socket
          |> put_flash(:info, "Starting scratch match between #{a_name} vs. #{b_name}")
          |> push_navigate(to: ~p"/scratch/#{scratch_match.id}")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket =
          socket
          |> put_flash(:error, "Failed to submit")
          |> assign_form(changeset.changes.options, action: :validate)

        {:noreply, socket}
    end
  end

  def assign_form(socket, %Ecto.Changeset{} = changeset, args \\ []) do
    form = to_form(changeset, Keyword.put(args, :as, @form_name))

    assign(socket, form: form)
  end
end
