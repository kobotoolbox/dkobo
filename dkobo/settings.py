"""
Django settings for dkobo project.

For more information on this file, see
https://docs.djangoproject.com/en/1.6/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/1.6/ref/settings/
"""

# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
import os
BASE_DIR = os.path.dirname(os.path.dirname(__file__))


# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/1.6/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = os.environ.get('DJANGO_SECRET_KEY')

# DEBUG is true unless an environment variable is set to something other than 'True'
DEBUG = (os.environ.get('DJANGO_DEBUG', 'True') == 'True')
LIVE_RELOAD = (os.environ.get('DJANGO_LIVE_RELOAD', str(DEBUG)) == 'True')
TRACKJS_TOKEN = os.environ.get('TRACKJS_TOKEN')
GOOGLE_ANALYTICS_TOKEN = os.environ.get('GOOGLE_ANALYTICS_TOKEN')

if not SECRET_KEY and not DEBUG:
    raise ValueError("DJANGO_SECRET_KEY environment variable must be set in production")
elif not SECRET_KEY:
    SECRET_KEY = 'secretShouldBeSetInAnEnvironmentVariable3^*m3xck13'

CSRF_COOKIE_DOMAIN = os.environ.get('CSRF_COOKIE_DOMAIN', None)

if CSRF_COOKIE_DOMAIN:
    SESSION_COOKIE_DOMAIN = CSRF_COOKIE_DOMAIN
    SESSION_COOKIE_NAME = 'kobonaut'

# default in django 1.6+
SESSION_SERIALIZER='django.contrib.sessions.serializers.JSONSerializer'

TEMPLATE_DEBUG = DEBUG

TEMPLATE_LOADERS = (
    'django.template.loaders.filesystem.Loader',
    'hamlpy.template.loaders.HamlPyFilesystemLoader',
    'hamlpy.template.loaders.HamlPyAppDirectoriesLoader',
    'django.template.loaders.app_directories.Loader',
    )

STATICFILES_FINDERS = (
    'django.contrib.staticfiles.finders.AppDirectoriesFinder',
    'django.contrib.staticfiles.finders.FileSystemFinder',
    'compressor.finders.CompressorFinder',
    )

STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')

STATICFILES_DIRS = (
    os.path.join(BASE_DIR, 'dkobo', 'static'),
    os.path.join(BASE_DIR, 'jsapp'),
    )

SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')

# Application definition

COMPRESS_ENABLED = str(os.environ.get('COMPRESS_ENABLED', not DEBUG)).lower() == 'true'
COMPRESS_OFFLINE = str(os.environ.get('COMPRESS_OFFLINE', not DEBUG)).lower() == 'true'
COMPRESS_ROOT = os.path.join(BASE_DIR, 'dkobo', 'static')

COMPRESS_PRECOMPILERS = (
    ('text/coffeescript', 'coffee --compile --stdio'),
    ('text/less', 'lessc {infile} {outfile}'),
    ('text/x-sass', 'sass {infile} {outfile}'),
    ('text/x-scss', 'sass --scss {infile} {outfile}'),
)

COMPRESS_STORAGE = 'compressor.storage.GzipCompressorFileStorage'

COMPRESS_JS_FILTERS = (
    'compressor.filters.jsmin.JSMinFilter',
    # 'compressor.filters.yuglify.YUglifyJSFilter',
)

COMPRESS_YUGLIFY_BINARY = 'yuglify'
COMPRESS_YUGLIFY_JS_ARGUMENTS = '--terminal'


GZIP_CONTENT_TYPES = (
    'text/css',
    'application/javascript',
    'text/javascript',
)

INSTALLED_APPS = (
    'dkobo.koboform',
    'dkobo.hub',
    'django.contrib.admin',
    'django.contrib.sites',
    'registration',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'compressor',
    'gunicorn',
    'south',
    'rest_framework',
    'rest_framework.authtoken',
    'django_extensions',
    'taggit',
    'django_digest',
    'reversion',
)

SOUTH_MIGRATION_MODULES = {
    'taggit': 'taggit.south_migrations',
    'reversion': 'reversion.south_migrations',
}

TEMPLATE_CONTEXT_PROCESSORS = (
    'django.contrib.auth.context_processors.auth',
    'dkobo.hub.context_processors.welcome_message',
    'dkobo.hub.context_processors.external_service_tokens',
)

KOBOCAT_URL = os.environ.get('KOBOCAT_URL')
KOBOCAT_INTERNAL_URL = os.environ.get('KOBOCAT_INTERNAL_URL', KOBOCAT_URL)

KPI_URL = os.environ.get('KPI_URL', False)

''' Since this project handles user creation but shares its database with
KoBoCAT, we must handle the model-level permission assignment that would've
been done by KoBoCAT's post_save signal handler. Here we record the content
types of the models listed in KC's set_api_permissions_for_user(). Verify that
this list still matches that function if you experience permission-related
problems. See
https://github.com/kobotoolbox/kobocat/blob/master/onadata/libs/utils/user_auth.py.
'''
KOBOCAT_DEFAULT_PERMISSION_CONTENT_TYPES = [
    #(app_label, model)
    ('main', 'userprofile'),
    ('logger', 'xform'),
    ('api', 'project'),
    ('api', 'team'),
    ('api', 'organizationprofile'),
    ('logger', 'note'),
]

