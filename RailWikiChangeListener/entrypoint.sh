#!/bin/bash -e

# Check and prepare the database
echo "Checking database readiness..."
until rails db:prepare; do
  echo "Database is unavailable - retrying in 5 seconds..."
  sleep 5
done

# Run migrations and seeds
bundle exec rails db:migrate
bundle exec rails db:seed

# Start the Rails server
exec "$@"
