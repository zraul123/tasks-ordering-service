defmodule TasksOrderingWeb.OrderTasksRequest do
  use Ecto.Schema
  import Ecto.Changeset

  schema "OrderTasksRequest" do
    embeds_many(:tasks, TasksOrderingWeb.TaskModel)
  end

  def changeset(%TasksOrderingWeb.OrderTasksRequest{} = ch, params) do
    ch
    |> cast(params, [])
    |> cast_embed(:tasks, required: true)
    |> validate_change(:tasks, &validate_request_tasks_constraints/2)
  end

  def validate(params) do
    changeset =
      TasksOrderingWeb.OrderTasksRequest.changeset(%TasksOrderingWeb.OrderTasksRequest{}, params)

    case changeset.valid? do
      true ->
        {:valid, Params.to_map(changeset)}

      false ->
        errored_tasks =
          changeset.changes
          |> Map.get(:tasks, [])
          |> Enum.filter(fn ch -> ch.errors != [] end)
          # We can map to a single reduce
          |> Enum.map(fn ch -> ch.errors end)
          |> List.flatten()

        errors = changeset.errors ++ errored_tasks

        {:invalid, errors}
    end
  end

  defp validate_request_tasks_constraints(:tasks, tasks) do
    case Enum.any?(tasks, fn changeset -> changeset.errors != [] end) do
      true ->
        []

      false ->
        do_validate_request_tasks_constraints(tasks)
    end
  end

  defp do_validate_request_tasks_constraints(tasks) do
    with {:ok, tasks_names_mapset} <- validate_task_names_unique(tasks),
         {:ok} <- validate_requires_exists(tasks, tasks_names_mapset),
         {:ok} <- validate_requires_unique(tasks),
         {:ok} <- validate_requires_not_on_itself(tasks) do
      []
    else
      {:error, :name_not_unique, name} ->
        [name: {"must be unique", [validation: :name_must_be_unique, name: name]}]

      {:error, :requirement_does_not_exists, name} ->
        [
          requires:
            {"must reference existing tasks",
             [validation: :requires_must_reference_existing_task, name: name]}
        ]

      {:error, :requirements_not_unique, name} ->
        [requires: {"must be unique", [validation: :requires_must_be_unique, name: name]}]

      {:error, :requirement_referencing_itself, name} ->
        [
          requires:
            {"must not reference itself",
             [validation: :requirement_referencing_itself, name: name]}
        ]
    end
  end

  defp validate_task_names_unique(tasks) do
    tasks
    |> Enum.reduce_while({:ok, MapSet.new()}, fn task_change, {:ok, acc} ->
      name = task_change.changes.name

      case MapSet.member?(acc, name) do
        false ->
          {:cont, {:ok, MapSet.put(acc, name)}}

        true ->
          {:halt, {:error, :name_not_unique, name}}
      end
    end)
  end

  defp validate_requires_exists(tasks, tasks_names_mapset) do
    tasks
    |> Enum.reduce_while({:ok}, fn task_change, _acc ->
      requires = Map.get(task_change.changes, :requires, [])

      do_validate_requires_exists(task_change.changes.name, requires, tasks_names_mapset)
    end)
  end

  defp do_validate_requires_exists(_name, [], _tasks_names_mapset), do: {:cont, {:ok}}

  defp do_validate_requires_exists(name, [requirement_name | tail], tasks_names_mapset) do
    if MapSet.member?(tasks_names_mapset, requirement_name) do
      do_validate_requires_exists(name, tail, tasks_names_mapset)
    else
      {:halt, {:error, :requirement_does_not_exists, name}}
    end
  end

  defp validate_requires_unique(tasks) do
    tasks
    |> Enum.reduce_while({:ok}, fn task_change, _acc ->
      requires = Map.get(task_change.changes, :requires, [])

      requires_length = Enum.count(requires)
      uniq_length = Enum.uniq(requires) |> Enum.count()

      if requires_length == uniq_length do
        {:cont, {:ok}}
      else
        {:halt, {:error, :requirements_not_unique, task_change.changes.name}}
      end
    end)
  end

  defp validate_requires_not_on_itself(tasks) do
    tasks
    |> Enum.reduce_while({:ok}, fn task_change, _acc ->
      requires = Map.get(task_change.changes, :requires, [])

      case Enum.member?(requires, task_change.changes.name) do
        false ->
          {:cont, {:ok}}

        true ->
          {:halt, {:error, :requirement_referencing_itself, task_change.changes.name}}
      end
    end)
  end
end
