defmodule Volley.Scoring do
  use Ash.Domain

  resources do
    resource Volley.Scoring.Match do
      define :get_match, get_by: :id, action: :read

      define :start_match, action: :start, args: [:settings]
      define :score, args: [:team]

      define_calculation :winning_team,
        args: [:_record, {:optional, :set_limit}]
    end

    resource Volley.Scoring.Event
  end

  def match_topic(%Volley.Scoring.Match{id: id}), do: "match:#{id}:score"
end
