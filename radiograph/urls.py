from django.conf.urls.defaults import *

from django.contrib import admin
from radioapp.api import resources, views
from djangorestframework.views import InstanceModelView
from radioapp.api.views import ListOrCreateModelView
admin.autodiscover()

urlpatterns = patterns('',

    # Admin and accounts
    (r'^admin/doc/', include('django.contrib.admindocs.urls')),
    (r'^admin/', include(admin.site.urls)),

    # url(r'^accounts/login/$', 
    #     'radioapp.views.login',
    #     {'template_name': 'radioapp/login.html'},
    #     name='login'),

    # url(r'^accounts/logout/$', 
    #     'radioapp.views.logout',
    #     {'next_page': '/'},
    #     name='logout'),

    # Specimens
    url(r'^specimens$',
        views.SpecimenView.as_view(),
        name='specimens'),
    url(r'^specimens/data.csv',
        'radioapp.views.build_dataset_csv',
        name='specimen-dataset'),
    url(r'^specimens/(?P<pk>[0-9]+)$',
        InstanceModelView.as_view(resource=resources.Specimen),
        name='specimen'),

    # Images
    url(r'^images$',
        ListOrCreateModelView.as_view(resource=resources.Image),
        name='images'),
    url(r'^images/(?P<pk>[^/]+)$',
        InstanceModelView.as_view(resource=resources.Image),
        name='image'),

    url(r'^images/(?P<image_id>[^/]+)/(?P<derivative>[^/]+)$',
        'radioapp.views.image_file',
        name='image-file'),

    # Institutions
    url(r'^institutions$',
        ListOrCreateModelView.as_view(resource=resources.Institution),
        name='institutions'),
    url(r'^institutions/(?P<pk>[0-9]+)$',
        InstanceModelView.as_view(resource=resources.Institution),
        name='institution'),

    # Users
    url(r'^users$',
        ListOrCreateModelView.as_view(resource=resources.User),
        name='users'),
    url(r'^users/(?P<username>[^/]+)$',
        InstanceModelView.as_view(resource=resources.User),
        name='user'),

    # Taxa
    url(r'^taxa$',
        ListOrCreateModelView.as_view(resource=resources.Taxon),
        name='taxa'),
    url(r'^taxa/filter-tree$',
        'radioapp.api.resources.taxon_filter_tree',
        name='taxon-filter-tree'),
    url(r'^taxa/(?P<pk>[^/]+)$',
        InstanceModelView.as_view(resource=resources.Taxon),
        name='taxon'),
)
