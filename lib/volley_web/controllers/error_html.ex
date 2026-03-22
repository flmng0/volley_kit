defmodule VolleyWeb.ErrorHTML do
  @moduledoc """
  This module is invoked by your endpoint in case of errors on HTML requests.

  See config/config.exs.
  """
  use VolleyWeb, :html

  defp error_message(%Phoenix.Router.NoRouteError{}) do
    {"Lost?", "The page you were looking for could not be found"}
  end

  defp error_message(%VolleyWeb.RequestError{message: message}) do
    {"Malformed Query", message}
  end

  defp error_message(%VolleyWeb.NotFoundError{message: message}) do
    {"Resource Not Found", message}
  end

  defp error_message(_err) do
    {"Unknown Error", "Uh oh... a genuinely unexpected error has occured"}
  end

  def render(_template, assigns) do
    {title, message} = error_message(assigns[:reason])

    assigns =
      assigns
      |> assign(:title, title)
      |> assign(:message, message)

    ~H"""
    <Layouts.error status={@status}>
      <div class="grid min-h-screen place-items-center">
        <div class="grid sm:grid-cols-[auto_1fr] gap-x-2 gap-y-1 px-4 max-w-xl w-full">
          <h1 class="sm:col-span-2 text-2xl font-mono text-center mb-6">{@title}</h1>

          <span class="font-mono text-base-content/80">status:</span>
          <p class="mb-6">{@status}</p>

          <span class="font-mono text-base-content/80">message:</span>
          <p class="mb-6">{@message}</p>

          <.link href="/" class="link col-span-2 text-center">Return to Safety</.link>
        </div>
      </div>
    </Layouts.error>
    """
  end
end
