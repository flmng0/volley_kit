defmodule Volley.Scoring.Changes.ClearSetEvents do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, _context) do
    id = Ash.Changeset.get_data(changeset, :id)

    events =
      Volley.Scoring.Event
      |> Ash.Query.filter(match_id: id)
      |> Ash.Query.sort(inserted_at: :desc)
      |> Ash.read!()
      |> Enum.drop_while(fn event ->
        event.type != :set_won
      end)

    changeset
    |> Ash.Changeset.manage_relationship(:events, events, on_missing: :destroy)
  end
end
