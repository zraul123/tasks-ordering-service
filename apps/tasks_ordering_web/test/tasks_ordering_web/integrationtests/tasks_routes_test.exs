defmodule TasksOrderingWeb.ErrorJSONTest do
  use TasksOrderingWeb.ConnCase, async: true

  @tag integrationtests: true
  test "returns 200 with json as body as default presentation" do
    %{status_code: status_code, body: body} =
      %{
        "tasks" => [
          %{"name" => "a", "command" => "a"},
          %{"name" => "b", "command" => "b", "requires" => ["a"]},
          %{"name" => "c", "command" => "c", "requires" => ["b"]},
          %{"name" => "d", "command" => "d", "requires" => ["b", "c"]}
        ]
      }
      |> Tests.TasksOrderingServiceClient.order()

    assert status_code == 200

    assert Jason.decode!(body) == %{
             "tasks" => [
               %{"command" => "a", "name" => "a"},
               %{"command" => "b", "name" => "b"},
               %{"command" => "c", "name" => "c"},
               %{"command" => "d", "name" => "d"}
             ]
           }
  end

  @tag integrationtests: true
  test "returns 200 with text as body when presentation is in query params" do
    %{status_code: status_code, body: body} =
      %{
        "tasks" => [
          %{"name" => "a", "command" => "a"},
          %{"name" => "b", "command" => "b", "requires" => ["a"]},
          %{"name" => "c", "command" => "c", "requires" => ["b"]},
          %{"name" => "d", "command" => "d", "requires" => ["b", "c"]}
        ]
      }
      |> Tests.TasksOrderingServiceClient.order(presentation: "text")

    assert status_code == 200
    assert body == "\"a\\nb\\nc\\nd\""
  end

  @tag integrationtests: true
  test "smoke test" do
    %{status_code: status_code, body: body} = Tests.TasksOrderingServiceClient.up()

    assert status_code == 200
    assert Jason.decode!(body) == %{"up" => true}
  end

  @tag integrationtests: true
  test "returns 400 if tasks is not provided" do
    %{status_code: status_code, body: body} = Tests.TasksOrderingServiceClient.order(%{})

    assert status_code == 400
    assert Jason.decode!(body) == %{"errors" => ["tasks is a required field"]}
  end

  @tag integrationtests: true
  test "returns 400 if task does not have a name" do
    %{status_code: status_code, body: body} =
      Tests.TasksOrderingServiceClient.order(%{"tasks" => [%{"command" => "a"}]})

    assert status_code == 400
    assert Jason.decode!(body) == %{"errors" => ["name is a required field"]}
  end

  @tag integrationtests: true
  test "returns 400 if task does not have a command" do
    %{status_code: status_code, body: body} =
      Tests.TasksOrderingServiceClient.order(%{"tasks" => [%{"name" => "a"}]})

    assert status_code == 400
    assert Jason.decode!(body) == %{"errors" => ["command is a required field"]}
  end

  @tag integrationtests: true
  test "returns 400 both errors if an empty task is provided" do
    %{status_code: status_code, body: body} =
      Tests.TasksOrderingServiceClient.order(%{"tasks" => [%{}]})

    assert status_code == 400

    assert Jason.decode!(body) == %{
             "errors" => ["name is a required field", "command is a required field"]
           }
  end

  @tag integrationtests: true
  test "returns 400 if name is not unique" do
    %{status_code: status_code, body: body} =
      %{
        "tasks" => [
          %{"name" => "a", "command" => "a"},
          %{"name" => "a", "command" => "b"}
        ]
      }
      |> Tests.TasksOrderingServiceClient.order()

    assert status_code == 400

    assert Jason.decode!(body) == %{
             "errors" => ["Task names must be unique, found 'a' that has multiple occurences."]
           }
  end

  @tag integrationtests: true
  test "returns 400 if requires is not an array" do
    %{status_code: status_code, body: body} =
      %{
        "tasks" => [
          %{"name" => "a", "command" => "a"},
          %{"name" => "b", "command" => "b", "requires" => "a"}
        ]
      }
      |> Tests.TasksOrderingServiceClient.order()

    assert status_code == 400

    assert Jason.decode!(body) == %{
             "errors" => ["requires needs to be an array"]
           }
  end

  @tag integrationtests: true
  test "returns 400 if requires is not referencing a valid task" do
    %{status_code: status_code, body: body} =
      %{
        "tasks" => [
          %{"name" => "a", "command" => "a", "requires" => ["b"]}
        ]
      }
      |> Tests.TasksOrderingServiceClient.order()

    assert status_code == 400

    assert Jason.decode!(body) == %{
             "errors" => [
               "Requires must reference an existing task, found 'a' that has an invalid reference."
             ]
           }
  end

  @tag integrationtests: true
  test "returns 400 if requirements are not unique" do
    %{status_code: status_code, body: body} =
      %{
        "tasks" => [
          %{"name" => "a", "command" => "a"},
          %{"name" => "b", "command" => "b", "requires" => ["a", "a"]}
        ]
      }
      |> Tests.TasksOrderingServiceClient.order()

    assert status_code == 400

    assert Jason.decode!(body) == %{
             "errors" => [
               "Requires must be unique, found task 'b' which has duplicated requires."
             ]
           }
  end

  @tag integrationtests: true
  test "returns 400 if requirements reference themselves" do
    %{status_code: status_code, body: body} =
      %{
        "tasks" => [
          %{"name" => "a", "command" => "a", "requires" => ["a"]}
        ]
      }
      |> Tests.TasksOrderingServiceClient.order()

    assert status_code == 400

    assert Jason.decode!(body) == %{
             "errors" => [
               "Requires shouldn't reference itself, found task 'a' which references itself."
             ]
           }
  end

  @tag integrationtests: true
  test "returns 400 if tasks form a loop" do
    %{status_code: status_code, body: body} =
      %{
        "tasks" => [
          %{"name" => "a", "command" => "a", "requires" => ["b"]},
          %{"name" => "b", "command" => "b", "requires" => ["a"]}
        ]
      }
      |> Tests.TasksOrderingServiceClient.order()

    assert status_code == 400

    assert Jason.decode!(body) == %{
             "errors" => [
               "The tasks provided should not form a loop."
             ]
           }
  end
end
