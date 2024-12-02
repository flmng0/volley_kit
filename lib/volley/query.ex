defmodule Volley.Query do
  import Ecto.Query, only: [from: 2]

  alias Volley.Schema.{Match, Event}

  def team_summary_from_events(%Match{id: match_id}, team) do
    # Map of output map suffix => event type.
    #
    # For example, [sets: :set_win] will result in an output of:
    #
    # %{ 
    #   :score => <count events where type == :set_win>,
    # }
    stats = [score: :score, sets: :set_win]

    query = from e in Event, where: e.match_id == ^match_id, select: %{}

    for {key, type} <- stats, reduce: query do
      query ->
        from e in query,
          select_merge: %{
            ^key => count(e.id) |> filter(e.team == ^team and e.type == ^type) |> coalesce(0)
          }
    end
  end
end
