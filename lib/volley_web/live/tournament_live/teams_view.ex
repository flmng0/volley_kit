defmodule VolleyWeb.TournamentLive.TeamsView do
  use VolleyWeb, :live_component

  alias Volley.Tournaments.Division

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div :if={@divisions_empty?} class="alert alert-warning mb-4">
        <.icon name="hero-exclamation-triangle" class="size-6" />
        <div>
          <p class="font-bold">No divisions!</p>
          <p>There are currently no divisions set up for your tournament.</p>
          <p>Create your first one below.</p>
        </div>
      </div>

      <.render_create_form
        :if={@divisions_empty?}
        variant="block"
        form={@form}
        target={@myself}
      />
    </div>
    """
  end

  @impl true
  def update(%{tournament: tournament, scope: scope}, socket) do
    socket =
      socket
      |> assign(:scope, scope)
      |> assign(:tournament_id, tournament.id)
      |> assign(:division, %Division{})
      |> assign(:divisions_empty?, tournament.divisions == [])
      |> stream(:divisions, tournament.divisions)
      |> assign_form(%{})

    {:ok, socket}
  end

  @impl true
  def handle_event("validate_division", %{"division" => params}, socket) do
    {:noreply, assign_form(socket, params, action: :validate)}
  end

  def handle_event("submit_division", %{"division" => params}, socket) do
    %{scope: scope, tournament_id: tournament_id} = socket.assigns

    case Volley.Tournaments.create_tournament_division(scope, tournament_id, params) do
      {:ok, division} ->
        socket =
          socket
          |> stream_insert(:divisions, division)
          |> assign(:divisions_empty?, false)
          |> assign_form(%{})

        send(self(), :created_division)

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, params, opts \\ [])

  defp assign_form(socket, %Ecto.Changeset{} = changeset, opts) do
    assign(socket, :form, to_form(changeset, opts ++ [as: "division"]))
  end

  defp assign_form(socket, params, opts) do
    changeset = Division.changeset(socket.assigns.division, params)
    assign_form(socket, changeset, opts)
  end

  attr :form, Phoenix.HTML.Form
  attr :variant, :string, default: "block", values: ~w(block inline)
  attr :target, :any

  defp render_create_form(assigns) do
    assigns =
      assign_new(assigns, :division_options, fn ->
        Division.types_list()
        |> Enum.map(fn type ->
          {div_type_text(type), type}
        end)
      end)

    ~H"""
    <.form
      :let={f}
      for={@form}
      phx-change="validate_division"
      phx-submit="submit_division"
      phx-target={@target}
    >
      <fieldset class={[
        "flex fieldset bg-base-200 border border-base-300 px-4 py-2 rounded-md",
        @variant == "block" && "flex-col",
        @variant == "inline" && "flex-row gap-x-2"
      ]}>
        <legend class="fieldset-legend">New Division Details</legend>
        <.input
          type="text"
          field={f[:name]}
          placeholder={@variant == "inline" && "Name"}
          label={@variant == "block" && "Name"}
          wrapper_class={@variant == "inline" && "flex-grow"}
        />
        <.input
          type="select"
          field={f[:type]}
          options={@division_options}
          label={@variant == "block" && "Type"}
          wrapper_class={@variant == "inline" && "flex-grow"}
        />
        <.input
          type="number"
          field={f[:max_age]}
          placeholder={@variant == "inline" && "Max Age"}
          label={@variant == "block" && "Max Age"}
          wrapper_class={@variant == "inline" && "flex-grow"}
        />

        <.button variant="create" class={@variant == "block" && "self-end"}>
          <.icon name="hero-plus" />
          {if @variant == "block", do: "Create"}
        </.button>
      </fieldset>
    </.form>
    """
  end

  defp div_type_text(:mixed), do: "Mixed"
  defp div_type_text(:men), do: "Men's"
  defp div_type_text(:women), do: "Women's"
end
