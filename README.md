# Dkobo.

[![Build Status](https://travis-ci.org/kobotoolbox/dkobo.svg)](https://travis-ci.org/kobotoolbox/dkobo)

#### A django project for developing components of the KoBoToolbox, including the new version of KoBoForm
------------------------------

### Installation

1. Clone the project:

    `git clone https://github.com/kobotoolbox/dkobo.git`

1. Activate a [python virtualenv](https://pypi.python.org/pypi/virtualenv).

    _It's suggested that you use virtualenv wrapper, which provides the "mkvirtualenv" and "workon" commands_<br>
    `mkvirtualenv kobo` 

1. Install python requirements:

    `pip install -r requirements.txt`

1. **If in production**, set production environment variables. (See below)

1. Install javascript dependencies

    `npm install --save-dev`
    `bower install`

1. Build javascript and stylesheet dependencies

    `grunt build`

1. Continue with "launching the server" (optionally skipping any repeated steps)

### Launching the server

1. Ensure the latest code is pulled

    `git pull origin master`

1. In development, you'll want to start the javascript and stylesheet compilation watcher and tester

    `grunt`

1. Activate the virtualenvironment

    _example virtualenv named kobo_<br>
    `source kobo/bin/activate`

1. Install any requirements that have not been installed

    `pip install -r requirements.txt`

1. Migrate the database

    `python manage.py syncdb`<br>
    `python manage.py migrate`

1. Run the server on port 8000

    `python manage.py runserver`

------------

### Production environment variables

    DJANGO_DEBUG=False
    DJANGO_SECRET_KEY=<use a unique django secret key here>
