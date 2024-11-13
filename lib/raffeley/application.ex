defmodule Raffeley.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RaffeleyWeb.Telemetry,
      Raffeley.Repo,
      {DNSCluster, query: Application.get_env(:raffeley, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Raffeley.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Raffeley.Finch},
      # Start a worker by calling: Raffeley.Worker.start_link(arg)
      # {Raffeley.Worker, arg},
      # Start to serve requests, typically the last entry
      RaffeleyWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Raffeley.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RaffeleyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
