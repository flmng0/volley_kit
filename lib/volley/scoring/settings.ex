defmodule Volley.Scoring.Settings do
  use Ash.TypedStruct

  typed_struct do
    field :a_name, :string,
      default: "Team A",
      allow_nil?: false,
      constraints: [min_length: 3]

    field :b_name, :string,
      default: "Team B",
      allow_nil?: false,
      constraints: [min_length: 3]

    field :set_limit, :integer, default: 25, allow_nil?: false

    field :total_sets, :integer, default: nil
    field :final_set_limit, :integer, default: nil
  end
end
