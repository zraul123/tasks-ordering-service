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
    |> IO.inspect(label: "b")
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
end
