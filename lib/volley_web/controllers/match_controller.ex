defmodule VolleyWeb.MatchController do
  use VolleyWeb, :controller

  def delete(conn, %{"id" => id}) do
    if match = Volley.Scoring.get_match_by_public_id(conn.assigns.current_scope, id) do
      {:ok, _match} = Volley.Scoring.delete_match(conn.assigns.current_scope, match)
      redirect(conn, to: ~p"/")
    else
      raise VolleyWeb.NotFoundError, "Match with id #{id} does not exist!"
    end
  end
end
