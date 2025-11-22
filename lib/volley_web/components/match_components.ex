defmodule VolleyWeb.MatchComponents do
  use Phoenix.Component

  attr :match, Volley.Scoring.Match

  attr :event, :string, required: true
  attr :can_score, :boolean, default: false
  attr :editing, :boolean, default: false
  attr :swap, :boolean, default: false

  def score_container(assigns) do
    ~H"""
    <div class="size-full touch-none">
      <div class={[
        "grid rounded-md not-fullscreen:overflow-hidden w-full fullscreen:h-full",
        "not-fullscreen:grid-cols-2 fullscreen:landscape:grid-cols-2 fullscreen:portrait:grid-rows-2"
      ]}>
        <.score_card
          :for={
            {team, score, sets, name} <- [
              {:a, @match.a_score, @match.a_sets, @match.settings.a_name},
              {:b, @match.b_score, @match.b_sets, @match.settings.b_name}
            ]
          }
          :key={team}
          team={team}
          score={score}
          sets={sets}
          team_name={name}
          swap={@swap}
          editing={@editing}
          can_score={@can_score}
          event={@event}
        />
      </div>
    </div>
    """
  end

  attr :team, :atom, values: [:a, :b]
  attr :event, :string
  attr :can_score, :boolean

  attr :score, :integer
  attr :sets, :integer
  attr :team_name, :string
  attr :editing, :boolean
  attr :swap, :boolean, default: false

  attr :rest, :global

  defp score_card(assigns) do
    ~H"""
    <.score_card_wrapper
      team={@team}
      can_score={@can_score}
      event={@event}
      class={@swap && @team == :a && "order-last"}
    >
      <span class="w-full text-xl">{@team_name}</span>
      <score-card
        id={"score_card_#{@team}"}
        class="basis-score-min min-w-score-min grow select-none"
        score={@score}
      />
      <span class="w-full text-xl">{@sets}</span>
    </.score_card_wrapper>
    """
  end

  attr :team, :atom, values: [:a, :b]
  attr :can_score, :boolean
  attr :event, :string
  attr :class, :string, default: ""

  slot :inner_block, required: true

  defp score_card_wrapper(assigns) do
    team_class =
      case assigns[:team] do
        :a -> "bg-team-a"
        :b -> "bg-team-b"
      end

    display_class =
      "flex flex-col justify-center max-h-full text-center not-fullscreen:aspect-square text-score-content py-4"

    assigns = assign(assigns, :class, [team_class, display_class, assigns[:class]])

    if assigns[:can_score] do
      ~H"""
      <button
        class={[@class, "cursor-pointer"]}
        phx-hook="ScoreCard"
        id={"score_button_#{@team}"}
        data-team={@team}
      >
        {render_slot(@inner_block)}
      </button>
      """
    else
      ~H"""
      <div class={@class}>
        {render_slot(@inner_block)}
      </div>
      """
    end
  end
end
