defmodule VolleyKitWeb.HomeLive.NewMatchForm do
  use VolleyKitWeb, :live_component

  alias VolleyKit.Manager

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-10 shadow-lg border border-gray-300/50">
      <.header>
        Start a New Match
      </.header>

      <.simple_form
        for={@form}
        id="new_match-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="mt-10 space-y-8 bg-white"
      >
        <.input label="Team A's Name" field={@form[:team_a_name]}></.input>
        <.input label="Team B's Name" field={@form[:team_b_name]}></.input>

        <:actions>
          <.button class="w-full">Start!</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    changeset = form_changeset(%{})

    {:ok, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("validate", %{"new_match" => new_match}, socket) do
    changeset = form_changeset(new_match) |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"new_match" => new_match}, socket) do
    case Manager.create_match(%{
           owner: socket.assigns.user_id,
           team_a: %{name: new_match["team_a_name"]},
           team_b: %{name: new_match["team_b_name"]}
         }) do
      {:ok, _} ->
        {:noreply, push_navigate(socket, to: ~p"/match/current")}

      {:error, %Ecto.Changeset{}} ->
        changeset = form_changeset(new_match) |> Map.put(:action, :validate)

        {:noreply, assign_form(socket, changeset)}
    end
  end

  @form_types %{team_a_name: :string, team_b_name: :string}

  def form_changeset(%{} = params) do
    {%{}, @form_types}
    |> Ecto.Changeset.cast(params, Map.keys(@form_types))
    |> Ecto.Changeset.validate_required(Map.keys(@form_types))
  end

  def assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset, as: "new_match"))
  end
end
