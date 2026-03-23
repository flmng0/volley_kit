defmodule VolleyWeb.MatchLive.Create do
  use VolleyWeb, :live_view

  alias Volley.Accounts
  alias Volley.Scoring
  alias Volley.Scoring.Settings

  @impl true
  def mount(params, _session, socket) do
    existing_match =
      not Accounts.known_user?(socket.assigns.current_scope) &&
        Scoring.get_recent_match(socket.assigns.current_scope)

    settings = %Settings{}
    changeset = Settings.changeset(settings)

    socket =
      socket
      |> assign(:return_to, params["return_to"])
      |> assign(:existing_match, existing_match)
      |> assign(:settings, settings)
      |> assign_form(changeset)

    {:ok, socket}
  end

  defp final_set_disabled(form) do
    total_sets = Phoenix.HTML.Form.input_value(form, :total_sets)
    not is_integer(total_sets) || total_sets < 2
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
    case Scoring.start_match(socket.assigns.current_scope, params) do
      {:ok, match} ->
        navigate_to = socket.assigns.return_to || ~p"/match/#{match}/score"

        socket =
          socket
          |> put_flash(:info, "Created match successfully")
          |> push_navigate(to: navigate_to)

        {:noreply, socket}

      {:erorr, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("select_preset", %{"key" => key}, socket) do
    key_atom = String.to_existing_atom(key)
    preset = Settings.presets()[key_atom]
    changeset = Settings.changeset(socket.assigns.settings, preset)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("delete_existing", _params, socket) do
    {:ok, _match} =
      Scoring.delete_match(socket.assigns.current_scope, socket.assigns.existing_match)

    {:noreply, assign(socket, :existing_match, nil)}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
