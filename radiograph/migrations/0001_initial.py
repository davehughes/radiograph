# encoding: utf-8
import datetime
from south.db import db
from south.v2 import SchemaMigration
from django.db import models

class Migration(SchemaMigration):

    def forwards(self, orm):
        
        # Adding model 'Taxon'
        db.create_table('radiograph_taxon', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('parent', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['radiograph.Taxon'], null=True)),
            ('level', self.gf('django.db.models.fields.IntegerField')()),
            ('name', self.gf('django.db.models.fields.CharField')(max_length=255, null=True)),
            ('common_name', self.gf('django.db.models.fields.CharField')(max_length=255, null=True)),
            ('description', self.gf('django.db.models.fields.TextField')(null=True)),
        ))
        db.send_create_signal('radiograph', ['Taxon'])

        # Adding model 'Institution'
        db.create_table('radiograph_institution', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('name', self.gf('django.db.models.fields.CharField')(max_length=255)),
            ('link', self.gf('django.db.models.fields.CharField')(max_length=255, null=True)),
            ('logo', self.gf('django.db.models.fields.files.FileField')(max_length=100, null=True)),
        ))
        db.send_create_signal('radiograph', ['Institution'])

        # Adding model 'Specimen'
        db.create_table('radiograph_specimen', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('specimen_id', self.gf('django.db.models.fields.CharField')(max_length=255, null=True)),
            ('taxon', self.gf('django.db.models.fields.related.ForeignKey')(related_name='specimens', to=orm['radiograph.Taxon'])),
            ('institution', self.gf('django.db.models.fields.related.ForeignKey')(related_name='specimens', to=orm['radiograph.Institution'])),
            ('sex', self.gf('django.db.models.fields.CharField')(max_length=10, null=True)),
            ('settings', self.gf('django.db.models.fields.TextField')(null=True)),
            ('comments', self.gf('django.db.models.fields.TextField')(null=True)),
            ('created', self.gf('django.db.models.fields.DateField')(auto_now_add=True, blank=True)),
            ('last_modified', self.gf('django.db.models.fields.DateField')(auto_now=True, blank=True)),
        ))
        db.send_create_signal('radiograph', ['Specimen'])

        # Adding model 'Image'
        db.create_table('radiograph_image', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('aspect', self.gf('django.db.models.fields.CharField')(max_length=1)),
            ('specimen', self.gf('django.db.models.fields.related.ForeignKey')(related_name='images', to=orm['radiograph.Specimen'])),
            ('image_full', self.gf('django.db.models.fields.files.FileField')(max_length=100)),
            ('image_medium', self.gf('django.db.models.fields.files.FileField')(max_length=100, null=True, blank=True)),
            ('image_thumbnail', self.gf('django.db.models.fields.files.FileField')(max_length=100, null=True, blank=True)),
        ))
        db.send_create_signal('radiograph', ['Image'])


    def backwards(self, orm):
        
        # Deleting model 'Taxon'
        db.delete_table('radiograph_taxon')

        # Deleting model 'Institution'
        db.delete_table('radiograph_institution')

        # Deleting model 'Specimen'
        db.delete_table('radiograph_specimen')

        # Deleting model 'Image'
        db.delete_table('radiograph_image')


    models = {
        'radiograph.image': {
            'Meta': {'object_name': 'Image'},
            'aspect': ('django.db.models.fields.CharField', [], {'max_length': '1'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'image_full': ('django.db.models.fields.files.FileField', [], {'max_length': '100'}),
            'image_medium': ('django.db.models.fields.files.FileField', [], {'max_length': '100', 'null': 'True', 'blank': 'True'}),
            'image_thumbnail': ('django.db.models.fields.files.FileField', [], {'max_length': '100', 'null': 'True', 'blank': 'True'}),
            'specimen': ('django.db.models.fields.related.ForeignKey', [], {'related_name': "'images'", 'to': "orm['radiograph.Specimen']"})
        },
        'radiograph.institution': {
            'Meta': {'object_name': 'Institution'},
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'link': ('django.db.models.fields.CharField', [], {'max_length': '255', 'null': 'True'}),
            'logo': ('django.db.models.fields.files.FileField', [], {'max_length': '100', 'null': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '255'})
        },
        'radiograph.specimen': {
            'Meta': {'object_name': 'Specimen'},
            'comments': ('django.db.models.fields.TextField', [], {'null': 'True'}),
            'created': ('django.db.models.fields.DateField', [], {'auto_now_add': 'True', 'blank': 'True'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'institution': ('django.db.models.fields.related.ForeignKey', [], {'related_name': "'specimens'", 'to': "orm['radiograph.Institution']"}),
            'last_modified': ('django.db.models.fields.DateField', [], {'auto_now': 'True', 'blank': 'True'}),
            'settings': ('django.db.models.fields.TextField', [], {'null': 'True'}),
            'sex': ('django.db.models.fields.CharField', [], {'max_length': '10', 'null': 'True'}),
            'specimen_id': ('django.db.models.fields.CharField', [], {'max_length': '255', 'null': 'True'}),
            'taxon': ('django.db.models.fields.related.ForeignKey', [], {'related_name': "'specimens'", 'to': "orm['radiograph.Taxon']"})
        },
        'radiograph.taxon': {
            'Meta': {'object_name': 'Taxon'},
            'common_name': ('django.db.models.fields.CharField', [], {'max_length': '255', 'null': 'True'}),
            'description': ('django.db.models.fields.TextField', [], {'null': 'True'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'level': ('django.db.models.fields.IntegerField', [], {}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '255', 'null': 'True'}),
            'parent': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['radiograph.Taxon']", 'null': 'True'})
        }
    }

    complete_apps = ['radiograph']
