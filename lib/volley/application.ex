defmodule Volley.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      VolleyWeb.Telemetry,
      Volley.Repo,
      {DNSCluster, query: Application.get_env(:volley, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Volley.PubSub},
      # Start a worker by calling: Volley.Worker.start_link(arg)
      # {Volley.Worker, arg},
      # Start to serve requests, typically the last entry
      VolleyWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Volley.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    VolleyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
