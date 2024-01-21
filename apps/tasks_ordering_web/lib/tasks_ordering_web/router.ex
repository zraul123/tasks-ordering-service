defmodule TasksOrderingWeb.Router do
  use TasksOrderingWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", TasksOrderingWeb do
    pipe_through :api

    get "/up", TasksRoutes, :up
    post "/order", TasksRoutes, :order
  end
end
