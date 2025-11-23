defmodule Volley.Scoring.Settings do
  use Ecto.Schema
  import Ecto.Changeset

  @team_name_length min: 3, max: 30

  @primary_key false
  embedded_schema do
    field :a_name, :string, default: "Team A"
    field :b_name, :string, default: "Team B"

    field :set_limit, :integer, default: 25

    field :total_sets, :integer
    field :final_set_limit, :integer
  end

  def changeset(settings, params \\ %{}) do
    settings
    |> cast(params, [:a_name, :b_name, :set_limit, :total_sets, :final_set_limit])
    |> validate_required([:a_name, :b_name, :set_limit])
    |> validate_length(:a_name, @team_name_length)
    |> validate_length(:b_name, @team_name_length)
    |> validate_number(:set_limit, greater_than: 1)
    |> validate_number(:final_set_limit, greater_than: 1)
  end
end
