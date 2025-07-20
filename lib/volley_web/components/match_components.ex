defmodule VolleyWeb.MatchComponents do
  use Phoenix.Component

  # alias Phoenix.LiveView.JS

  attr :score, :integer, required: true
  attr :team, :atom, values: [:a, :b], required: true

  attr :rest, :global

  def score_card(assigns) do
    team_class =
      case assigns[:team] do
        :a -> "bg-(--color-team-a)"
        :b -> "bg-(--color-team-b)"
      end

    assigns = assign(assigns, :class, team_class)

    ~H"""
    <button class={[@class]} {@rest}>
      Test {@score}
    </button>
    """
  end

  slot :inner_block, required: true

  def score_container(assigns) do
    ~H"""
    <div class="flex landscape:flex-row portrait:flex-col"></div>
    """
  end
end
