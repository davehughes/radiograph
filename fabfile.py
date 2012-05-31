from fabric.api import *
from fabric.contrib import files
from cuisine import *
from cuisine_postgresql import *

def radiograph_install():
    settings = {
        'home': '/home/radiograph/app',
        'user': 'radiograph',
        'db': {
            'name': 'radiograph'
            'user': 'radiograph',
            'password': 'radiograph',
            'host': 'localhost',
            'port': '5432'
            }
    }

    # install python stuff, we'll need it
    package_ensure('python2.7')
    package_ensure('python-dev')
    package_ensure('python-pip')
    sudo('pip install --upgrade pip')
    sudo('pip install virtualenv')

    # get source
    user_ensure('radiograph', home='/home/radiograph')
    sudo('git clone git://github.com/davehughes/radiograph.git %s' % settings['home'], user='radiograph')

    # create a virtualenv and install the requirements
    with cd(settings['home']):
        sudo('virtualenv --no-site-packages --python=python2.7 --distribute env')
        package_ensure('libpq-dev')
        with prefix('source env/bin/activate'):
            sudo('pip install -r requirements.txt')
            sudo('pip install -e .')

    # configure and connect to database
    postgresql_role_ensure(settings['db']['name'], settings['db']['password'])
    postgresql_database_ensure(settings['db']['name'], owner='radiograph', encoding='utf8')

    # install as supervisord service
    # files.upload_template('conf/gunicorn.conf.py',

