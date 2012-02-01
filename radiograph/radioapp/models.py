import logging
import os
import tempfile

from django.core.files import File as DjangoFile
from django.db import models

# The current project scope is almost too narrow to store these details, but
# I'll include them for completeness and to enable meaningful semantic data
# sharing.
# 
# The radiographs that we're interested in are in
# Animalia -> Chordata -> Mammalia -> Primates

TAXONOMY_LEVELS = (
    (0, 'Kingdom'),
    (1, 'Phylum'),
    (2, 'Class'),
    (3, 'Order'),
    (4, 'Family'),
    (5, 'Genus'),
    (6, 'Species'),
    (7, 'Subspecies')
)

class Taxon(models.Model):
    parent = models.ForeignKey('self', null=True)
    level = models.IntegerField(choices=TAXONOMY_LEVELS)
    name = models.CharField(max_length=255)
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

class Institution(models.Model):
    name = models.CharField(max_length=255)
    link = models.CharField(max_length=255, null=True)
    logo = models.FileField(upload_to='institutions', null=True)

# Create your models here.
class Specimen(models.Model):
    SEX_CHOICES = (('M', 'Male'), ('F', 'Female'), ('U', 'Unknown'))

    specimen_id = models.CharField(max_length=255, null=True)
    taxon = models.ForeignKey('Taxon', related_name='specimens')
    institution = models.ForeignKey('Institution', related_name='specimens')
    sex = models.CharField(max_length=10, choices=SEX_CHOICES, null=True)
    settings = models.TextField(null=True)
    comments = models.TextField(null=True)

    created = models.DateField(auto_now_add=True)
    last_modified = models.DateField(auto_now=True)

    def __unicode__(self):
        return '%s - %s' % (taxonomy_node, self.specimen_id)

class ImageManager(models.Manager):

    def generate_derivatives(self, tmpdir=None, regenerate=False):
        tmpdir = tempfile.mkdtemp(dir=tmpdir)
        for img in self.get_query_set():
            try:
                img.generate_derivatives(tmpdir=tmpdir, regenerate=regenerate)
            except Exception as e:
                print 'Error generating image derivatives: %s' % e
            

class Image(models.Model):
    objects = ImageManager()

    ASPECT_CHOICES = (
        ('S', 'Superior'),
        ('L', 'Lateral')
        )
    aspect = models.CharField(max_length=1, choices=ASPECT_CHOICES)
    
    specimen = models.ForeignKey('Specimen', related_name='images')

    # image and derivative files
    image_full = models.FileField(upload_to='images/full')
    image_medium = models.FileField(upload_to='images/medium', null=True)
    image_thumbnail = models.FileField(upload_to='images/thumbnail', null=True)

    def generate_derivatives(self, tmpdir=None, regenerate=False):
        #source_image = PILImage.open(self.image_full) 
        tmpdir = tmpdir or tempfile.mkdtemp()
        
        derivatives = [
            ('image_thumbnail', 
             ['-define', 'jpeg:size=300x300', 
              '-thumbnail', '90x90>']),
            ('image_medium', ['-resize', '1024x1024>'])
            ]

        for attr, args in derivatives:
            derivative = getattr(self, attr)
            if (not derivative) or regenerate:
                # write updated image to temp file
                fd, resized_tmp = tempfile.mkstemp(suffix='.png', dir=tmpdir)
                os.close(fd)

                _imagemagick_convert(self.image_full, resized_tmp, args)

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
