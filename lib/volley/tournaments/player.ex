defmodule Volley.Tournaments.Player do
  use Ecto.Schema

  embedded_schema do
    field :name, :string
    field :dob, :date
    field :association_id, :string
  end
end
