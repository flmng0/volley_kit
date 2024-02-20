defmodule VolleyKit.ManagerFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `VolleyKit.Manager` context.
  """

  @doc """
  Generate a team.
  """
  def team_fixture(attrs \\ %{}) do
    {:ok, team} =
      attrs
      |> Enum.into(%{
        members: %{},
        name: "some name",
        points: 42,
        sets: 42
      })
      |> VolleyKit.Manager.create_team()

    team
  end

  @doc """
  Generate a match.
  """
  def match_fixture(attrs \\ %{}) do
    {:ok, match} =
      attrs
      |> Enum.into(%{

      })
      |> VolleyKit.Manager.create_match()

    match
  end
end
