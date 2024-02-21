defmodule VolleyKitWeb.MatchLive.ScoreCard do
  alias VolleyKit.Manager
  use VolleyKitWeb, :live_component

  def render(assigns) do
    ~H"""
    <section class={["flex-1 w-full aspect-square", color(@variant)]} id={@id}>
      <button
        class="w-full h-full flex flex-col justify-center gap-6"
        phx-click="increment"
        phx-target={@myself}
      >
        <span class="text-lg"><%= @team.sets %></span>
        <span class="score text-4xl"><%= @team.points %></span>
        <span><%= @team.name %></span>
      </button>
    </section>
    """
  end

  def handle_event("increment", _params, socket) do
    {:ok, team} =
      Manager.update_team(socket.assigns.team, %{points: socket.assigns.team.points + 1})

    notify_parent(:increment)

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
