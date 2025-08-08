defmodule Volley.Scoring.Changes.UndoEvents do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, _context) do
    id = Ash.Changeset.get_data(changeset, :id)
    count = Ash.Changeset.get_argument(changeset, :count)

    events =
      Volley.Scoring.Event
      |> Ash.Query.filter(match_id: id)
      |> Ash.Query.sort(inserted_at: :desc)
      |> Ash.Query.offset(count)
      |> Ash.read!()
      |> Enum.reverse()

    summarized =
      for event <- events, reduce: %{a_score: 0, b_score: 0, a_sets: 0, b_sets: 0} do
        acc ->
          case {event.type, event.team} do
            {:score, :a} ->
              %{acc | a_score: acc.a_score + 1}

            {:score, :b} ->
              %{acc | b_score: acc.b_score + 1}

            {:set_won, :a} ->
              %{acc | a_score: 0, b_score: 0, a_sets: acc.a_sets + 1}

            {:set_won, :b} ->
              %{acc | a_score: 0, b_score: 0, b_sets: acc.b_sets + 1}
          end
      end

    changeset
    |> Ash.Changeset.manage_relationship(:events, events, on_missing: :destroy)
    |> Ash.Changeset.change_attributes(summarized)
  end
end
