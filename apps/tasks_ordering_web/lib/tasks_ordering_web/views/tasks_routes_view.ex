defmodule TasksOrderingWeb.TasksRoutesView do
  def up(_args) do
    %{
      up: true
    }
  end

  def ordered_tasks(_args) do
    %{
      tasks: []
    }
  end

  def ordered_tasks_invalid(%{metadata: %TasksOrderingWeb.EctoValidationError{errors: errors}}) do
    errors =
      errors
      |> Enum.map(&get_error_from_changeset_format/1)

    %{
      errors: errors
    }
  end

  defp get_error_from_changeset_format({field, {ecto_error, metadata}}) do
    validation = Keyword.get(metadata, :validation)
    internal_error = Keyword.get(metadata, :name)

    get_error_from_validation(field, ecto_error, validation, internal_error)
  end

  defp get_error_from_validation(field, ecto_error, :required, _internal_error),
    do: "#{field} is a required field"
end
