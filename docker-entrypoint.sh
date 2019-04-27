#!/bin/sh

if [ ! -n "$DBHOST" ]; then
    echo "Must supply DBHOST environment variable"
    exit 1
fi

if [ ! -n "$DBPASS" ]; then
    echo "Must supply DBPASS environment variable"
    exit 1
fi

CONFDIR=/usr/src/app/config

cat $CONFDIR/database.yml.template \
  | sed "s/%%%DBHOST%%%/$DBHOST/" \
  | sed "s/%%%DBPASS%%%/$DBHOST/" \
  > $CONFDIR/database.yml

exec "$@"


