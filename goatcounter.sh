#!/usr/bin/env bash

set -e

declare OPTS=""

OPTS="-automigrate"
OPTS="$OPTS -listen $GOATCOUNTER_LISTEN"
OPTS="$OPTS -tls proxy"
OPTS="$OPTS -email-from $GOATCOUNTER_EMAIL"
OPTS="$OPTS -db sqlite+file:$GOATCOUNTER_DB"

if [ -n "$GOATCOUNTER_SMTP" ]; then
  OPTS="$OPTS -smtp $GOATCOUNTER_SMTP"
fi

if [ -n "$GOATCOUNTER_DEBUG" ]; then
  OPTS="$OPTS -debug all"
fi

/usr/local/bin/goatcounter serve $OPTS
