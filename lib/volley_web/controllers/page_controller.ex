defmodule VolleyWeb.PageController do
  use VolleyWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
