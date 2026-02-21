defmodule Volley.Tournaments do
  alias Volley.Accounts.Scope
  alias Volley.Accounts.User

  alias Volley.Tournaments.Tournament

  alias Volley.Repo

  alias Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  def list_tournaments(%Scope{user: user}) when is_struct(user, User) do
    Repo.all_by(Tournament, owner_id: user.id)
  end

  def get_tournament(%Scope{user: user}, id) when is_struct(user, User) do
    query = from t in Tournament, where: t.owner_id == ^user.id
    Repo.get(query, id)
  end

  def create_tournament_draft(%Scope{user: user}, params) when is_struct(user, User) do
    %Tournament{draft: true}
    |> Tournament.create_changeset(params)
    |> Changeset.put_assoc(:owner, user)
    |> Repo.insert()
  end

  def is_tournament_owner?(%Scope{user: %User{id: user_id}}, %Tournament{owner_id: user_id}),
    do: true

  def is_tournament_owner?(%User{id: user_id}, %Tournament{owner_id: user_id}), do: true
  def is_tournament_owner?(_, _), do: false

  def update_tournament_overview(%Scope{} = scope, %Tournament{} = tournament, params) do
    true = is_tournament_owner?(scope, tournament)

    tournament
    |> Tournament.overview_changeset(params)
    |> Repo.update()
  end

  def delete_tournament(%Scope{} = scope, %Tournament{} = tournament) do
    true = is_tournament_owner?(scope, tournament)
    Repo.delete(tournament)
  end
end
