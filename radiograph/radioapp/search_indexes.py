import json

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
    taxon = IntegerField()
    taxon_label = CharField()

    # facet fields
    institution = FacetCharField()
    institution_label = FacetCharField()
    sex = FacetCharField(model_attr='sex', null=True)
    sex_label = FacetCharField(null=True)
    taxa = FacetMultiValueField()
    json_doc = FacetCharField()

    def prepare(self, obj):
        doc = super(SpecimenIndex, self).prepare(obj)
        doc.update({
            'institution': obj.institution.id,
            'institution_label': obj.institution.name,
            'sex_label': obj.get_sex_display() if obj.sex else 'Unspecified/Unknown',
            'taxon': obj.taxon.id,
            'taxon_label': ' '.join([t.name for t in 
                                     obj.taxon.hierarchy 
                                     if t.level >= 7]),
            'taxa': [t.id for t in obj.taxon.hierarchy]
            })

        doc['json_doc'] = json.dumps({
            'institution': obj.institution.id,
            'sex': obj.sex,
            'taxon': obj.taxon.id,
            'skull_length': obj.skull_length,
            'cranial_width': obj.cranial_width,
            'neurocranial_height': obj.neurocranial_height,
            'facial_height': obj.facial_height,
            'palate_length': obj.palate_length,
            'palate_width': obj.palate_width,
            'images': [{'href': reverse('image', args=[img.id]),
                        'aspect': img.aspect,
                        'file': reverse('image-file', args=[img.id, 'full'])}
                       for img in obj.images.all()]
            })
        return doc

    def index_queryset(self):
        return Specimen.objects.select_related()

class TaxonomicIndex(SearchIndex):
    label = EdgeNgramField() 
    label_sort = FacetCharField()
    text = CharField(document=True)
    
    def prepare_label(self, obj):
        return ' '.join([t.name for t in obj.hierarchy if t.level >= 7])

    def prepare_label_sort(self, obj):
        return self.prepare_label(obj)

    def index_queryset(self):
        return Taxon.objects.filter(level__gt=7)

site.register(Specimen, SpecimenIndex)
site.register(Taxon, TaxonomicIndex)
