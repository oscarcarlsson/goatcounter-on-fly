#!/usr/bin/env bash

set -eu

# Restore the database if it does not already exist.
if [ -f "$GOATCOUNTER_DB" ]; then
    echo "Database exists, skipping restore."
else
    echo "No database found, attempt to restore from a replica."

    # Attempt to restore.  If replica does not exist litestream will
    # return 0, which is confusing.
    if litestream restore -if-replica-exists "$GOATCOUNTER_DB"; then
        # Guessing we just don't have a database setup - lets create
        # one!

        /usr/local/bin/goatcounter db create site \
                                   -db "sqlite+file:$GOATCOUNTER_DB" \
                                   -createdb \
                                   -vhost "$GOATCOUNTER_DOMAIN" \
                                   -user.email "$GOATCOUNTER_EMAIL" \
                                   -password "$GOATCOUNTER_PASSWORD" || echo "panic"

        echo "Setup a new goatcounter site"
    else
        echo "Finished restoring the database."
    fi
fi

echo "Starting litestream & goatcounter service."

# Run litestream with your app as the subprocess.
exec litestream replicate -exec "$@"
