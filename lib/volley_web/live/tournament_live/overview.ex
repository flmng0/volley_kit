defmodule VolleyWeb.TournamentLive.Overview do
  use VolleyWeb, :live_view

  alias Volley.Tournaments

  @impl true
  def mount(_params, _session, socket) do
    time_zone_opts = VolleyWeb.Util.collect_timezone_options()

    {:ok, assign(socket, valid_time_zones: time_zone_opts)}
  end

  @impl true
  def handle_info({:updated_tournament, tournament}, socket) do
    {:noreply, assign(socket, tournament: tournament)}
  end
end
