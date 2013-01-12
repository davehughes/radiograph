import logging
import os
import subprocess
import tempfile

from django.contrib.auth.models import User
from django.core.files import File as DjangoFile
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
    Kingdom     = C(0, 'Kingdom'),
    Phylum      = C(1, 'Phylum'),
    Class       = C(2, 'Class'),
    Order       = C(3, 'Order'),
    Suborder    = C(4, 'Suborder'),
    Family      = C(5, 'Family'),
    Subfamily   = C(6, 'Subfamily'),
    Genus       = C(7, 'Genus'),
    Species     = C(8, 'Species'),
    Subspecies  = C(9, 'Subspecies')

class DeletedMarkerManager(models.Manager):
    def get_query_set(self):
        return super(DeletedMarkerManager, self).get_query_set().filter(deleted=False)

class DeletedObjectManager(models.Manager):
    def get_query_set(self):
        return super(DeletedObjectManager, self).get_query_set().filter(deleted=True)

class Taxon(models.Model):
    parent = models.ForeignKey('self', null=True)
    level = models.IntegerField(choices=TaxonomyLevels.choices)
    name = models.CharField(max_length=255, null=True)
    common_name = models.CharField(max_length=255, null=True)
    description = models.TextField(null=True)

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

class Institution(models.Model):
    name = models.CharField(max_length=255)
    link = models.CharField(max_length=255, null=True)
    logo = models.FileField(upload_to='institutions', null=True)

# Create your models here.
class Specimen(models.Model):

    class SexChoices(Choices):
        Male    = C('M')
        Female  = C('F')
        Unknown = C('U')

    objects = DeletedMarkerManager()

    specimen_id = models.CharField(max_length=255, null=True, verbose_name='Specimen ID')
    taxon = models.ForeignKey('Taxon', related_name='specimens')
    institution = models.ForeignKey('Institution', related_name='specimens')
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

    def get_taxon_display(self):
        return 'TODO: implement get_taxon_display()'


class ImageManager(DeletedMarkerManager):

    def generate_derivatives(self, tmpdir=None, regenerate=False):
        tmpdir = tempfile.mkdtemp(dir=tmpdir)
        for img in self.get_query_set():
            try:
                img.generate_derivatives(tmpdir=tmpdir, regenerate=regenerate)
            except Exception as e:
                print 'Error generating image derivatives: %s' % e

class Image(models.Model):
    objects = ImageManager()
    deleted = DeletedObjectManager()

    class AspectChoices(Choices):
        Superior = C('S')
        Lateral  = C('L')

    aspect = models.CharField(max_length=1, choices=AspectChoices.choices)
    specimen = models.ForeignKey('Specimen', related_name='images')

    # image and derivative files
    image_full = models.FileField(upload_to='images/full')
    image_medium = models.FileField(upload_to='images/medium', null=True, blank=True)
    image_thumbnail = models.FileField(upload_to='images/thumbnail', null=True, blank=True)

    deleted = models.BooleanField(default=False)

    def generate_derivatives(self, tmpdir=None, regenerate=False):
        tmpdir = tmpdir or tempfile.mkdtemp()
        
        derivatives = [
            ('image_thumbnail', 
             ['-define', 'jpeg:size=300x300', 
              '-rotate', '90',
              '-resize', '150x150>']),
              # '-thumbnail', '150x150>']),
            ('image_medium', 
             ['-resize', '1024x1024>', 
              '-rotate', '90'])
            ]

        for attr, args in derivatives:
            derivative = getattr(self, attr)
            if (not derivative) or regenerate:
                # write updated image to temp file
                fd, resized_tmp = tempfile.mkstemp(suffix='.png', dir=tmpdir)
                os.close(fd)

                _imagemagick_convert(self.image_full.path, resized_tmp, args)

                # clean up existing image
                if derivative:
                    path = derivative.path
                    derivative.delete()
                    if os.path.isfile(path):
                        os.remove(path)

                # set new image and save
                setattr(self, attr, DjangoFile(open(resized_tmp, 'r'), 
                                               '%s.png' % self.id))
                self.save()

                # finally, clean up the temporary image
                if os.path.isfile(resized_tmp):
                    os.remove(resized_tmp)

def _imagemagick_convert(inpath, outpath, args=None):
    
    if not os.path.isfile(inpath):
        LOG.warn('%s is not a file.', inpath)
        return False
    
    command = ['convert', inpath]
    command.extend(args)
    command.append(outpath)
    
    LOG.debug('Calling imagemagick: %s.', command)

    proc = subprocess.Popen(
                command,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE)
    out, err = proc.communicate()
    
    if err:
        LOG.error('Error calling imagemagick: %s', err)

    return proc.returncode == 0