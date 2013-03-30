import os
import re
from radiograph.models import *

IMAGES_ROOT = '/home/dave/dropbox/terry/Dropbox/Dissertation data backup/x-rays'
IMAGES_TARGET_ROOT = 'specimens'


def load_image_records():
    recs = []

    standard_pattern = re.compile(r'(?P<specimen_id>usnm_[^_]+)_.*_(?P<aspect>lateral|superior).*')

    for dir, _, filenames in os.walk(IMAGES_ROOT):
        for filename in filenames:
            rec = {
                # 'directory': dir,
                # 'filename': filename,
                'path': os.path.join(dir, filename).replace(IMAGES_ROOT, IMAGES_TARGET_ROOT),
            }

            # rec['genus'], rec['species'] = os.path.basename(dir).split(' ')
            rec['taxon'] = Taxon.objects.find_species(*os.path.basename(dir).split(' '))

            # Look for pieces to add to record
            m = standard_pattern.match(filename)
            if m:
                # rec['aspect'] = m.group('aspect')
                if m.group('aspect') == 'lateral':
                    rec['aspect'] = Image.AspectChoices.Lateral
                elif m.group('aspect') == 'superior':
                    rec['aspect'] = Image.AspectChoices.Superior
                else:
                    raise Exception('This should never happen')

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

def load_images_to_db():
    recs = load_image_records()
    for rec in recs:
        if 'specimen_id' not in rec:
            continue
        specimen = Specimen.objects.filter(specimen_id=rec['specimen_id'])[0]
        if specimen.images.filter(aspect=rec['aspect']).count() > 0:
            # raise Exception('An image with that aspect already exists')
            print 'Skipping specimen image with existing aspect'
            
        image = Image(aspect=rec['aspect'], specimen=specimen)
        image.image_full.name = rec['path']
        image.save()
