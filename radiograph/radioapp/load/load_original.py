import csv
import glob
import itertools
import mimetypes
import os
import re

from django.core.files.uploadedfile import UploadedFile
from radioapp import models

def load_django_models(image_dir_path, csv_path, institution):

    # assumes that taxa are already loaded
    for record in load_image_records(csv_path):
        taxon_labels = record['species'].split(' ')
        if record.get('subspecies'):
            taxon_labels.append(record['subspecies'])

        comments = [record.get('comments')]

        parent = None
        level = models.GENUS # start here
        for level_offset, taxon_label in enumerate(taxon_labels):
            taxa = models.Taxon.objects.filter(level=(level + level_offset))
            if parent:
                taxa = taxa.filter(parent=parent)
            try:
                parent = taxon = taxa.get(name__iexact=taxon_label)
            except models.Taxon.DoesNotExist:
                if level_offset == 2:
                    comments.append('Original classification: %s' %
                                     ' '.join(taxon_labels))
                else:
                    import ipdb; ipdb.set_trace();
        
        comments = '\n\n'.join(c.strip() for c in comments if len(c.strip()) > 0)
        models.Specimen.objects.create(taxon=taxon,
                                       institution=institution,
                                       specimen_id = record.get('specimen_id'),
                                       sex = record.get('sex'),
                                       settings = record.get('settings'),
                                       comments = comments)
    
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

        #image.generate_derivatives()

    for key, vals in record_mismatches.items():
        print 'ID: %s' % key
        print 'Files: %s\n' % [x['file'].name for x in vals]

    for key, vals in duplicate_ids.items():
        print 'ID: %s' % key

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
    mime, encoding = mimetypes.guess_type(filepath)
    file_ = UploadedFile(file=open(filepath, 'rb'),
                         name=filename,
                         content_type=mime,
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
