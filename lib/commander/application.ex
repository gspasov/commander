defmodule Commander.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CommanderWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:commander, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Commander.PubSub},
      # Start a worker by calling: Commander.Worker.start_link(arg)
      # {Commander.Worker, arg},
      # Start to serve requests, typically the last entry
      CommanderWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Commander.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CommanderWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
