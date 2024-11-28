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

alias Volley.Repo

if Application.compile_env!(:volley, :dev_routes) do
  {:ok, match} = Volley.create_match("test a", "test b")

  {:ok, match} = Volley.score_match(match, :a)
  {:ok, match} = Volley.score_match(match, :a)
  {:ok, _match} = Volley.score_match(match, :a)
end
