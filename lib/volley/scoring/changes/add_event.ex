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

  defp validate(:team_argument_or_attribute, opts) do
    arg = Keyword.get(opts, :team_argument_or_attributes)

    if is_nil(arg) or is_atom(arg) do
      :ok
    else
      {:error, "expected team argument to be an atom"}
    end
  end

  @impl true
  def init(opts) do
    with :ok <- validate(:type, opts),
         :ok <- validate(:team_argument_or_attribute, opts) do
      {:ok, opts}
    end
  end

  @impl true
  def change(changeset, opts, _ctx) do
    team_argument_or_attribute = opts[:team_argument_or_attribute] || :team

    event = %{
      match_id: Ash.Changeset.get_data(changeset, :id),
      type: opts[:type],
      team: Ash.Changeset.get_argument_or_attribute(changeset, team_argument_or_attribute)
    }

    Ash.Changeset.manage_relationship(changeset, :events, [event], type: :create)
  end
end
