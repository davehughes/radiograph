import os
import sys
import site

# If using a virtualenv add the site-packages dir to the path
vepath = '/projects/radiograph/env/lib/python2.7/site-packages'
site.addsitedir(vepath)

SITE_ROOT = os.path.abspath(os.path.dirname(__file__))
sys.path.append(SITE_ROOT)

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'radiograph.settings')

from django.core.wsgi import get_wsgi_application
application = get_wsgi_application()

# If this is a development instance, uncomment the following lines
# to enable auto-restart . DO NOT ENABLE ON PRODUCTION 
from radiograph import monitor
monitor.start()

