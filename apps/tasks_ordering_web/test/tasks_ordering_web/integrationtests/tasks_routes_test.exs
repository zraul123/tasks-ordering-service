defmodule TasksOrderingWeb.ErrorJSONTest do
  use TasksOrderingWeb.ConnCase, async: true

  @tag integrationtests: true
  test "smoke test" do
    %{status_code: status_code, body: body} = Tests.TasksOrderingServiceClient.up()

    assert status_code == 200
    assert Jason.decode!(body) == %{"up" => true}
  end
end
