defmodule Volley.Scoring.Match do
  use Ash.Resource,
    domain: Volley.Scoring,
    notifiers: Ash.Notifier.PubSub

  alias Volley.Scoring.Types.Team

  actions do
    defaults [:read, :destroy]

    create :start do
      accept [:a_name, :b_name]
      primary? true
    end

    update :settings do
      accept [:a_name, :b_name]
    end

    update :score do
      argument :team, Team

      change increment(:a_score), where: argument_equals(:team, :a)
      change increment(:b_score), where: argument_equals(:team, :b)
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

    attribute :a_name, :string do
      constraints allow_empty?: false,
                  min_length: 3

      allow_nil? false
      default "Team A"
    end

    attribute :a_score, :integer, default: 0

    attribute :b_name, :string do
      constraints allow_empty?: false,
                  min_length: 3

      allow_nil? false
      default "Team B"
    end

    attribute :b_score, :integer, default: 0
  end
end
