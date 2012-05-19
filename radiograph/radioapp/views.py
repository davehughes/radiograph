import copy
import csv
import datetime
import json
import math
import mimetypes
import os
import types

from django.conf import settings
from django.contrib.auth import views as authviews
from django.contrib.auth.decorators import login_required, user_passes_test
from django.core.paginator import Paginator, InvalidPage
from django.core.urlresolvers import reverse, resolve
from django.db import transaction
from django.forms import fields as formfields
from django import http
from django.shortcuts import render, render_to_response, get_object_or_404
from django.template import RequestContext
from django.views.decorators.http import require_http_methods
import haystack.forms
import haystack.views
from haystack.query import SearchQuerySet
import pysolr
from radioapp import forms, models, util, search_indexes

specimen_index = search_indexes.SpecimenIndex(models.Specimen)

class SearchView(haystack.views.FacetedSearchView):
    template = 'radioapp/specimen_list.html'
    load_all = True

    def __init__(self, *args, **kwargs):
        kwargs.setdefault('form_class', SearchForm)
        super(SearchView, self).__init__(*args, **kwargs)

    def create_response(self, *args, **kwargs):
        if self.form.is_valid():
            ctx = self.create_context(*args, **kwargs)
        if self.request.is_ajax():
            return http.HttpResponse(json.dumps(ctx), 
                                content_type='application/json')
        else:
            ctx_instance = self.context_class(self.request)
            return render_to_response(self.template, 
                                      ctx,
                                      context_instance=ctx_instance)

    def create_context(self, *args, **kwargs):
        ''' 
        Mostly a direct copy from super.create_response(), but separate 
        context generation from rendering to make it easier to return
        alternate representations.
        '''
        self.results_per_page = self.form.cleaned_data['results_per_page']
        (paginator, page) = self.build_page()
        
        context = {
            'search': None,
            'query': self.query,
            'page': page,
            'paginator': paginator,
            'suggestion': None,
            'results': self.results
        }
        
        if getattr(settings, 'HAYSTACK_INCLUDE_SPELLING', False):
            context['suggestion'] = self.form.get_suggestion()
        
        context.update(self.extra_context())
        return context

    def extra_context(self):
        extra = super(SearchView, self).extra_context()

        facets = copy.deepcopy(self.form.facets)
        facet_map = self.results.facet_counts().get('fields', {})
        for f in facets:
            f['values'] = facet_map.get(f['field'], [])
        extra['facets'] = facets

        return extra


class SearchForm(haystack.forms.FacetedModelSearchForm):
    page = formfields.IntegerField(required=False)
    results_per_page = formfields.IntegerField(initial=20, required=False)
    sort_field = formfields.CharField(required=False)
    sort_direction = formfields.CharField(required=False)

    facets = [{
        'field': 'sex', 
        'label': 'Sex',
        'multi': False
        }, {
        'field': 'taxa', 
        'label': 'Taxon',
        'multi': True
    }]

    sortmap = {
        'sex': 'sex_label',
        'taxon': 'taxon_label_facet',
        'last_modified': 'last_modified',
        'relevance': 'score',
        'default': 'score'
    }

    def __init__(self, *args, **kwargs):
        self.selected_facets = kwargs.pop("selected_facets", [])
        super(SearchForm, self).__init__(*args, **kwargs)

    def no_query_found(self):
        return self.searchqueryset.all()

    def get_models(self):
        return [models.Specimen]
    
    def search(self):
        sqs = super(SearchForm, self).search()
        for facet in self.facets:
            sqs = sqs.facet(facet['field'])

        multifacets = {}
        facet_map = {f['field']: f for f in self.facets}
        for facet in self.selected_facets:
            if ':' not in facet:
                continue
                
            field, value = facet.split(':', 1)
            facet = facet_map.get(field, {})
            if facet.get('multi', False):
                multifacets.setdefault(field, []).append(value)
            else:
                sqs = sqs.narrow(u'%s:"%s"' % (field, sqs.query.clean(value)))
                
        for field, vals in multifacets.iteritems():
            clauses = [u'%s:"%s"' % (field, sqs.query.clean(v)) for v in vals]
            sqs = sqs.narrow(' OR '.join(clauses))

        order_by = self.sortmap.get(self.cleaned_data['sort_field'], 'score')
        if self.cleaned_data.get('sort_direction', 'asc') == 'desc':
            order_by = '-' + order_by
        sqs = sqs.order_by(order_by)

        return sqs

    def clean(self):
        cleaned_data = super(SearchForm, self).clean()
        cleaned_data.update({
            'page': cleaned_data.get('page', 1) or 1,
            'results_per_page': cleaned_data.get('results_per_page', 20) or 20,
            'q': cleaned_data.get('q', '*:*'),
            'sort_field': cleaned_data.get('sort_field', 'default'),
            'sort_direction': cleaned_data.get('sort_direction', 'asc')
            })
        return cleaned_data

