defmodule Kamegor.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      KamegorWeb.Telemetry,
      Kamegor.Repo,
      {DNSCluster, query: Application.get_env(:kamegor, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Kamegor.PubSub},
      # Add Presence tracker
      KamegorWeb.Presence,

      # Start a worker by calling: Kamegor.Worker.start_link(arg)
      # {Kamegor.Worker, arg},
      # Start to serve requests, typically the last entry
      KamegorWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Kamegor.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    KamegorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
