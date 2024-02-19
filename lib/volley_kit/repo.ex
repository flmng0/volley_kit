defmodule VolleyKit.Repo do
  use Ecto.Repo,
    otp_app: :volley_kit,
    adapter: Ecto.Adapters.Postgres
end
