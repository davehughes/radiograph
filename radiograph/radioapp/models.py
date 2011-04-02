import os
from PIL import Image as PILImage
import tempfile

from django.core.files import File as DjangoFile
from django.db import models

# Create your models here.
class Specimen(models.Model):
    SEX_CHOICES = (
        ('M', 'Male'),
        ('F', 'Female')
        )

    specimen_id = models.CharField(max_length=255, null=True)
    species = models.CharField(max_length=255)
    subspecies = models.CharField(max_length=255, null=True)
    sex = models.CharField(max_length=1, choices=SEX_CHOICES, null=True)
    settings = models.TextField(null=True)
    comments = models.TextField(null=True)

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

    file = models.FileField(upload_to='images/full')
    image_medium = models.FileField(upload_to='images/medium', null=True)
    image_thumbnail = models.FileField(upload_to='images/thumbnail', null=True)

    def generate_derivatives(self, tmpdir=None, regenerate=False):
        source_image = PILImage.open(self.file) 
        tmpdir = tmpdir or tempfile.mkdtemp()
        
        derivatives = [
            ('image_thumbnail', (80, 80)),
            ('image_medium', (800, 600))
            ]

        for attr, size in derivatives:
            derivative_attr = getattr(self, attr)
            if (not derivative_attr) or regenerate:
                # write updated image to temp file
                resized = source_image.resize(size, PILImage.ANTIALIAS)
                _, resized_tmp = tempfile.mkstemp(suffix='.png', dir=tmpdir)
                resized.save(open(resized_tmp, 'wb'))

                # clean up existing image
                if derivative_attr:
                    path = derivative_attr.path
                    derivative_attr.delete()
                    if os.path.isfile(path):
                        os.remove(path)

                # set new image and save
                setattr(self, attr, DjangoFile(open(resized_tmp, 'r'), 
                                               '%s.png' % self.id))
                self.save()

                # finally, clean up the temporary image
                if os.path.isfile(resized_tmp):
                    os.remove(resized_tmp)

    
    

    
