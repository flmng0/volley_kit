defmodule VolleyWeb.TournamentLive.Setup do
  use VolleyWeb, :live_view

  alias Volley.Tournaments.Tournament

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.stepped
      current_scope={@current_scope}
      flash={@flash}
      current_step={@live_action}
      complete={@completed_steps}
    >
      <:step name="Details" key={:details} icon="hero-pencil-solid">
        <.header>
          Details
          <:subtitle>
            Adjust the basic settings for your tournament. The only required field is the Name, and everything can be altered later.
          </:subtitle>
        </.header>

        <.live_component
          :let={form}
          module={VolleyWeb.LiveForm}
          id="details_step"
          changeset_fn={&Tournament.details_setup_changeset(@tournament, &1)}
          message_fn={&{:submit_step, &1}}
        >
          <FormComponents.Tournament.details form={form.form} time_zone_options={@valid_time_zones} />
          <div class="flex justify-end mt-4">
            <.button variant="create">Next</.button>
          </div>
        </.live_component>
      </:step>
      <:step name="Divisions" key={:divisions} icon="hero-users-solid">
        <.header>
          Divisions
          <:subtitle>
            Optionally define divisions for teams registering for your competition. For example, a men's vs. a women's division in the same tournament.
          </:subtitle>
        </.header>

        <.live_component
          :let={form}
          module={VolleyWeb.LiveForm}
          id="divisions_step"
          changeset_fn={&Tournament.divisions_setup_changeset(@tournament, &1)}
          message_fn={&{:submit_step, &1}}
          class="group"
        >
          <div class="bg-base-300 border border-base-200 w-md px-4 py-2 mx-auto mt-4">
            <FormComponents.Tournament.divisions form={form.form} />
          </div>

          <div class="flex justify-between mt-4">
            <.button patch={~p"/tournaments/setup/details"}>Back</.button>

            <div class="flex flex-col gap-2 items-end">
              <.button variant="create">Next</.button>
              <span class="group-has-[input:focus]:inline-block hidden text-right text-xs text-base-content/50">
                <kbd class="kbd kbd-sm">Shift</kbd> + <kbd class="kbd kbd-sm">Enter</kbd> to submit.
              </span>
            </div>
          </div>
        </.live_component>
      </:step>
      <:step name="Registration" key={:registration} icon="hero-book-open-solid">
        <.header>
          Registration
          <:subtitle>
            The below configures from what dates users will be allowed to register.
          </:subtitle>
        </.header>

        <.live_component
          :let={form}
          module={VolleyWeb.LiveForm}
          id="registration_step"
          changeset_fn={&Tournament.registration_setup_changeset(@tournament, &1)}
          message_fn={&{:submit_step, &1}}
        >
          <FormComponents.Tournament.registration form={form.form} />

          <div class="flex justify-between mt-4">
            <.button type="button" patch={~p"/tournaments/setup/divisions"}>Back</.button>
            <.button variant="create">Create Tournament!</.button>
          </div>
        </.live_component>
      </:step>
    </Layouts.stepped>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:tournament, %Tournament{divisions: []})
      |> assign(:completed_steps, [])

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    if socket.assigns.live_action != :details && socket.assigns.completed_steps == [] do
      {:noreply, push_patch(socket, to: ~p"/tournaments/setup/details", replace: true)}
    else
      {:noreply, apply_action(socket, socket.assigns.live_action)}
    end
  end

  defp apply_action(socket, :details) do
    assign(socket, :valid_time_zones, VolleyWeb.Util.collect_timezone_options())
  end

  defp apply_action(socket, _action), do: socket

  @impl true
  def handle_info({:submit_step, tournament}, socket) do
    socket =
      socket
      |> assign(:tournament, tournament)
      |> apply_next(socket.assigns.live_action)

    {:noreply, socket}
  end

  defp apply_next(socket, :registration) do
    tournament =
      Volley.Tournaments.complete_tournament_setup!(
        socket.assigns.current_scope,
        socket.assigns.tournament
      )

    push_navigate(socket, to: ~p"/tournaments/#{tournament}")
  end

  defp apply_next(socket, action) do
    socket
    |> update(:completed_steps, &(&1 ++ [action]))
    |> push_patch(to: next_route(action))
  end

  defp next_route(:details), do: ~p"/tournaments/setup/divisions"
  defp next_route(:divisions), do: ~p"/tournaments/setup/registration"
end
