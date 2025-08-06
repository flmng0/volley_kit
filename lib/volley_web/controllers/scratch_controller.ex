defmodule VolleyWeb.ScratchController do
  use VolleyWeb, :controller

  plug :put_view, html: VolleyWeb.PageHTML

  alias Volley.Scoring

  def new(conn, %{"form" => settings}) do
    with {:ok, settings} <- Ash.create(Scoring.Settings, settings),
         {:ok, match} <- Scoring.start_match(settings) do
      view_match(conn, match, true)
    else
      _ ->
        conn
        |> put_flash(:error, "Failed to create match")
        |> redirect(to: ~p"/")
    end
  end

  def join(conn, %{"id" => id}) do
    with {:ok, match} <- Scoring.get_match(id) do
      view_match(conn, match)
    else
      _ ->
        conn
        |> put_flash(:error, "No such match exists")
        |> redirect(to: ~p"/")
    end
  end

  defp view_match(conn, %{id: id} = match, owner \\ false) do
    conn = if owner, do: put_session(conn, :owns_match_id, id), else: conn

    title = "#{match.settings.a_name} vs. #{match.settings.b_name}"

    conn
    |> put_session(:match_id, id)
    |> put_status(:moved_permanently)
    |> put_resp_header("location", ~p"/scratch")
    |> assign(:page_title, title)
    |> render(:redirect)
  end
end
