defmodule Volley.Tournaments do
  import Ecto.Query, only: [from: 2]

  alias Volley.Repo
  alias Volley.Accounts.Scope

  alias Volley.Tournaments.{Tournament, Team, Fixture}

  def create_tournament(%Scope{user: user}, params \\ %{}) do
    %Tournament{}
    |> Tournament.changeset(params)
    |> Ecto.Changeset.put_assoc(:owner, user)
    |> Repo.insert()
  end

  defp user_tournaments(%{id: user_id}), do: from(t in Tournament, where: t.owner_id == ^user_id)

  def count_tournaments(%Scope{user: user}) do
    user_tournaments(user) |> Repo.aggregate(:count)
  end

  def list_tournaments(%Scope{user: user}) do
    user_tournaments(user) |> Repo.all()
  end

  def get_tournament(%Scope{user: user}, id) do
    user_tournaments(user) |> Repo.get(id)
  end

  def delete_tournament(%Scope{} = scope, %Tournament{} = tournament) do
    if Scope.own_resource?(scope, tournament) do
      Repo.delete(tournament)
    else
      {:error, :not_owner}
    end
  end
end
