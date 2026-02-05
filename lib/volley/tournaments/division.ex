defmodule Volley.Tournaments.Division do
  use Ecto.Schema

  embedded_schema do
    field :name, :string

    field :type, Ecto.Enum, values: [:mixed, :men, :women]
    field :max_age, :integer
  end
end
