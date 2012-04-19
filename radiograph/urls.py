from django.conf.urls.defaults import *

from django.contrib import admin
from haystack.views import search_view_factory
from radioapp.views import SearchView
admin.autodiscover()

urlpatterns = patterns('',
    (r'^admin/doc/', include('django.contrib.admindocs.urls')),
    (r'^admin/', include(admin.site.urls)),

    url(r'^accounts/login/$', 
        'radioapp.views.login',
        {'template_name': 'radioapp/login.html'},
        name='login'),

    url(r'^accounts/logout/$', 
        'radioapp.views.logout',
        {'next_page': '/'},
        name='logout'),

    url(r'^specimens/$',
        'radioapp.views.specimens',
        name='specimen-collection'),

    url(r'^specimens/search$',
        search_view_factory(SearchView),
        name='specimen-search'),

    url(r'^specimens/new$',
        'radioapp.views.new_specimen',
        name='specimen-new'),

    url(r'^specimens/(?P<specimen_id>[^/]+)$',
        'radioapp.views.specimen',
        name='specimen'),

    url(r'^specimens/(?P<specimen_id>[^/]+)/edit$',
        'radioapp.views.edit_specimen',
        name='specimen-edit'),

    url(r'^specimens/(?P<specimen_id>[^/]+)/delete$',
        'radioapp.views.delete_specimen',
        name='specimen-delete'),

    url(r'^images/(?P<image_id>[^/]+)$',
        'radioapp.views.image',
        name='image'),

    url(r'^images/(?P<image_id>[^/]+)/(?P<derivative>[^/]+)$',
        'radioapp.views.image_file',
        name='image-file'),

    url(r'^app/state',
        'radioapp.views.app_state',
        name='app-state'),

    # Endpoints exposing choices for various fields
    url(r'^choices/(?P<field>[^/]+)$', 
        'radioapp.views.field_choices',
        name='field-choices'),

    # Endpoints exposing templates for media types
    url(r'^templates/(?P<mediatype>[^/]+)$', 'radioapp.views.template', name='template'),

    url(r'^$', 'radioapp.views.index', name='index'),
)
