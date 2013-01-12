import os
import re
from radiograph.models import *

IMAGES_ROOT = '/home/dave/dropbox/terry/Dropbox/Dissertation data backup/x-rays'


def load_image_records():
    recs = []

    standard_pattern = re.compile(r'(?P<specimen_id>usnm_[^_]+)_.*_(?P<aspect>lateral|superior).*')

    for dir, _, filenames in os.walk(IMAGES_ROOT):
        for filename in filenames:
            rec = {
                'directory': dir,
                'filename': filename,
            }

            # Look for pieces to add to record
            m = standard_pattern.match(filename)
            if m:
                rec['aspect'] = m.group('aspect')
                rec['specimen_id'] = 'USNM {0}'.format(m.group('specimen_id')[5:])

            recs.append(rec)

    return recs


def get_nonstandard_named_images():
    images = load_image_records()
    return [x for x in images if 'specimen_id' not in x]

def get_images_missing_specimens():
    images = load_image_records()

    ids = list(set(x['specimen_id'] for x in images if 'specimen_id' in x))
    existing_ids = Specimen.objects.values_list('specimen_id', flat=True)

    missing_ids = set(ids) - set(existing_ids)
    return [x for x in images if x.get('specimen_id') in missing_ids]
