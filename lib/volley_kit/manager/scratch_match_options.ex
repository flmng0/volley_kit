defmodule VolleyKit.Manager.ScratchMatchOptions do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :a_name, :string
    field :b_name, :string

    field :set_count, :integer
  end

  @doc false
  def changeset(options, attrs \\ %{}) do
    options
    |> cast(attrs, [:a_name, :b_name, :set_count])
    |> validate_required([:a_name, :b_name, :set_count])
    |> validate_number(:set_count, greater_than: 0)
  end
end