def create_user_struct(request):
    if request.user.is_authenticated():
        return {
            'firstName': request.user.first_name,
            'lastName': request.user.last_name,
            'isStaff': request.user.is_staff,
            'loggedIn': True,
            }
    else:
        return {
            'isStaff': False,
            'loggedIn': False,
            }

def login(request, *args, **kwargs):
    response = authviews.login(request, *args, **kwargs)
    if not request.is_ajax():
        return response

    user_struct = create_user_struct(request)
    if request.user.is_authenticated():
        return http.HttpResponse(json.dumps({'success': True, 'user': user_struct}),
                            content_type='application/json')
    else:
        return http.HttpResponse(json.dumps({'success': False, 'user': user_struct}),
                            status=401,
                            content_type='application/json')
        
def logout(request, *args, **kwargs):
    response = authviews.logout(request, *args, **kwargs)
    if not request.is_ajax():
        return response
    json_response = {
        'success': True,
        'user': {
            'isStaff': False,
            'loggedIn': False,
            'links': {'login': reverse('login')}
            }
        }
    return http.HttpResponse(json.dumps(json_response),
                        content_type='application/json')

def index(request):
    ctx = {
        'user': create_user_struct(request),
        'specimens': _specimens(request),
        'choices': {
            'taxon': _taxon_choices(),
            'institution': _institution_choices(),
            'sex': models.Specimen.SEX_CHOICES,
            'aspect': models.Image.ASPECT_CHOICES
            },
        'links': {
            'login': reverse('login'),
            'logout': reverse('logout')
            },
        'resources': {
            'specimens': reverse('specimen-collection'),
            # 'images': reverse('image-collection'
            }
    }
    return render(request, 'radioapp/index.html', ctx)

def field_choices(request, field):
    if field == 'institution':
        result = institution_choices()
    elif field == 'taxon':
        result = _taxon_choices()
    else:
        result = []
    return http.HttpResponse(json.dumps(result), content_type='application/json')

def _institution_choices():
    return [(i.id, i.name) for i in models.Institution.objects.all()]

def taxa(request):
    pass

def taxon(request, taxon_id):
    pass

def _taxon_choices():
    solr = pysolr.Solr(settings.HAYSTACK_SOLR_URL)
    result = solr.search(q="django_ct:radioapp.taxon", 
                         start=0, rows=1000, 
                         fl="django_id label",
                         sort="label_sort asc")
    return [(int(doc['django_id']), doc['label']) for doc in result.docs]

def image(request, image_id):
    pass

def image_file(request, image_id, derivative='full'):
    if request.method == 'GET':
        image = get_object_or_404(models.Image, id=image_id)
        imgfile = getattr(image, 'image_%s' % derivative)
        if not imgfile:
            raise http.Http404()        
        
        taxon = ' '.join([t.name for t in image.specimen.taxon.hierarchy if t.level >= 7])
        _, ext = os.path.splitext(imgfile.path)
        filename = '%s-%s-%s-%s%s' % (taxon,
                                      image.specimen.id,
                                      image.get_aspect_display(),
                                      derivative,
                                      ext)
        filepath = os.path.join(settings.MEDIA_ROOT, imgfile.path)
                                  
        mime = mimetypes.guess_type(filepath)[0]
        response = http.HttpResponse(mimetype=mime)
        response['X-Sendfile'] = filepath
        # response['Content-Length'] = imgfile.size
        
        # Browsers seem to force a download for full images, due to their large
        # size, so set an appropriate descriptive filename.
        download = request.GET.get('download', 'false').lower().startswith('t') 
        download = download or derivative == 'full'
        if download: # generate appropriate filename and set disposition
            response['Content-Disposition'] = 'attachment; filename=%s' % filename
        return response

def template(request, mediatype):
    if mediatype == 'image':
        result = IMAGE_TEMPLATE()
    elif mediatype == 'specimen':
        result = SPECIMEN_TEMPLATE()
    else:
        return http.Http404()
    return http.HttpResponse(json.dumps(result), content_type='application/json')

