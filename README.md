# Dkobo.
#### A django project for developing components of the kobotoolbox.
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

1. Install sass (ruby) and coffee-script (node/npm)

1. Continue with "launching the server" (optionally skipping any repeated steps)

### Launching the server

1. Ensure the latest code is pulled

    `git pull origin master`

1. Activate the virtualenvironment

    _example virtualenv named kobo_<br>
    `workon kobo`

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
