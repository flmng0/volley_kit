defmodule VolleyWeb.HomeLive do
  alias Volley.Scoring
  use VolleyWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    match =
      with %{"match_id" => id} <- session,
           {:ok, match} <- Scoring.get_match(id) do
        match
      else
        _ -> nil
      end

    {:ok, assign(socket, :match, match)}
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
            <.continue_match_card :if={@match} match={@match} />
            <.scratch_match_card :if={is_nil(@match)} />

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
    Ash.destroy!(socket.assigns.match, action: :destroy)

    {:noreply, assign(socket, :match, nil)}
  end

  attr :title, :string
  attr :subtitle, :string
  attr :actions_class, :string, default: ""

  slot :inner_block, required: true

  defp hero_card(assigns) do
    ~H"""
    <div class="p-4 space-y-6 rounded-box shadow-lg bg-base-200 border border-base-300">
      <h2 class="text-2xl font-semibold">{@title}</h2>
      <p class="text-base-content/80 text-sm">{@subtitle}</p>
      <div class={@actions_class}>
        {render_slot(@inner_block)}
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
      <.button href={~p"/scratch/#{@match.id}"} class="grow max-w-full">
        {@match.a_name} vs. {@match.b_name}
      </.button>
      <.button phx-click="delete" variant="delete" class="flex-[1_1_0]">
        Delete <.icon name="hero-trash" />
      </.button>
    </.hero_card>
    """
  end

  defp scratch_match_card(assigns) do
    ~H"""
    <.hero_card
      title="Start A Scratch Match!"
      subtitle="Jump straight into scoring a new volleyball match, no additional config required."
      actions_class="text-right"
    >
      <.button href={~p"/scratch/new"} variant="primary">
        Start <.icon name="hero-chevron-right" />
      </.button>
    </.hero_card>
    """
  end
end
