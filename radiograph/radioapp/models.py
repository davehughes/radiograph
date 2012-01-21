import logging
import os
#from PIL import Image as PILImage
import tempfile

from django.core.files import File as DjangoFile
from django.db import models
from django.template.defaultfilters import slugify

def slugify_uniquely(value, model, slugfield):
    suffix = 0
    potential = base = slugify(value)
    while True:
        if suffix:
            potential = "-".join([base, str(suffix)])
        if not model.objects.filter(**{slugfield: potential}).count():
            return potential
        suffix += 1

# Create your models here.
class Specimen(models.Model):
    SEX_CHOICES = (('M', 'Male'), ('F', 'Female'))

    slug = models.SlugField(editable=False, null=True)
    specimen_id = models.CharField(max_length=255, null=True)
    species = models.CharField(max_length=255)
    subspecies = models.CharField(max_length=255, null=True)
    sex = models.CharField(max_length=10, choices=SEX_CHOICES, null=True)
    settings = models.TextField(null=True)
    comments = models.TextField(null=True)

    def __unicode__(self):
        return '%s %s - %s' % (self.species, self.subspecies or '', self.specimen_id)

    def save(self, *args, **kwargs):
        if not self.slug:
            slugbase = '%s %s %s' % (self.species, 
                                     self.subspecies or '', 
                                     self.specimen_id)
            self.slug = slugify_uniquely(slugbase, self.__class__, 'slug')
        return super(Specimen, self).save(*args, **kwargs)

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
