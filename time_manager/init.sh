#!/bin/sh

echo "Starting initialization script..."

# Set the environment
export PHX_SERVER=true

# Parse DATABASE_URL and export variables if it exists
if [ ! -z "$DATABASE_URL" ]; then
    # Extract database connection info from DATABASE_URL
    export DB_USER=$(echo $DATABASE_URL | awk -F[:/@] '{print $4}')
    export DB_PASS=$(echo $DATABASE_URL | awk -F[:/@] '{print $5}')
    export DB_HOST=$(echo $DATABASE_URL | awk -F[:/@] '{print $6}')
    export DB_PORT=$(echo $DATABASE_URL | awk -F[:/@] '{print $7}' | awk -F/ '{print $1}')
    export DB_NAME=$(echo $DATABASE_URL | awk -F[:/@] '{print $8}')
fi

echo "Environment: $MIX_ENV"
echo "Database Host: $DB_HOST"
echo "Database Name: $DB_NAME"
echo "Port: $PORT"

# Install dependencies
mix local.hex --force
mix local.rebar --force
mix deps.get --only prod
mix compile

# Database operations
echo "Running migrations..."
mix ecto.migrate

echo "Populating database..."
mix run priv/repo/seeds.exs

# Start the Phoenix server
mix phx.server