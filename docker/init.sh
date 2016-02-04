#!/bin/bash
set -e

export PATH=$PATH:./node_modules/.bin

oldpwd=$(pwd)
cd /srv/src/koboform

python manage.py syncdb --noinput

# FIXME: Convince South that KPI has already done the overlapping migrations.
python manage.py migrate --fake hub
python manage.py migrate --fake authtoken
python manage.py migrate --fake taggit
python manage.py migrate --fake reversion

python manage.py migrate --noinput

cd $oldpwd
