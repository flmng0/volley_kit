defmodule VolleyKitWeb.MatchLive do
  use VolleyKitWeb, :live_view

  defp inc_score(%{score: score} = state), do: %{state | score: score + 1}

  defp team_ids, do: ["a", "b"]

  defp teams,
    do: %{
      "a" => %{name: "Team A", score: 0, color: "bg-blue-700 text-white"},
      "b" => %{name: "Team B", score: 0, color: "bg-red-700 text-white"}
    }

  defp enum_teams(ids, teams) do
    Enum.map(ids, fn id -> {teams[id], id} end)
  end

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:teams, teams())
      |> assign(:page_title, "Showing Match")

    {:ok, socket}
  end

  @impl true
  def handle_event("increment", %{"team" => team}, socket) do
    socket =
      update(socket, :teams, fn teams ->
        Map.update!(teams, team, &inc_score(&1))
      end)

    {:noreply, socket}
  end

  defp increment(js \\ %JS{}, team) do
    js
    |> JS.push("increment", value: %{"team" => team})
  end

  attr :class, :string, default: nil
  attr :id, :string, required: true
  attr :on_click, :any, required: true, doc: "callback for when this score is incremented"

  attr :value, :integer, required: true

  def score_card(assigns) do
    ~H"""
    <section id={@id} class={["flex-1 w-full aspect-square", @class]}>
      <button class="w-full h-full grid place-items-center" phx-click={@on_click}>
        <span class="text-4xl"><%= @value %></span>
      </button>
    </section>
    """
  end
end
