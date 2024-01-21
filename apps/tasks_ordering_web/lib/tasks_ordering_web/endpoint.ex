defmodule TasksOrderingWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :tasks_ordering_web

  @session_options [
    store: :cookie,
    key: "_tasks_ordering_web_key",
    encryption_salt: "_encryption_salt",
    signing_salt: "miwBwrRB",
    same_site: "Lax"
  ]

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug TasksOrderingWeb.Router

  def init(_key, config) do
    {:ok, config}
  end
end
