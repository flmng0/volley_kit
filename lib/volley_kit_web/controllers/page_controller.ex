defmodule VolleyKitWeb.PageController do
  use VolleyKitWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
