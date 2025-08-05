defmodule Volley.Scoring do
  use Ash.Domain

  resources do
    resource Volley.Scoring.Match do
      define :get_match, get_by: :id, action: :read

      define :start_match, action: :start, args: [:settings]

      define :score, args: [:team]
      define :complete_set, args: [:team]

      define :undo_event, action: :undo, args: [{:optional, :count}]

      define_calculation :winning_team, args: [:_record]
      define_calculation :current_set, args: [:_record]
    end

    resource Volley.Scoring.Event
  end

  def match_topic(%Volley.Scoring.Match{id: id}), do: "match:#{id}"
end
