defmodule VolleyKit.ManagerTest do
  use VolleyKit.DataCase

  alias VolleyKit.Manager

  describe "teams" do
    alias VolleyKit.Manager.Team

    import VolleyKit.ManagerFixtures

    @invalid_attrs %{name: nil, sets: nil, points: nil, members: nil}

    test "list_teams/0 returns all teams" do
      team = team_fixture()
      assert Manager.list_teams() == [team]
    end

    test "get_team!/1 returns the team with given id" do
      team = team_fixture()
      assert Manager.get_team!(team.id) == team
    end

    test "create_team/1 with valid data creates a team" do
      valid_attrs = %{name: "some name", sets: 42, points: 42, members: %{}}

      assert {:ok, %Team{} = team} = Manager.create_team(valid_attrs)
      assert team.name == "some name"
      assert team.sets == 42
      assert team.points == 42
      assert team.members == %{}
    end

    test "create_team/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Manager.create_team(@invalid_attrs)
    end

    test "update_team/2 with valid data updates the team" do
      team = team_fixture()
      update_attrs = %{name: "some updated name", sets: 43, points: 43, members: %{}}

      assert {:ok, %Team{} = team} = Manager.update_team(team, update_attrs)
      assert team.name == "some updated name"
      assert team.sets == 43
      assert team.points == 43
      assert team.members == %{}
    end

    test "update_team/2 with invalid data returns error changeset" do
      team = team_fixture()
      assert {:error, %Ecto.Changeset{}} = Manager.update_team(team, @invalid_attrs)
      assert team == Manager.get_team!(team.id)
    end

    test "delete_team/1 deletes the team" do
      team = team_fixture()
      assert {:ok, %Team{}} = Manager.delete_team(team)
      assert_raise Ecto.NoResultsError, fn -> Manager.get_team!(team.id) end
    end

    test "change_team/1 returns a team changeset" do
      team = team_fixture()
      assert %Ecto.Changeset{} = Manager.change_team(team)
    end
  end

  describe "matches" do
    alias VolleyKit.Manager.Match

    import VolleyKit.ManagerFixtures

    @invalid_attrs %{}

    test "list_matches/0 returns all matches" do
      match = match_fixture()
      assert Manager.list_matches() == [match]
    end

    test "get_match!/1 returns the match with given id" do
      match = match_fixture()
      assert Manager.get_match!(match.id) == match
    end

    test "create_match/1 with valid data creates a match" do
      valid_attrs = %{}

      assert {:ok, %Match{} = match} = Manager.create_match(valid_attrs)
    end

    test "create_match/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Manager.create_match(@invalid_attrs)
    end

    test "update_match/2 with valid data updates the match" do
      match = match_fixture()
      update_attrs = %{}

      assert {:ok, %Match{} = match} = Manager.update_match(match, update_attrs)
    end

    test "update_match/2 with invalid data returns error changeset" do
      match = match_fixture()
      assert {:error, %Ecto.Changeset{}} = Manager.update_match(match, @invalid_attrs)
      assert match == Manager.get_match!(match.id)
    end

    test "delete_match/1 deletes the match" do
      match = match_fixture()
      assert {:ok, %Match{}} = Manager.delete_match(match)
      assert_raise Ecto.NoResultsError, fn -> Manager.get_match!(match.id) end
    end

    test "change_match/1 returns a match changeset" do
      match = match_fixture()
      assert %Ecto.Changeset{} = Manager.change_match(match)
    end
  end
end
