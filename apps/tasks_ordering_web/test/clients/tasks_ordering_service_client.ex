defmodule Tests.TasksOrderingServiceClient do
  def up() do
    api_url = api_url()

    case HTTPoison.get!("#{api_url}/up") do
      %HTTPoison.Response{status_code: status_code, body: body} ->
        %{status_code: status_code, body: body}

      error ->
        error
    end
  end

  def order(tasks) do
    api_url = api_url()
    serialized_tasks = Jason.encode!(tasks)

    case HTTPoison.post!("#{api_url}/order", serialized_tasks, "content-type": "application/json") do
      %HTTPoison.Response{status_code: status_code, body: body} ->
        %{status_code: status_code, body: body}

      error ->
        error
    end
  end

  defp api_url() do
    port = System.get_env("PORT", "4000")
    "http://localhost:#{port}/api"
  end
end
