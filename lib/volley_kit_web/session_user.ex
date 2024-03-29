defmodule VolleyKitWeb.SessionUser do
  @user_session_key "user_id"

  def get_user(conn) do
    conn
    |> Plug.Conn.get_session(@user_session_key)
  end

  defp gen_uuid, do: Ecto.UUID.bingenerate()

  # Plug callbacks
  def init(opts), do: opts

  def call(conn, _opts) do
    if get_user(conn) == nil do
      Plug.Conn.put_session(conn, @user_session_key, gen_uuid())
    else
      conn
    end
  end
end
