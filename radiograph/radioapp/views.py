import copy
import datetime
import json
import mimetypes
import os

from django.conf import settings
from django.contrib.auth import views as authviews
from django.contrib.auth.decorators import login_required, user_passes_test
from django.core.paginator import Paginator, InvalidPage
from django.core.urlresolvers import reverse
from django.forms import fields as formfields
from django.http import HttpResponse, HttpResponseRedirect, Http404
from django.shortcuts import render, render_to_response, get_object_or_404
from django.template import RequestContext
from django.views.decorators.http import require_http_methods
import haystack.forms
import haystack.views
from haystack.query import SearchQuerySet
import pysolr
from radioapp import forms, models

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
            return HttpResponse(json.dumps(ctx), 
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
    results_per_page = formfields.IntegerField(initial=20, required=False)

    facets = [{
        'field': 'sex', 
        'label': 'Sex',
        'multi': False
        }, {
        'field': 'taxa', 
        'label': 'Taxon',
        'multi': True
    }]

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

        return sqs

    def clean(self):
        cleaned_data = super(SearchForm, self).clean()
        cleaned_data['results_per_page'] = cleaned_data['results_per_page'] or 20
        cleaned_data['q'] = cleaned_data['q'] or ''
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
        return HttpResponse(json.dumps({'success': True, 'user': user_struct}),
                            content_type='application/json')
    else:
        return HttpResponse(json.dumps({'success': False, 'user': user_struct}),
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
    return HttpResponse(json.dumps(json_response),
                        content_type='application/json')

def index(request):
    ctx = {
        'user': create_user_struct(request),
        'specimens': _specimens(request),
        'links': {
            'login': reverse('login'),
            'logout': reverse('logout')
            }
    }
    return render(request, 'radioapp/index.html', ctx)

def app_state(request):
    return HttpResponse(json.dumps(_app_state(request)), content_type='application_json')

def _app_state(request):
    return {
        'user': create_user_struct(request),
        'choices': {
            'taxon': _taxon_choices(),
            'institution': _institution_choices(),
            'sex': models.Specimen.SEX_CHOICES
            }
    }

def field_choices(request, field):
    if field == 'institution':
        result = institution_choices()
    elif field == 'taxon':
        result = _taxon_choices()
    else:
        result = []
    return HttpResponse(json.dumps(result), content_type='application/json')

def _institution_choices():
    return [(i.id, i.name) for i in models.Institution.objects.all()]

def _taxon_choices():
    solr = pysolr.Solr(settings.HAYSTACK_SOLR_URL)
    result = solr.search(q="django_ct:radioapp.taxon", 
                         start=0, rows=1000, 
                         fl="django_id label",
                         sort="label_sort asc")
    return [(doc['django_id'], doc['label']) for doc in result.docs]

def image(request, image_id):
    pass

def image_file(request, image_id, derivative='full'):
    if request.method == 'GET':
        image = get_object_or_404(models.Image, id=image_id)
        imgfile = getattr(image, 'image_%s' % derivative)
        if not imgfile:
            raise Http404()        
        
        taxon = ' '.join([t.name for t in image.specimen.taxon.hierarchy if t.level >= 7])
        _, ext = os.path.splitext(imgfile.path)
        filename = '%s-%s-%s-%s%s' % (taxon,
                                      image.specimen.id,
                                      image.get_aspect_display(),
                                      derivative,
                                      ext)
        filepath = os.path.join(settings.MEDIA_ROOT, imgfile.path)
                                  
        response = HttpResponse()
        response['X-Sendfile'] = filepath
        response['Content-Length'] = imgfile.size
        response['Content-Type'] = '%s; %s' % mimetypes.guess_type(filepath)
        
        # Browsers seem to force a download for full images, due to their large
        # size, so set an appropriate descriptive filename.
        download = request.GET.get('download', 'false').lower().startswith('t') 
        download = download or derivative == 'full'
        if download: # generate appropriate filename and set disposition
            response['Content-Disposition'] = 'attachment; filename=%s' % filename
        return response

def specimen(request, specimen_id):
    if request.method == 'GET':
        specimen = get_object_or_404(models.Specimen, id=specimen_id)
        ctx = RequestContext(request, {'specimen': specimen})
        return render_to_response('radioapp/specimen_detail.html',
                                  context_instance=ctx)
    elif request.method == 'POST':
        return save_specimen_changes(request, specimen_id)
    else:
        return HttpResponseNotAllowed(['GET', 'POST'])

@user_passes_test(lambda u: u.is_staff)
def save_specimen_changes(request, specimen_id):
    specimen = get_object_or_404(models.Specimen, id=specimen_id)
    specimen_form = forms.SpecimenForm(request.POST, instance=specimen)
    images_form = forms.ImageFormSet(request.POST, request.FILES, 
                                     instance=specimen,
                                     prefix='IMAGES_%s' % specimen_id)
    if specimen_form.is_valid() and images_form.is_valid():
        #specimen_form.save()

        # save images
        return HttpResponseRedirect(reverse('specimen-edit', args=[specimen_id]))
    else:
        import ipdb; ipdb.set_trace();
        raise Exception("Error was encountered")

def template(request, mediatype):
    if mediatype == 'image':
        result = IMAGE_TEMPLATE()
    elif mediatype == 'specimen':
        result = SPECIMEN_TEMPLATE()
    else:
        return Http404()
    return HttpResponse(json.dumps(result), content_type='application/json')

def IMAGE_TEMPLATE():
    return {
        'data': [
            {'name': 'uri', 'value': None, 'prompt': 'Image URI'},
            {'name': 'file', 'value': None, 'prompt': 'Image File'},
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
    return HttpResponse(json.dumps(IMAGE_TEMPLATE()), content_type='application/json')

def specimen_template(request):
    return HttpResponse(json.dumps(SPECIMEN_TEMPLATE()), content_type='application/json')

#@user_passes_test(lambda u: u.is_staff)

def _specimens(request):
    '''
    Return paginated application/vnd.collection+json item list.
    '''

    # TODO: apply search filters, etc. to arrive at values list
    values = [{
        'django_id': 1,
        'taxon': 15,
        'institution': 1,
        'sex': 'M',
        'comments': 'This is a bogus comment',
        'settings': '1.21 Gw',
        'created': datetime.datetime.now(),
        'created_by': None,
        'last_modified': datetime.datetime.now(),
        'last_modified_by': None,
        'images': [{
            'uri': reverse('image', args=['{id}']),
            'aspect': 'Lateral',
            'files': {
                'thumbnail': reverse('image-file', args=['{id}', 'thumb']),
                'medium': reverse('image-file', args=['{id}', 'medium']),
                'large': reverse('image-file', args=['{id}', 'large']),
                'full': reverse('image-file', args=['{id}', 'full'])
                }
            }]
        }]

    def create_specimen_item(idx_value):
        specimen_id = idx_value['django_id']

        template = SPECIMEN_TEMPLATE()
        for field in template.get('data', []):
            field['value'] = idx_value.get(field['name'])

        return {
            'href': reverse('specimen', args=[specimen_id]),
            'data': template['data']
            }

    return {
        'collection': {
            'version': '1.0',
            'href': request.build_absolute_uri(),
            'items': [create_specimen_item(v) for v in values],
            'queries': [SPECIMEN_SEARCH_TEMPLATE()],
            'links': [
                {'rel': 'template', 'href': reverse('template', args=['specimen'])}
                # {'rel': 'profile', ...}
                ],
            'pagination': {
                'currentPage': 5,
                'totalPages': 15
                }
            }
        }
            
def specimens(request):
    if request.method == 'GET':
        return HttpResponse(json.dumps(_specimen(request)), 
                            content_type='application/json')

    elif request.method == 'POST':
        # create new specimen from values
        specimen_form = forms.SpecimenForm(request.POST)
        images_form = forms.ImageFormSet(request.POST, request.FILES, 
                                         prefix='IMAGES_new')
        if specimen_form.is_valid():
            new_specimen = specimen_form.save()
            return HttpResponseRedirect(reverse('specimen-edit', args=[new_specimen.id]))
    else:
        return HttpResponseNotAllowed(['GET', 'POST'])

@user_passes_test(lambda u: u.is_staff)
def new_specimen(request):
    if request.method == 'GET':
        images_form = forms.ImageFormSet(prefix='IMAGES_new')
        ctx = RequestContext(request, {
            'form': forms.SpecimenForm(),
            'images_form': images_form
            })
        return render_to_response('radioapp/specimen_edit.html', context_instance=ctx)
    else:
        return HttpResponseNotAllowed(['GET'])

@user_passes_test(lambda u: u.is_staff)
def edit_specimen(request, specimen_id):
    specimen = get_object_or_404(models.Specimen, id=specimen_id)
    ctx = RequestContext(request, {
        'form': forms.SpecimenForm(instance=specimen),
        'images_form': forms.ImageFormSet(instance=specimen,
                                          prefix='IMAGES_%s' % specimen.id)
        })
    return render_to_response('radioapp/specimen_edit.html', context_instance=ctx)

@user_passes_test(lambda u: u.is_staff)
def delete_specimen(request, specimen_id):
    pass

def build_taxa_tree():
    taxa = (models.Taxon.objects.order_by('level')
            .values_list('id', 'parent_id', 'level'))


