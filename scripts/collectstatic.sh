#!/bin/sh
python manage.py collectstatic --noinput --settings=dkobo.settings
grunt build_all
npm install yuglify
python manage.py compress --settings=dkobo.settings
mkdir -p jsapp/CACHE
cp -R jsapp/components/fontawesome/fonts jsapp/CACHE/fonts
python manage.py collectstatic --noinput --settings=dkobo.settings
