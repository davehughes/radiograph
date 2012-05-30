import csv
from decimal import Decimal

from django.conf import settings
import pysolr
from radioapp import models

INPUT_FILE = 'linear-measurements.csv'

def load_file_objects(input_file=None):
    input_file = input_file or INPUT_FILE
    with open(input_file, 'r') as f:
        reader = csv.reader(f)
        header = reader.next()
        return [load_row_object(row) for row in reader]

def load_row_object(row):
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
        obj[k] = Decimal(val)

    # convert sex
    if not obj.get('sex') in dict(models.Specimen.SEX_CHOICES):
        obj['sex'] = 'U' # unknown

    # set institution
    #obj['institution'] = 0

    # identify taxon
    taxon_label = obj['species']
    if len(obj['subspecies']) > 0:
        taxon_label += ' %s' % obj['subspecies']
    try:
        obj['taxon'] = identify_taxon(taxon_label)
    except Exception as e:
        print e
    del obj['species']
    del obj['subspecies']

    return obj

def identify_taxon(taxon_label):
    solr = pysolr.Solr(settings.HAYSTACK_SOLR_URL)
    results = solr.search(q='django_ct:radioapp.taxon AND label_sort:"%s"' % taxon_label)
    if results.hits != 1:
        raise Exception('Unexpected number of matches for taxon %s: %s' % (taxon_label, results.hits))

    return results.docs[0]['django_id']
