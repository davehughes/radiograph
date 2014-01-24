import csv
from decimal import Decimal
import json

from django.conf import settings
from django.db import transaction
import pysolr
from radiograph import models

SPECIMENS_CSV = 'data/linear-measurements.csv'
IMAGES_JSON = 'data/specimen-images.json'


def load_data():
    specimens = ingest_specimen_objects(SPECIMENS_CSV)    
    images = ingest_images(IMAGES_JSON)


@transaction.commit_on_success
def ingest_specimen_objects(input_file):
    objs = load_specimen_objects(input_file)
    specimens = []
    for obj in objs:
        taxon = ensure_taxon_leaf(**obj)
        specimen, created = models.Specimen.objects.get_or_create(
            specimen_id=obj['specimen_id'],
            defaults=dict(
                taxon               = taxon,
                sex                 = obj['sex'],
                facial_height       = obj['facial_height'],
                skull_length        = obj['skull_length'],
                cranial_width       = obj['cranial_width'],
                neurocranial_height = obj['neurocranial_height'],
                palate_length       = obj['palate_length'],
                palate_width        = obj['palate_width'],
                comments            = obj['comments'],
            ))
        if not created:
            print 'Duplicate specimen ID: {}'.format(obj['specimen_id'])
        else:
            specimens.append(specimen)
    return specimens


def load_specimen_objects(input_file):
    with open(input_file, 'r') as f:
        reader = csv.reader(f)
        header = reader.next()
        return [load_specimen_object(row) for row in reader]


def load_specimen_object(row):
    cols = [
        'specimen_id',
        'species', 
        'subspecies',
        'sex',
        'skull_length',
        'cranial_width',
        'neurocranial_height',
        'facial_height',
        'palate_length',
        'palate_width',
        'comments'
        ]

    # read row into dict
    obj = {col: value for col, value in zip(cols, row)}

    # convert decimal fields
    for k in [
        'skull_length',
        'cranial_width',
        'neurocranial_height',
        'facial_height',
        'palate_length',
        'palate_width'
        ]:
        val = obj[k]
        if val.endswith('*'):
            val = val[:-1]
        if not val:
            obj[k] = None
        else:
            obj[k] = Decimal(val)

    # convert sex
    if not obj.get('sex') in dict(models.Specimen.SexChoices.choices):
        obj['sex'] = 'U' # unknown

    # identify taxon
    obj['genus'], _, obj['species'] = obj['species'].partition(' ')
    obj['subspecies'] = obj['subspecies'] or None
    return obj


def ingest_images(input_file=None):
    img_structs = json.load(open(input_file))
    images = []

    for img in img_structs:
        sid = '{} {}'.format(img['institution'].upper(), img['specimen_id'])
        sid = ID_MATCH_MAP.get(sid, sid)
        try:
            specimen = models.Specimen.objects.get(specimen_id=sid)
        except models.Specimen.DoesNotExist:
            print "Couldn't match id: {}".format(sid)
            taxon = ensure_taxon_leaf(*img['taxon'].split())
            specimen, created = models.Specimen.objects.get_or_create(
                specimen_id=sid,
                defaults=dict(
                    taxon=taxon,
                    sex=None
                ))

        aspect = {
            'lateral': models.Image.AspectChoices.Lateral,
            'superior': models.Image.AspectChoices.Superior,
            }.get(img['aspect'])

        image, created = (models.Image.objects.get_or_create(
            original_path=img['src'],
            defaults=dict(
                aspect=aspect,
                md5=img['md5'],
                specimen=specimen,
            )))
        if created:
            images.append(image)

    return images


def ensure_taxon_leaf(genus=None, species=None, subspecies=None, **kwargs):
    taxon_leaf = None
    levels = [
        (models.TaxonomyLevels.Genus, genus),
        (models.TaxonomyLevels.Species, species),
        (models.TaxonomyLevels.Subspecies, subspecies),
        ]

    for level, name in levels:
        if not name:
            break

        taxon_leaf, created = models.Taxon.objects.get_or_create(
            parent=taxon_leaf,
            level=level,
            name=name,
            )
    
    return taxon_leaf

# Image -> Specimen data ID fixes, based on manual reconciliation
ID_MATCH_MAP = {
    'USNM 154533': 'USNM 154553',
    'USNM 290572': '290572',
    'USNM 2336280': 'USNM 336280',
}
