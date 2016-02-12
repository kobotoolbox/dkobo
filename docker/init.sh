#!/bin/bash
set -e

echo '`dkobo` initializing...'

export PATH=$PATH:./node_modules/.bin

oldpwd=$(pwd)
cd /srv/src/koboform

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

echo '`dkobo` initialization complete.'

cd $oldpwd
