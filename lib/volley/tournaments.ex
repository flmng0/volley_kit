defmodule Volley.Tournaments do
  alias Volley.Accounts.Scope
  alias Volley.Accounts.User

  alias Volley.Tournaments.Tournament
  alias Volley.Tournaments.Team
  alias Volley.Tournaments.Division

  alias Volley.Repo

  alias Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  def is_tournament_owner?(scope, tournament)

  def is_tournament_owner?(%Scope{user: %User{id: user_id}}, %Tournament{owner_id: user_id}),
    do: true

  def is_tournament_owner?(%User{id: user_id}, %Tournament{owner_id: user_id}), do: true
  def is_tournament_owner?(_, _), do: false

  defp maybe_preload(result, preloads, opts \\ [])

  defp maybe_preload({:ok, result}, preloads, opts),
    do: {:ok, Repo.preload(result, preloads, opts)}

  defp maybe_preload(result, _preloads, _opts), do: result

  def list_tournaments(%Scope{user: user}) when is_struct(user, User) do
    Repo.all_by(Tournament, owner_id: user.id)
  end

  def list_teams(%Scope{} = scope, %Tournament{} = tournament) do
    true = is_tournament_owner?(scope, tournament)

    query =
      from t in Team,
        preload: [:division]

    Repo.all_by(query, tournament_id: tournament.id)
  end

  def get_tournament(%Scope{user: user}, id) when is_struct(user, User) do
    query =
      from t in Tournament,
        where: t.owner_id == ^user.id,
        preload: [:teams, :divisions]

    Repo.get_by(query, public_id: id)
  end

  def get_team(%Scope{user: user}, team_id) when is_struct(user, User) do
    query =
      from t in Team,
        join: tournament in assoc(t, :tournament),
        preload: [:division, tournament: tournament],
        where: tournament.owner_id == ^user.id

    Repo.get(query, team_id)
  end

  def complete_tournament_setup!(%Scope{user: user}, %Tournament{} = tournament)
      when is_struct(user, User) do
    tournament
    |> Changeset.change()
    |> Changeset.put_assoc(:owner, user)
    |> Repo.insert!()
  end

  def update_tournament_overview(%Scope{} = scope, %Tournament{} = tournament, params) do
    true = is_tournament_owner?(scope, tournament)

    tournament
    |> Tournament.overview_changeset(params)
    |> Repo.update()
    |> maybe_preload([:teams, :divisions])
  end

  def create_team(%Scope{} = scope, %Tournament{} = tournament, params) do
    true = is_tournament_owner?(scope, tournament)

    Ecto.build_assoc(tournament, :teams)
    |> Team.changeset(params, division_required: tournament.divisions != [])
    |> Repo.insert()
    |> maybe_preload(:division)
  end

  def update_team(%Scope{} = scope, %Team{} = team, params) do
    true = is_tournament_owner?(scope, team.tournament)

    changeset = Team.changeset(team, params, divisions_required: team.tournament.divisions != [])
    force_preload = Ecto.Changeset.changed?(changeset, :division_id)

    changeset
    |> Repo.update()
    |> maybe_preload(:division, force: force_preload)
  end

  def delete_tournament(%Scope{} = scope, %Tournament{} = tournament) do
    true = is_tournament_owner?(scope, tournament)

    Repo.transact(fn ->
      teams = from t in Team, where: t.tournament_id == ^tournament.id
      divisions = from d in Division, where: d.tournament_id == ^tournament.id

      Repo.delete_all(teams)
      Repo.delete_all(divisions)
      Repo.delete(tournament)
    end)
  end

  def delete_team(%Scope{} = scope, %Team{} = team) do
    true = is_tournament_owner?(scope, team.tournament)
    Repo.delete(team)
  end
end
