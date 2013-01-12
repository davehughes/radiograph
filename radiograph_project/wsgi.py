import os
import sys
import site

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'radiograph_project.settings')

from django.core.wsgi import get_wsgi_application
application = get_wsgi_application()

# If this is a development instance, uncomment the following lines
# to enable auto-restart . DO NOT ENABLE ON PRODUCTION 
# from radiograph import monitor
monitor.start()

