defmodule Volley.Scoring.Match do
  use Ash.Resource,
    domain: Volley.Scoring,
    notifiers: Ash.Notifier.PubSub,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshOban]

  alias Volley.Accounts.User
  alias Volley.Accounts.AnonymousUser

  alias Volley.Scoring.Team
  alias Volley.Scoring.Settings
  alias Volley.Scoring.Changes

  postgres do
    table "scoring_matches"
    repo Volley.Repo
  end

  oban do
    triggers do
      trigger :clean_old do
        scheduler_cron "@daily"
        worker_module_name __MODULE__.CleanOld.Worker
        scheduler_module_name __MODULE__.CleanOld.Scheduler
        action :destroy
        queue :cleanup
        read_action :read
        where expr(is_old)
      end
    end
  end

  actions do
    defaults [:read, :destroy]

    create :start do
      accept [:settings]

      change fn changeset, context ->
        case context.actor.user do
          %AnonymousUser{} = user ->
            Ash.Changeset.change_attribute(changeset, :anonymous_owner_id, user.id)

          %User{} = user ->
            Ash.Changeset.change_attribute(changeset, :owner_id, user.id)
        end
      end
    end

    read :get_by_user do
      filter expr(
               if ^actor(:anonymous) do
                 anonymous_owner_id == ^actor([:user, :id])
               else
                 owner_id == ^actor([:user, :id])
               end
             )
    end

    update :update_settings do
      accept [:settings]
    end

    update :score do
      argument :team, Team
      require_atomic? false

      change increment(:a_score), where: argument_equals(:team, :a)
      change increment(:b_score), where: argument_equals(:team, :b)

      change {Changes.AddEvent, type: :score}
      load :events
    end

    update :complete_set do
      argument :team, Team

      require_atomic? false

      change increment(:a_sets), where: argument_equals(:team, :a)
      change increment(:b_sets), where: argument_equals(:team, :b)

      change set_attribute(:a_score, 0)
      change set_attribute(:b_score, 0)

      change {Changes.AddEvent, type: :set_won}
    end

    update :undo do
      argument :count, :integer do
        allow_nil? false
        constraints min: 1
        default 1
      end

      require_atomic? false

      change {Changes.UndoEvents, []}
    end

    destroy :finish do
      primary? true
      soft? true

      change set_attribute(:finished?, true)
    end
  end

  policies do
    bypass AshOban.Checks.AshObanInteraction do
      authorize_if always()
    end

    policy_group action_type([:update, :destroy]) do
      policy actor_attribute_equals(:anonymous, true) do
        authorize_if expr(anonymous_owner_id == ^actor([:user, :id]))
      end

      policy actor_attribute_equals(:anonymous, false) do
        authorize_if expr(owner_id == ^actor([:user, :id]))
      end
    end

    policy action_type(:create) do
      authorize_if actor_present()
    end

    policy action_type(:read) do
      authorize_if always()
    end
  end

  pub_sub do
    module VolleyWeb.Endpoint

    prefix "match"

    publish :start, "start"
    publish :score, [:id]
    publish :complete_set, [:id]
    publish :update_settings, [:id]
  end

  attributes do
    uuid_primary_key :id

    create_timestamp :inserted_at
    update_timestamp :updated_at

    attribute :owner_id, :integer, allow_nil?: true
    attribute :anonymous_owner_id, :string, allow_nil?: true

    attribute :a_score, :integer, default: 0, constraints: [min: 0]
    attribute :b_score, :integer, default: 0, constraints: [min: 0]
    attribute :a_sets, :integer, default: 0, constraints: [min: 0]
    attribute :b_sets, :integer, default: 0, constraints: [min: 0]

    attribute :settings, Settings, public?: true, allow_nil?: false

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

    calculate :is_old, :boolean, expr(is_nil(owner_id) and updated_at < ago(1, :day))
  end
end
