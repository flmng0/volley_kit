defmodule VolleyWeb.LiveForm do
  use VolleyWeb, :live_component

  attr :changeset_fn, {:fun, 1}
  attr :submit_fn, {:fun, 1}
  attr :message_fn, {:fun, 1}
  attr :class, :string, default: nil

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
        class={@class}
      >
        {render_slot(@inner_block, %{
          form: @form,
          cid: @myself,
          clean?: @clean?,
          cancel: JS.push("cancel", target: @myself)
        })}
      </.form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_new(:submit_fn, fn %{changeset_fn: csfn} ->
        &Ecto.Changeset.apply_action(csfn.(&1), :insert)
      end)
      |> assign_form(%{})

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", params, socket) do
    params = params[socket.assigns.form.name]
    {:noreply, assign_form(socket, params, action: :validate)}
  end

  def handle_event("submit", params, socket) do
    params = params[socket.assigns.form.name]

    case socket.assigns.submit_fn.(params) do
      {:ok, result} ->
        message = socket.assigns.message_fn.(result)
        send(self(), message)
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
    |> assign(:form, to_form(changeset, opts))
  end

  defp assign_form(socket, params, opts) do
    changeset = socket.assigns.changeset_fn.(params)
    assign_form(socket, changeset, opts)
  end
end
