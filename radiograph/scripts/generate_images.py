import hashlib
import os
import re
import subprocess

LOCAL_IMAGES_SRC = '/Users/dave/projects/radiograph/x-rays'
LOCAL_IMAGES_DEST = '/Users/dave/projects/radiograph/x-rays-converted'
S3_IMAGES_LOCATION = 'images'
FILENAME_PATTERN = re.compile('^(usnm_([^_]+))_.*_(lateral|superior).tif$')

def crawl_images():
    images = []
    for dirpath, dirnames, filenames in os.walk(LOCAL_IMAGES_SRC):
        for filename in filenames:
            src = os.path.join(dirpath, filename)
            m = FILENAME_PATTERN.match(os.path.basename(src))
            if not m:
                print 'File didn\'t match pattern: {}'.format(src)
                continue
             
            relpath = os.path.relpath(src, LOCAL_IMAGES_SRC)
            aspect = m.group(3)
            filename_base = m.group(1)
            specimen_id = m.group(2)
            taxon = os.path.basename(dirpath)
            dest = os.path.join(
                LOCAL_IMAGES_DEST,
                os.path.dirname(relpath),
                filename_base,
                aspect,
                )
            images.append({
                'src': src,
                'dest': dest,
                'institution': 'usnm',
                'specimen_id': specimen_id,
                'aspect': aspect,
                'taxon': taxon,
                })
    return images


def ensure_directory(path):
    try:
        os.makedirs(path)
    except OSError as e:
        if e.errno == 17:
            return
        raise

def process_images():
    imgs = crawl_images()
    for img in imgs:
        ensure_directory(img['dest'])
        img.update({
            'full': os.path.join(img['dest'], 'full.png'),
            'medium': os.path.join(img['dest'], 'medium.png'),
            'thumbnail': os.path.join(img['dest'], 'thumbnail.png'),
            })
        cmds = [
            'convert "{}" "{}"'.format(img['src'], img['full']),
            'convert "{}" -resize 800x800 "{}"'.format(img['src'], img['medium']),
            'convert "{}" -resize 150x150 "{}"'.format(img['src'], img['thumbnail']),
            ]
        for cmd in cmds:
            print 'Running command: {}'.format(cmd)
            subprocess.call(cmd, shell=True)
    return imgs


def directory_to_s3(path, s3path):
    '''
    Given a `path` to a local directory and a remote `s3path` in the form
    BUCKET[/PATH], recursively upload the local directory to the remote
    location.
    '''
    from boto import connect_s3
    path = os.path.abspath(path)
    bucket_name, _ , bucket_path = s3path.partition('/')
    conn = connect_s3()  # Assumes that access creds are in the environment
    bucket = conn.get_bucket(bucket_name)
    for dirpath, directories, files in os.walk(path):
        for f in files:
            local_path = os.path.join(dirpath, f)
            remote_path = os.path.join(bucket_path,
                                       os.path.relpath(local_path, path))
            print 'Uploading {} -> {}'.format(local_path, remote_path)
            key = bucket.new_key(remote_path)
            key.set_contents_from_filename(local_path)


def get_file_hashes(path):
    hashers = [hashlib.md5(), hashlib.sha1()]
    with open(path, 'rb') as f:
        huge_content_in_memory = f.read()
        for h in hashers:
            h.update(huge_content_in_memory)

        return {h.name: h.hexdigest() for h in hashers}
