defmodule VolleyKit.Manager do
  @moduledoc """
  The Manager context.
  """

  import Ecto.Query, warn: false
  alias VolleyKit.Sqids
  alias VolleyKit.Repo

  alias VolleyKit.Manager.Team

  @doc """
  Updates a team.

  ## Examples

      iex> update_team(team, %{field: new_value})
      {:ok, %Team{}}

      iex> update_team(team, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_team(%Team{} = team, attrs) do
    team
    |> Team.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team changes.

  ## Examples

      iex> change_team(team)
      %Ecto.Changeset{data: %Team{}}

  """
  def change_team(%Team{} = team, attrs \\ %{}) do
    Team.changeset(team, attrs)
  end

  alias VolleyKit.Manager.Match

  def reload_match(%Match{} = match) do
    Repo.reload(match) |> load_match_teams()
  end

  def load_match_teams(nil), do: nil
  def load_match_teams(%Match{} = match), do: Repo.preload(match, [:team_a, :team_b])

  def get_owned_match(user_id) do
    case Repo.get_by(Match, owner: user_id) do
      nil ->
        nil

      match ->
        load_match_teams(match)
    end
  end

  @type share_level :: :view | :score

  @spec share_level_val(share_level()) :: integer()
  defp share_level_val(:view), do: 0
  defp share_level_val(:score), do: 1

  @spec get_share_level(integer()) :: {:ok, share_level()} | :error
  def get_share_level(0), do: {:ok, :view}
  def get_share_level(1), do: {:ok, :score}
  def get_share_level(_), do: :error

  @spec get_share_code(%Match{}, share_level()) :: String.t()

  def get_share_code(%Match{} = match, level \\ :view) do
    level_val = share_level_val(level)
    Sqids.encode!([match.id, level_val])
  end

  def decode_share_code(share_code) do
    with [match_id, level] <- Sqids.decode!(share_code),
         {:ok, share_level} <- get_share_level(level) do
      {match_id, share_level}
    end
  end

  def get_shared_match(share_code) do
    with {id, _} <- decode_share_code(share_code) do
      Repo.get(Match, id) |> load_match_teams()
    end
  end

  @doc """
  Returns the list of matches.

  ## Examples

      iex> list_matches()
      [%Match{}, ...]

  """
  def list_matches do
    Repo.all(Match)
  end

  @doc """
  Gets a single match.

  Raises `Ecto.NoResultsError` if the Match does not exist.

  ## Examples

      iex> get_match!(123)
      %Match{}

      iex> get_match!(456)
      ** (Ecto.NoResultsError)

  """
  def get_match!(id), do: Repo.get!(Match, id) |> load_match_teams()

  @doc """
  Creates a match.

  ## Examples

      iex> create_match(%{field: value})
      {:ok, %Match{}}

      iex> create_match(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_match(attrs \\ %{}) do
    %Match{}
    |> Match.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a match.

  ## Examples

      iex> update_match(match, %{field: new_value})
      {:ok, %Match{}}

      iex> update_match(match, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_match(%Match{} = match, attrs) do
    match
    |> Match.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a match.

  ## Examples

      iex> delete_match(match)
      {:ok, %Match{}}

      iex> delete_match(match)
      {:error, %Ecto.Changeset{}}

  """
  def delete_match!(%Match{} = match) do
    team_a_id = match.team_a_id
    team_b_id = match.team_b_id

    match = Repo.delete!(match)

    Repo.get!(Team, team_a_id) |> Repo.delete!()
    Repo.get!(Team, team_b_id) |> Repo.delete!()

    match
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking match changes.

  ## Examples

      iex> change_match(match)
      %Ecto.Changeset{data: %Match{}}

  """
  def change_match(%Match{} = match, attrs \\ %{}) do
    Match.changeset(match, attrs)
  end
end
