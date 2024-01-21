defmodule TasksOrderingWeb.ErrorJSONTest do
  use TasksOrderingWeb.ConnCase, async: true

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
end
