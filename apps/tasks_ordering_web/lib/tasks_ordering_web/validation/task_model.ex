defmodule TasksOrderingWeb.TaskModel do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:name, :string)
    field(:command, :string)
    field(:requires, {:array, :string})
  end

  def changeset(%TasksOrderingWeb.TaskModel{} = ch, params \\ %{}) do
    ch
    |> cast(params, [:name, :command, :requires])
    |> validate_required([:name, :command])
  end
end