def IMAGE_TEMPLATE():
    return {
        'data': [
            {'name': 'href', 'value': None, 'prompt': 'Image URI'},
            {'name': 'url', 'value': None, 'prompt': 'Image File URL'},
            {'name': 'name', 'value': None, 'prompt': 'Image Filename'},
            {'name': 'aspect', 'value': None, 'prompt': 'Aspect',
             'choices': models.Image.ASPECT_CHOICES}
            ]
        }

def SPECIMEN_TEMPLATE():
    return {
        'data': [
            {'name': 'taxon', 'value': '', 'prompt': 'Taxon',
             'choices': reverse('field-choices', args=['taxon'])},
            {'name': 'institution', 'value': '', 'prompt': 'Institution',
             'choices': reverse('field-choices', args=['institution'])},
            {'name': 'specimenId', 'value': '', 'prompt': 'Specimen ID'},
            {'name': 'sex', 'value': '', 'prompt': 'Sex',
             'choices': models.Specimen.SEX_CHOICES},
            {'name': 'comments', 'value': '', 'prompt': 'Comments'},
            {'name': 'settings', 'value': '', 'prompt': 'Settings'},
            {'name': 'skullLength', 'value': '', 'prompt': 'Skull Length'},
            {'name': 'cranialWidth', 'value': '', 'prompt': 'Cranial Width'},
            {'name': 'neurocranialHeight', 'value': '', 'prompt': 'Neurocranial Height'},
            {'name': 'facialHeight', 'value': '', 'prompt': 'Facial Height'},
            {'name': 'palateLength', 'value': '', 'prompt': 'Palate Length'},
            {'name': 'palateWidth', 'value': '', 'prompt': 'Palate Width'},
            {'name': 'images', 'value': [], 'prompt': 'Images',
             'template': IMAGE_TEMPLATE()}
            ]
        }

def SPECIMEN_SEARCH_TEMPLATE():
    return {
        'rel': 'search', 
        'prompt': 'Search Specimens',
        'href': reverse('specimen-collection'),
        'data': [
            {'name': 'q', 'value': '*:*', 'prompt': 'Query'},
            {'name': 'page', 'value': 1, 'prompt': 'Page'},
            {'name': 'results_per_page', 'value': 20, 'prompt': 'Results Per Page'},
            {'name': 'taxa_filter', 'value': [], 'prompt': 'Taxa filter'},
            {'name': 'sex', 'value': [], 'prompt': 'Sex filter'},
            {'name': 'order', 'value': '', 'prompt': 'Order By'}
        ]
    }

def image_template(request):
    return http.HttpResponse(json.dumps(IMAGE_TEMPLATE()), content_type='application/json')

def specimen_template(request):
    return http.HttpResponse(json.dumps(SPECIMEN_TEMPLATE()), content_type='application/json')

def _specimens(request):
    '''
    Return paginated application/vnd.collection+json item list.
    '''
    form = SearchForm(request.REQUEST)
    if not form.is_valid():
        raise Exception('Invalid search parameters: %s' % form.errors)
    sqs = form.search()

    current_page = form.cleaned_data['page']
    results_per_page = form.cleaned_data['results_per_page']
    total_pages = int(math.ceil(sqs.count() / (results_per_page * 1.0)))
    offset = (current_page - 1) * results_per_page
    limit = offset + results_per_page
    values = [json.loads(r.json_doc) for r in sqs[offset:limit]]

    def create_specimen_item(idx_value):
        specimen_id = idx_value['id']
        data = [{'name': k, 'value': v} for k, v in idx_value.items()]
        return {
            'href': reverse('specimen', args=[specimen_id]),
            'data': data
            }

    return {
        'collection': {
            'version': '1.0',
            'href': reverse('specimen-collection'),
            'items': [create_specimen_item(v) for v in values],
            'queries': [SPECIMEN_SEARCH_TEMPLATE()],
            'links': [
                {'rel': 'template', 'href': reverse('template', args=['specimen'])}
                # {'rel': 'profile', ...}
                ],
            'pagination': {
                'currentPage': current_page,
                'totalPages': total_pages
                }
            }
        }
            
def specimens(request):
    if request.method == 'GET':
        return list_specimens(request)
    elif request.method == 'POST':
        try: 
            specimen = create_or_update_specimen(request)
        except Exception as e:
            import ipdb; ipdb.set_trace();
            return http.HttpResponse(json.dumps({'success': False}), 
                                     content_type="application/json")
        else:
            result = {
                'success': True,
                'href': reverse('specimen', args=[specimen.id])
                }
            return http.HttpResponse(json.dumps(result),
                                     content_type="application/json")
    else:
        return http.HttpResponseNotAllowed(['GET', 'POST'])

