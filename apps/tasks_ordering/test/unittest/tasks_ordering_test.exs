defmodule TaskOrdering.Tests.UnitTest.TasksOrdering do
  use ExUnit.Case, async: true

  @tag unittest: true
  test "returns error if the graph is cyclic" do
    result =
      [
        %{name: "a", command: "a", requires: ["b"]},
        %{name: "b", command: "b", requires: ["a"]}
      ]
      |> TasksOrdering.order_tasks()

    assert result == {:error, :cyclic_graph}
  end

  @tag unittest: true
  test "returns parsed tasks in order if the tasks are valid" do
    result =
      [
        %{name: "a", command: "a", requires: ["b"]},
        %{name: "b", command: "b"}
      ]
      |> TasksOrdering.order_tasks()

    assert result ==
             {:ok, [%{command: "b", name: "b"}, %{command: "a", name: "a", requires: ["b"]}]}
  end

  @tag unittest: true
  test "returns complex tasks in order" do
    result =
      [
        %{name: "a", command: "a"},
        %{name: "b", command: "b", requires: ["a"]},
        %{name: "c", command: "c", requires: ["b"]},
        %{name: "d", command: "d", requires: ["b", "c"]}
      ]
      |> TasksOrdering.order_tasks()

    assert result ==
             {:ok,
              [
                %{command: "a", name: "a"},
                %{command: "b", name: "b", requires: ["a"]},
                %{command: "c", name: "c", requires: ["b"]},
                %{command: "d", name: "d", requires: ["b", "c"]}
              ]}
  end

  @tag unittest: true
  test "returns if tasks do not depend on eachother" do
    result =
      [
        %{name: "a", command: "a"},
        %{name: "b", command: "b"},
        %{name: "c", command: "c"},
        %{name: "d", command: "d"}
      ]
      |> TasksOrdering.order_tasks()

    assert result ==
             {:ok,
              [
                %{command: "d", name: "d"},
                %{command: "a", name: "a"},
                %{command: "c", name: "c"},
                %{command: "b", name: "b"}
              ]}
  end
end
