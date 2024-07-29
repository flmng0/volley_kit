defmodule VolleyKitWeb.UserLive do
  import Phoenix.Component

  def on_mount(:default, _params, %{"user_id" => user_id} = _session, socket) do
    socket = assign_new(socket, :user_id, fn -> user_id end)

    {:cont, socket}
  end
end
