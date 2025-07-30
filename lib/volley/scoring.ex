defmodule Volley.Scoring do
  use Ash.Domain

  resources do
    resource Volley.Scoring.Match do
      define :start_match, args: [:a_name, :b_name], action: :start
      define :score, args: [:team]

      define_calculation :winning_team,
        args: [:_record, {:optional, :set_limit}]
    end

    resource Volley.Scoring.Event
  end
end
