defmodule VolleyKitWeb.MatchLive do
  use VolleyKitWeb, :live_view

  alias VolleyKitWeb.MatchLive.ScoreCard

  defp team_variants, do: [:a, :b]

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Showing Match")

    {:ok, socket}
  end

  @impl true
  def handle_info({ScoreCard, {:increment, variant}}, socket) do
    IO.puts("Incremented value for #{variant}")

    {:noreply, socket}
  end
end
