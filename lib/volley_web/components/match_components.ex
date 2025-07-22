defmodule VolleyWeb.MatchComponents do
  use Phoenix.Component

  attr :a_score, :integer, required: true
  attr :b_score, :integer, required: true

  attr :event, :string, required: true

  def score_container(assigns) do
    ~H"""
    <div class="size-full">
      <div class="grid not-fullscreen:grid-cols-2 fullscreen:landscape:grid-cols-2 fullscreen:portrait:grid-rows-2 h-full">
        <.score_card team={:a} score={@a_score} phx-click={@event} />
        <.score_card team={:b} score={@b_score} phx-click={@event} />
      </div>
    </div>
    """
  end

  attr :score, :integer, required: true
  attr :team, :atom, values: [:a, :b], required: true

  attr :rest, :global

  defp score_card(assigns) do
    team_class =
      case assigns[:team] do
        :a -> "bg-team-a"
        :b -> "bg-team-b"
      end

    assigns = assign(assigns, :class, team_class)

    ~H"""
    <button
      class={[
        "flex flex-col justify-center max-h-full cursor-pointer not-fullscreen:aspect-square",
        @class
      ]}
      phx-value-team={@team}
      {@rest}
    >
      <svg
        viewBox="0 0 24 14"
        stroke="none"
        preserveAspectRatio="true"
        width="100%"
        height="100%"
        fill="currentColor"
      >
        <text x="50%" y="50%" dominant-baseline="central" text-anchor="middle">{@score}</text>
      </svg>
    </button>
    """
  end
end
