defmodule Onlinemaze.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      OnlinemazeWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Onlinemaze.PubSub},
      # Start the Endpoint (http/https)
      OnlinemazeWeb.Endpoint,
      # Start a worker by calling: Onlinemaze.Worker.start_link(arg)
      # {Onlinemaze.Worker, arg}
      {DynamicSupervisor,
       strategy: :one_for_one, restart: :temporary, name: Onlinemaze.DynamicGameServerSupervisor},
      {DynamicSupervisor,
       strategy: :one_for_one,
       restart: :temporary,
       name: Onlinemaze.DynamicCharacterServerSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Onlinemaze.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    OnlinemazeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
