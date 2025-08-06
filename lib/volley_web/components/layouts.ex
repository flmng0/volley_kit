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
    <main class="px-2 sm:px-6 lg:px-8">
      <div class="bleed-container gap-y-4">
        {render_slot(@inner_block)}
      </div>
    </main>

    <.flash_group flash={@flash} />
    """
  end

  attr :flash, :map, required: true
  slot :inner_block, required: true

  slot :action
  slot :footer

  def scorer(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <main class="max-w-xl md:max-w-2xl lg:max-w-3xl mx-auto space-y-6 pb-16">
        <div
          class={[
            "fullscreen:max-w-none space-y-2",
            "fullscreen:fixed fullscreen:inset-0 fullscreen:isolate"
          ]}
          id="scoringContainer"
        >
          {render_slot(@inner_block)}
          <div class={
            [
              "flex flex-row gap-1 w-full flex-wrap",
              # full screen rules
              "fullscreen:fixed fullscreen:w-auto bottom-4",
              # full screen, and portrait
              "fullscreen:portrait:flex-col portrait:left-4",
              # full screen, and landscape
              "landscape:left-1/2 fullscreen:landscape:-translate-x-1/2"
            ]
          }>
            <div :for={action <- @action} class="basis-max flex-1">
              {render_slot(action)}
            </div>
          </div>
        </div>

        <%= for footer <- @footer do %>
          {render_slot(footer)}
        <% end %>
      </main>
    </Layouts.app>
    """
  end

  attr :label, :string, required: true
  attr :icon_name, :string, required: true
  attr :fullscreen_icon_name, :string, default: nil
  attr :show_in_fullscreen?, :boolean, default: true
  attr :rest, :global

  def scorer_action_button(assigns) do
    ~H"""
    <.button {@rest} class={["btn-block btn-md p-4", @show_in_fullscreen? || "fullscreen:hidden"]}>
      <span class="fullscreen:hidden text-nowrap">{@label}</span>
      <.icon
        class={["size-4 fullscreen:size-6", @fullscreen_icon_name && "fullscreen:hidden"]}
        name={@icon_name}
      />
      <.icon
        :if={@fullscreen_icon_name}
        class="size-4 fullscreen:size-6 not-fullscreen:hidden"
        name={@fullscreen_icon_name}
      />
    </.button>
    """
  end

  def toggle_fullscreen_button(assigns) do
    ~H"""
    <.scorer_action_button
      id="toggle-fs-button"
      phx-hook="FullscreenButton"
      label="Toggle Fullscreen"
      icon_name="hero-arrows-pointing-out"
      fullscreen_icon_name="hero-arrows-pointing-in"
    />
    """
  end

  attr :hide_home_button, :boolean, default: false
  attr :current_scope, :map, default: nil

  attr :class, :string, default: nil
  attr :rest, :global

  def app_header(assigns) do
    ~H"""
    <header class={["navbar max-w-screen-xl mx-auto px-4 sm:px-6 lg:px-8", @class]} {@rest}>
      <div class="">
        <a :if={!@hide_home_button} href="/" class="flex w-fit items-center gap-2">
          <.icon name="hero-home-solid" class="size-6" />
          <%!-- <img src={~p"/images/logo.svg"} width="36" /> --%>
          <span class="text-sm font-semibold text-nowrap">Home</span>
        </a>
      </div>
      <ul class="menu menu-horizontal w-full relative z-10 flex items-center gap-4 px-4 sm:px-6 lg:px-8 justify-end">
        <.theme_toggle />
        <%!-- FIXME: Temporarily disabled until mailer is setup --%>
        <%!-- <.user_buttons current_scope={@current_scope} /> --%>
      </ul>
    </header>
    """
  end

  # FIXME: Temporarily disabled until mailer is setup
  # attr :current_scope, :map, default: nil
  #
  # def user_buttons(assigns) do
  #   ~H"""
  #   <%= if known_user?(@current_scope) do %>
  #     <li>
  #       {@current_scope.user.email}
  #     </li>
  #     <li>
  #       <.button variant="ghost" href={~p"/users/settings"}>Settings</.button>
  #     </li>
  #     <li>
  #       <.button variant="ghost" href={~p"/users/log-out"} method="delete">Log out</.button>
  #     </li>
  #   <% else %>
  #     <li>
  #       <.button variant="ghost" href={~p"/users/register"}>Register</.button>
  #     </li>
  #     <li>
  #       <.button variant="ghost" href={~p"/users/log-in"}>Log in</.button>
  #     </li>
  #   <% end %>
  #   """
  # end

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
