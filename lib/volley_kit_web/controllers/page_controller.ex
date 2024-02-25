defmodule VolleyKitWeb.PageController do
  use VolleyKitWeb, :controller

  def join(conn, _params) do
    %{ "match-code" => code } = conn.query_params

    redirect(conn, to: ~p"/#{code}")
  end
end
