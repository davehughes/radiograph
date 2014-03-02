# -*- coding: utf-8 -*-
import datetime
from south.db import db
from south.v2 import SchemaMigration
from django.db import models


class Migration(SchemaMigration):

    def forwards(self, orm):
        # Adding field 'Specimen.image_lateral'
        db.add_column(u'radiograph_specimen', 'image_lateral',
                      self.gf('django.db.models.fields.related.ForeignKey')(related_name='+', null=True, to=orm['radiograph.Image']),
                      keep_default=False)

        # Adding field 'Specimen.image_superior'
        db.add_column(u'radiograph_specimen', 'image_superior',
                      self.gf('django.db.models.fields.related.ForeignKey')(related_name='+', null=True, to=orm['radiograph.Image']),
                      keep_default=False)


        # Changing field 'Image.specimen'
        db.alter_column(u'radiograph_image', 'specimen_id', self.gf('django.db.models.fields.related.ForeignKey')(null=True, to=orm['radiograph.Specimen']))

    def backwards(self, orm):
        # Deleting field 'Specimen.image_lateral'
        db.delete_column(u'radiograph_specimen', 'image_lateral_id')

        # Deleting field 'Specimen.image_superior'
        db.delete_column(u'radiograph_specimen', 'image_superior_id')


        # User chose to not deal with backwards NULL issues for 'Image.specimen'
        raise RuntimeError("Cannot reverse this migration. 'Image.specimen' and its values cannot be restored.")

    models = {
        u'auth.group': {
            'Meta': {'object_name': 'Group'},
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '80'}),
            'permissions': ('django.db.models.fields.related.ManyToManyField', [], {'to': u"orm['auth.Permission']", 'symmetrical': 'False', 'blank': 'True'})
        },
        u'auth.permission': {
            'Meta': {'ordering': "(u'content_type__app_label', u'content_type__model', u'codename')", 'unique_together': "((u'content_type', u'codename'),)", 'object_name': 'Permission'},
            'codename': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'content_type': ('django.db.models.fields.related.ForeignKey', [], {'to': u"orm['contenttypes.ContentType']"}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '50'})
        },
        u'auth.user': {
            'Meta': {'object_name': 'User'},
            'date_joined': ('django.db.models.fields.DateTimeField', [], {'default': 'datetime.datetime.now'}),
            'email': ('django.db.models.fields.EmailField', [], {'max_length': '75', 'blank': 'True'}),
            'first_name': ('django.db.models.fields.CharField', [], {'max_length': '30', 'blank': 'True'}),
            'groups': ('django.db.models.fields.related.ManyToManyField', [], {'to': u"orm['auth.Group']", 'symmetrical': 'False', 'blank': 'True'}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'is_active': ('django.db.models.fields.BooleanField', [], {'default': 'True'}),
            'is_staff': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            'is_superuser': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            'last_login': ('django.db.models.fields.DateTimeField', [], {'default': 'datetime.datetime.now'}),
            'last_name': ('django.db.models.fields.CharField', [], {'max_length': '30', 'blank': 'True'}),
            'password': ('django.db.models.fields.CharField', [], {'max_length': '128'}),
            'user_permissions': ('django.db.models.fields.related.ManyToManyField', [], {'to': u"orm['auth.Permission']", 'symmetrical': 'False', 'blank': 'True'}),
            'username': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '30'})
        },
        u'contenttypes.contenttype': {
            'Meta': {'ordering': "('name',)", 'unique_together': "(('app_label', 'model'),)", 'object_name': 'ContentType', 'db_table': "'django_content_type'"},
            'app_label': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'model': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '100'})
        },
        u'radiograph.image': {
            'Meta': {'object_name': 'Image'},
            'aspect': ('django.db.models.fields.CharField', [], {'max_length': '1'}),
            'deleted': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'image_full': ('django.db.models.fields.files.FileField', [], {'max_length': '1024'}),
            'image_medium': ('django.db.models.fields.files.FileField', [], {'max_length': '100', 'null': 'True', 'blank': 'True'}),
            'image_thumbnail': ('django.db.models.fields.files.FileField', [], {'max_length': '100', 'null': 'True', 'blank': 'True'}),
            'md5': ('django.db.models.fields.CharField', [], {'max_length': '32', 'null': 'True'}),
            'original_path': ('django.db.models.fields.CharField', [], {'max_length': '1024', 'null': 'True'}),
            'specimen': ('django.db.models.fields.related.ForeignKey', [], {'related_name': "'images'", 'null': 'True', 'to': u"orm['radiograph.Specimen']"})
        },
        u'radiograph.institution': {
            'Meta': {'object_name': 'Institution'},
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'link': ('django.db.models.fields.CharField', [], {'max_length': '255', 'null': 'True'}),
            'logo': ('django.db.models.fields.files.FileField', [], {'max_length': '100', 'null': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '255'})
        },
        u'radiograph.specimen': {
            'Meta': {'object_name': 'Specimen'},
            'comments': ('django.db.models.fields.TextField', [], {'null': 'True'}),
            'cranial_width': ('django.db.models.fields.DecimalField', [], {'null': 'True', 'max_digits': '10', 'decimal_places': '2'}),
            'created': ('django.db.models.fields.DateField', [], {'auto_now_add': 'True', 'blank': 'True'}),
            'created_by': ('django.db.models.fields.related.ForeignKey', [], {'related_name': "'specimens_created'", 'null': 'True', 'to': u"orm['auth.User']"}),
            'deleted': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            'facial_height': ('django.db.models.fields.DecimalField', [], {'null': 'True', 'max_digits': '10', 'decimal_places': '2'}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'image_lateral': ('django.db.models.fields.related.ForeignKey', [], {'related_name': "'+'", 'null': 'True', 'to': u"orm['radiograph.Image']"}),
            'image_superior': ('django.db.models.fields.related.ForeignKey', [], {'related_name': "'+'", 'null': 'True', 'to': u"orm['radiograph.Image']"}),
            'institution': ('django.db.models.fields.related.ForeignKey', [], {'related_name': "'specimens'", 'null': 'True', 'to': u"orm['radiograph.Institution']"}),
            'last_modified': ('django.db.models.fields.DateField', [], {'auto_now': 'True', 'blank': 'True'}),
            'last_modified_by': ('django.db.models.fields.related.ForeignKey', [], {'related_name': "'specimens_last_modified'", 'null': 'True', 'to': u"orm['auth.User']"}),
            'neurocranial_height': ('django.db.models.fields.DecimalField', [], {'null': 'True', 'max_digits': '10', 'decimal_places': '2'}),
            'palate_length': ('django.db.models.fields.DecimalField', [], {'null': 'True', 'max_digits': '10', 'decimal_places': '2'}),
            'palate_width': ('django.db.models.fields.DecimalField', [], {'null': 'True', 'max_digits': '10', 'decimal_places': '2'}),
            'settings': ('django.db.models.fields.TextField', [], {'null': 'True'}),
            'sex': ('django.db.models.fields.CharField', [], {'max_length': '10', 'null': 'True'}),
            'skull_length': ('django.db.models.fields.DecimalField', [], {'null': 'True', 'max_digits': '10', 'decimal_places': '2'}),
            'specimen_id': ('django.db.models.fields.CharField', [], {'max_length': '255', 'null': 'True'}),
            'taxon': ('django.db.models.fields.related.ForeignKey', [], {'related_name': "'specimens'", 'to': u"orm['radiograph.Taxon']"})
        },
        u'radiograph.taxon': {
            'Meta': {'object_name': 'Taxon'},
            'common_name': ('django.db.models.fields.CharField', [], {'max_length': '255', 'null': 'True'}),
            'description': ('django.db.models.fields.TextField', [], {'null': 'True'}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'level': ('django.db.models.fields.IntegerField', [], {}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '255', 'null': 'True'}),
            'parent': ('django.db.models.fields.related.ForeignKey', [], {'to': u"orm['radiograph.Taxon']", 'null': 'True'})
        }
    }

    complete_apps = ['radiograph']