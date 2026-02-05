defmodule Volley.Tournaments.Tournament do
  use Ecto.Schema

  alias Volley.Tournaments.{Division, Team}

  schema "tournaments" do
    field :name, :string

    field :draft, :boolean, default: true
    field :timezone, :string

    field :location, :string

    field :start, :naive_datetime
    field :end, :naive_datetime

    field :registration_opened_at, :naive_datetime
    field :registration_closed_at, :naive_datetime
    field :registration_open, :boolean, virtual: true

    # Consider adding currency for registration. Currently AUD is assumed.
    # Stored in AUD Cents
    field :registration_price, :integer

    embeds_many :divisions, Division
    embeds_many :teams, Team

    belongs_to :owner, Volley.Accounts.User
  end
end
