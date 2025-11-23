defmodule Volley.Scoring.Match do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Phoenix.Param, key: :public_id}

  alias Volley.Scoring.{Event, Settings}

  schema "matches" do
    field :public_id, Ecto.UUID, autogenerate: true

    field :a_score, :integer, default: 0
    field :b_score, :integer, default: 0

    field :a_sets, :integer, default: 0
    field :b_sets, :integer, default: 0

    embeds_one :settings, Settings, on_replace: :update

    belongs_to :fixture, Volley.Tournaments.Fixture
    belongs_to :owner, Volley.Accounts.User

    field :anonymous_owner_id, Ecto.UUID

    has_many :events, Event, on_replace: :delete

    timestamps()
  end

  def start_changeset(match, params \\ %{}) do
    match
    |> cast(params, [:anonymous_owner_id])
    |> cast_assoc(:owner)
    |> cast_embed(:settings, required: true)
  end

  def update_settings_changeset(match, params \\ %{}) do
    match
    |> cast(params, [])
    |> cast_embed(:settings, required: true)
  end

  def winning_team(%__MODULE__{} = match), do: winning_team(match, match.settings.set_limit)

  def winning_team(%__MODULE__{} = match, set_limit) do
    cond do
      match.a_score >= set_limit and match.a_score >= match.b_score + 2 ->
        :a

      match.b_score >= set_limit and match.b_score >= match.a_score + 2 ->
        :b

      true ->
        nil
    end
  end

  def current_set(%__MODULE__{} = match) do
    match.a_sets + match.b_sets
  end
end
