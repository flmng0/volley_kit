defmodule Volley.Scoring.Match do
  use Ash.Resource,
    domain: Volley.Scoring,
    notifiers: Ash.Notifier.PubSub,
    data_layer: AshPostgres.DataLayer

  alias Volley.Scoring.Team

  defmodule AddEvent do
    use Ash.Resource.Change

    defp validate(:type, opts) do
      types = Volley.Scoring.EventType.types()
      type = Keyword.get(opts, :type)

      cond do
        is_nil(type) -> {:error, "event type is required"}
        type not in types -> {:error, "expected type to be one of: #{inspect(types)}"}
        true -> :ok
      end
    end

    defp validate(:team_argument, opts) do
      arg = Keyword.get(opts, :team_arguments)

      if is_nil(arg) or is_atom(arg) do
        :ok
      else
        {:error, "expected team argument to be an atom"}
      end
    end

    @impl true
    def init(opts) do
      with :ok <- validate(:type, opts),
           :ok <- validate(:team_argument, opts) do
        {:ok, opts}
      end
    end

    @impl true
    def change(changeset, opts, _ctx) do
      team_argument = opts[:team_argument] || :team

      event = %{
        match_id: Ash.Changeset.get_data(changeset, :id),
        type: opts[:type],
        team: Ash.Changeset.get_argument(changeset, team_argument)
      }

      Ash.Changeset.manage_relationship(changeset, :events, [event], type: :create)
    end
  end

  postgres do
    table "scoring_matches"
    repo Volley.Repo
  end

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
      require_atomic? false

      change increment(:a_score), where: argument_equals(:team, :a)
      change increment(:b_score), where: argument_equals(:team, :b)

      change {AddEvent, type: :score}
      load :events
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

    attribute :a_score, :integer, default: 0, constraints: [min: 0]

    attribute :b_name, :string do
      constraints allow_empty?: false,
                  min_length: 3

      allow_nil? false
      default "Team B"
    end

    attribute :b_score, :integer, default: 0, constraints: [min: 0]
  end

  relationships do
    has_many :events, Volley.Scoring.Event
  end

  calculations do
    calculate :winning_team,
              Team,
              expr(
                cond do
                  a_score >= ^arg(:set_limit) && a_score >= b_score + 2 -> :a
                  b_score >= ^arg(:set_limit) && b_score >= a_score + 2 -> :b
                  true -> nil
                end
              ) do
      argument :set_limit, :integer do
        default 25
        constraints min: 1
        allow_nil? true
      end
    end
  end
end
