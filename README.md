# Dkobo.
## A django project for developing components of the kobotoolbox.
------------------------------

This is a django project intended to house django implementations of KoboToolbox work.

------------------------------

## Installation

1. Clone the project:

    git clone https://github.com/kobotoolbox/dkobo.git

2. Activate a [python virtualenv](https://pypi.python.org/pypi/virtualenv).

3. Install python requirements:

    pip install -r requirements.txt

4. Create a "local_settings.py" file:

    cp dkobo/local_settings_example.py local_settings.py

5. Create a database:

    python manage.py syncdb

4. Run the development server:

    python manage.py runserver
