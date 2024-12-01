defmodule Volley.Schema.Match do
  use Ecto.Schema

  alias Volley.Schema

  schema "matches" do
    embeds_one :team_a_summary, Schema.TeamSummary, on_replace: :update
    embeds_one :team_b_summary, Schema.TeamSummary, on_replace: :update

    embeds_one :options, Schema.MatchOptions, on_replace: :update

    timestamps(type: :utc_datetime)
  end
end