# The number of surveys to import. -1 is all
KOBO_SURVEY_IMPORT_COUNT = os.environ.get('KOBO_SURVEY_IMPORT_COUNT', 100)

# The number of hours to keep a kobo survey preview (generated for enketo)
# around before purging it.
KOBO_SURVEY_PREVIEW_EXPIRATION = os.environ.get('KOBO_SURVEY_PREVIEW_EXPIRATION', 24)

KOBOFORM_PREVIEW_SERVER = os.environ.get('KOBOFORM_PREVIEW_SERVER', 'http://kf.kobotoolbox.org')
ENKETO_SERVER = os.environ.get('ENKETO_SERVER', 'https://enketo.org')
ENKETO_PREVIEW_URI = os.environ.get('ENKETO_PREVIEW_URI', '/webform/preview')
MARKITUP_FILTER = ('markdown.markdown', {'safe_mode': False})

LOGIN_REDIRECT_URL = '/'

MIDDLEWARE_CLASSES = (
    'reversion.middleware.RevisionMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'dkobo.hub.middleware.OtherFormBuilderRedirectMiddleware',
)

ROOT_URLCONF = 'dkobo.urls'

WSGI_APPLICATION = 'dkobo.wsgi.application'


# Database
# https://docs.djangoproject.com/en/1.6/ref/settings/#databases

import dj_database_url

DATABASES = {
    'default': dj_database_url.config(default="sqlite:///%s/db.sqlite3" % BASE_DIR)
}

ALLOWED_HOSTS = ['*']
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')

# For GeoDjango heroku buildpack
GEOS_LIBRARY_PATH = os.environ.get('GEOS_LIBRARY_PATH')
GDAL_LIBRARY_PATH = os.environ.get('GDAL_LIBRARY_PATH')
POSTGIS_VERSION = (2, 0, 3)

# Internationalization
# https://docs.djangoproject.com/en/1.6/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_L10N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/1.6/howto/static-files/

STATIC_URL = '/static/'

# DKOBO_URL should be set in the environment when running in a subdirectory
DKOBO_URL = os.environ.get('DKOBO_URL', False)
if DKOBO_URL:
    STATIC_URL = DKOBO_URL + STATIC_URL

EMAIL_HOST = 'smtp.gmail.com'
EMAIL_HOST_USER = os.environ.get('EMAIL_HOST_USER')
EMAIL_HOST_PASSWORD = os.environ.get('EMAIL_HOST_PASSWORD')
EMAIL_PORT = 587
EMAIL_USE_TLS = True


SITE_ID = os.environ.get('DJANGO_SITE_ID', '1')

ACCOUNT_ACTIVATION_DAYS = 3
LOGIN_REDIRECT_URL = '/'

LOGGING = {
    'version': 1,
    'disable_existing_loggers': True,
    'formatters': {
        'verbose': {
            'format': '%(levelname)s %(asctime)s %(module)s %(process)d %(thread)d %(message)s'
        },
        'simple': {
            'format': '%(levelname)s %(message)s'
        },
    },
    'handlers': {
        'null': {
            'level': 'DEBUG',
            'class': 'django.utils.log.NullHandler',
        },
        'console': {
            'level': 'DEBUG',
            'class': 'logging.StreamHandler',
            'formatter': 'simple'
        },
        'mail_admins': {
            'level': 'ERROR',
            'class': 'django.utils.log.AdminEmailHandler',
            'filters': [],
        }
    },
    'loggers': {
        'django': {
            'handlers': ['null'],
            'propagate': True,
            'level': 'INFO',
        },
        'django.request': {
            'handlers': ['mail_admins'],
            'level': 'ERROR',
            'propagate': False,
        },
    }
}

# Djangular

APPEND_SLASH = False

# -------------------------------------------

REST_FRAMEWORK = {
    # Use hyperlinked styles by default.
    # Only used if the `serializer_class` attribute is not set on a view.
    'DEFAULT_MODEL_SERIALIZER_CLASS':
        'rest_framework.serializers.HyperlinkedModelSerializer',

    # Use Django's standard `django.contrib.auth` permissions,
    # or allow read-only access for unauthenticated users.
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticatedOrReadOnly'
    ]
}

# needed by guardian
ANONYMOUS_USER_ID = -1

from registration.signals import user_activated
from django.contrib.auth import login
def login_on_activation(sender, user, request, **kwargs):
    user.backend='django.contrib.auth.backends.ModelBackend'
    login(request,user)
user_activated.connect(login_on_activation)

if os.environ.get('EMAIL_BACKEND'):
    EMAIL_BACKEND = os.environ.get('EMAIL_BACKEND')

if os.environ.get('DEFAULT_FROM_EMAIL'):
    DEFAULT_FROM_EMAIL = os.environ.get('DEFAULT_FROM_EMAIL')
    SERVER_EMAIL = DEFAULT_FROM_EMAIL

if os.environ.get('AWS_ACCESS_KEY_ID'):
    AWS_ACCESS_KEY_ID = os.environ.get('AWS_ACCESS_KEY_ID')
    AWS_SECRET_ACCESS_KEY = os.environ.get('AWS_SECRET_ACCESS_KEY')
    AWS_SES_REGION_NAME = os.environ.get('AWS_SES_REGION_NAME')
    AWS_SES_REGION_ENDPOINT = os.environ.get('AWS_SES_REGION_ENDPOINT')
