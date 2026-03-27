defmodule Volley.Scoring.Match do
  use Ecto.Schema
  import Ecto.Changeset

  alias Volley.Scoring.Settings

  @derive {Phoenix.Param, key: :public_id}

  schema "matches" do
    field :public_id, Ecto.UUID, autogenerate: true

    field :a_score, :integer, default: 0
    field :b_score, :integer, default: 0

    field :a_sets, :integer, default: 0
    field :b_sets, :integer, default: 0

    embeds_one :settings, Settings, on_replace: :update

    belongs_to :owner, Volley.Accounts.User
    field :anonymous_owner_id, Ecto.UUID

    field :status, Ecto.Enum,
      values: [:in_progress, :completed],
      virtual: true,
      default: :in_progress

    has_many :events, Volley.Scoring.Event, on_replace: :delete

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

  def winning_team(%__MODULE__{} = match) do
    set_limit =
      if match.a_sets == match.b_sets && match.a_sets + 1 == match.settings.sets_to_win do
        match.settings.final_set_limit || match.settings.set_limit
      else
        match.settings.set_limit
      end

    cond do
      match.a_score >= set_limit and match.a_score >= match.b_score + 2 ->
        :a

      match.b_score >= set_limit and match.b_score >= match.a_score + 2 ->
        :b

      true ->
        nil
    end
  end

  # Zero-indexed current set
  def current_set(%__MODULE__{} = match) do
    match.a_sets + match.b_sets
  end

  @doc "Checks whether the game is finished, and assumes that there is a winning_team"
  def game_over?(%__MODULE__{} = match) do
    match.a_sets + 1 == match.settings.sets_to_win ||
      match.b_sets + 1 == match.settings.sets_to_win
  end
end
