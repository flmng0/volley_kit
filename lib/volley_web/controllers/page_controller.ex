defmodule VolleyWeb.PageController do
  use VolleyWeb, :controller

  def home(conn, _params) do
    match =
      if scope = conn.assigns.current_scope do
        Volley.Scoring.get_recent_match(scope)
      end

    render(conn, :home, match: match)
  end
end
