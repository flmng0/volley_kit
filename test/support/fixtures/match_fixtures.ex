defmodule Volley.MatchFixtures do
  alias Volley.Repo

  @doc """
  Create a match with default options.

  Takes the following options, which will be updated on the returned match:

  > NOTE: This will not generate events, it updates the object directly.

  - `:a_score`
  - `:a_sets`
  - `:b_score`
  - `:b_sets`
  - `:options` - Expects a map that will be merged with the creation options.
  """
  def match_fixture(opts \\ []) do
    options =
      Volley.default_match_options()
      |> Map.from_struct()
      |> Map.merge(Keyword.get(opts, :options, %{}))

    {:ok, match} = Volley.create_match(options)

    match
    |> Ecto.Changeset.change(%{
      team_a_summary: %{
        score: Keyword.get(opts, :a_score, 0),
        sets: Keyword.get(opts, :a_sets, 0)
      },
      team_b_summary: %{
        score: Keyword.get(opts, :b_score, 0),
        sets: Keyword.get(opts, :b_sets, 0)
      }
    })
    |> Repo.update!()
  end
end
