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

  def list_tournaments(%Scope{user: user}) do
    Repo.all_by(Tournament, owner_id: user.id)
  end

  def get_tournament(%Scope{user: user}, id) do
    query = from tournament in Tournament, where: tournament.owner_id == ^user.id

    Repo.get(query, id)
  end

  def delete_tournament(%Scope{} = scope, %Tournament{} = tournament) do
    if Scope.own_resource?(scope, tournament) do
      Repo.delete(tournament)
    else
      {:error, :not_owner}
    end
  end
end
