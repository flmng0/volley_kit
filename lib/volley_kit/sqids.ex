defmodule VolleyKit.Sqids do
  import Sqids.Hacks, only: [dialyzed_ctx: 1]

  @alphabet "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  @context Sqids.new!(alphabet: @alphabet, min_length: 6)

  def alphabet, do: @alphabet

  def encode!(nums), do: Sqids.encode!(dialyzed_ctx(@context), nums)
  def decode!(id), do: Sqids.decode!(dialyzed_ctx(@context), id)
end
