defmodule VolleyKitWeb.SessionTest do
  @user_session_key "user_id"

  def init_session(conn) do
    IO.inspect(conn)
    user_id = Plug.Conn.get_session(conn, @user_session_key)

    if user_id == nil, do: raise("Somehow no user ID in session?")

    %{@user_session_key => user_id}
  end

  def on_mount(:default, _params, %{ @user_session_key => user_id }, socket) do
    IO.inspect(user_id)

    {:cont, socket}
  end

  def init(_opts), do: _opts

  def call(conn, _opts) do
    if Plug.Conn.get_session(conn, @user_session_key) == nil do
      Plug.Conn.put_session(conn, @user_session_key, System.unique_integer([:positive]))
    else
      conn
    end
  end
end
