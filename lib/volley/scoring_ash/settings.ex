defmodule Volley.ScoringAsh.Settings do
  use Ash.Resource,
    data_layer: :embedded

  attributes do
    attribute :a_name, :string,
      default: "Team A",
      description: "First team name",
      public?: true,
      allow_nil?: false,
      constraints: [allow_empty?: false, min_length: 3, max_length: 30]

    attribute :b_name, :string,
      default: "Team B",
      public?: true,
      allow_nil?: false,
      constraints: [allow_empty?: false, min_length: 3, max_length: 30]

    attribute :set_limit, :integer, default: 25, public?: true, allow_nil?: false

    attribute :total_sets, :integer, default: nil, public?: true
    attribute :final_set_limit, :integer, default: nil, public?: true
  end
end
