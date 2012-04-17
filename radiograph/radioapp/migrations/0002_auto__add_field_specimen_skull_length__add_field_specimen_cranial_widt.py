# encoding: utf-8
import datetime
from south.db import db
from south.v2 import SchemaMigration
from django.db import models

class Migration(SchemaMigration):

    def forwards(self, orm):
        
        # Adding field 'Specimen.skull_length'
        db.add_column('radioapp_specimen', 'skull_length', self.gf('django.db.models.fields.DecimalField')(null=True, max_digits=10, decimal_places=2), keep_default=False)

        # Adding field 'Specimen.cranial_width'
        db.add_column('radioapp_specimen', 'cranial_width', self.gf('django.db.models.fields.DecimalField')(null=True, max_digits=10, decimal_places=2), keep_default=False)

        # Adding field 'Specimen.neurocranial_height'
        db.add_column('radioapp_specimen', 'neurocranial_height', self.gf('django.db.models.fields.DecimalField')(null=True, max_digits=10, decimal_places=2), keep_default=False)

        # Adding field 'Specimen.facial_height'
        db.add_column('radioapp_specimen', 'facial_height', self.gf('django.db.models.fields.DecimalField')(null=True, max_digits=10, decimal_places=2), keep_default=False)

        # Adding field 'Specimen.palate_length'
        db.add_column('radioapp_specimen', 'palate_length', self.gf('django.db.models.fields.DecimalField')(null=True, max_digits=10, decimal_places=2), keep_default=False)

        # Adding field 'Specimen.palate_width'
        db.add_column('radioapp_specimen', 'palate_width', self.gf('django.db.models.fields.DecimalField')(null=True, max_digits=10, decimal_places=2), keep_default=False)

        # Adding field 'Specimen.created_by'
        db.add_column('radioapp_specimen', 'created_by', self.gf('django.db.models.fields.related.ForeignKey')(related_name='specimens_created', null=True, to=orm['auth.User']), keep_default=False)

        # Adding field 'Specimen.last_modified_by'
        db.add_column('radioapp_specimen', 'last_modified_by', self.gf('django.db.models.fields.related.ForeignKey')(related_name='specimens_last_modified', null=True, to=orm['auth.User']), keep_default=False)


    def backwards(self, orm):
        
        # Deleting field 'Specimen.skull_length'
        db.delete_column('radioapp_specimen', 'skull_length')

        # Deleting field 'Specimen.cranial_width'
        db.delete_column('radioapp_specimen', 'cranial_width')

        # Deleting field 'Specimen.neurocranial_height'
        db.delete_column('radioapp_specimen', 'neurocranial_height')

        # Deleting field 'Specimen.facial_height'
        db.delete_column('radioapp_specimen', 'facial_height')

        # Deleting field 'Specimen.palate_length'
        db.delete_column('radioapp_specimen', 'palate_length')

        # Deleting field 'Specimen.palate_width'
        db.delete_column('radioapp_specimen', 'palate_width')

        # Deleting field 'Specimen.created_by'
        db.delete_column('radioapp_specimen', 'created_by_id')

        # Deleting field 'Specimen.last_modified_by'
        db.delete_column('radioapp_specimen', 'last_modified_by_id')


    models = {
        'auth.group': {
            'Meta': {'object_name': 'Group'},
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '80'}),
            'permissions': ('django.db.models.fields.related.ManyToManyField', [], {'to': "orm['auth.Permission']", 'symmetrical': 'False', 'blank': 'True'})
        },
        'auth.permission': {
            'Meta': {'ordering': "('content_type__app_label', 'content_type__model', 'codename')", 'unique_together': "(('content_type', 'codename'),)", 'object_name': 'Permission'},
            'codename': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'content_type': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['contenttypes.ContentType']"}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '50'})
        },
        'auth.user': {
            'Meta': {'object_name': 'User'},
            'date_joined': ('django.db.models.fields.DateTimeField', [], {'default': 'datetime.datetime.now'}),
            'email': ('django.db.models.fields.EmailField', [], {'max_length': '75', 'blank': 'True'}),
            'first_name': ('django.db.models.fields.CharField', [], {'max_length': '30', 'blank': 'True'}),
            'groups': ('django.db.models.fields.related.ManyToManyField', [], {'to': "orm['auth.Group']", 'symmetrical': 'False', 'blank': 'True'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'is_active': ('django.db.models.fields.BooleanField', [], {'default': 'True'}),
            'is_staff': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            'is_superuser': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            'last_login': ('django.db.models.fields.DateTimeField', [], {'default': 'datetime.datetime.now'}),
            'last_name': ('django.db.models.fields.CharField', [], {'max_length': '30', 'blank': 'True'}),
            'password': ('django.db.models.fields.CharField', [], {'max_length': '128'}),
            'user_permissions': ('django.db.models.fields.related.ManyToManyField', [], {'to': "orm['auth.Permission']", 'symmetrical': 'False', 'blank': 'True'}),
            'username': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '30'})
        },
        'contenttypes.contenttype': {
            'Meta': {'ordering': "('name',)", 'unique_together': "(('app_label', 'model'),)", 'object_name': 'ContentType', 'db_table': "'django_content_type'"},
            'app_label': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'model': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '100'})
        },
        'radioapp.image': {
            'Meta': {'object_name': 'Image'},
            'aspect': ('django.db.models.fields.CharField', [], {'max_length': '1'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'image_full': ('django.db.models.fields.files.FileField', [], {'max_length': '100'}),
            'image_medium': ('django.db.models.fields.files.FileField', [], {'max_length': '100', 'null': 'True', 'blank': 'True'}),
            'image_thumbnail': ('django.db.models.fields.files.FileField', [], {'max_length': '100', 'null': 'True', 'blank': 'True'}),
            'specimen': ('django.db.models.fields.related.ForeignKey', [], {'related_name': "'images'", 'to': "orm['radioapp.Specimen']"})
        },
        'radioapp.institution': {
            'Meta': {'object_name': 'Institution'},
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'link': ('django.db.models.fields.CharField', [], {'max_length': '255', 'null': 'True'}),
            'logo': ('django.db.models.fields.files.FileField', [], {'max_length': '100', 'null': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '255'})
        },
        'radioapp.specimen': {
            'Meta': {'object_name': 'Specimen'},
            'comments': ('django.db.models.fields.TextField', [], {'null': 'True'}),
            'cranial_width': ('django.db.models.fields.DecimalField', [], {'null': 'True', 'max_digits': '10', 'decimal_places': '2'}),
            'created': ('django.db.models.fields.DateField', [], {'auto_now_add': 'True', 'blank': 'True'}),
            'created_by': ('django.db.models.fields.related.ForeignKey', [], {'related_name': "'specimens_created'", 'null': 'True', 'to': "orm['auth.User']"}),
            'facial_height': ('django.db.models.fields.DecimalField', [], {'null': 'True', 'max_digits': '10', 'decimal_places': '2'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'institution': ('django.db.models.fields.related.ForeignKey', [], {'related_name': "'specimens'", 'to': "orm['radioapp.Institution']"}),
            'last_modified': ('django.db.models.fields.DateField', [], {'auto_now': 'True', 'blank': 'True'}),
            'last_modified_by': ('django.db.models.fields.related.ForeignKey', [], {'related_name': "'specimens_last_modified'", 'null': 'True', 'to': "orm['auth.User']"}),
            'neurocranial_height': ('django.db.models.fields.DecimalField', [], {'null': 'True', 'max_digits': '10', 'decimal_places': '2'}),
            'palate_length': ('django.db.models.fields.DecimalField', [], {'null': 'True', 'max_digits': '10', 'decimal_places': '2'}),
            'palate_width': ('django.db.models.fields.DecimalField', [], {'null': 'True', 'max_digits': '10', 'decimal_places': '2'}),
            'settings': ('django.db.models.fields.TextField', [], {'null': 'True'}),
            'sex': ('django.db.models.fields.CharField', [], {'max_length': '10', 'null': 'True'}),
            'skull_length': ('django.db.models.fields.DecimalField', [], {'null': 'True', 'max_digits': '10', 'decimal_places': '2'}),
            'specimen_id': ('django.db.models.fields.CharField', [], {'max_length': '255', 'null': 'True'}),
            'taxon': ('django.db.models.fields.related.ForeignKey', [], {'related_name': "'specimens'", 'to': "orm['radioapp.Taxon']"})
        },
        'radioapp.taxon': {
            'Meta': {'object_name': 'Taxon'},
            'common_name': ('django.db.models.fields.CharField', [], {'max_length': '255', 'null': 'True'}),
            'description': ('django.db.models.fields.TextField', [], {'null': 'True'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'level': ('django.db.models.fields.IntegerField', [], {}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '255', 'null': 'True'}),
            'parent': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['radioapp.Taxon']", 'null': 'True'})
        }
    }

    complete_apps = ['radioapp']
