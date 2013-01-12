import os

from fabric.api import *
from fabric.contrib import files
from cuisine import *
# from cuisine_postgresql import *
from fabutils import config, postgresql, files, deploy, environments as env
from fabutils import config as _


def radiograph_install(ref='master'):

    # install python stuff, we'll need it
    package_ensure('python2.7')
    package_ensure('python-dev')
    package_ensure('python-pip')
    sudo('pip install --upgrade pip')
    sudo('pip install virtualenv')

    # get source
    user_ensure('radiograph', home=_['app.home'])
    with cd(_['app.home']):
        source = deploy.GitDeployment(_['git.url'], ref)
        source.deploy()

        reqs = os.path.join(source.target, 'requirements.txt')
        venv = deploy.VirtualenvDeployment(reqs, source.version)
        venv.deploy()

    # create a virtualenv and install the requirements
    with cd(settings['home']):
        sudo('virtualenv --no-site-packages --python=python2.7 --distribute env')
        package_ensure('libpq-dev')
        with prefix('source env/bin/activate'):
            sudo('pip install -r requirements.txt')
            sudo('pip install -e .')

    # configure and connect to database
    postgresql.role_ensure(_['app.database.name'],
                           _['app.database.password'])
    postgresql.database_ensure(_['app.database.name'],
                               owner=_['app.database.user'],
                               encoding='utf8')

    # install as supervisord service
    # files.upload_template('conf/gunicorn.conf.py',
    files.template(source, dest)


@task
@config
def common():
    config = {
        'git': {
            'url': 'git://github.com/davehughes/radiograph.git'
            },
        'app': {
            'user': 'radiograph',
            'home': '/home/radiograph',
            'root': '/home/radiograph/app',
            'static_root': '/home/radiograph/static',
            'media_root': '/home/radiograph/media',
            'server': {
                'name': 'www.primate-radiograph.com',
                'location': 'http://localhost:8000'
                },
            'database': {
                'name': 'radiograph',
                'user': 'radiograph',
                'password': 'radiograph',
                'host': 'localhost',
                'port': '5432'
                }
            },
        'api': {
            'server': {
                'name': 'api.primate-radiograph.com',
                'location': '/tmp/radiograph-api.sock'
                }
            }
        }
    return config
