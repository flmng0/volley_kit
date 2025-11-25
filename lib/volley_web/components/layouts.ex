defmodule VolleyWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use VolleyWeb, :html
  alias Volley.Accounts

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
  attr :centered, :boolean, default: false
  attr :current_scope, :map, default: nil

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <.app_header
      hide_home_button={@hide_home_button}
      current_scope={@current_scope}
    />

    <main class={["w-full px-2 sm:px-6 lg:px-8", @centered && "place-self-center"]}>
      <div class="bleed-container gap-y-4">
        {render_slot(@inner_block)}
      </div>
    </main>

    <.flash_group flash={@flash} />
    """
  end

  attr :flash, :map, required: true
  attr :current_scope, :map, default: nil

  slot :inner_block, required: true

  slot :action do
    attr :show_in_fullscreen?, :boolean
  end

  slot :footer

  def scorer(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope} centered>
      <main class="w-full max-w-xl md:max-w-2xl lg:max-w-3xl mx-auto space-y-6 pb-16">
        <div
          class={[
            "fullscreen:max-w-none space-y-2 fullscreen:z-40",
            "fullscreen:fixed fullscreen:inset-0 fullscreen:isolate"
          ]}
          id="scoringContainer"
        >
          {render_slot(@inner_block)}
          <div
            class="hidden fullscreen:flex fixed bottom-4 gap-2 inset-x-4 bg-transparent"
            data-theme="dark"
          >
            <.button
              class="btn-lg btn-circle"
              phx-click={toggle_fullscreen("#scoringContainer")}
            >
              <.icon name="hero-arrows-pointing-in" class="size-5" />
            </.button>
            <div class="fab absolute right-0 bottom-0">
              <div tabindex="0" role="button" class="btn btn-lg btn-circle">
                <.icon name="hero-ellipsis-horizontal" class="size-5" />
              </div>

              <div class="fab-close btn btn-lg btn-circle btn-error">
                <.icon name="hero-x-mark" class="size-5" />
              </div>

              <%= for action <- @action, Map.get(action, :show_in_fullscreen?, true) do %>
                {render_slot(action)}
              <% end %>
            </div>
          </div>
        </div>

        <div class="flex gap-1 w-full flex-wrap">
          <div class="text-nowrap basis-max flex-1">
            <.button variant="scorer-action" phx-click={toggle_fullscreen("#scoringContainer")}>
              <.icon name="hero-arrows-pointing-out" /> Fullscreen
            </.button>
          </div>
          <div :for={action <- @action} class="text-nowrap basis-max flex-1">
            {render_slot(action)}
          </div>
        </div>

        <%= for footer <- @footer do %>
          {render_slot(footer)}
        <% end %>
      </main>
    </Layouts.app>
    """
  end

  attr :hide_home_button, :boolean, default: false
  attr :current_scope, :map, default: nil

  attr :class, :string, default: nil
  attr :rest, :global

  def app_header(assigns) do
    ~H"""
    <header
      class={["navbar max-w-screen-xl mx-auto px-4 sm:px-6 lg:px-8 gap-2 lg:gap-4", @class]}
      {@rest}
    >
      <ul class="menu menu-horizontal grow items-center">
        <%= if !@hide_home_button do %>
          <li class="lg:hidden">
            <.link navigate="/" class="btn btn-ghost btn-square">
              <.icon name="hero-home-solid" class="size-4" />
            </.link>
          </li>
          <li class="max-lg:hidden">
            <.link navigate="/">
              <.icon name="hero-home-solid" class="size-4" />
              <span class="hidden lg:inline">Home</span>
            </.link>
          </li>
        <% end %>
        <li>
          <.link navigate={~p"/tournaments"}>Tournaments</.link>
        </li>
      </ul>
      <.theme_toggle />
      <.user_menu current_scope={@current_scope} />
      <%!-- <ul class="menu menu-horizontal items-center gap-4"> --%>
      <%!--   <.user_buttons current_scope={@current_scope} /> --%>
      <%!-- </ul> --%>
    </header>
    """
  end

  attr :current_scope, :map, default: nil

  def user_menu(assigns) do
    ~H"""
    <%= if Accounts.known_user?(@current_scope) do %>
      <details class="dropdown dropdown-end" phx-click-away={JS.remove_attribute("open")}>
        <summary class="btn btn-neutral max-lg:btn-square p-2">
          <.icon name="hero-user-solid" class="size-4 lg:hidden" />
          <span class="hidden lg:inline">{@current_scope.user.email}</span>
        </summary>

        <ul class="dropdown-content menu bg-base-200 rounded-box shadow-sm p-2 w-52 gap-1">
          <li class="lg:hidden menu-title">
            {@current_scope.user.email}
          </li>
          <li>
            <.link href={~p"/users/settings"}>Settings</.link>
          </li>
          <li>
            <.link href={~p"/users/log-out"} method="delete">Log out</.link>
          </li>
        </ul>
      </details>
    <% else %>
      <ul class="menu menu-horizontal">
        <li class="hidden lg:block">
          <.link href={~p"/users/register"}>Register</.link>
        </li>
        <li>
          <.link href={~p"/users/log-in"}>Log in</.link>
        </li>
      </ul>
    <% end %>
    """
  end

  attr :current_scope, :map, default: nil

  def user_buttons(assigns) do
    ~H"""
    <%= if Accounts.known_user?(@current_scope) do %>
      <li>
        {@current_scope.user.email}
      </li>
      <li>
        <.link href={~p"/users/settings"}>Settings</.link>
      </li>
      <li>
        <.link href={~p"/users/log-out"} method="delete">Log out</.link>
      </li>
    <% end %>
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
