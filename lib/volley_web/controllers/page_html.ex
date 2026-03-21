defmodule VolleyWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use VolleyWeb, :html

  embed_templates "page_html/*"

  def redirect(assigns) do
    ~H"""
    <p>You are being redirected...</p>
    """
  end

  attr :title, :string
  attr :subtitle, :string
  attr :actions_class, :string, default: ""

  slot :inner_block
  slot :action

  defp hero_card(assigns) do
    ~H"""
    <div class="p-4 space-y-6 rounded-box shadow-lg bg-base-200 border border-base-300">
      <h2 class="text-2xl font-semibold">{@title}</h2>
      <p class="text-base-content/80 text-sm">{@subtitle}</p>

      <%= if @inner_block != [] do %>
        {render_slot(@inner_block)}
      <% end %>

      <div :if={@action != []} class={@actions_class}>
        <%= for action <- @action do %>
          {render_slot(action)}
        <% end %>
      </div>
    </div>
    """
  end

  attr :match, Volley.Scoring.Match

  defp continue_match_card(assigns) do
    ~H"""
    <.hero_card
      title="Continue Scoring"
      subtitle="Jump back in where you left off, or press Delete to start a new one."
      actions_class="flex flex-row flex-wrap justify-stretch gap-2"
    >
      <:action>
        <.button navigate={~p"/scratch/#{@match}"} variant="neutral" class="grow max-w-full">
          {@match.settings.a_name} vs. {@match.settings.b_name}
        </.button>
      </:action>
      <:action>
        <.button onclick="deleteConfirmation.showModal()" variant="delete" class="flex-[1_1_0]">
          Delete <.icon name="hero-trash" />
        </.button>
      </:action>
    </.hero_card>
    <.modal id="deleteConfirmation" noportal>
      <.header header_tag="h3">Are you sure?</.header>
      <p>Are you sure you want to delete this scratch match?</p>

      <:action>
        <.button variant="delete" href={~p"/scratch/#{@match}"} method="delete">Yes, delete</.button>
      </:action>
      <:action>
        <.button>Cancel</.button>
      </:action>
    </.modal>
    """
  end

  defp start_match_card(assigns) do
    ~H"""
    <.hero_card
      title="Start A Scratch Match!"
      subtitle="Jump straight into scoring a new volleyball match, no additional config required."
      actions_class="text-right"
    >
      <.button navigate={~p"/scratch/new"} variant="primary" class="btn-block">
        Start Match <.icon name="hero-flag" class="size-4 ml-2" />
      </.button>
    </.hero_card>
    """
  end
end
