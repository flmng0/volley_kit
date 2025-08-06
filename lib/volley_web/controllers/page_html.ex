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
end
