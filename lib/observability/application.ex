defmodule Observability.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ObservabilityWeb.Telemetry,
      # Observability.Repo, # Commented out to avoid PostgreSQL connection errors
      {DNSCluster, query: Application.get_env(:observability, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Observability.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Observability.Finch},
      # Start a worker by calling: Observability.Worker.start_link(arg)
      # {Observability.Worker, arg},
      # Start to serve requests, typically the last entry
      ObservabilityWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Observability.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ObservabilityWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
