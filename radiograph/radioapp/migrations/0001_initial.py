# encoding: utf-8
import datetime
from south.db import db
from south.v2 import SchemaMigration
from django.db import models

class Migration(SchemaMigration):

    def forwards(self, orm):
        
        # Adding model 'Specimen'
        db.create_table('radioapp_specimen', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('specimen_id', self.gf('django.db.models.fields.CharField')(max_length=255, null=True)),
            ('species', self.gf('django.db.models.fields.CharField')(max_length=255)),
            ('subspecies', self.gf('django.db.models.fields.CharField')(max_length=255, null=True)),
            ('sex', self.gf('django.db.models.fields.CharField')(max_length=1, null=True)),
            ('settings', self.gf('django.db.models.fields.TextField')(null=True)),
            ('comments', self.gf('django.db.models.fields.TextField')(null=True)),
        ))
        db.send_create_signal('radioapp', ['Specimen'])

        # Adding model 'Image'
        db.create_table('radioapp_image', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('aspect', self.gf('django.db.models.fields.CharField')(max_length=1)),
            ('specimen', self.gf('django.db.models.fields.related.ForeignKey')(related_name='images', to=orm['radioapp.Specimen'])),
            ('image_full', self.gf('django.db.models.fields.files.FileField')(max_length=100)),
            ('image_medium', self.gf('django.db.models.fields.files.FileField')(max_length=100, null=True)),
            ('image_thumbnail', self.gf('django.db.models.fields.files.FileField')(max_length=100, null=True)),
        ))
        db.send_create_signal('radioapp', ['Image'])


    def backwards(self, orm):
        
        # Deleting model 'Specimen'
        db.delete_table('radioapp_specimen')

        # Deleting model 'Image'
        db.delete_table('radioapp_image')


    models = {
        'radioapp.image': {
            'Meta': {'object_name': 'Image'},
            'aspect': ('django.db.models.fields.CharField', [], {'max_length': '1'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'image_full': ('django.db.models.fields.files.FileField', [], {'max_length': '100'}),
            'image_medium': ('django.db.models.fields.files.FileField', [], {'max_length': '100', 'null': 'True'}),
            'image_thumbnail': ('django.db.models.fields.files.FileField', [], {'max_length': '100', 'null': 'True'}),
            'specimen': ('django.db.models.fields.related.ForeignKey', [], {'related_name': "'images'", 'to': "orm['radioapp.Specimen']"})
        },
        'radioapp.specimen': {
            'Meta': {'object_name': 'Specimen'},
            'comments': ('django.db.models.fields.TextField', [], {'null': 'True'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'settings': ('django.db.models.fields.TextField', [], {'null': 'True'}),
            'sex': ('django.db.models.fields.CharField', [], {'max_length': '1', 'null': 'True'}),
            'species': ('django.db.models.fields.CharField', [], {'max_length': '255'}),
            'specimen_id': ('django.db.models.fields.CharField', [], {'max_length': '255', 'null': 'True'}),
            'subspecies': ('django.db.models.fields.CharField', [], {'max_length': '255', 'null': 'True'})
        }
    }

    complete_apps = ['radioapp']
