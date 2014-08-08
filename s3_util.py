import os
import zipfile
from django.conf import settings
from boto import connect_s3
from radiograph.models import *


ROOT = '/Users/dave/Downloads/radiograph-x-rays-original'
conn = connect_s3(settings.AWS_ACCESS_KEY_ID, settings.AWS_SECRET_ACCESS_KEY)
bucket = conn.get_bucket(settings.AWS_STORAGE_BUCKET_NAME)


def get_keys():
    return bucket.list(prefix=settings.AWS_LOCATION)


def get_local_path_for_key(key):
    rel = '/'.join(key.name.split('/')[2:])
    return os.path.abspath(os.path.join(ROOT, rel))


def download_key(key):
    path = get_local_path_for_key(key)
    if os.path.isfile(path):
        print 'Path {} already exists, skipping...'.format(path)
    path_dir = os.path.dirname(path)
    try:
        os.makedirs(path_dir)
    except OSError as e:
        pass

    print 'Retrieving key: {}'.format(key.name)
    return key.get_contents_to_filename(path)


def download_all():
    for key in get_keys():
        download_key(key)


def get_joined_name_from_path(path):
    '''
    Convert from .../{taxon}/{specimen-id}/{aspect}/image.png to 
    {taxon}_{specimen_id}_{aspect}.png
    '''
    path_dir = os.path.dirname(path)
    taxon, specimen_id, aspect = path_dir.split('/')[-3:]
    return 'images/{}-{}-{}.png'.format(taxon, specimen_id, aspect)


def generate_medium_zip(output_path='radiograph-medium.zip'):
    return generate_image_zip(output_path=output_path, target_image_name='medium.png')


def generate_full_zip(output_path='radiograph-full.zip'):
    return generate_image_zip(output_path=output_path, target_image_name='full.png')


def generate_image_zip(output_path='radiograph-full.zip', target_image_name='full.png'):
    mappings = generate_file_mappings(target_image_name, get_joined_name_from_path)
    with zipfile.ZipFile(output_path, 'w', allowZip64=True) as z:
        for path, target in mappings:
            z.write(path, target)
    return output_path


def generate_file_mappings(target_filename, map_func):
    for dirname, dirpaths, filepaths in os.walk(ROOT):
        targets = [f for f in filepaths if f == target_filename]
        for target in targets:
            path = os.path.join(dirname, target)
            yield path, map_func(path)
