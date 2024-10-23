# backend/config/dev.exs
import Config

IO.puts "Loading DEV environment configuration..."

# Configure your database
config :time_manager, TimeManager.Repo,
  username: System.get_env("DB_USER") || "postgres",
  password: System.get_env("DB_PASS") || "postgres",
  hostname: System.get_env("DB_HOST") || "localhost",
  database: System.get_env("DB_NAME") || "time_manager_dev",
  port: String.to_integer(System.get_env("DB_PORT") || "5432"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: true,
  ssl_opts: [verify: :verify_none],
  # ssl_opts: [
  #   verify: :verify_none,
  #   cacertfile: "/app/cacert.pem"  # Heroku's CA certificate
  # ],
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

# Configure the endpoint
config :time_manager, TimeManagerWeb.Endpoint,
  url: [
    scheme: System.get_env("SCHEME") || "http",
    host: System.get_env("PHX_HOST") || "localhost",
    port: String.to_integer(System.get_env("PORT") || "4000")
  ],
  http: [
    ip: {0, 0, 0, 0},
    port: String.to_integer(System.get_env("PORT") || "4000")
  ],
  server: true,
  check_origin: false,
  code_reloader: false,
  debug_errors: false,
  watchers: []  # Remove watchers in production

# Print current database configuration
if Mix.env() == :dev do
  IO.puts """
  Current database configuration:
  Host: #{System.get_env("DB_HOST") || "localhost"}
  Database: #{System.get_env("DB_NAME") || "time_manager_dev"}
  User: #{System.get_env("DB_USER") || "postgres"}
  Port: #{System.get_env("DB_PORT") || "5432"}
  SSL: #{System.get_env("DB_SSL") || "false"}
  """
end

# Configure logging
config :logger, :console,
  format: "[$level] $message\n",
  level: :debug

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Set a higher stacktrace during development
config :phoenix, :stacktrace_depth, 20
