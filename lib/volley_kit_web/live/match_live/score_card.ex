defmodule VolleyKitWeb.MatchLive.ScoreCard do
  use VolleyKitWeb, :live_component

  def mount(socket) do
    socket =
      socket
      |> assign(:score, 0)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <section class={["flex-1 w-full aspect-square", color(@variant)]} id={@id}>
      <button class="w-full h-full grid place-items-center" phx-click="increment" phx-target={@myself}>
        <span class="score text-4xl"><%= @score %></span>
      </button>
    </section>
    """
  end

  def handle_event("increment", _params, socket) do
    notify_parent({:increment, socket.assigns.variant})

    socket =
      socket
      |> update(:score, &(&1 + 1))

    {:noreply, socket}
  end

  def notify_parent(msg) do
    send(self(), {__MODULE__, msg})
  end

  @type variant :: :a | :b

  @spec color(variant()) :: String.t()

  defp color(:a), do: "bg-blue-700 text-white"
  defp color(:b), do: "bg-red-700 text-white"
end
