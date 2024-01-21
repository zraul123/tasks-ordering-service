defmodule TasksOrderingWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TasksOrderingWeb.Telemetry,
      # Start a worker by calling: TasksOrderingWeb.Worker.start_link(arg)
      # {TasksOrderingWeb.Worker, arg},
      # Start to serve requests, typically the last entry
      TasksOrderingWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TasksOrderingWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TasksOrderingWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
