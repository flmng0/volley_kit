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

if Application.compile_env!(:volley, :dev_routes) do
  {:ok, match} = Volley.create_match(%{team_a_name: "a", team_b_name: "b", set_point_limit: 25})

  for _ <- 1..3, reduce: match do
    match ->
      {:ok, match} = Volley.score_match(match, :a)
      match
  end
end
