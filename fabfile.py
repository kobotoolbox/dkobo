import os
import sys
import json

from fabric.api import local, hosts, cd, env, prefix, run, sudo

def kobo_workon(venv_name):
    return prefix('kobo_workon %s' % venv_name)

DEPLOYMENTS = {}
IMPORTED_DEPLOYMENTS = {}
if os.path.exists('deployments.json'):
    with open('deployments.json', 'r') as f:
        IMPORTED_DEPLOYMENTS = json.load(f)

def exit_with_error(message):
    print message
    sys.exit(1)

def check_key_filename(deployment_configs):
    if 'key_filename' in deployment_configs and \
       not os.path.exists(deployment_configs['key_filename']):
        exit_with_error("Cannot find required permissions file: %s" %
                        deployment_configs['key_filename'])

def setup_env(deployment_name):
    deployment = DEPLOYMENTS.get(deployment_name, {})

    if 'shared' in IMPORTED_DEPLOYMENTS:
        deployment.update(IMPORTED_DEPLOYMENTS['shared'])

    if deployment_name in IMPORTED_DEPLOYMENTS:
        deployment.update(IMPORTED_DEPLOYMENTS[deployment_name])

    env.update(deployment)
    check_key_filename(deployment)

    env.virtualenv = os.path.join('/home', 'ubuntu', '.virtualenvs',
                                  env.virtualenv_name, 'bin', 'activate')
    env.uwsgi_pidfile = os.path.join('/home', 'ubuntu', 'pids',
                                  'kobo-uwsgi-master.pid')
    env.code_src = os.path.join(env.home, env.project)
    env.pip_requirements_file = os.path.join(env.code_src,
                                             'requirements.txt')

def deploy(deployment_name, branch='master'):
    setup_env(deployment_name)
    with cd(env.code_src):
        run("git fetch origin")
        run("git checkout origin/%s" % branch)
        run('find . -name "*.pyc" -exec rm -rf {} \;')
        run('find . -type d -empty -delete')

    with kobo_workon(env.virtualenv_name):
        run("pip install -r %s" % env.pip_requirements_file)

    with cd(env.code_src):
        run("npm install")
        run("bower install")
        run("grunt build_all")

        with kobo_workon(env.virtualenv_name):
            # run("echo 'from django.contrib.auth.models import User; print User.objects.count()' | python manage.py shell")
            run("python manage.py syncdb --all")
            run("python manage.py migrate")
            run("python manage.py compress")
            run("python manage.py collectstatic --noinput")

    run("uwsgi --reload %s" % env.uwsgi_pidfile)
