defmodule TimeManager.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Repo first
      TimeManager.Repo,

      # Start system monitoring
      TimeManagerWeb.Telemetry,

      # DNS Clustering if configured
      {DNSCluster, query: Application.get_env(:time_manager, :dns_cluster_query) || :ignore},

      # PubSub system for real-time features
      {Phoenix.PubSub, name: TimeManager.PubSub},

      # HTTP client for emails
      {Finch, name: TimeManager.Finch},

      # Start endpoint last
      {TimeManagerWeb.Endpoint, []}
    ]

    opts = [strategy: :one_for_one, name: TimeManager.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    TimeManagerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
