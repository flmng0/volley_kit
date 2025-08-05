defmodule Volley.Scoring.Changes.AddEvent do
  use Ash.Resource.Change

  defp validate(:type, opts) do
    types = Volley.Scoring.EventType.types()
    type = Keyword.get(opts, :type)

    cond do
      is_nil(type) -> {:error, "event type is required"}
      type not in types -> {:error, "expected type to be one of: #{inspect(types)}"}
      true -> :ok
    end
  end

  @impl true
  def init(opts) do
    with :ok <- validate(:type, opts) do
      {:ok, opts}
    end
  end

  @impl true
  def change(changeset, opts, _ctx) do
    event = %{
      match_id: Ash.Changeset.get_data(changeset, :id),
      type: opts[:type],
      team: Ash.Changeset.get_argument(changeset, :team)
    }

    Ash.Changeset.manage_relationship(changeset, :events, [event], type: :create)
  end
end
