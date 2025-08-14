defmodule Volley.Scoring.Query do
  import Ecto.Query, only: [from: 2, subquery: 1]

  alias Volley.Scoring.Event
  alias Volley.Scoring.Match

  def latest_event(%Match{id: match_id}) do
    from e in Event,
      order_by: [desc: :id],
      where: e.id == ^match_id,
      limit: 1
  end

  def score_timeline(%Match{id: match_id}, set \\ nil) do
    with_set =
      from e in Event,
        select: %{e | current_set: count() |> filter(e.type == :set_won) |> over(order_by: e.id)},
        where: e.match_id == ^match_id

    query =
      from e in subquery(with_set),
        select: %{
          a_sets: count(e.id) |> filter(e.type == :set_won and e.team == :a) |> over(:sets),
          b_sets: count(e.id) |> filter(e.type == :set_won and e.team == :b) |> over(:sets),
          a_score: count(e.id) |> filter(e.type == :score and e.team == :a) |> over(:score),
          b_score: count(e.id) |> filter(e.type == :score and e.team == :b) |> over(:score)
        },
        windows: [
          sets: [order_by: e.current_set],
          score: [partition_by: e.current_set, order_by: e.id]
        ],
        order_by: e.id

    if set do
      from e in query, where: e.current_set == ^set
    else
      query
    end
  end
end
