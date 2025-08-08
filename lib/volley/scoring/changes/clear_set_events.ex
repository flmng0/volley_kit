defmodule Volley.Scoring.Changes.ClearSetEvents do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, _context) do
    clear_sets? = Ash.Changeset.get_argument(changeset, :clear_sets?)

    events =
      if clear_sets? do
        []
      else
        id = Ash.Changeset.get_data(changeset, :id)

        Volley.Scoring.Event
        |> Ash.Query.filter(match_id: id)
        |> Ash.Query.sort(inserted_at: :desc)
        |> Ash.read!()
        |> Enum.drop_while(fn event ->
          event.type != :set_won
        end)
      end

    Ash.Changeset.manage_relationship(changeset, :events, events, on_missing: :destroy)
  end
end
