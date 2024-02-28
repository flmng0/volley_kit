defmodule VolleyKit.Policy.Checks do
  alias VolleyKit.Manager
  alias Ecto.UUID

  def is_owner(user_id, %{owner: owner}) when is_binary(user_id) do
    match?({:ok, ^owner}, UUID.cast(user_id))
  end

  def is_owner(_, _), do: false

  def is_share_level(share_code, %{id: match_id}, level) when is_binary(share_code) do
    match?({^match_id, ^level}, Manager.decode_share_code(share_code))
  end

  def is_share_level(_, _, _), do: false
end
