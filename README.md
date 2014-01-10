# Dkobo.
## A django project for developing components of the kobotoolbox.
------------------------------

This is a django project intended to house django implementations of KoboToolbox work.

------------------------------

## Installation

1. Clone the project:

    git clone https://github.com/kobotoolbox/dkobo.git

1. Activate a [python virtualenv](https://pypi.python.org/pypi/virtualenv).

    # It's suggested that you use virtualenv wrapper, which provides the "mkvirtualenv" and "workon" commands
    mkvirtualenv kobo

1. Install python requirements:

    pip install -r requirements.txt

1. Load submodules

    git submodule init
    git submodule update

1. If in production, set the following environment variables: (If in development, you can ignore this step)

	* DJANGO_DEBUG=False
	* DJANGO_SECRET_KEY=s3cr3tk3y

1. Install sass (ruby) and coffee-script (node/npm)

1. Continue with "launching the server" (optionally skipping any repeated steps)

## Launching the server

1. Ensure the latest code is pulled

    git pull origin master

1. Activate the virtualenvironment

    # example
    workon kobo

1. Install any requirements that have not been installed

    pip install -r requirements.txt

1. Create and update the database

    python manage.py syncdb

