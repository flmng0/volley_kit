defmodule Volley.Scoresheets.SetSummary do
  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field :set, :integer

    field :a_name, :string
    field :a_score, :integer

    field :b_name, :string
    field :b_score, :integer

    embeds_many :rotation_summaries, RotationSummary, primary_key: false do
      field :position, :integer
      field :score, :integer
      field :player, :string
    end

    embeds_many :timeouts, Timeout, primary_key: false do
      field :initiator, Ecto.Enum, values: [:a, :b]
      field :initiator_score, :integer
      field :opposing_score, :integer
    end
  end
end
