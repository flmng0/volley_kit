defmodule VolleyWeb.TournamentLive.Setup do
  use VolleyWeb, :live_view

  alias Volley.Tournaments.Tournament

  embed_templates "setup/*.html"

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
        <.details form={@form} valid_time_zones={@valid_time_zones} />
      </:step>
      <:step name="Divisions" key={:divisions} icon="hero-users-solid">
        <.divisions form={@form} />
      </:step>
      <:step name="Registration" key={:registration} icon="hero-book-open-solid">
        <.registration />

        <div class="flex justify-between">
          <.button patch={~p"/tournament/setup/divisions"}>Back</.button>
          <.button variant="create">Create Tournament</.button>
        </div>
      </:step>
    </Layouts.stepped>
    """
  end

  defp divisions_empty?(%Phoenix.HTML.Form{} = form) do
    a = form[:divisions].value || []
    b = form.source.changes[:divisions] || []
    a ++ b == []
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
      {:noreply, push_patch(socket, to: ~p"/tournament/setup/details", replace: true)}
    else
      socket =
        socket
        |> apply_action(socket.assigns.live_action)
        |> assign_form(%{})

      {:noreply, socket}
    end
  end

  defp apply_action(socket, :details) do
    assign(socket, :valid_time_zones, VolleyWeb.Util.collect_timezone_options())
  end

  defp apply_action(socket, _action), do: socket

  @impl true
  def handle_event("update", %{"tournament" => params}, socket) do
    {:noreply, assign_form(socket, params, action: :validate)}
  end

  def handle_event("next", %{"tournament" => params}, socket) do
    changeset_fn = changeset(socket.assigns.live_action)
    changeset = changeset_fn.(socket.assigns.tournament, params)

    case Ecto.Changeset.apply_action(changeset, :insert) do
      {:ok, tournament} ->
        socket =
          socket
          |> assign(:tournament, tournament)
          |> apply_next(socket.assigns.live_action)

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("skip", _params, socket) do
    {:noreply, apply_next(socket, :divisions)}
  end

  defp apply_next(socket, action) do
    socket
    |> update(:completed_steps, &(&1 ++ [action]))
    |> push_patch(to: next_route(action))
  end

  defp next_route(:details), do: ~p"/tournament/setup/divisions"
  defp next_route(:divisions), do: ~p"/tournament/setup/registration"

  defp changeset(:details), do: &Tournament.details_setup_changeset/2
  defp changeset(:divisions), do: &Tournament.divisions_setup_changeset/2
  defp changeset(:registration), do: &Tournament.divisions_setup_changeset/2

  defp assign_form(socket, params_or_changeset, opts \\ [])

  defp assign_form(socket, %Ecto.Changeset{} = changeset, opts) do
    assign(socket, :form, to_form(changeset, opts ++ [as: "tournament"]))
  end

  defp assign_form(socket, params, opts) do
    changeset_fn = changeset(socket.assigns.live_action)
    assign_form(socket, changeset_fn.(socket.assigns.tournament, params), opts)
  end
end
