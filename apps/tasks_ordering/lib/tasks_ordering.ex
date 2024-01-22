defmodule TasksOrdering do
  require Logger

  def order_tasks(tasks) do
    graph = build_graph(tasks)

    case :digraph_utils.is_acyclic(graph) do
      false ->
        {:error, :cyclic_graph}

      true ->
        result =
          :digraph_utils.topsort(graph)
          |> Enum.map(fn name -> Enum.find(tasks, fn task -> task.name == name end) end)

        {:ok, result}
    end
  end

  defp build_graph(tasks) do
    :digraph.new([:private])
    |> add_vertices(tasks)
    |> add_edges(tasks)
  end

  defp add_vertices(graph, tasks) do
    tasks
    |> Enum.each(fn task -> :digraph.add_vertex(graph, task.name) end)

    graph
  end

  defp add_edges(graph, tasks) do
    tasks
    |> Enum.each(fn task -> do_add_edge_for_task(graph, task) end)

    graph
  end

  defp do_add_edge_for_task(graph, task) do
    case Map.get(task, :requires) do
      nil ->
        :noop

      requires when is_list(requires) ->
        requires
        |> Enum.each(fn requirement ->
          Logger.info("Adding from #{requirement} to #{task.name}")

          :digraph.add_edge(
            graph,
            requirement,
            task.name,
            "#{requirement} -> #{task.name}" |> String.to_atom()
          )
        end)

      error ->
        Logger.error(
          "A request tries to add edges that do not match what we expect, requires: #{inspect(error)}"
        )
    end
  end
end
