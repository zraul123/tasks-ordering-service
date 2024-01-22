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

  defp render_output({:ok, ordered_tasks}, %Plug.Conn{query_params: query_params} = conn) do
    presentation = Map.get(query_params, "presentation", "json")

    render_template =
      case presentation do
        "script" ->
          "ordered_tasks.text"

        _ ->
          "ordered_tasks.json"
      end

    conn
    |> put_status(200)
    |> render(render_template, tasks: ordered_tasks, presentation: presentation)
  end

  defp render_output({:invalid, errors}, conn) do
    conn
    |> put_status(400)
    |> render(:ordered_tasks_invalid, metadata: errors)
  end
end
