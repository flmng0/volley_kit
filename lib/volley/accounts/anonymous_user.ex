defmodule Volley.Accounts.AnonymousUser do
  use Volley.Schema

  @primary_key {:id, :id, autogenerate: false}

  embedded_schema do
  end
end
