defmodule Volley.Tournaments.Tournament do
  use Ecto.Schema
  import Ecto.Changeset

  alias Volley.Tournaments.Division
  alias Volley.Tournaments.Team

  @derive {Phoenix.Param, key: :public_id}

  schema "tournaments" do
    field :public_id, Ecto.UUID, autogenerate: true

    field :name, :string

    field :draft, :boolean, default: true
    field :timezone, :string

    field :location, :string

    field :start, :naive_datetime
    field :end, :naive_datetime

    field :registration_opened_at, :naive_datetime
    field :registration_closed_at, :naive_datetime
    field :registration_open, :boolean, virtual: true

    # Consider adding currency for registration. Currently AUD is assumed.
    # Stored in AUD dollars
    field :registration_price, :integer

    has_many :divisions, Division, on_replace: :delete
    has_many :teams, Team, on_replace: :delete

    belongs_to :owner, Volley.Accounts.User

    timestamps()
  end

  def details_setup_changeset(tournament, params \\ %{}) do
    tournament
    |> cast(params, [:name, :location, :start, :end, :timezone])
    |> validate_required([:name, :timezone])
    |> validate_timezone()
  end

  def divisions_setup_changeset(tournament, params \\ %{}) do
    tournament
    |> cast(params, [])
    |> cast_divisions()
  end

  def registration_setup_changeset(tournament, params \\ %{}) do
    tournament
    |> cast(params, [:registration_opened_at, :registration_closed_at, :registration_price])
  end

  def overview_changeset(tournament, params \\ %{}) do
    # TODO: Validate that start < end
    tournament
    |> cast(params, [
      :name,
      :timezone,
      :location,
      :start,
      :end,
      :registration_closed_at,
      :registration_opened_at,
      :registration_price
    ])
    |> validate_timezone()
    |> validate_required([:name, :timezone])
    |> validate_number(:registration_price, greater_than: 0)
    |> cast_divisions()
  end

  def teams_changeset(tournament, params \\ %{}) do
    tournament
    |> cast(params, [])
    |> cast_teams()
  end

  def publish_confirm_changeset(params \\ %{}) do
    data = %{}
    types = %{confirmation: :boolean}

    {data, types}
    |> cast(params, Map.keys(types))
    |> validate_acceptance(:confirmation, message: "Please confirm you have read the disclaimer.")
  end

  def publish_changeset(tournament) do
    change(tournament, draft: false)
  end

  defp validate_timezone(changeset) do
    valid_timezones = TimeZoneInfo.time_zones()
    validate_inclusion(changeset, :timezone, valid_timezones, message: "not a valid timezone")
  end

  # For consistent sort_param and drop_param across changesets
  defp cast_divisions(changeset) do
    cast_assoc(changeset, :divisions, sort_param: :sort_divisions, drop_param: :drop_divisions)
  end

  defp cast_teams(changeset) do
    cast_assoc(changeset, :teams, sort_param: :sort_teams, drop_param: :drop_teams)
  end

  def open_registration_changeset(tournament) do
    if timezone = get_field(tournament, :timezone) do
      {:ok, now} = DateTime.now(timezone)

      change(tournament, registration_opened_at: now)
    end
  end

  def teams_need_attention?(%__MODULE__{} = tournament) do
    tournament = Volley.Repo.preload(tournament, [:divisions, :teams])

    division_ids = tournament.divisions |> Enum.map(& &1.id) |> MapSet.new()

    stale_division = fn %Team{} = team ->
      team.division_id == nil || not MapSet.member?(division_ids, team.division_id)
    end

    tournament.divisions != [] and Enum.any?(tournament.teams, stale_division)
  end
end
