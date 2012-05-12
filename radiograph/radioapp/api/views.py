import types

from django.conf import settings
from djangorestframework import mixins, views
import pysolr

class ListModelMixin(mixins.ListModelMixin):
    def get(self, request, *args, **kwargs):
        queryset = super(ListModelMixin, self).get(request, *args, **kwargs)

        # Add any prefetch_related() lookups to queryset
        lookups = coerce_to_list(getattr(self.resource, 'prefetch_related', []))
        if lookups:
            queryset = queryset.prefetch_related(*lookups)

        # Add any select_related() lookups to queryset
        lookups = coerce_to_list(getattr(self.resource, 'select_related', []))
        if lookups:
            queryset = queryset.select_related(*lookups)

        return queryset

def coerce_to_list(x):
    if type(x) is types.TupleType:
        return list(x)
    elif type(x) is not types.ListType:
        return [x]
    return x

class ListOrCreateModelView(ListModelMixin, 
                            mixins.CreateModelMixin, 
                            views.ModelView):
    """
    A view which provides default operations for list and create, against a model in the database.
    """
    _suffix = 'List'

class TaxaView(mixins.ListModelMixin):

    def get(self):
        solr = pysolr.Solr(settings.HAYSTACK_SOLR_URL)
        result = solr.search(q="django_ct:radioapp.taxon", 
                             start=0, rows=1000, 
                             fl="django_id label",
                             sort="label_sort asc")
        return [(doc['django_id'], doc['label']) for doc in result.docs]









