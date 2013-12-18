# Dkobo.
## A django project for developing components of the kobotoolbox.
------------------------------

This is a django project intended to house django implementations of KoboToolbox work.

------------------------------

## Installation

1. Clone the project:

    git clone https://github.com/kobotoolbox/dkobo.git

1. Activate a [python virtualenv](https://pypi.python.org/pypi/virtualenv).

1. Install python requirements:

    pip install -r requirements.txt

1. Load submodules

    git submodule init
    git submodule update

1. If in production, set the following environment variables: (If in development, you can ignore this step)

	* DJANGO_DEBUG=False
	* DJANGO_SECRET_KEY=s3cr3tk3y

1. Install sass (ruby) and coffee-script (node/npm)

1. Create a database:

    python manage.py syncdb

1. Run the development server:

    python manage.py runserver
