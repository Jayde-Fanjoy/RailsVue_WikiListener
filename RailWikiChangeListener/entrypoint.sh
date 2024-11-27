#!/bin/bash -e

# Check and prepare the database
echo "Checking database readiness..."
until rails db:prepare; do
  echo "Database is unavailable - retrying in 5 seconds..."
  sleep 5
done

# Start the Rails server
exec "$@"
