defmodule VolleyKit.Manager do
  @moduledoc """
  The Manager context.
  """

  import Ecto.Query, warn: false
  alias VolleyKit.Repo

  alias VolleyKit.Manager.ScratchMatch

  @doc """
  Returns the list of scratch_matches.

  ## Examples

      iex> list_scratch_matches()
      [%ScratchMatch{}, ...]

  """
  def list_scratch_matches do
    Repo.all(ScratchMatch)
  end

  @doc """
  Gets a single scratch_match.

  Raises `Ecto.NoResultsError` if the Scratch match does not exist.

  ## Examples

      iex> get_scratch_match!(123)
      %ScratchMatch{}

      iex> get_scratch_match!(456)
      ** (Ecto.NoResultsError)

  """
  def get_scratch_match!(id), do: Repo.get!(ScratchMatch, id)

  @doc """
  Creates a scratch_match from its options, given a creator's ID.

  ## Examples

      iex> create_scratch_match(user_id, %{field: value})
      {:ok, %ScratchMatch{}}

      iex> create_scratch_match(user_id, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_scratch_match(created_by, options \\ %{}) do
    %ScratchMatch{created_by: created_by, a_score: 0, b_score: 0}
    |> ScratchMatch.changeset(%{"options" => options})
    |> Repo.insert()
  end

  @doc """
  Updates a scratch_match.

  ## Examples

      iex> update_scratch_match(scratch_match, %{field: new_value})
      {:ok, %ScratchMatch{}}

      iex> update_scratch_match(scratch_match, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_scratch_match(%ScratchMatch{} = scratch_match, attrs) do
    scratch_match
    |> ScratchMatch.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a scratch_match.

  ## Examples

      iex> delete_scratch_match(scratch_match)
      {:ok, %ScratchMatch{}}

      iex> delete_scratch_match(scratch_match)
      {:error, %Ecto.Changeset{}}

  """
  def delete_scratch_match(%ScratchMatch{} = scratch_match) do
    Repo.delete(scratch_match)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking scratch_match changes.

  ## Examples

      iex> change_scratch_match(scratch_match)
      %Ecto.Changeset{data: %ScratchMatch{}}

  """
  def change_scratch_match(%ScratchMatch{} = scratch_match, attrs \\ %{}) do
    ScratchMatch.changeset(scratch_match, attrs)
  end
end
