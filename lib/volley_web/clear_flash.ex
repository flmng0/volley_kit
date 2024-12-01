defmodule VolleyWeb.ClearFlash do
  import Phoenix.LiveView

  def on_mount(:default, _params, _session, socket) do
    socket =
      socket
      |> attach_hook(:clear_flash, :handle_event, fn
        "flash_timeout", _params, socket ->
          {:halt, clear_flash(socket)}

        _event_name, _params, socket ->
          {:cont, socket}
      end)

    {:cont, socket}
  end
end
