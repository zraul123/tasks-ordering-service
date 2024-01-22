defmodule TasksOrderingWeb.TasksRoutes do
  use TasksOrderingWeb, :controller

  def up(conn, _params) do
    conn
    |> put_status(200)
    |> render(:up)
  end

  def order(conn, params) do
    TasksOrderingWeb.OrderTasksRequest.validate(params)
    |> do_order()
    |> render_output(conn)
  end

  defp do_order({:invalid, errors}),
    do: {:invalid, %TasksOrderingWeb.EctoValidationError{errors: errors}}

  defp do_order({:valid, %{tasks: tasks}}) do
    case TasksOrdering.order_tasks(tasks) do
      {:ok, order} ->
        {:ok, order}

      {:error, error} ->
        {:invalid, %TasksOrderingWeb.ControllerError{error: error}}
    end
  end

  defp render_output({:ok, ordered_tasks}, conn) do
    conn
    |> put_status(200)
    |> render(:ordered_tasks, metadata: ordered_tasks)
  end

  defp render_output({:invalid, errors}, conn) do
    conn
    |> put_status(400)
    |> render(:ordered_tasks_invalid, metadata: errors)
  end
end
