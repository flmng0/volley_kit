defmodule VolleyWeb.ScratchController do
  use VolleyWeb, :controller

  alias Volley.Scoring

  def new(conn, _params) do
    if match = Scoring.get_match(conn.assigns.current_scope) do
      redirect(conn, to: ~p"/scratch/#{match}")
    else
      {:ok, match} = Scoring.start_match(conn.assigns.current_scope, %{})
      redirect(conn, to: ~p"/scratch/#{match}")
    end
  end

  def delete(conn, %{"id" => id}) do
    if match = Scoring.get_match_by_public_id(conn.assigns.current_scope, id) do
      Scoring.delete_match(conn.assigns.current_scope, match)
      redirect(conn, to: ~p"/")
    end
  end
end