def specimen(request, specimen_id):
    if request.method == 'GET':
        pass
    elif request.method == 'POST':
        try: 
            specimen = create_or_update_specimen(request, specimen_id)
        # except Exception as e:
        except KeyError:
            return http.HttpResponse(json.dumps({'success': False}), 
                                     content_type="application/json")
        else:
            result = {
                'success': True,
                'href': reverse('specimen', args=[specimen.id])
                }
            return http.HttpResponse(json.dumps(result),
                                     content_type="application/json")
    else:
        return http.HttpResponseNotAllowed(['GET', 'POST'])

def get_model_from_uri(model_class, uri, pkarg=0, target_route_name=None):
    route = resolve(uri)
    if target_route_name and route.url_name is not target_route_name:
        raise ValueError('Resolved route did not match expected route')

    if type(pkarg) == types.IntType:
        pk = route.args[pkarg]
    else:
        pk = route.kwargs.get(pkarg)

    return model_class.objects.get(pk=pk)

@user_passes_test(lambda u: u.is_staff)
@transaction.commit_on_success
def create_or_update_specimen(request, specimen_id=None):

    specimen = None
    specimen_data = json.loads(request.POST.get('specimen'))
    specimen_data = util.underscorize(specimen_data)
    images = specimen_data.pop('images', [])

    if specimen_id:
        specimen = get_object_or_404(models.Specimen, id=specimen_id)
        specimen_data['last_modified_by'] = request.user.id
        specimen_data['created_by'] = specimen.created_by.id
        del specimen_data['last_modified']
        del specimen_data['created']
    else:
        specimen_data['created_by'] = request.user.id
        specimen_data['last_modified_by'] = request.user.id

    # create new specimen from values
    specimen_form = forms.SpecimenForm(specimen_data, instance=specimen)
    if not specimen_form.is_valid():
        errors = specimen_form.errors
        raise Exception('Form validation failed')

    specimen = specimen_form.save()
    images_seen = []

    # Process and save specimen images
    for image_data in images:
        if image_data.get('href'):
            image = get_model_from_uri(models.Image, image_data['href'], 'image_id', 'image')
            if image.specimen != specimen:
                raise Exception('Cannot reassign image to new specimen')
        else:
            image = models.Image(specimen=specimen)

        image.aspect = image_data.get('aspect', image.aspect)
        if not image.aspect in [x for x, _ in models.Image.ASPECT_CHOICES]:
            raise ValueError('Invalid aspect value: %s' % image.aspect)
        if image_data.get('replacement_file'):
            image.image_full = request.FILES.get(image_data['replacement_file'])

        image.save() 
        images_seen.append(image.id)

    # delete unreferenced images
    for img in specimen.images.exclude(id__in=images_seen):
        img.deleted = True
        img.save()
    
    # (re)index specimen
    specimen_index.update_object(specimen)
    return specimen

def list_specimens(request):
    return http.HttpResponse(json.dumps(_specimens(request)), 
                        content_type='application/json')

def build_taxa_tree():
    taxa = (models.Taxon.objects.order_by('level')
            .values_list('id', 'parent_id', 'level'))

def build_dataset_csv(request):
    sqs = SearchForm(request.REQUEST).search()

    response = http.HttpResponse(content_type='text/csv')
    w = csv.writer(response)

    # write header
    w.writerow(('Specimen ID', 'Institution', 'Sex', 'Taxon', 'Comments', 'Settings',
            'Skull Length', 'Cranial Width', 'Neurocranial Height', 'Facial Height',
            'Palate Length', 'Palate Width', 'Lateral Image', 'Superior Image'))

    # TODO: implement label functions
    choices = {
        'institution': dict(_institution_choices()),
        'sex': dict(models.Specimen.SEX_CHOICES),
        'taxon': dict(_taxon_choices())
        }

    for specimen in sqs:
        s = json.loads(specimen.json_doc)
        values = (
            s['specimenId'],
            choices['institution'].get(s['institution']),
            choices['sex'].get(s['sex']),
            choices['taxon'].get(s['taxon']),
            s['comments'],
            s['settings'],
            s['skullLength'],
            s['cranialWidth'],
            s['neurocranialHeight'],
            s['facialHeight'],
            s['palateLength'],
            s['palateWidth'],
            None, # image lateral
            None  # image superior
        )
        w.writerow(values)

    return response
