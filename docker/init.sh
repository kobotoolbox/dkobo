#!/bin/bash
set -e

export PATH=$PATH:./node_modules/.bin

oldpwd=$(pwd)
cd /srv/src/koboform

echo 'Waiting for Postgres.'
KOBO_PSQL_DB_NAME=${KOBO_PSQL_DB_NAME:-"kobotoolbox"}
KOBO_PSQL_DB_USER=${KOBO_PSQL_DB_USER:-"kobo"}
KOBO_PSQL_DB_PASS=${KOBO_PSQL_DB_PASS:-"kobo"}
dockerize -timeout=20s -wait ${PSQL_PORT}
until $(PGPASSWORD="${KOBO_PSQL_DB_PASS}" psql -d ${KOBO_PSQL_DB_NAME} -h psql -U ${KOBO_PSQL_DB_USER} -c '' 2> /dev/null); do
    sleep 1
done
echo 'Postgres ready.'

echo 'Synchronizing database.'
python manage.py syncdb --noinput

# FIXME: Convince South that KPI has already done the overlapping migrations.
echo 'Running fake migrations.'
python manage.py migrate --noinput --fake hub
python manage.py migrate --noinput --fake authtoken
python manage.py migrate --noinput --fake taggit
python manage.py migrate --noinput --fake reversion

echo 'Running migrations.'
python manage.py migrate --noinput

echo '\`dkobo\` initialization completed.'

cd $oldpwd
