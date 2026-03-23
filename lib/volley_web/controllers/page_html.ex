defmodule VolleyWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use VolleyWeb, :html
  alias Volley.Accounts

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

  defp continue_match(assigns) do
    ~H"""
    <div class="self-end flex flex-col items-center gap-2">
      <div>
        <.button variant="cta" navigate={~p"/match/#{@match}/score"} class="text-center">
          {@match.settings.a_name} vs. {@match.settings.b_name}
        </.button>
        <.button
          onclick="deleteConfirmation.showModal()"
          variant="delete"
          class="btn-soft btn-square"
        >
          <.icon name="hero-trash" />
        </.button>
      </div>
      <span class="text-base-content/50 text-sm">
        Return to Existing Match
      </span>
    </div>
    <.modal noportal id="deleteConfirmation" close={%JS{}}>
      <.header header_tag="h3">
        Are you sure?
        <:subtitle>
          Are you want to delete your match between {@match.settings.a_name} and {@match.settings.b_name}?
        </:subtitle>
      </.header>
      <:action>
        <.button type="dialog">Cancel</.button>
        <.button
          variant="delete"
          method="delete"
          href={~p"/match/#{@match}"}
        >
          Yes, Delete My Match
        </.button>
      </:action>
    </.modal>
    """
  end
end
