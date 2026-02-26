defmodule Volley.Tournaments.Tournament do
  use Ecto.Schema
  import Ecto.Changeset

  alias Volley.Tournaments.{Division, Team}

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
    # Stored in AUD Cents
    field :registration_price, :integer

    has_many :divisions, Division, on_replace: :delete, on_delete: :delete_all
    has_many :teams, Team

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
  end

  def teams_changeset(tournament, params \\ %{}) do
    tournament
    |> cast(params, [])
    |> cast_divisions()
    |> cast_teams()
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

  def release_changeset(tournament) do
    change(tournament, draft: false)
  end

  def open_registration_changeset(tournament) do
    if timezone = get_field(tournament, :timezone) do
      {:ok, now} = DateTime.now(timezone)

      change(tournament, registration_opened_at: now)
    end
  end
end
