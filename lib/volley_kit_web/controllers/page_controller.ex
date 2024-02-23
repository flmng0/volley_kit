defmodule VolleyKitWeb.PageController do
  use VolleyKitWeb, :controller

  alias VolleyKit.Manager

  def home(conn, _params) do
    user_id = VolleyKitWeb.SessionUser.get_user(conn)

    owned_match = Manager.get_owned_match(user_id)

    conn
    |> assign(:owned_match, owned_match)
    |> render(:home)
  end
end
