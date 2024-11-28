defmodule Volley.Query do
  import Ecto.Query, only: [from: 2]

  alias Volley.Schema.{Match, Event, Team}

  def get_set(%Match{id: match_id}) do
    from e in Event,
      where: e.match_id == ^match_id,
      select: max(e.set) |> coalesce(0)
  end

  def get_score(%Match{id: match_id}) do
    from e in Event,
      where: e.match_id == ^match_id,
      select: [e.team_id, count() |> coalesce(0)],
      group_by: e.team_id
  end
end
