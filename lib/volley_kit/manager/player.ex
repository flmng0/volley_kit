defmodule VolleyKit.Manager.Player do
	use Ecto.Schema
	import Ecto.Changeset

  embedded_schema do
    field :name, :string
    field :number, :integer
  end

	def changeset(player, attrs) do
		player
		|> cast(attrs, [:name, :number])
		|> validate_required([:name])
		|> validate_length(:name, min: 3)
	end
end
