#!/bin/sh

# Print environnement variables for debugging
echo "Environment variables:"
echo "DB_HOST: $DB_HOST"
echo "DB_PORT: $DB_PORT"
echo "DB_USER: $DB_USER"

# Generate the SECRET_KEY_BASE
SECRET_KEY_BASE=$(mix phx.gen.secret)
export SECRET_KEY_BASE

# Print the generated SECRET_KEY_BASE for debugging
echo "Generated SECRET_KEY_BASE: $SECRET_KEY_BASE"

# Set a timeout for database connection attempts (e.g., 5 minutes)
TIMEOUT=300
ELAPSED=0

echo "Waiting for database to be ready..."
while ! pg_isready -q -h $DB_HOST -p $DB_PORT -U $DB_USER
do
  echo "$(date) - still waiting for database to start"
  sleep 2
  ELAPSED=$((ELAPSED+2))
  if [ $ELAPSED -ge $TIMEOUT ]; then
    echo "Timeout reached. Database is not ready."
    exit 1
  fi
done
echo "Database is ready!"

echo "Creating database..."
mix ecto.create || { echo "Failed to create database"; exit 1; }

echo "Running migrations..."
mix ecto.migrate || { echo "Failed to run migrations"; exit 1; }

echo "Starting Phoenix server..."
exec mix phx.server