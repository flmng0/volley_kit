defmodule Volley.Schema.Match do
  use Ecto.Schema

  alias Volley.Schema

  schema "matches" do
    belongs_to :team_a, Schema.Team
    embeds_one :team_a_summary, Schema.TeamSummary, on_replace: :update

    belongs_to :team_b, Schema.Team
    embeds_one :team_b_summary, Schema.TeamSummary, on_replace: :update

    timestamps(type: :utc_datetime)
  end
end
