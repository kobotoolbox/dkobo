# Dkobo.

[![Build Status](https://travis-ci.org/kobotoolbox/dkobo.svg)](https://travis-ci.org/kobotoolbox/dkobo)

#### A django project for developing components of the KoBoToolbox, including the new version of KoBoForm
------------------------------

### Installation

1. Clone the project:

    `git clone https://github.com/kobotoolbox/dkobo.git`

1. Activate a [python virtualenv](https://pypi.python.org/pypi/virtualenv).

    _It's suggested that you use virtualenv wrapper, which provides the "mkvirtualenv" and "workon" commands_<br>
    _However, without that, you can still create a virtualenv e.g. named pykobo_
    `virtualenv ~/pykobo` 

1. **If in production**, set production environment variables. (See below)

1. Install python:

    `pip install -r requirements.txt`

1. Ensure system packages are installed:

    `apt-get install python2.7-dev`
    `apt-get install libxml2 libxml2-dev libxslt1-dev`

1. Special package installs (require custom repositories):

    `apt-get install postgresql-server-dev-9.3`
    `apt-get install nodejs`

1. Install javascript dependencies:

    `npm install`<br>
    `bower install`

1. Build javascript and stylesheet dependencies

    `grunt build`

1. Continue with "launching the server" (optionally skipping any repeated steps)

### Launching the server

1. Ensure the latest code is pulled

    `git pull origin master`

1. Activate the virtualenvironment

    _example virtualenv named pykobo_<br>
    `source ~/pykobo/bin/activate`

1. Consider installing any requirements that have not been installed

    `pip install -r requirements.txt` _# this installs python dependencies inside the vitualenv_<br>
    `npm install`<br>
    `bower install`

1. Migrate the database

    `python manage.py syncdb`<br>
    `python manage.py migrate`

1. Run the server on port 8000

    `python manage.py runserver` OR (when actively developing the application) <br>
    `python manage.py gruntserver` _This is an alias for running 'grunt' in the background._

------------

### Production environment variables

    DJANGO_DEBUG=False
    DJANGO_SECRET_KEY=<use a unique django secret key here>
    
    The server should run in development / debug mode by default, but if you want to change it you can run the command

    `source scripts/set_debug.sh true` #sets development mode<br>
    or<br>
    
    LOCAL:  source scripts/set_debug.sh true
    LOCAL:  source scripts/set_debug.sh false
    HEROKU: sh scripts/set_debug.sh --heroku true
    HEROKU: sh scripts/set_debug.sh --heroku false
    `source scripts/set_debug.sh false` #sets production mode

### Grunt commands

###### grunt (no arguments)
  _default task: triggers `requirejs:compile_xlform`, `build_css`, and `watch` for changes_

###### grunt build
  _triggers `requirejs:compile_xlform`, `build_css`_
  * Creates js and css dependencies

###### grunt build_all
  * Used when launching production
  * Runs `build` and generates modernizr.js file for use when django is not in debug mode.

###### grunt build_css
  * Runs `sass:dist`, `cssmin:strip_duplicates`, `cssmin:dist`

###### grunt test
  * Runs `build`, `karma:unit`
