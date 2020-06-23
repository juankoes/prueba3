#!/bin/bash
# Docker entrypoint script.

# Wait until Postgres is ready
while ! pg_isready -q -h $PGHOST -p $PGPORT -U $PGUSER
do
  echo "$(date) - waiting for database to start"
  sleep 2
done

mix clean
mix do deps.get, deps.compile, compile

# This step builds assets for the Phoenix app (if there is one)
# If you aren't building a Phoenix app, pass `--build-arg SKIP_PHOENIX=true`
# This is mostly here for demonstration purposes
cd assets
npm install
node node_modules/brunch/bin/brunch build
cd ..
mix phx.digest;

# Create database if it doesn't exist.
if [[ -z `psql -Atqc "\\list $PGDATABASE"` ]]; then
  echo "Database $PGDATABASE does not exist. Creating..."
  createdb -E UTF8 $PGDATABASE -l en_US.UTF-8 -T template0
  echo "Database $PGDATABASE created."
fi

MIX_ENV=prod mix release --env=prod
trap 'exit' INT;

chmod +x $APP_HOME/_build/prod/rel/$APP_NAME/releases/$APP_VSN/commands/migrate.sh
chmod +x $APP_HOME/_build/prod/rel/$APP_NAME/releases/$APP_VSN/commands/seed.sh

# _build/prod/rel/sat/bin/sat migrate
# _build/prod/rel/sat/bin/sat foreground