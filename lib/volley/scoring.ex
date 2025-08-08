defmodule Volley.Scoring do
  use Ash.Domain

  resources do
    resource Volley.Scoring.Match do
      define :get_match, get_by: :id, action: :read, not_found_error?: false

      define :get_match_by_user, action: :get_by_user, get?: true, not_found_error?: false

      define :start_match, action: :start, args: [:settings]

      define :score, args: [:team]
      define :complete_set, args: [:team]
      define :reset_scores

      define :update_settings, args: [:settings]
      define :undo_event, action: :undo, args: [{:optional, :count}]

      define_calculation :winning_team, args: [:_record]
      define_calculation :current_set, args: [:_record]
    end

    resource Volley.Scoring.Event
  end

  def match_topic(%Volley.Scoring.Match{id: id}), do: "match:#{id}"
end
