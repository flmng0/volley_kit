defmodule VolleyWeb.TournamentLive.Common do
  def collect_timezone_options() do
    TimeZoneInfo.time_zones()
    |> Enum.group_by(fn tz ->
      case String.split(tz, "/", parts: 2) do
        [prefix, _] -> prefix
        prefix -> prefix
      end
    end)
    |> Enum.sort_by(&elem(&1, 1))
  end
end
