from haystack.indexes import *
from haystack import site
from radioapp.models import Specimen, Image

class SpecimenIndex(SearchIndex):
    text = CharField(document=True, use_template=True)
    species = CharField(model_attr='species')
    subspecies = CharField(model_attr='subspecies', null=True)

    # facet fields
    species_facet = FacetCharField(model_attr='species')
    subspecies_facet = FacetCharField(model_attr='subspecies', null=True)
    sex = FacetCharField(null=True)

    def prepare_sex(self, object):
        if object.sex:
            return object.get_sex_display()
        else:
            return 'Unspecified/Unknown'
    
    def get_queryset(self):
        return Specimen.objects.all()

site.register(Specimen, SpecimenIndex)
