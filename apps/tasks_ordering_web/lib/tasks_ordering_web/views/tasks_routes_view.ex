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
      |> IO.inspect(label: "error")
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

  defp get_error_from_validation(field, _ecto_error, :required, _internal_error),
    do: "#{field} is a required field"

  defp get_error_from_validation(:requires, _ecto_error, :cast, _internal_error),
    do: "requires needs to be an array"

  defp get_error_from_validation(_field, _ecto_error, :name_must_be_unique, name),
    do: "Task names must be unique, found '#{name}' that has multiple occurences."

  defp get_error_from_validation(
         _field,
         _ecto_error,
         :requires_must_reference_existing_task,
         name
       ),
       do:
         "Requires must reference an existing task, found '#{name}' that has an invalid reference."

  defp get_error_from_validation(_field, _ecto_error, :requires_must_be_unique, name),
    do: "Requires must be unique, found task '#{name}' which has duplicated requires."

  defp get_error_from_validation(_field, _ecto_error, :requirement_referencing_itself, name),
    do: "Requires shouldn't reference itself, found task '#{name}' which references itself."

  defp get_error_from_validation(_field, _ecto_error, :requirement_referencing_itself, name),
    do: "Requires shouldn't reference itself, found task '#{name}' which references itself."
end
