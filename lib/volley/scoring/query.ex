defmodule Volley.Scoring.Query do
  import Ecto.Query, only: [from: 2]

  alias Volley.Scoring.MatchSnapshot
  alias Volley.Scoring.Event
  alias Volley.Scoring.Match

  def latest_event(%Match{id: match_id}) do
    from e in Event,
      order_by: [desc: :id],
      where: e.match_id == ^match_id,
      limit: 1
  end

  def events_with_set() do
    from e in Event,
      select: %{
        id: e.id,
        set: count() |> filter(e.type == :set_won) |> over(order_by: e.id)
      }
  end

  def score_timeline(%Match{} = match) do
    from e in Event,
      join: se in subquery(events_with_set()),
      as: :events_with_set,
      on: e.id == se.id,
      select: %{
        event: e,
        snapshot: %MatchSnapshot{
          a_sets: count() |> filter(e.type == :set_won and e.team == :a) |> over(:sets),
          b_sets: count() |> filter(e.type == :set_won and e.team == :b) |> over(:sets),
          a_score: count() |> filter(e.type == :score and e.team == :a) |> over(:score),
          b_score: count() |> filter(e.type == :score and e.team == :b) |> over(:score)
        }
      },
      windows: [
        sets: [order_by: se.set],
        score: [partition_by: se.set, order_by: e.id]
      ],
      order_by: [desc: e.id],
      where: e.match_id == ^match.id
  end
end
