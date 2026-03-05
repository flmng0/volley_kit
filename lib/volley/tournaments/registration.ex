defmodule Volley.Tournaments.Registration do
  use Ecto.Schema

  alias Volley.Tournaments.Team

  schema "registrations" do
    field :email, :string
    field :accepted_at, :utc_datetime

    belongs_to :team, Team

    timestamps(updated_at: false)
  end
end
