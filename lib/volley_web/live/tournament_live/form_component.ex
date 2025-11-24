defmodule VolleyWeb.TournamentLive.FormComponent do
  use VolleyWeb, :live_component

  alias Volley.Tournaments.Tournament

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
        class="flex flex-col"
      >
        <.step number={1} title="Name Your Tournament">
          <.input field={f[:name]} label="Tournament Name*" />
        </.step>

        <div class="divider" />

        <.step number={2} title="Setup Teams" subtitle="This can be completed later!">
          <fieldset class="fieldset">
            <.inputs_for :let={team} field={f[:teams]}>
              <.team_card team={team} />
            </.inputs_for>

            <.button
              type="button"
              variant="create"
              class="btn-sm btn-wide"
              name="tournament[teams_sort][]"
              value="new"
              phx-click={JS.dispatch("change")}
            >
              Add Team
            </.button>
          </fieldset>
        </.step>

        <%!-- <div class="divider" /> --%>
        <%!----%>
        <%!-- <.step number={3} title="Create Fixtures" subtitle="This can also be completed later!"> --%>
        <%!-- </.step> --%>

        <div class="flex justify-between mt-8">
          <.button href={~p"/"} variant="neutral" class="btn-wide">Cancel</.button>
          <.button type="submit" variant="primary" class="btn-wide">Submit</.button>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:tournament, %Tournament{})
      |> assign_form()

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", params, socket) do
    %{"tournament" => tournament_params} = params

    {:noreply, assign_form(socket, tournament_params, action: :validate)}
  end

  def handle_event("submit", params, socket) do
    %{"tournament" => tournament_params} = params

    case Tournament.changeset(socket.assigns.tournament, tournament_params) do
      %Ecto.Changeset{valid?: true} = _changeset ->
        {:noreply, socket}

      changeset ->
        {:noreply, assign_form(socket, changeset, action: :validate)}
    end
  end

  defp assign_form(socket, params_or_changeset \\ %{}, opts \\ [])

  defp assign_form(socket, %Ecto.Changeset{} = changeset, opts) do
    form = to_form(changeset, opts ++ [as: "tournament"])

    assign(socket, :form, form)
  end

  defp assign_form(socket, params, opts) do
    changeset = Tournament.changeset(socket.assigns.tournament, params)
    assign_form(socket, changeset, opts)
  end

  attr :number, :integer
  attr :title, :string
  attr :subtitle, :string, default: nil

  slot :inner_block, required: true

  defp step(assigns) do
    ~H"""
    <section class="bg-base-100 p-4 rounded-box">
      <.header header_tag="h2">
        <span class="slashed-zero text-base-content/70">
          #{String.pad_leading(to_string(@number), 2, "0")}
        </span>
        {@title}
        <:subtitle :if={@subtitle}>{@subtitle}</:subtitle>
      </.header>

      <div>
        {render_slot(@inner_block)}
      </div>
    </section>
    """
  end

  attr :team, Phoenix.HTML.Form

  defp team_card(assigns) do
    assigns =
      assign_new(assigns, :name, fn ->
        name = assigns.team[:name].value

        if is_nil(name) or name == "" do
          nil
        else
          name
        end
      end)

    ~H"""
    <input type="hidden" name="tournament[teams_sort][]" value={@team.index} />

    <details
      class="collapse bg-base-200 group"
      phx-mounted={
        JS.remove_attribute("open", to: ".collapse")
        |> JS.set_attribute({"open", "true"})
      }
    >
      <summary class="collapse-title px-4 py-2 space-x-2">
        <.icon
          name="hero-chevron-down"
          class="is-collapse-open:-rotate-180 transition-transform size-4"
        />
        <span class="text-base-content font-bold leading-6">Team #{@team.index + 1}</span>
        <span class={[
          "is-collapse-open:hidden badge badge-sm",
          if(@name, do: "badge-neutral", else: "badge-warning")
        ]}>
          {@name || "No name set!"}
        </span>

        <.button
          type="button"
          variant="delete"
          class="btn-ghost btn-circle btn-sm float-right"
          name="tournament[teams_drop][]"
          value={@team.index}
          phx-click={JS.dispatch("change")}
        >
          <.icon name="hero-trash" />
        </.button>
      </summary>

      <div class="collapse-content text-sm">
        <.input field={@team[:name]} label="Team Name*" class="w-full input input-sm" />

        <fieldset class="fieldset gap-1">
          <span class="fieldset-label">Players</span>

          <.inputs_for :let={player} field={@team[:players]}>
            <input type="hidden" name={"#{@team.name}[players_sort][]"} value={player.index} />

            <div class="flex gap-1 items-start">
              <.input
                field={player[:name]}
                placeholder="Name*"
                container_class="grow py-0"
                class="w-full input input-sm"
              />
              <.input
                field={player[:number]}
                placeholder="Number"
                container_class="grow py-0"
                class="w-full input input-sm"
                type="text"
                inputmode="numeric"
              />

              <.button
                type="button"
                variant="ghost"
                class="btn-circle btn-sm"
                name={"#{@team.name}[players_drop][]"}
                value={player.index}
                phx-click={JS.dispatch("change")}
              >
                <.icon name="hero-minus" />
              </.button>
            </div>
          </.inputs_for>

          <.button
            type="button"
            variant="create"
            name={"#{@team.name}[players_sort][]"}
            class="btn-sm justify-self-start"
            value="new"
            phx-click={JS.dispatch("change")}
          >
            Add Player
          </.button>
        </fieldset>
      </div>
    </details>
    """
  end
end
