from django.conf.urls.defaults import *

# Uncomment the next two lines to enable the admin:
# from django.contrib import admin
# admin.autodiscover()

urlpatterns = patterns('',
    # Example:
    # (r'^radiograph/', include('radiograph.foo.urls')),

    # Uncomment the admin/doc line below to enable admin documentation:
    # (r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    # (r'^admin/', include(admin.site.urls)),
    url(r'^specimens/(?P<specimen_id>[^/]+)$',
        'radioapp.views.specimen',
        name='specimen'),

    url(r'^images/(?P<image_id>[^/]+)/(?P<derivative>[^/]+)$',
        'radioapp.views.image',
        name='image'),
)
