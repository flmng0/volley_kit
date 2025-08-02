defmodule VolleyWeb.MatchComponents do
  use Phoenix.Component

  attr :match, Volley.Scoring.Match

  attr :event, :string, required: true
  attr :editing, :boolean, default: false

  def score_container(assigns) do
    ~H"""
    <div class="size-full">
      <div class={[
        "grid rounded-md not-fullscreen:overflow-hidden h-full",
        "not-fullscreen:grid-cols-2 fullscreen:landscape:grid-cols-2 fullscreen:portrait:grid-rows-2"
      ]}>
        <.score_card
          team={:a}
          score={@match.a_score}
          team_name={@match.a_name}
          editing={@editing}
          phx-click={@event}
        />
        <.score_card
          team={:b}
          score={@match.b_score}
          team_name={@match.b_name}
          editing={@editing}
          phx-click={@event}
        />
      </div>
    </div>
    """
  end

  attr :team, :atom, values: [:a, :b]
  attr :score, :integer
  attr :team_name, :string

  attr :editing, :boolean

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
        "flex flex-col justify-center max-h-full cursor-pointer not-fullscreen:aspect-square text-score-content py-4",
        @class
      ]}
      phx-value-team={@team}
      {@rest}
    >
      <span class="text-xl">{@team_name}</span>
      <svg
        viewBox="0 0 24 14"
        stroke="none"
        preserveAspectRatio="true"
        width="100%"
        height="100%"
        class="basis-score-min grow"
        fill="currentColor"
      >
        <text x="50%" y="50%" dominant-baseline="central" text-anchor="middle">{@score}</text>
      </svg>
    </button>
    """
  end
end
