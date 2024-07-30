defmodule VolleyKitWeb.HomeLive do
  use VolleyKitWeb, :live_view

  alias VolleyKitWeb.HomeLive.{ScratchMatchForm, ScratchMatchList}

  attr :title, :string, required: true
  attr :subtitle, :string, default: nil

  slot :inner_block, required: true

  def section_card(assigns) do
    ~H"""
    <div class="max-w-xl bg-white flex flex-col px-6 py-5 gap-10">
      <hgroup>
        <h2 class="text-xl font-serif font-semibold tracking-wider"><%= @title %></h2>
        <p :if={@subtitle} class="text-gray-700 tracking-wide"><%= @subtitle %></p>
      </hgroup>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket, layout: false}
  end
end
