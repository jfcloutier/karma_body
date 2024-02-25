defmodule KarmaBody.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      KarmaBodyWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:karma_body, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: KarmaBody.PubSub},
      # Start a worker by calling: KarmaBody.Worker.start_link(arg)
      # {KarmaBody.Worker, arg},
      # Start to serve requests, typically the last entry
      KarmaBodyWeb.Endpoint,
      KarmaBody.BodySupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KarmaBody.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    KarmaBodyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
