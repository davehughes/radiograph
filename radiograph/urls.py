from django.conf.urls.defaults import *

from django.contrib import admin
from haystack.views import search_view_factory
from radioapp.views import SearchView
admin.autodiscover()

urlpatterns = patterns('',
    (r'^admin/doc/', include('django.contrib.admindocs.urls')),
    (r'^admin/', include(admin.site.urls)),

    url(r'^login/$', 'django.contrib.auth.views.login',
        {'template_name': 'radioapp/login.html'},
        name='login'),
    url(r'^logout/$', 'django.contrib.auth.views.logout',
        {'next_page': '/'},
        name='logout'),

    url(r'^specimens/$',
        'radioapp.views.specimens',
        name='specimen-list'),

    url(r'^specimens/new$',
        'radioapp.views.new_specimen',
        name='specimen-new'),

    url(r'^specimens/(?P<specimen_id>[^/]+)$',
        'radioapp.views.specimen',
        name='specimen'),

    url(r'^specimens/(?P<specimen_id>[^/]+)/edit$',
        'radioapp.views.edit_specimen',
        name='specimen-edit'),

    url(r'^images/(?P<image_id>[^/]+)/(?P<derivative>[^/]+)$',
        'radioapp.views.image',
        name='image'),

    url(r'^autocomplete/taxa$', 
        'radioapp.views.taxa_autocomplete',
        name='taxa-autocomplete'),

    url(r'^$', search_view_factory(SearchView), name='index')
)
