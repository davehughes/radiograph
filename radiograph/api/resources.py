from collections import defaultdict
import simplejson as json

from django.core.cache import cache
from django.core.urlresolvers import reverse
from django.db.models import Count
from django.http import HttpResponse
from djangorestframework import resources

from radioapp import models

class Institution(resources.ModelResource):
    model = models.Institution
    fields = ('href', 'name', 'link', 'logo')

    def href(self, o):
        return reverse('institution', args=[o.id])

class User(resources.ModelResource):
    model = models.User
    fields = ('first_name', 'last_name', 'username', 'date_joined')


class Taxon(resources.ModelResource):
    model = models.Taxon
    fields = ('href', 'name', 'parent', 'level', 'label')

    def href(self, o):
        return reverse('taxon', args=[o.id])

    def parent(self, o):
        if o.parent_id:
            return reverse('taxon', args=[o.parent_id])

    def level(self, o):
        return o.get_level_display()

    def label(self, o):
        return self.label_cache.get(o.id)

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
            'href': reverse('taxon', args=[taxon.id]),
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


class Image(resources.ModelResource):
    model = models.Image
    fields = ('href', 'specimen', 'aspect', 'versions')

    def href(self, o):
        return reverse('image', args=[o.id])

    def specimen(self, o):
        if o.specimen_id:
            return reverse('specimen', args=[o.specimen_id])

    def versions(self, o):
        derivs = {}
        derivs['full'] = reverse('image-file', args=[o.id, 'full'])
        if o.image_medium:
            derivs['medium'] = reverse('image-file', args=[o.id, 'medium'])
        if o.image_thumbnail:
            derivs['thumbnail'] = reverse('image-file', args=[o.id, 'thumbnail'])
        return derivs

    def aspect(self, o):
        return o.get_aspect_display()

class Specimen(resources.ModelResource):
    model = models.Specimen
    prefetch_related = 'images'
    select_related = ('institution', 'created_by', 'last_modified_by')
    fields = (
        'href',
        # 'created',
        # 'last_modified',
        # 'created_by',
        # 'last_modified_by',

        'specimen_id',
        'sex',
        'skull_height',
        'cranial_width',
        'neurocranial_height',
        'facial_height',
        'palate_width',
        'palate_length',
        'settings',
        'comments',
        ('images', 'Image'),
        ('taxon', 'Taxon'),
        ('institution', 'Institution'),
    )

    def href(self, o):
        return reverse('specimen', args=[o.id])

    # def created_by(self, o):
    #     if o.created_by_id:
    #         return reverse('user', args=[o.created_by.username])

    # def last_modified_by(self, o):
    #     if o.last_modified_by_id:
    #         return reverse('user', args=[o.last_modified_by.username])

    def sex(self, o):
        return o.get_sex_display()


