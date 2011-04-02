import csv
import glob
import itertools
import os
import re

from django.core.files.uploadedfile import UploadedFile
from radioapp import models

import magic

MIME = magic.Magic(mime=True)

def load_django_models(image_dir_path, csv_path):

    for record in load_image_records(csv_path):
        models.Specimen.objects.create(species = record['species'],
                                       subspecies = record.get('subspecies'),
                                       specimen_id = record.get('specimen_id'),
                                       sex = record.get('sex'),
                                       settings = record.get('settings'),
                                       comments = record.get('comments'))
    
    record_mismatches = {}
    duplicate_ids = {}
    for image_info in load_image_info(image_dir_path):
        try:
            specimen_id = image_info.get('specimen_id')
            if not specimen_id:
                print "No specimen id for image: %s" % image_info
                continue
            specimen = models.Specimen.objects.get(specimen_id=specimen_id)
        except models.Specimen.DoesNotExist:
            record_mismatches.setdefault(image_info['specimen_id'], [])\
                .append(image_info)
            print 'Specimen does not exist: %s' % image_info['specimen_id']
            print '%s' % image_info
            continue
        except models.Specimen.MultipleObjectsReturned:
            duplicate_ids.setdefault(image_info['specimen_id'], [])\
                .append(image_info)
            print 'Multiple specimens for id: %s' % image_info['specimen_id']
            print '%s' % image_info            
            continue

        image = models.Image.objects.create(specimen=specimen,
                                            aspect=image_info['aspect'][0].upper())
        image.image_full = image_info['file']
        image.save()

    for key, vals in record_mismatches.items():
        print 'ID: %s' % key
        print 'Files: %s\n' % [x['file'].name for x in vals]

    for key, vals in duplicate_ids.items():
        print 'ID: %s'
        

def load_image_info(path='.', levels=10):
    # glob for .tifs up to @levels directories deep from @path
    patterns = itertools.chain(('%s/%s*.tif' % (path, '*/' * x) 
                                for x in range(0, levels)))
    filepaths = itertools.chain(*(glob.iglob(p) for p in patterns))
    return (_load_image_info(f) for f in filepaths)

FILENAME_PATTERN = '(?P<species_code>[A-Z][a-z]+)' + \
    '(?P<specimen_id>.+)' + \
    '(?P<aspect>(S|s|L|l))' + \
    '\.(?P<format>tif)'
FILENAME_PATTERN = re.compile(FILENAME_PATTERN)

def _load_image_info(image_path):
    filename = os.path.basename(image_path)
    filepath = os.path.abspath(image_path)
    m = FILENAME_PATTERN.match(filename)
    if not m:
        error = 'Pattern mismatch: %s' % filepath
        return {'filename': filename, 'path': filepath, 'error': error}
    
    aspect = 'superior' if m.group('aspect').lower() == 's' else 'lateral'
    file_ = UploadedFile(file=open(filepath, 'rb'),
                         name=filename,
                         content_type=MIME.from_file(filepath),
                         size=os.path.getsize(filepath))
    return {
        'species_code': m.group('species_code'),
        'specimen_id': m.group('specimen_id'),
        'aspect': aspect,
        'file': file_
        }

def load_image_records(filepath):
    reader = csv.reader(open(filepath, 'r'))
    
    # read headings from first row
    headings = reader.next()
    headings = ['species', 'subspecies', 'specimen_id', 'sex', 'settings', 'comments']

    # read remaining rows and make data dicts out of them
    return (dict(zip(headings, row)) for row in reader)
