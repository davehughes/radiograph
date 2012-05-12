from django.conf.urls.defaults import *
from radioapp.api import resources, views
from djangorestframework.views import InstanceModelView, ListOrCreateModelView

urlpatterns = patterns('',
    # Specimens
    url(r'^specimens$',
        ListOrCreateModelView.as_view(resource=resources.Specimen),
        name='specimens'),
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
    url(r'^taxa/(?P<pk>[^/]+)$',
        InstanceModelView.as_view(resource=resources.Taxon),
        name='taxon'),
    
)
