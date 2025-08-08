defmodule VolleyWeb.MatchComponents do
  use Phoenix.Component

  import Phoenix.LiveView.ColocatedHook

  attr :match, Volley.Scoring.Match

  attr :event, :string, required: true
  attr :can_score, :boolean, default: false
  attr :editing, :boolean, default: false
  attr :swap, :boolean, default: false

  def score_container(assigns) do
    ~H"""
    <div class="size-full touch-none">
      <div class={[
        "grid rounded-md not-fullscreen:overflow-hidden h-full",
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
      <svg
        viewBox="0 0 24 14"
        stroke="none"
        preserveAspectRatio="true"
        width="100%"
        height="100%"
        class="basis-score-min min-w-score-min grow select-none"
        fill="currentColor"
        phx-update="ignore"
        id={"score_text_#{@team}"}
      >
        <text x="50%" y="50%" dominant-baseline="central" text-anchor="middle" class="scoreText">{@score}</text>
      </svg>
      <span class="w-full text-xl">{@sets}</span>
    </.score_card_wrapper>

    <script :type={ColocatedHook} name="ScoreCard">
      export default {
        mounted() {
            let value = 0;
            let timeout;
            let wait = false;
      
            const target = this.el.querySelector("text.scoreText");

            const handleCount = (score) => {
              timeout && clearTimeout(timeout);
              if (score > value || wait) {
                value = score;
                target.innerText = value;
              }
              else {
                timeout = setTimeout(() => {
                  value = score;
                  target.innerText = value;
                });
              }
            }

            this.el.addEventListener("click", () => {
              if (!wait) {
                value += 1;
                target.innerText = value;
              }
      
              this.pushEvent("inc", null, (reply) => {
                if (reply.score !== undefined) {
                  handleCount(reply.score)
                }
                timeout && clearTimeout(timeout);

                if (reply.wait !== undefined) {
                  wait = reply.wait;
                }
              })
            })
          }
      }
    </script>
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
      <button class={[@class, "cursor-pointer"]} phx-hook=".ScoreCard" id={"score_button_#{@team}"} data-team={@team}>
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
