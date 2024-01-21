defmodule TasksOrdering.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {DNSCluster, query: Application.get_env(:tasks_ordering, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: TasksOrdering.PubSub}
      # Start a worker by calling: TasksOrdering.Worker.start_link(arg)
      # {TasksOrdering.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: TasksOrdering.Supervisor)
  end
end
