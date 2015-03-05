import os
import sys
import json
import re
import requests

from fabric.api import local, hosts, cd, env, prefix, run, sudo

def kobo_workon(venv_name):
    return prefix('kobo_workon %s' % venv_name)

DEPLOYMENTS = {}
IMPORTED_DEPLOYMENTS = {}
deployments_file = os.environ.get('DEPLOYMENTS_JSON', 'deployments.json')
if os.path.exists(deployments_file):
    with open(deployments_file, 'r') as f:
        IMPORTED_DEPLOYMENTS = json.load(f)

def exit_with_error(message):
    print message
    sys.exit(1)

def check_key_filename(deployment_configs):
    if 'key_filename' in deployment_configs and \
       not os.path.exists(deployment_configs['key_filename']):
        # Maybe the path contains a ~; try expanding that before failing
        deployment_configs['key_filename'] = os.path.expanduser(
            deployment_configs['key_filename']
        )
        if not os.path.exists(deployment_configs['key_filename']):
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
                                  env.kf_virtualenv_name, 'bin', 'activate')
    env.uwsgi_pidfile = os.path.join('/home', 'ubuntu', 'pids',
                                  'kobo-uwsgi-master.pid')
    env.kf_path = os.path.join(env.home, env.kf_path)
    env.pip_requirements_file = os.path.join(env.kf_path,
                                             'requirements.txt')

def deploy_ref(deployment_name, ref):
    setup_env(deployment_name)
    with cd(env.kf_path):
        run("git fetch origin")
        # Make sure we're not moving to an older codebase
        git_output = run('git rev-list {}..HEAD --count 2>&1'.format(ref))
        if int(git_output) > 0:
            raise Exception("The server's HEAD is already in front of the "
                "commit to be deployed.")
        # We want to check out a specific commit, but this does leave the HEAD
        # detached. Perhaps consider using `git reset`.
        run('git checkout {}'.format(ref))
        # Report if the working directory is unclean.
        git_output = run('git status --porcelain')
        if len(git_output):
            run('git status')
            print('WARNING: The working directory is unclean. See above.') 
        run('find . -name "*.pyc" -exec rm -rf {} \;')
        run('find . -type d -empty -delete')

    with kobo_workon(env.kf_virtualenv_name):
        run("pip install -r %s" % env.pip_requirements_file)

    with cd(env.kf_path):
        run("npm install")
        run("bower install")
        run("grunt build_all")

        with kobo_workon(env.kf_virtualenv_name):
            # run("echo 'from django.contrib.auth.models import User; print User.objects.count()' | python manage.py shell")
            run("python manage.py syncdb")
            run("python manage.py migrate")
            run("python manage.py compress")
            run("python manage.py collectstatic --noinput")

    run("sudo service uwsgi reload")
    sudo("service celeryd restart")


def deploy(deployment_name, branch='master'):
    deploy_ref(deployment_name, 'origin/{}'.format(branch))

def repopulate_summary_field(deployment_name):
    setup_env(deployment_name)
    with cd(env.kf_path):
        with kobo_workon(env.kf_virtualenv_name):
            run("python manage.py populate_summary_field")

def deploy_passing(deployment_name, branch='master'):
    ''' Deploy the latest code on the given branch that's
    been marked passing by Travis CI. '''
    print 'Asking Travis CI for the hash of the latest passing commit...'
    desired_commit = get_last_successfully_built_commit(branch)
    print 'Found passing commit {} for branch {}!'.format(desired_commit,
        branch)
    deploy_ref(deployment_name, desired_commit)


def get_last_successfully_built_commit(branch):
    ''' Returns the hash of the latest successfully built commit
    on the given branch according to Travis CI. '''

    API_ENDPOINT='https://api.travis-ci.org/'
    REPO_SLUG='kobotoolbox/dkobo'
    COMMON_HEADERS={'accept': 'application/vnd.travis-ci.2+json'}

    ''' Travis only lets us specify `number`, `after_number`, and `event_type`.
    It'd be great to filter by state and branch, but it seems we can't
    (http://docs.travis-ci.com/api/?http#builds). '''

    request = requests.get(
        '{}repos/{}/builds'.format(API_ENDPOINT, REPO_SLUG),
        headers=COMMON_HEADERS
    )
    if request.status_code != 200:
        raise Exception('Travis returned unexpected code {}.'.format(
            request.status_code
        ))
    response = json.loads(request.text)

    builds = response['builds']
    commits = {commit['id']: commit for commit in response['commits']}

    for build in builds:
        if build['state'] != 'passed' or build['pull_request']:
            # No interest in non-passing builds or PRs
            continue
        commit = commits[build['commit_id']]
        if commit['branch'] == branch:
            # Assumes the builds are in descending chronological order
            if re.match('^[0-9a-f]+$', commit['sha']) is None:
                raise Exception('Travis returned the invalid SHA {}.'.format(
                    commit['sha']))
            return commit['sha']

    raise Exception("Couldn't find a passing build for the branch {}. "
        "This could be due to pagination, in which case this code "
        "must be made more robust!".format(branch))
