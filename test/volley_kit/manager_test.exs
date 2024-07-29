defmodule VolleyKit.ManagerTest do
  use VolleyKit.DataCase

  alias VolleyKit.Manager

  describe "scratch_matches" do
    alias VolleyKit.Manager.ScratchMatch

    import VolleyKit.ManagerFixtures

    @invalid_attrs %{options: nil, team_a_name: nil, team_a_score: nil, team_b_name: nil, team_b_score: nil}

    test "list_scratch_matches/0 returns all scratch_matches" do
      scratch_match = scratch_match_fixture()
      assert Manager.list_scratch_matches() == [scratch_match]
    end

    test "get_scratch_match!/1 returns the scratch_match with given id" do
      scratch_match = scratch_match_fixture()
      assert Manager.get_scratch_match!(scratch_match.id) == scratch_match
    end

    test "create_scratch_match/1 with valid data creates a scratch_match" do
      valid_attrs = %{options: %{}, team_a_name: "some team_a_name", team_a_score: 42, team_b_name: "some team_b_name", team_b_score: 42}

      assert {:ok, %ScratchMatch{} = scratch_match} = Manager.create_scratch_match(valid_attrs)
      assert scratch_match.options == %{}
      assert scratch_match.team_a_name == "some team_a_name"
      assert scratch_match.team_a_score == 42
      assert scratch_match.team_b_name == "some team_b_name"
      assert scratch_match.team_b_score == 42
    end

    test "create_scratch_match/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Manager.create_scratch_match(@invalid_attrs)
    end

    test "update_scratch_match/2 with valid data updates the scratch_match" do
      scratch_match = scratch_match_fixture()
      update_attrs = %{options: %{}, team_a_name: "some updated team_a_name", team_a_score: 43, team_b_name: "some updated team_b_name", team_b_score: 43}

      assert {:ok, %ScratchMatch{} = scratch_match} = Manager.update_scratch_match(scratch_match, update_attrs)
      assert scratch_match.options == %{}
      assert scratch_match.team_a_name == "some updated team_a_name"
      assert scratch_match.team_a_score == 43
      assert scratch_match.team_b_name == "some updated team_b_name"
      assert scratch_match.team_b_score == 43
    end

    test "update_scratch_match/2 with invalid data returns error changeset" do
      scratch_match = scratch_match_fixture()
      assert {:error, %Ecto.Changeset{}} = Manager.update_scratch_match(scratch_match, @invalid_attrs)
      assert scratch_match == Manager.get_scratch_match!(scratch_match.id)
    end

    test "delete_scratch_match/1 deletes the scratch_match" do
      scratch_match = scratch_match_fixture()
      assert {:ok, %ScratchMatch{}} = Manager.delete_scratch_match(scratch_match)
      assert_raise Ecto.NoResultsError, fn -> Manager.get_scratch_match!(scratch_match.id) end
    end

    test "change_scratch_match/1 returns a scratch_match changeset" do
      scratch_match = scratch_match_fixture()
      assert %Ecto.Changeset{} = Manager.change_scratch_match(scratch_match)
    end
  end
end
