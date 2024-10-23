defmodule TimeManagerWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :time_manager

  @session_options [
    store: :cookie,
    key: "_time_manager_key",
    signing_salt: "D9TqyShe",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  plug Plug.Static,
    at: "/",
    from: :time_manager,
    gzip: false,
    only: TimeManagerWeb.static_paths()

  # Code reloading plugs for development environment
  if code_reloading? do
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :time_manager
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options

  # Configure CORS with dynamic origins
  plug CORSPlug,
    origin: ["http://localhost:5173", "https://time-manager-frontend-ac9007c3e870.herokuapp.com"],
    methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"],
    expose: ["Authorization"],
    credentials: true,
    headers: [
      "Authorization",
      "Content-Type",
      "Accept",
      "Origin",
      "User-Agent",
      "DNT",
      "Cache-Control",
      "X-Mx-ReqToken",
      "Keep-Alive",
      "X-Requested-With",
      "If-Modified-Since",
      "X-CSRF-Token",
      "Access-Control-Allow-Origin"
    ],
    max_age: 86400  # 24 hours

  # Router plug should come after other plugs
  plug TimeManagerWeb.Router
end
