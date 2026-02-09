defmodule Volley.Tournaments.Tournament do
  use Ecto.Schema
  import Ecto.Changeset

  alias Volley.Tournaments.{Division, Team}

  @derive Phoenix.Param
  schema "tournaments" do
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

    embeds_many :divisions, Division
    embeds_many :teams, Team

    belongs_to :owner, Volley.Accounts.User

    timestamps()
  end

  def create_changeset(tournament, params \\ %{}) do
    tournament
    |> cast(params, [:name, :timezone])
    |> validate_required([:name, :timezone])
    |> validate_timezone()
  end

  def overview_changeset(tournament, params \\ %{}) do
    # TODO: Validate that start < end
    tournament
    |> cast(params, [:name, :timezone, :location, :start, :end])
    |> validate_required([:name, :timezone])
  end

  def update_changeset(tournament, params \\ %{}) do
    tournament
    |> cast(params, [
      :name,
      :timezone,
      :location,
      :start,
      :end,
      :registration_opened_at,
      :registration_closed_at,
      :registration_price
    ])
    |> validate_timezone()
    |> cast_embed(:divisions, sort_param: :sort_divisions, drop_param: :drop_divisions)
    |> cast_embed(:teams, sort_param: :sort_teams, drop_param: :drop_teams)
  end

  defp validate_timezone(changeset) do
    valid_timezones = TimeZoneInfo.time_zones()
    validate_inclusion(changeset, :timezone, valid_timezones)
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
