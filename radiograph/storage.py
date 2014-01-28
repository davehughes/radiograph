import hashlib
import logging
import mimetypes
import os
import types
import urllib
from urlparse import urlsplit, urlunsplit, unquote

from django.conf import settings
from django.contrib.staticfiles.storage import (CachedFilesMixin,
    matches_patterns, ContentFile, smart_str)
from django.core.exceptions import SuspiciousOperation, ImproperlyConfigured
from django.db import models
from django.utils.encoding import force_unicode
from storages.backends import s3boto

LOG = logging.getLogger(__name__)

try:
    from boto.s3.key import Key
except ImportError:
    raise ImproperlyConfigured("Could not load Boto's S3 bindings.\n"
                               "See https://github.com/boto/boto")


class StorageOperationNotSupported(Exception):
    pass


class DjangoSettingsDict(object):
    '''
    Basic dict wrapper for django.conf.settings that supports a limited
    interface for performing lookups.
    '''
    def get(self, item, default=None):
        if item in self:
            return self[item]
        return default

    def __contains__(self, item):
        try:
            self[item]
        except:
            return False
        else:
            return True

    def __getitem__(self, item):
        try:
            return getattr(settings, item)
        except AttributeError as e:
            raise KeyError(unicode(e))


class S3BotoStorageConfig(object):
    '''
    Custom configuration:
      + In settings.STORAGES with a custom key name
    Default configuration
      + In settings.STORAGES['default']
      + Enabled by default, controlled by `use_default_config` constructor param
    Settings root configuration
      + Available through properties directly on settings object
        (e.g. settings.AWS_S3_ACCESS_KEY_ID)
    Environment variables:
      + Enabled by default, controlled by `use_environment` constructor param
    '''

    read_config = {
        'access_key':           (['AWS_S3_ACCESS_KEY_ID', 'AWS_ACCESS_KEY_ID'],),
        'secret_key':           (['AWS_S3_SECRET_ACCESS_KEY', 'AWS_SECRET_ACCESS_KEY'],),
        'file_overwrite':       ('AWS_S3_FILE_OVERWRITE', True),
        'headers':              ('AWS_HEADERS', {}),
        'bucket_name':          ('AWS_STORAGE_BUCKET_NAME',),
        'auto_create_bucket':   ('AWS_AUTO_CREATE_BUCKET', False),
        'default_acl':          ('AWS_DEFAULT_ACL', 'public-read'),
        'bucket_acl':           (['AWS_BUCKET_ACL', 'AWS_DEFAULT_ACL'],  'public-read'),
        'querystring_auth':     ('AWS_QUERYSTRING_AUTH', True),
        'querystring_expire':   ('AWS_QUERYSTRING_EXPIRE', 3600),
        'reduced_redundancy':   ('AWS_REDUCED_REDUNDANCY', False),
        'location':             ('AWS_LOCATION', ''),
        'encryption':           ('AWS_S3_ENCRYPTION', False),
        'custom_domain':        ('AWS_S3_CUSTOM_DOMAIN',),
        'calling_format':       ('AWS_S3_CALLING_FORMAT', s3boto.SubdomainCallingFormat()),
        'secure_urls':          ('AWS_S3_SECURE_URLS', True),
        'file_name_charset':    ('AWS_S3_FILE_NAME_CHARSET', 'utf-8'),
        'gzip':                 ('AWS_IS_GZIPPED', False),
        'preload_metadata':     ('AWS_PRELOAD_METADATA', False),
        'gzip_content_types':   ('GZIP_CONTENT_TYPES', (
                                    'text/css',
                                    'application/javascript',
                                    'application/x-javascript',
                                )),
        'url_protocol':         ('AWS_S3_URL_PROTOCOL', 'http:'),
        }

    def __init__(self, name=None, use_environment=True, use_default_config=True):
        self.name = name
        self.use_environment = use_environment
        self.use_default_config = use_default_config

        self.config_contexts = [
            getattr(settings, 'STORAGES', {}).get(name, {}),
            getattr(settings, 'STORAGES', {}).get('default', {}) if use_default_config else {},
            DjangoSettingsDict(),
            os.environ if use_environment else {},
            ]
        self.config_contexts = [c for c in self.config_contexts if c]

    def read_settings(self):
        return {attr: self.read_setting(*args)
                for attr, args in self.read_config.iteritems()}

    def read_setting(self, keys, default=None):
        if type(keys) != list:
            keys = [keys]

        for context in self.config_contexts: 
            for key in keys:
                if key in context:
                    return context[key]
        return default


