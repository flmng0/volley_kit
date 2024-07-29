defmodule VolleyKitWeb.HomeLive do
  use VolleyKitWeb, :live_view

  alias VolleyKitWeb.HomeLive.ScratchMatchForm

  def mount(_params, _session, socket) do
    {:ok, socket, layout: false}
  end
end
