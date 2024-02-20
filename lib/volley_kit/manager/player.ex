defmodule VolleyKit.Manager.Player do
	use Ecto.Schema

  embedded_schema do
    field :name, :string
    field :number, :integer
  end
end
