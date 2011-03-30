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

class Image(models.Model):
    ASPECT_CHOICES = (
        ('S', 'Superior'),
        ('L', 'Lateral')
        )
    aspect = models.CharField(max_length=1, choices=ASPECT_CHOICES)
    file = models.FileField(upload_to='images')
    specimen = models.ForeignKey('Specimen', related_name='images')
    