class S3BotoMulticonfigStorage(s3boto.S3BotoStorage):
    """
    S3 Storage class that enables more flexible storage configuration by
    reading its settings using an S3BotoStorageConfig object.  Settings passed
    into the constructor take precedence.
    """
    def __init__(self, config=None, **override_settings):
        config = config or getattr(self, 'using_storage', None)
        if type(config) in types.StringTypes:
            config = S3BotoStorageConfig(name=config)
        config = config or S3BotoStorageConfig()
        self.config = config

        settings = config.read_settings()
        settings.update(override_settings)

        # Implement our own property assignment, since the class we're
        # inheriting from didn't plan on being extended ...
        for name, value in settings.iteritems():
            if name in S3BotoStorageConfig.read_config:
                setattr(self, name, value)

        super(S3BotoMulticonfigStorage, self).__init__()


class FastS3CachedFilesMixin(CachedFilesMixin):
    '''
    Improved version of Django's CachedFilesMixin with a few key changes:
    + Updates CSS replacement patterns to skip conversion of empty 'url()'
      inclusions
    + Decodes file content as UTF-8, fixing some character handling issues
    + Detects changes to post-processed files and doesn't upload them if they
      haven't changed, saving significant time uploading to S3.
    '''

    patterns = (
        ("*.css", (
            u"""(url\(['"]{0,1}\s*(.+?)["']{0,1}\))""",
            u"""(@import\s*["']\s*(.*?)["'])""",
        )),
    )
    
    def post_process(self, paths, dry_run=False, **options):
        """
        Post process the given list of files (called from collectstatic).

        Processing is actually two separate operations:

        1. renaming files to include a hash of their content for cache-busting,
           and copying those files to the target storage.
        2. adjusting files which contain references to other files so they
           refer to the cache-busting filenames.

        If either of these are performed on a file, then that file is considered
        post-processed.
        """
        # don't even dare to process the files if we're in dry run mode
        if dry_run:
            return

        # where to store the new paths
        hashed_paths = {}

        # build a list of adjustable files
        matches = lambda path: matches_patterns(path, self._patterns.keys())
        adjustable_paths = [path for path in paths if matches(path)]

        # then sort the files by the directory level
        path_level = lambda name: len(name.split(os.sep))
        for name in sorted(paths.keys(), key=path_level, reverse=True):

            # use the original, local file, not the copied-but-unprocessed
            # file, which might be somewhere far away, like S3
            storage, path = paths[name]
            with storage.open(path) as original_file:

                # generate the hash with the original content, even for
                # adjustable files.
                hashed_name = self.hashed_name(name, original_file)

                # then get the original's file content..
                if hasattr(original_file, 'seek'):
                    original_file.seek(0)

                hashed_file_exists = self.exists(hashed_name)
                processed = False

                # ..to apply each replacement pattern to the content
                if name in adjustable_paths:
                    content = original_file.read().decode('utf-8')
                    converter = self.url_converter(name)
                    for patterns in self._patterns.values():
                        for pattern in patterns:
                            content = pattern.sub(converter, content)
                    if hashed_file_exists:
                        self.delete(hashed_name)

                    # Build cache key from (filepath, md5) -> saved_name
                    md5sum = hashlib.md5(content.encode('utf-8')).hexdigest()[:12]
                    cache_key = 'staticfiles:post_process:{}:{}'.format(path, md5sum)
                    cached = self.cache.get(cache_key)
                    if cached:
                        saved_name = cached
                    else:
                        content_file = ContentFile(smart_str(content))
                        saved_name = self._save(hashed_name, content_file)
                        self.cache.set(cache_key, saved_name)

                    hashed_name = force_unicode(saved_name.replace('\\', '/'))
                    processed = True
                else:
                    # or handle the case in which neither processing nor
                    # a change to the original file happened
                    if not hashed_file_exists:
                        processed = True
                        saved_name = self._save(hashed_name, original_file)
                        hashed_name = force_unicode(saved_name.replace('\\', '/'))

                # and then set the cache accordingly
                hashed_paths[self.cache_key(name)] = hashed_name
                yield name, hashed_name, processed

        # Finally set the cache
        self.cache.set_many(hashed_paths)


class S3MediaStorage(FastS3CachedFilesMixin, S3BotoMulticonfigStorage):
    using_storage = 'media'
