import logging
import os
import subprocess
import tempfile

from django.contrib.auth.models import User
from django.core.files import File as DjangoFile
from django.core.files.storage import default_storage
from django.db import models
from djchoices import DjangoChoices as Choices, C

LOG = logging.getLogger(__name__)

# The current project scope is almost too narrow to store these details, but
# I'll include them for completeness and to enable meaningful semantic data
# sharing.
# 
# The radiographs that we're interested in are in
# Animalia -> Chordata -> Mammalia -> Primates

class TaxonomyLevels(Choices):
    # Kingdom     = C(0, 'Kingdom')
    # Phylum      = C(1, 'Phylum')
    # Class       = C(2, 'Class')
    # Order       = C(3, 'Order')
    # Suborder    = C(4, 'Suborder')
    # Family      = C(5, 'Family')
    # Subfamily   = C(6, 'Subfamily')
    Genus       = C(7, 'Genus')
    Species     = C(8, 'Species')
    Subspecies  = C(9, 'Subspecies')

class DeletedMarkerManager(models.Manager):
    def get_query_set(self):
        return super(DeletedMarkerManager, self).get_query_set().filter(deleted=False)


class DeletedObjectManager(models.Manager):
    def get_query_set(self):
        return super(DeletedObjectManager, self).get_query_set().filter(deleted=True)


TAXON_LABEL_CACHE = None
def taxon_label_cache():
    '''
    Walk taxon nodes below 'genus' level and cache a map of taxon_id -> label
    so we don't need to walk this tree each time we display a specimen's taxon.
    '''
    import radiograph.models
    if radiograph.models.TAXON_LABEL_CACHE is None:
        radiograph.models.TAXON_LABEL_CACHE = {
            tid: ' '.join((ppname, pname, name)[TaxonomyLevels.Subspecies - tlevel:])
            for ppname, pname, name, tid, tlevel
            in (Taxon.objects
                .filter(level__gte=TaxonomyLevels.Genus)
                .values_list('parent__parent__name', 'parent__name', 'name', 'id', 'level'))
            }
    return radiograph.models.TAXON_LABEL_CACHE


class TaxonManager(models.Manager):

    def find_species(self, genus, species):
        try:
            return Taxon.objects.get(name=species, parent__name=genus)
        except Taxon.DoesNotExist:
            return None


class Taxon(models.Model):
    parent = models.ForeignKey('self', null=True)
    level = models.IntegerField(choices=TaxonomyLevels.choices)
    name = models.CharField(max_length=255, null=True)
    common_name = models.CharField(max_length=255, null=True)
    description = models.TextField(null=True)

    objects = TaxonManager()

    def __unicode__(self):
        return self.name

    @property
    def hierarchy(self):
        return (self.parent.hierarchy if self.parent else []) + [self]

    def create_child_taxon(self, *args, **kwargs):
        kwargs['parent'] = self
        kwargs['level'] = self.level + 1
        return Taxon.objects.create(*args, **kwargs)

    def children(self):
        return Taxon.objects.filter(parent=self)

    def get_json_subtree(self):
        '''Create a JSON-compatible subtree rooted with this Taxon.'''
        return {'level': self.level,
                'level_name': self.get_level_display(),
                'name': self.name,
                'common_name': self.common_name,
                'description': self.description,
                'children': [child.get_json_subtree() 
                             for child in self.children()]}

    @property
    def label(self):
        label = taxon_label_cache().get(self.id)
        if not label:
            taxon = models.Taxon.objects.get(id=self.id)
            label = ' '.join([t.name for t in taxon.hierarchy 
                              if t.level >= models.TaxonomyLevels.Genus])
        return label


class Institution(models.Model):
    name = models.CharField(max_length=255)
    link = models.CharField(max_length=255, null=True)
    logo = models.FileField(upload_to='institutions', null=True)


class Specimen(models.Model):

    class SexChoices(Choices):
        Male    = C('M')
        Female  = C('F')
        Unknown = C('U')

    objects = DeletedMarkerManager()

    specimen_id = models.CharField(max_length=255, null=True, verbose_name='Specimen ID')
    taxon = models.ForeignKey('Taxon', related_name='specimens')
    institution = models.ForeignKey('Institution', related_name='specimens', null=True)
    sex = models.CharField(max_length=10, choices=SexChoices.choices, null=True)
    settings = models.TextField(null=True)
    comments = models.TextField(null=True)

    # cranial measurements
    skull_length = models.DecimalField(max_digits=10, decimal_places=2, null=True)
    cranial_width = models.DecimalField(max_digits=10, decimal_places=2, null=True)
    neurocranial_height = models.DecimalField(max_digits=10, decimal_places=2, null=True)
    facial_height = models.DecimalField(max_digits=10, decimal_places=2, null=True)
    palate_length = models.DecimalField(max_digits=10, decimal_places=2, null=True)
    palate_width = models.DecimalField(max_digits=10, decimal_places=2, null=True)

    created = models.DateField(auto_now_add=True)
    created_by = models.ForeignKey(User, related_name='specimens_created', null=True)
    last_modified = models.DateField(auto_now=True)
    last_modified_by = models.ForeignKey(User, related_name='specimens_last_modified', null=True)

    deleted = models.BooleanField(default=False)

    def __unicode__(self):
        return '%s - %s' % (self.taxon, self.specimen_id)


class ImageManager(DeletedMarkerManager):
    pass


class Image(models.Model):
    objects = ImageManager()
    deleted = DeletedObjectManager()

    class AspectChoices(Choices):
        Superior = C('S')
        Lateral  = C('L')

    original_path = models.CharField(max_length=1024, null=True)
    md5 = models.CharField(max_length=32, null=True)
    aspect = models.CharField(max_length=1, choices=AspectChoices.choices)
    specimen = models.ForeignKey('Specimen', related_name='images', null=True)

    # image and derivative files
    image_full = models.FileField(max_length=1024, storage=default_storage)
    image_medium = models.FileField(null=True, blank=True, storage=default_storage)
    image_thumbnail = models.FileField(null=True, blank=True, storage=default_storage)

    deleted = models.BooleanField(default=False)
