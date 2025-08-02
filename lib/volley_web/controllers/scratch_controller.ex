defmodule VolleyWeb.ScratchController do
  use VolleyWeb, :controller

  alias Volley.Scoring

  def new(conn, _params) do
    match = Scoring.start_match!()

    view_match(conn, match.id)
  end

  def join(conn, %{"id" => id}) do
    with {:ok, match} <- Scoring.get_match(id) do
      view_match(conn, match.id)
    else
      _ ->
        conn
        |> put_flash(:error, "No such match exists")
        |> redirect(to: ~p"/")
    end
  end

  defp view_match(conn, id) do
    conn
    |> put_session(:match_id, id)
    |> put_status(:moved_permanently)
    |> redirect(to: ~p"/scratch")
  end
end
