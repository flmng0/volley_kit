defmodule VolleyWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use VolleyWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :hide_home_button, :boolean, default: false

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="grid grid-rows-[auto_1fr] min-h-screen">
      <.app_header hide_home_button={@hide_home_button} />
      <main class="px-2 py-20 sm:px-6 lg:px-8">
        <div class="bleed-container gap-y-4">
          {render_slot(@inner_block)}
        </div>
      </main>
    </div>

    <.flash_group flash={@flash} />
    """
  end

  attr :flash, :map, required: true
  slot :inner_block, required: true

  def scorer(assigns) do
    ~H"""
    <.app_header />
    <div
      class={[
        "w-xl md:w-2xl lg:w-3xl max-w-screen mx-auto space-y-2",
        "fullscreen:fixed fullscreen:inset-0 fullscreen:isolation-isolate"
      ]}
      id="scoringContainer"
    >
      {render_slot(@inner_block)}
      <div class={[
        "flex flex-col w-full",
        "fullscreen:fixed fullscreen:w-auto top-4 left-4"
      ]}>
        <.button id="toggle-fs-button" phx-hook="FullscreenButton" class="cursor-pointer p-2">
          <span class="fullscreen:hidden">
            Toggle Fullscreen <.icon name="hero-arrows-pointing-out" />
          </span>
          <span class="not-fullscreen:hidden">
            <.icon name="hero-arrows-pointing-in" class="size-6" />
          </span>
        </.button>
      </div>
    </div>

    <.flash_group flash={@flash} />
    """
  end

  attr :hide_home_button, :boolean, default: false

  attr :class, :string, default: nil
  attr :rest, :global

  def app_header(assigns) do
    ~H"""
    <header class={["navbar px-4 sm:px-6 lg:px-8", @class]} {@rest}>
      <div class="">
        <a :if={!@hide_home_button} href="/" class="flex w-fit items-center gap-2">
          <img src={~p"/images/logo.svg"} width="36" />
          <span class="text-sm font-semibold">Volley Kit</span>
        </a>
      </div>
      <ul class="menu menu-horizontal w-full relative z-10 flex items-center gap-4 px-4 sm:px-6 lg:px-8 justify-end">
        <.theme_toggle />
      </ul>
    </header>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "system"})}
        class="flex p-2 cursor-pointer w-1/3"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "light"})}
        class="flex p-2 cursor-pointer w-1/3"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "dark"})}
        class="flex p-2 cursor-pointer w-1/3"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
