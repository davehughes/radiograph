import os
import sys
import site

SITE_ROOT = os.path.abspath(os.path.dirname(__file__))
sys.path.append(SITE_ROOT)

# If using a virtualenv add the site-packages dir to the path
#vepath = 'path/to/virtualenv/lib/python2.7/site-packages'
#site.addsitedir(vepath)

os.environ['DJANGO_SETTINGS_MODULE'] = 'radiograph.settings'

# If this is a development instance, uncomment the following lines
# to enable auto-restart . DO NOT ENABLE ON PRODUCTION 
#from radiograph import monitor
#monitor.start()

import django.core.handlers.wsgi
application = django.core.handlers.wsgi.WSGIHandler()
