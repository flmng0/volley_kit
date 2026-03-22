defmodule VolleyWeb.MatchLive.PutMatch do
  use VolleyWeb, :live_component

  def on_mount(:default, %{"id" => id}, _session, socket) do
    if match = Volley.Scoring.get_match_by_public_id(socket.assigns.current_scope, id) do
      {:cont, assign(socket, :match, match)}
    else
      raise VolleyWeb.NotFoundError, "Match with that ID does not exist"
    end
  end
end
