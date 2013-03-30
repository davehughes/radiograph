from django.conf.urls.defaults import *

# from rest_framework.views import InstanceModelView
from rest_framework import generics
from rest_framework.urlpatterns import format_suffix_patterns
from radiograph.api import views as apiviews
from radiograph import views, models
# from radiograph.api.views import ListOrCreateModelView

api_patterns = patterns('radiograph.api.views',

    # Specimens
    url(r'^specimens$',
        apiviews.SpecimenList.as_view(),
        name='specimen-list'),
    url(r'^specimens/(?P<pk>[0-9]+)$',
        apiviews.SpecimenDetail.as_view(),
        name='specimen-detail'),
    # url(r'^specimens/data',
    #     'radiograph.api.resources.specimen_dataset',
    #     name='specimen-dataset'),
    # url(r'^specimens/data.csv',
    #     'radiograph.views.build_dataset_csv',
    #     name='specimen-dataset-csv'),

    # Images
    url(r'^images$',
        apiviews.ImageList.as_view(),
        name='image-list'),
    url(r'^images/(?P<pk>[^/]+)$',
        apiviews.ImageDetail.as_view(),
        name='image-detail'),
    # url(r'^images/(?P<image_id>[^/]+)/(?P<derivative>[^/]+)$',
    #     'radiograph.views.image_file',
    #     name='image-file'),

    # Institutions
    url(r'^institutions$',
        generics.ListCreateAPIView.as_view(model=models.Institution),
        name='institution-list'),
    url(r'^institutions/(?P<pk>[0-9]+)$',
        generics.RetrieveUpdateDestroyAPIView.as_view(model=models.Institution),
        name='institution-detail'),

    # # Users
    # url(r'^users$',
    #     ListOrCreateModelView.as_view(resource=resources.User),
    #     name='users'),
    # url(r'^users/(?P<username>[^/]+)$',
    #     InstanceModelView.as_view(resource=resources.User),
    #     name='user'),

    # Taxa
    url(r'^taxa$',
        generics.ListCreateAPIView.as_view(model=models.Taxon),
        name='taxon-list'),
    # url(r'^taxa/filter-tree$',
    #     'radiograph.api.resources.taxon_filter_tree',
    #     name='taxon-filter-tree'),
    url(r'^taxa/(?P<pk>[^/]+)$',
        generics.RetrieveAPIView.as_view(model=models.Taxon),
        name='taxon-detail'),

    # url(r'^accounts/login/$',
    #     'radiograph.views.login',
    #     {'template_name': 'radiograph/login.html'},
    #     name='login'),

    # url(r'^accounts/logout/$',
    #     'radiograph.views.logout',
    #     {'next_page': '/'},
    #     name='logout'),

    # API root
    url(r'', 'api_root', name='root'),
)
api_patterns = format_suffix_patterns(api_patterns)

urlpatterns = patterns('',
    url(r'^api/', include(api_patterns, namespace='api')),

    # Primary views
    url(r'^$', 'radiograph.views.index', name='index'),
    url(r'^specimens$', 'radiograph.views.specimens', name='specimen-list'),
    url(r'^specimens/(?P<specimen_id>[0-9]+)$',
        'radiograph.views.specimen',
        name='specimen-detail'),
    url(r'^images/(?P<image_id>[0-9]+)/(?P<derivative>[^/]+)$',
        'radiograph.views.image_file',
        name='image'),
)
