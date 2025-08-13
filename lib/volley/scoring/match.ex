defmodule Volley.Scoring.Match do
  use Volley.Schema
  import Ecto.Changeset

  @team_name_length min: 3, max: 30

  schema "matches" do
    field :a_score, :integer, default: 0
    field :b_score, :integer, default: 0

    field :a_sets, :integer, default: 0
    field :b_sets, :integer, default: 0

    embeds_one :settings, Settings do
      field :a_name, :string, default: "Team A"
      field :b_name, :string, default: "Team B"

      field :set_limit, :integer, default: 25

      field :total_sets, :integer
      field :final_set_limit, :integer
    end

    belongs_to :owner, Volley.Accounts.User
    belongs_to :anonymous_owner, Volley.Accounts.AnonymousUser

    has_many :events, Volley.Scoring.Event

    timestamps()
  end

  def settings_changeset(settings, params \\ %{}) do
    settings
    |> cast(params, [:a_name, :b_name, :set_limit, :total_sets, :final_set_limit])
    |> validate_required([:a_name, :b_name, :set_limit])
    |> validate_length(:a_name, @team_name_length)
    |> validate_length(:b_name, @team_name_length)
    |> validate_number(:set_limit, greater_than: 1)
    |> validate_number(:final_set_limit, greater_than: 1)
  end

  def start_changeset(match, params \\ %{}) do
    match
    |> cast(params, [])
    |> cast_embed(:settings, required: true, with: &settings_changeset/2)
  end
end
