defmodule Volley.Sqids.Helpers do
  @doc """
  Create the encoding and decoding methods for a resource type.

  This generated `decode/2` method ensure that the returned ID is for the
  desired type.
  """
  defmacro resource(name, prefix) do
    quote do
      def encode!(unquote(name), id), do: Sqids.encode!(context(), [unquote(prefix), id])

      def decode(unquote(name), sqid) do
        case Sqids.decode!(context(), sqid) do
          [unquote(prefix), id] -> {:ok, id}
          [] -> :error
        end
      end
    end
  end
end

defmodule Volley.Sqids do
  import Sqids.Hacks, only: [dialyzed_ctx: 1]

  @context Sqids.new!(alphabet: "ABCDEFGHIJKLMNOPQRSTUVWXYZ", min_length: 6)

  defp context, do: dialyzed_ctx(@context)

  @spec encode!(atom(), number()) :: String.t()
  @spec decode(atom(), String.t()) :: {:ok, number()} | :error

  require Volley.Sqids.Helpers, as: Helpers

  Helpers.resource(:match, 0)
end
