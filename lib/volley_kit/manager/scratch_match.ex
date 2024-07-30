defmodule VolleyKit.Manager.ScratchMatch do
  use Ecto.Schema
  import Ecto.Changeset

  alias VolleyKit.Manager.ScratchMatchOptions

  schema "scratch_matches" do
    field :a_score, :integer, default: 0
    field :a_sets, :integer, default: 0

    field :b_score, :integer, default: 0
    field :b_sets, :integer, default: 0

    embeds_one :options, ScratchMatchOptions

    field :created_by, Ecto.UUID

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(scratch_match, attrs \\ %{}) do
    scratch_match
    |> cast(attrs, [:a_score, :a_sets, :b_score, :b_sets, :created_by])
    |> cast_embed(:options, required: true)
    |> validate_required([:a_score, :a_sets, :b_score, :b_sets, :created_by])
    |> validate_number(:a_score, greater_than_or_equal_to: 0)
    |> validate_number(:b_score, greater_than_or_equal_to: 0)
    |> validate_number(:a_sets, greater_than_or_equal_to: 0)
    |> validate_number(:b_sets, greater_than_or_equal_to: 0)
  end
end
