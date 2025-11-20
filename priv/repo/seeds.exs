# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Volley.Repo.insert!(%Volley.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.


if email = Application.get_env(:volley, :seed_user, nil) do
  alias Volley.Accounts

  confirmed = DateTime.utc_now() |> DateTime.truncate(:second)
  
  %Accounts.User{email: email, confirmed_at: confirmed}
  |> Volley.Repo.insert!()
end
