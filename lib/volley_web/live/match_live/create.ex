defmodule VolleyWeb.MatchLive.Create do
  use VolleyWeb, :live_view
  alias Volley.Scoring
  alias Volley.Scoring.Settings

  @impl true
  def mount(_params, _session, socket) do
    settings = %Settings{}
    changeset = Settings.changeset(settings)

    socket =
      socket
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
        socket =
          socket
          |> put_flash(:info, "Created match successfully")
          |> push_navigate(to: ~p"/match/#{match}/score")

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

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
