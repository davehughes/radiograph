from collections import defaultdict
import simplejson as json

from django.core.cache import cache
# from django.core.urlresolvers import reverse
from django.db.models import Count
from django.http import HttpResponse
from rest_framework.reverse import reverse
from rest_framework import serializers

from radiograph import models


class Institution(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = models.Institution
        view_name = 'api:institution-detail'
        fields = ('url', 'name', 'link', 'logo')


class User(serializers.ModelSerializer):
    class Meta:
        model = models.User
        view_name = 'api:user-detail'
        fields = ('first_name', 'last_name', 'username', 'date_joined')


class Taxon(serializers.HyperlinkedModelSerializer):
    level = serializers.Field(source='get_level_display')
    label = serializers.SerializerMethodField('get_label')
    class Meta:
        model = models.Taxon
        view_name = 'api:taxon-detail'
        fields = ('url', 'name', 'parent', 'level', 'label')

    def get_label(self, obj):
        return self.label_cache.get(obj.id)

    @property
    def label_cache(self):
        label_map = cache.get('taxon_label_cache')
        if not label_map:
            taxa = models.Taxon.objects.all()
            tmap = {t.id: t for t in taxa}

            ancestor_map = {}
            def compute_ancestors_and_self(tid):
                if not tid in ancestor_map:
                    t = tmap[tid]
                    if t.parent_id is None:
                        ancestor_map[tid] = [t]
                    else:
                        ancestors = list(compute_ancestors_and_self(t.parent_id))
                        ancestors.append(t)
                        ancestor_map[tid] = ancestors
                return ancestor_map[tid]

            # Build a mapping between taxon ID and species/subspecies label
            label_map = {}
            for t in taxa.filter(level__gt=models.GENUS):
                hierarchy = compute_ancestors_and_self(t.id)
                label_map[t.id] = ' '.join(t.name for t in hierarchy[models.GENUS:])

            cache.set('taxon_label_cache', label_map)

        return label_map


def specimen_dataset(request):
    data = cache.get('specimen_dataset_full')
    if not data:
        properties = [
          'id',
          'skull_length',
          'cranial_width',
          'neurocranial_height',
          'facial_height',
          'palate_length',
          'palate_width'
          ]

        dataobj = {
            'header': properties,
            'rows': list(models.Specimen.objects.values_list(*properties))
            }
        data = json.dumps(dataobj, use_decimal=True)
        cache.set('specimen_dataset_full', data)

    return HttpResponse(data, content_type='application/json')


def taxon_filter_tree(request):
    tree = cache.get('taxon_filter_tree')
    if not tree:
        tree = _taxon_filter_tree(models.Taxon.objects.get(name='Primates'),
                                  levels=[models.FAMILY, models.GENUS, models.SPECIES])
        cache.set('taxon_filter_tree', tree)

    return HttpResponse(json.dumps(tree), content_type='application/json')


def _taxon_filter_tree(root, include_root=False, levels=None, hide_empty=True):
    '''
    Returns a nested tree structure of the taxa descended from `root`,
    including only the `levels` provided.  If `include_root` is False
    (the default), the representation begins with `root`'s children.
    Descendant counts are included, and nodes without any descendants are
    suppressed if `hide_empty` is True.
    '''

    specimen_counts = {id: count for id, count in
                       (models.Taxon.objects
                        .annotate(specimen_count=Count('specimens'))
                        .filter(specimen_count__gt=0)
                        .values_list('id', 'specimen_count'))}

    def create_node(taxon):
        return {
            'id': taxon.id,
            'name': taxon.name,
            'href': reverse('radiograph:taxon', args=[taxon.id]),
            'level': taxon.get_level_display(),
            'level_id': taxon.level,
            'count': specimen_counts.get(taxon.id, 0),
            'children': []
            }

    taxa = models.Taxon.objects.order_by('-level')
    taxon_map = {t.id: create_node(t) for t in taxa}

    for taxon in taxa:
        if not taxon.parent_id:
            continue

        parent_node = taxon_map.get(taxon.parent_id)
        self_node = taxon_map.get(taxon.id)

        if hide_empty and self_node['count'] == 0:
            continue
        parent_node['count'] += self_node['count']
        if self_node['level_id'] in levels:
            parent_node['children'].append(self_node)
        else:
            parent_node['children'].extend(self_node['children'])

    tree = taxon_map[root.id]
    return [tree] if include_root else tree['children']


class Image(serializers.HyperlinkedModelSerializer):
    specimen = serializers.HyperlinkedRelatedField(view_name='api:specimen-detail')
    aspect = serializers.Field(source='get_aspect_display')
    derivatives = serializers.SerializerMethodField('get_derivatives')

    class Meta:
        model = models.Image
        view_name = 'api:image-detail'
        fields = ('url', 'specimen', 'aspect', 'versions')

    def get_derivatives(self, obj):
        derivs = {}
        derivs['full'] = reverse('api:image-file', args=[obj.id, 'full'])
        if obj.image_medium:
            derivs['medium'] = reverse('api:image-file',
                                       args=[obj.id, 'medium'])
        if obj.image_thumbnail:
            derivs['thumbnail'] = reverse('api:image-file',
                                          args=[obj.id, 'thumbnail'])
        return derivs


class Specimen(serializers.HyperlinkedModelSerializer):
    images = serializers.ManyHyperlinkedRelatedField(view_name='api:image-detail')
    images2 = serializers.RelatedField()
    taxon = serializers.HyperlinkedRelatedField(view_name='api:taxon-detail')
    # institution = serializers.HyperlinkedRelatedField(view_name='api:institution-detail')
    #institution = Institution()
    modification_info = serializers.SerializerMethodField('get_modification_info')
    measurements = serializers.SerializerMethodField('get_measurements')
    sex_label = serializers.Field(source='get_sex_display')
    taxon_label = serializers.Field(source='taxon.label')

    class Meta:
        depth = 1
        model = models.Specimen
        view_name = 'api:specimen-detail'
        fields = (
            # metadata
            'url',
            'modification_info',

            # primary data
            'specimen_id',
            'sex',
            'sex_label',
            'settings',
            'comments',
            'images',
            'taxon',
            'taxon_label',
            'institution',

            # measurements
            'measurements',
        )

    def get_measurements(self, obj):
        return {
            'skull_length': obj.skull_length,
            'cranial_width': obj.cranial_width,
            'neurocranial_height': obj.neurocranial_height,
            'facial_height': obj.facial_height,
            'palate_width': obj.palate_width,
            'palate_length': obj.palate_length
            }

    def get_modification_info(self, obj):
        info = {
            'last_modified': obj.last_modified,
            'created': obj.created
            }
        if obj.created_by_id:
            info['created_by'] = reverse('api:user-detail', args=[obj.created_by_id])
        if obj.last_modified_by_id:
            info['last_modified_by'] = reverse('api:user-detail', args=[obj.last_modified_by_id])
        return info
