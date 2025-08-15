defmodule Volley.Accounts.AnonymousUser do
  use Ecto.Schema

  @primary_key {:id, Ecto.UUID, autogenerate: false}

  embedded_schema do
  end
end
