import os
import json

from fabric.api import local, hosts, run, env

DEPLOYMENTS = {
    'prod': {
        'heroku_app_name': 'kobotoolbox',
        'cookie_domain':    '.kobotoolbox.org',
        'domain':           'kf.kobotoolbox.org',
        'kobocat_domain':   'kc.kobotoolbox.org',
        'django_site_id': 1,
    },
    'staging': {
        'heroku_app_name': 'kobo-dev',
        'cookie_domain':    '.staging.kobotoolbox.org',
        'domain':           'kf.staging.kobotoolbox.org',
        'kobocat_domain':   'kc.staging.kobotoolbox.org',
        'django_site_id': 2,
    },
}

IMPORTED_DEPLOYMENTS = {}
if os.path.exists('deployments.json'):
    with open('deployments.json', 'r') as f:
        IMPORTED_DEPLOYMENTS = json.load(f)

def exit_with_error(message):
    print message
    sys.exit(1)

def setup_env(deployment_name):
    deployment = DEPLOYMENTS.get(deployment_name)
    if 'shared' == deployment_name:
        exit_with_error('SHARED is not a deployment')
    if deployment is None:
        exit_with_error('Deployment "%s" not found.' % deployment_name)
    if 'shared' in IMPORTED_DEPLOYMENTS:
        env.update(IMPORTED_DEPLOYMENTS['shared'])
    env.update(deployment)
    if deployment_name in IMPORTED_DEPLOYMENTS:
        env.update(IMPORTED_DEPLOYMENTS.get(deployment_name))


def _database_url(user, password, name, host, protocol='postgis', port='5432'):
    return "%s://%s:%s@%s:%s/%s" % ( \
                                protocol, user, password, host, port, name, )

def _heroku_settings_dict():
    heroku_environment = {
        'GDAL_LIBRARY_PATH': '/app/.geodjango/gdal/lib/libgdal.so',
        'GEOS_LIBRARY_PATH': '/app/.geodjango/geos/lib/libgeos_c.so',
    }
    if 'secret_key' in env:
        heroku_environment['DJANGO_SECRET_KEY'] = env.get('secret_key')
    if 'database' in env:
        heroku_environment['DATABASE_URL'] = _database_url(**env.get('database'))
    if 'cookie_domain' in env:
        heroku_environment['CSRF_COOKIE_DOMAIN'] = env.get('cookie_domain')
    if 'django_site_id' in env:
        heroku_environment['DJANGO_SITE_ID'] = env.get('django_site_id')
    if 'kobocat_domain' in env:
        heroku_environment['KOBOCAT_SERVER'] = env.get('kobocat_domain')
    heroku_environment['DJANGO_DEBUG'] = env.get('debug', False)
    return heroku_environment

def _set_heroku_configs(configs):
    app_name = env['heroku_app_name']
    settings_strings = []
    for kv in configs.items():
        settings_strings.append("%s=\"%s\"" % kv)
    local("heroku config:set %s --app=%s" % (' '.join(settings_strings), app_name,))

@hosts('staging')
def deploy():
    setup_env(env.host)
    print "Checking that Heroku Exists"
    heroku = local('which heroku')
    _set_heroku_configs(_heroku_settings_dict())

