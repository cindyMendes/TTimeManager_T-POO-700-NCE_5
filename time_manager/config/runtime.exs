import Config

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: postgres://USER:PASS@HOST:PORT/DATABASE
      """

  config :time_manager, TimeManager.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    ssl: true,
    ssl_opts: [verify: :verify_none]

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  # Add CORS configuration
  config :cors_plug,
    origin: String.split(System.get_env("CORS_ORIGINS") || "http://localhost:5173,https://time-manager-frontend-ac9007c3e870.herokuapp.com", ","),
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    headers: ["Authorization", "Content-Type", "Accept", "Origin", "User-Agent", "DNT", "Cache-Control", "X-Mx-ReqToken", "Keep-Alive", "X-Requested-With", "If-Modified-Since", "X-CSRF-Token"]

  config :time_manager, TimeManagerWeb.Endpoint,
    secret_key_base: secret_key_base,
    # Add CORS configuration to endpoint as well
    cors_plug_opts: [
      origin: String.split(System.get_env("CORS_ORIGINS") || "http://localhost:5173,https://time-manager-frontend-ac9007c3e870.herokuapp.com", ","),
      methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
      headers: ["Authorization", "Content-Type", "Accept", "Origin", "User-Agent", "DNT", "Cache-Control", "X-Mx-ReqToken", "Keep-Alive", "X-Requested-With", "If-Modified-Since", "X-CSRF-Token"]
    ]
end
