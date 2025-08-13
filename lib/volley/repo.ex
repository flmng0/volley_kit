defmodule Volley.Repo do
  use Ecto.Repo,
    otp_app: :volley,
    adapter: Ecto.Adapters.Postgres
end
