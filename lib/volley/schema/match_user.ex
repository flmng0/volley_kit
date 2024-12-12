defmodule Volley.Schema.MatchUser do
  use Ecto.Schema

  alias Volley.Schema.Match
  alias Volley.Accounts.User

  @primary_key false
  schema "match_users" do
    belongs_to :user, User
    belongs_to :match, Match

    # second_ref?
    field :level, Ecto.Enum, values: [owner: 1, scorer: 2]

    timestamps(type: :utc_datetime)
  end
end
