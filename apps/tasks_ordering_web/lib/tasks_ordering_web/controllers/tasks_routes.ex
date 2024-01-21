defmodule TasksOrderingWeb.TasksRoutes do
  use TasksOrderingWeb, :controller

  def up(conn, _params) do
    conn
    |> put_status(200)
    |> render(:up)
  end
end
