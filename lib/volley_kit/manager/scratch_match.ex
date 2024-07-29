defmodule VolleyKit.Manager.ScratchMatch do
  use Ecto.Schema
  import Ecto.Changeset

  alias VolleyKit.Manager.ScratchMatchOptions

  schema "scratch_matches" do
    field :a_score, :integer
    field :b_score, :integer

    embeds_one :options, ScratchMatchOptions

    field :created_by, Ecto.UUID

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(scratch_match, attrs \\ %{}) do
    scratch_match
    |> cast(attrs, [:a_score, :b_score, :created_by])
    |> cast_embed(:options, required: true)
    |> validate_required([:a_score, :b_score, :created_by])
    |> validate_number(:a_score, greater_than_or_equal_to: 0)
    |> validate_number(:b_score, greater_than_or_equal_to: 0)
  end
end
