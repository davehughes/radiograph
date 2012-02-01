from django.core.urlresolvers import reverse
from haystack.indexes import *
from haystack import site

from radioapp.models import Specimen, Image, Taxon

class SpecimenIndex(SearchIndex):
    text = CharField(document=True, use_template=True)
    specimen_id = CharField(model_attr='specimen_id', null=True)
    comments = CharField(model_attr='comments', null=True)
    settings = CharField(model_attr='settings', null=True)
    images = MultiValueField()

    # facet fields
    species_facet = FacetCharField(model_attr='species')
    subspecies_facet = FacetCharField(model_attr='subspecies', null=True)
    sex = FacetCharField(null=True)
    taxa = FacetMultiValueField()

    def prepare_sex(self, obj):
        return obj.get_sex_display() if obj.sex else 'Unspecified/Unknown'

    def prepare_taxa(self, obj):
        return [t.id for t in obj.taxon.heirarchy]

    def prepare_images(self, obj):
        return ['%s:%s' % (i.id, i.get_aspect_display())
                for i in obj.images.all()]
    
    def index_queryset(self):
        return Specimen.objects.select_related()

class TaxonomicIndex(SearchIndex):
    label = EdgeNgramField() 
    text = CharField(document=True)
    
    def prepare_label(self, obj):
        return ' '.join([t.name for t in obj.hierarchy if t.level >= 5])

    def index_queryset(self):
        return Taxon.objects.filter(level__gt=5)

site.register(Specimen, SpecimenIndex)
site.register(Taxon, TaxonomicIndex)
