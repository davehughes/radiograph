import os
import sys
import site

SITE_ROOT = os.path.abspath(os.path.dirname(__file__))
sys.path.append(SITE_ROOT)

# If using a virtualenv add the site-packages dir to the path
# vepath = '/path/to/pyenvs/asurepo/lib/python2.6/site-packages'
# site.addsitedir(vepath)

os.environ['DJANGO_SETTINGS_MODULE'] = 'radiograph.settings'

import django.core.handlers.wsgi
application = django.core.handlers.wsgi.WSGIHandler()