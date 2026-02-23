defmodule Volley.Tournaments do
  alias Volley.Accounts.Scope
  alias Volley.Accounts.User

  alias Volley.Tournaments.Tournament
  alias Volley.Tournaments.Division

  alias Volley.Repo

  alias Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  def list_tournaments(%Scope{user: user}) when is_struct(user, User) do
    Repo.all_by(Tournament, owner_id: user.id)
  end

  def get_tournament(%Scope{user: user}, id) when is_struct(user, User) do
    query =
      from t in Tournament,
        where: t.owner_id == ^user.id,
        preload: [:teams, :divisions]

    Repo.get(query, id)
  end

  def complete_tournament_setup!(%Scope{user: user}, %Tournament{} = tournament)
      when is_struct(user, User) do
    tournament
    |> Changeset.change()
    |> Changeset.put_assoc(:owner, user)
    |> Repo.insert!()
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

  def create_tournament_division(%Scope{} = scope, tournament_id, params) do
    tournament = get_tournament(scope, tournament_id)
    true = is_tournament_owner?(scope, tournament)

    tournament
    |> Ecto.build_assoc(:divisions)
    |> Division.changeset(params)
    |> Repo.insert()
  end

  def delete_tournament(%Scope{} = scope, %Tournament{} = tournament) do
    true = is_tournament_owner?(scope, tournament)
    Repo.delete(tournament)
  end
end
