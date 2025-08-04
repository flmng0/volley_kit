defmodule Volley.Scoring.Match do
  use Ash.Resource,
    domain: Volley.Scoring,
    notifiers: Ash.Notifier.PubSub,
    data_layer: AshPostgres.DataLayer

  alias Volley.Scoring.Team
  alias Volley.Scoring.Settings
  alias Volley.Scoring.Changes.AddEvent

  postgres do
    table "scoring_matches"
    repo Volley.Repo
  end

  actions do
    defaults [:read, :destroy]

    create :start do
      accept [:settings]
    end

    update :settings do
      accept [:settings]
    end

    update :score do
      argument :team, Team
      require_atomic? false

      change increment(:a_score), where: argument_equals(:team, :a)
      change increment(:b_score), where: argument_equals(:team, :b)

      change {AddEvent, type: :score}
      load :events
    end

    destroy :finish do
      primary? true
      soft? true

      change set_attribute(:finished?, true)
    end
  end

  pub_sub do
    module VolleyWeb.Endpoint

    prefix "match"

    publish :start, "start"
    publish :score, [:id, "score"]
  end

  attributes do
    uuid_primary_key :id

    create_timestamp :inserted_at
    update_timestamp :updated_at

    attribute :a_score, :integer, default: 0, constraints: [min: 0]
    attribute :b_score, :integer, default: 0, constraints: [min: 0]
    attribute :a_sets, :integer, default: 0, constraints: [min: 0]
    attribute :b_sets, :integer, default: 0, constraints: [min: 0]

    attribute :settings, Settings, allow_nil?: false

    attribute :finished?, :boolean
  end

  relationships do
    has_many :events, Volley.Scoring.Event
  end

  calculations do
    # zero-indexed current set
    calculate :current_set, :integer, expr(a_sets + b_sets)

    # the current set limit, accounting for if final set
    calculate :set_limit,
              :integer,
              expr(
                cond do
                  is_nil(settings[:total_sets]) or is_nil(settings[:final_set_limit]) ->
                    settings[:set_limit]

                  current_set + 1 < settings[:total_sets] ->
                    settings[:set_limit]

                  true ->
                    settings[:final_set_limit]
                end
              ) do
      load :current_set
    end

    # get the current winning team, if any
    calculate :winning_team,
              Team,
              expr(
                cond do
                  a_score >= set_limit && a_score >= b_score + 2 -> :a
                  b_score >= set_limit && b_score >= a_score + 2 -> :b
                  true -> nil
                end
              ) do
      load :set_limit
    end
  end
end
