from django.conf.urls.defaults import *

from django.contrib import admin

admin.autodiscover()

urlpatterns = patterns('',

    # Admin and accounts
    (r'^admin/doc/', include('django.contrib.admindocs.urls')),
    (r'^admin/', include(admin.site.urls)),

    # Main radiograph URLs
    url(r'', include('radiograph.urls')),

    # API/Django REST framework URLs
    # url(r'^restframework',
    #     include('djangorestframework.urls',
    #             namespace='djangorestframework'))
)
