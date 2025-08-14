defmodule VolleyWeb.HomeLive do
  use VolleyWeb, :live_view

  on_mount {VolleyWeb.UserAuth, :mount_current_scope}

  alias Volley.Scoring

  @impl true
  def mount(_params, _session, socket) do
    match =
      if socket.assigns.current_scope do
        Scoring.get_match(socket.assigns.current_scope)
      end

    socket = assign(socket, :match, match)

    {:ok, assign(socket, :hide_home_button, true)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app hide_home_button={true} flash={@flash}>
      <main class="full-bleed hero">
        <div class="hero-content flex flex-col lg:flex-row gap-y-12">
          <div class="text-center lg:text-left prose">
            <hgroup>
              <h1 class="mb-0">Volley Kit</h1>
              <p class="text-base-content/50 mt-1">
                Real-time scoring companion, designed with volleyball in mind.
              </p>
            </hgroup>

            <ul class="text-left">
              <li>
                Quickly score a scratch match amongst friends.
              </li>
              <li>
                Run a full-blown tournament with real-time statistics and FIVB scoresheet generation.
              </li>
            </ul>
          </div>

          <nav class="flex flex-col w-full max-w-sm shrink-0">
            <%= if @match do %>
              <.continue_match_card match={@match} />
            <% else %>
              <.start_match_card />
            <% end %>

            <%!-- <span class="divider">OR</span> --%>
            <%!----%>
            <%!-- <.button navigate={~p"/tournament/new"}> --%>
            <%!--   <.icon name="hero-cog-8-tooth-solid" /> Configure a Tournament --%>
            <%!-- </.button> --%>
          </nav>
        </div>
      </main>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("delete", _params, socket) do
    {:ok, _} = Scoring.delete_match(socket.assigns.current_scope, socket.assigns.match)

    {:noreply, assign(socket, :match, nil)}
  end

  @impl true
  def handle_info({:submit_settings, settings}, socket) do
    {:ok, match} = Scoring.start_match(socket.assigns.current_scope, settings)

    {:noreply, redirect(socket, to: ~p"/scratch/#{match.public_id}")}
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
        <.button href={~p"/scratch/#{@match.public_id}"} variant="neutral" class="grow max-w-full">
          {@match.settings.a_name} vs. {@match.settings.b_name}
        </.button>
      </:action>
      <:action>
        <.button phx-click={show_modal("deleteConfirmation")} variant="delete" class="flex-[1_1_0]">
          Delete <.icon name="hero-trash" />
        </.button>
      </:action>
    </.hero_card>
    <.modal id="deleteConfirmation">
      <h3 class="text-lg font-bold">Are you sure?</h3>
      <p>Are you sure you want to delete this scratch match?</p>

      <:action>
        <.button variant="delete" phx-click="delete">Yes, delete</.button>
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
      <.live_component
        id="scratch-match-create-form"
        module={VolleyWeb.MatchSettingsForm}
        type={:create}
      />
    </.hero_card>
    """
  end
end
