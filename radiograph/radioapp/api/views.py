import types

from django.conf import settings
from djangorestframework import mixins, views
from radioapp.api import resources
import pysolr

class ListModelMixin(mixins.ListModelMixin):
    '''
    Implementation of ListModelMixin that allows resources to declare related
    model values that they require and select/prefetch them.  This is a minor
    optimization, but seems to save ~15% of execution time.
    '''

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
    A view which provides default operations for list and create, against a 
    model in the database.
    """
    _suffix = 'List'

class SpecimenView(ListOrCreateModelView):
    _suffix = 'List'
    resource = resources.Specimen

    def get_query_kwargs(self, request, *args, **kwargs):
        qargs = super(SpecimenView, self).get_query_kwargs(self, request, *args, **kwargs)

        # Create taxa filters
        taxa_list = request.GET.getlist('taxa')
        if taxa_list:
            qargs['taxon__in'] = taxa_list

        # Create sex filters
        sex_list = request.GET.getlist('sex')
        if sex_list:
            qargs['sex__in'] = sex_list
        return qargs
