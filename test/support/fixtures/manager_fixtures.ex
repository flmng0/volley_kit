defmodule VolleyKit.ManagerFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `VolleyKit.Manager` context.
  """

  @doc """
  Generate a scratch_match.
  """
  def scratch_match_fixture(attrs \\ %{}) do
    {:ok, scratch_match} =
      attrs
      |> Enum.into(%{
        options: %{},
        team_a_name: "some team_a_name",
        team_a_score: 42,
        team_b_name: "some team_b_name",
        team_b_score: 42
      })
      |> VolleyKit.Manager.create_scratch_match()

    scratch_match
  end
end
