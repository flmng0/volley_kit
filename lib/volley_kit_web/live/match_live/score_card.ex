defmodule VolleyKitWeb.MatchLive.ScoreCard do
  alias VolleyKit.Manager
  use VolleyKitWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <section class={["flex-1 w-full aspect-square", color(@variant)]} id={@id} phx-hook="ScoreCard">
      <.dynamic_tag
        name={if @is_owner, do: "button", else: "div"}
        class="w-full h-full flex flex-col justify-center items-center gap-6"
        phx-click={@is_owner && "increment"}
        phx-target={@is_owner && @myself}
      >
        <span class="text-lg"><%= @team.sets %></span>
        <div class="text-4xl relative">
          <span class="old-score absolute inset-0" id={@id <> "-old-score"} phx-update="ignore">
          </span>
          <span class="score block"><%= @team.points %></span>
        </div>
        <span><%= @team.name %></span>
      </.dynamic_tag>
    </section>
    """
  end

  @impl true
  def handle_event(event, params, socket) do
    if socket.assigns.is_owner do
      apply_event(event, params, socket)
    else
      socket =
        put_flash(socket, :error, "You are not the owner of this match. Action not allowed.")

      {:noreply, socket}
    end
  end

  def apply_event("increment", _params, socket) do
    {:ok, team} =
      Manager.update_team(socket.assigns.team, %{points: socket.assigns.team.points + 1})

    notify_parent({:increment, socket.assigns.variant, team.points})

    {:noreply, assign(socket, :team, team)}
  end

  def notify_parent(msg) do
    send(self(), {__MODULE__, msg})
  end

  @type variant :: :a | :b

  @spec color(variant()) :: String.t()

  defp color(:a), do: "bg-blue-700 text-white"
  defp color(:b), do: "bg-red-700 text-white"
end
