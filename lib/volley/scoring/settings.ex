defmodule Volley.Scoring.Settings do
  use Ecto.Schema
  import Ecto.Changeset

  @team_name_length min: 3, max: 30

  embedded_schema do
    field :a_name, :string, default: "Team A"
    field :b_name, :string, default: "Team B"

    field :set_limit, :integer, default: 25

    field :total_sets, :integer
    field :final_set_limit, :integer
  end

  defp best_of_three,
    do: %{
      title: "Best of 3",
      set_limit: 25,
      total_sets: 3
    }

  defp best_of_five,
    do: %{
      title: "Best of 5",
      set_limit: 25,
      total_sets: 5,
      final_set_limit: 15
    }

  defp scratch,
    do: %{
      title: "Scratch",
      set_limit: 25
    }

  def presets() do
    [
      bo3: best_of_three(),
      bo5: best_of_five(),
      scratch: scratch()
    ]
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
