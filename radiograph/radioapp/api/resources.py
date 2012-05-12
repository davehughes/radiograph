from django.core.urlresolvers import reverse
from djangorestframework import resources

from radioapp import models


class Institution(resources.ModelResource):
    model = models.Institution
    fields = ('id', 'label')

class User(resources.ModelResource):
    model = models.User
    fields = ('first_name', 'last_name', 'username', 'date_joined')

class Taxon(resources.ModelResource):
    model = models.Taxon

class Image(resources.ModelResource):
    model = models.Image
    fields = (
        'href',
        'specimen',
        'file',
        'aspect',
        'derivatives'
        )

    def href(self, o):
        return reverse('api:image', args=[o.id])

    def specimen(self, o):
        if o.specimen_id:
            return reverse('api:specimen', args=[o.specimen_id])

    def derivatives(self, o):
        derivs = {}
        if o.image_medium:
            derivs['medium'] = reverse('image-file', args=[o.id, 'medium'])
        if o.image_thumbnail:
            derivs['thumbnail'] = reverse('image-file', args=[o.id, 'thumbnail'])
        return derivs

class Specimen(resources.ModelResource):
    model = models.Specimen
    # prefetch_related = 'images'
    # select_related = ('institution', 'created_by', 'last_modified_by')
    fields = (
        'href',
        'created', 
        'last_modified',
        'created_by',
        'last_modified_by',
        'institution',
        'specimen_id',
        'taxon',
        'skull_height',
        'cranial_width',
        'neurocranial_height',
        'facial_height',
        'palate_width',
        'palate_length',
        'settings',
        'comments',
        ('images', 'Image')
    )

    def href(self, o):
        return reverse('api:specimen', args=[o.id])

    def institution(self, o):
        if o.institution_id:
            return reverse('api:institution', args=[o.institution_id])

    def created_by(self, o):
        if o.created_by_id:
            return reverse('api:user', args=[o.created_by.username])

    def last_modified_by(self, o):
        if o.last_modified_by_id:
            return reverse('api:user', args=[o.last_modified_by.username])

    def taxon(self, o):
        if o.taxon_id:
            return reverse('api:taxon', args=[o.taxon_id])
