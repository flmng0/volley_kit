defmodule VolleyWeb.ScratchController do
  use VolleyWeb, :controller

  alias Volley.Scoring

  def new(conn, %{"form" => settings}) do
    with {:ok, settings} <- Ash.create(Scoring.Settings, settings),
         {:ok, match} <- Scoring.start_match(settings) do
      view_match(conn, match.id, true)
    else
      _ ->
        conn
        |> put_flash(:error, "Failed to create match")
        |> redirect(to: ~p"/")
    end
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

  defp view_match(conn, id, owner \\ false) do
    conn = if owner, do: put_session(conn, :owns_match_id, id), else: conn

    conn
    |> put_session(:match_id, id)
    |> put_status(:moved_permanently)
    |> redirect(to: ~p"/scratch")
  end
end
