#!/bin/sh

if [ ! -n "$DBHOST" ]; then
    echo "Missing DBHOST environment variable.  Must supply DBHOST, DBNAME, DBUSER, and DBPASS"
    exit 1
fi

if [ ! -n "$DBNAME" ]; then
    echo "Missing DBNAME environment variable.  Must supply DBHOST, DBNAME, DBUSER, and DBPASS"
    exit 1
fi

if [ ! -n "$DBUSER" ]; then
    echo "Missing DBUSER environment variable.  Must supply DBHOST, DBNAME, DBUSER, and DBPASS"
    exit 1
fi

if [ ! -n "$DBPASS" ]; then
    echo "Missing DBPASS environment variable.  Must supply DBHOST, DBNAME, DBUSER, and DBPASS"
    exit 1
fi

CONFDIR=/usr/src/app/config

cat $CONFDIR/database.yml.template \
  | sed "s/%%%DBHOST%%%/$DBHOST/; s/%%%DBUSER%%%/$DBUSER/; s/%%%DBNAME%%%/$DBNAME/; s/%%%DBPASS%%%/$DBPASS/;" \
  > $CONFDIR/database.yml

exec "$@"


