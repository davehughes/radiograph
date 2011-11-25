from django.core.urlresolvers import reverse
from haystack.indexes import *
from haystack import site

from radioapp.models import Specimen, Image

class SpecimenIndex(SearchIndex):
    text = CharField(document=True, use_template=True)
    species = CharField(model_attr='species')
    subspecies = CharField(model_attr='subspecies', null=True)
    specimen_id = CharField(model_attr='specimen_id', null=True)
    comments = CharField(model_attr='comments', null=True)
    settings = CharField(model_attr='settings', null=True)
    images = MultiValueField()

    # facet fields
    species_facet = FacetCharField(model_attr='species')
    subspecies_facet = FacetCharField(model_attr='subspecies', null=True)
    sex = FacetCharField(null=True)

    def prepare_sex(self, obj):
        return obj.get_sex_display() if obj.sex else 'Unspcified/Unknown'

    def prepare_images(self, obj):
        return obj.images.values_list('id', flat=True)
    
    def index_queryset(self):
        return Specimen.objects.select_related()

site.register(Specimen, SpecimenIndex)
