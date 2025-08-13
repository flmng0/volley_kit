defmodule Volley.ScoringAsh.Event do
  use Ash.Resource,
    domain: Volley.Scoring,
    data_layer: AshPostgres.DataLayer

  alias Volley.Scoring.{Team, EventType}

  postgres do
    table "scoring_events"
    repo Volley.Repo

    references do
      reference :match, on_delete: :delete
    end
  end

  actions do
    defaults [:read, :destroy, create: :*]
  end

  attributes do
    uuid_primary_key :id
    create_timestamp :inserted_at

    attribute :type, EventType do
      allow_nil? false
      public? true
    end

    attribute :team, Team do
      allow_nil? false
      public? true
    end
  end

  relationships do
    belongs_to :match, Volley.Scoring.Match, public?: true, allow_nil?: false
  end
end
