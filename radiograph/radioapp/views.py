import copy
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
from django.shortcuts import render_to_response, get_object_or_404
from django.template import RequestContext
from django.views.decorators.http import require_http_methods
import haystack.forms
import haystack.views
from haystack.query import SearchQuerySet
from radioapp import forms, models

class SearchView(haystack.views.FacetedSearchView):
    template = 'radioapp/specimen_list.html'
    load_all = True

    def __init__(self, *args, **kwargs):
        kwargs.setdefault('form_class', SearchForm)
        super(SearchView, self).__init__(*args, **kwargs)

    def create_response(self, *args, **kwargs):
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
        (paginator, page) = self.build_page()
        
        context = {
            'user': get_user_struct(self.request),
            'search': None,
            'query': self.query,
            'page': page,
            'paginator': paginator,
            'suggestion': None,
            'results': lambda: self.results()
        }
        
        if getattr(settings, 'HAYSTACK_INCLUDE_SPELLING', False):
            context['suggestion'] = self.form.get_suggestion()
        
        context.update(self.extra_context())
        return context
    
    def build_page(self):
        form_data = getattr(self.form, 'cleaned_data', {})
        per_page = form_data.get('results_per_page') or self.results_per_page
        paginator = Paginator(self.results, per_page)
        
        try:
            page = paginator.page(self.request.GET.get('page', 1))
        except InvalidPage:
            raise Http404
        
        return (paginator, page)

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
            clbauses = [u'%s:"%s"' % (field, sqs.query.clean(v)) for v in vals]
            sqs = sqs.narrow(' OR '.join(clauses))

        return sqs

def login(request, *args, **kwargs):
    response = authviews.login(request, *args, **kwargs)
    if not request.is_ajax():
        return response

    user_struct = get_user_struct(request)
    if request.user.is_authenticated():
        return HttpResponse(json.dumps({'success': True, 'user': user_struct}),
                            content_type='application/json')
    else:
        return HttpResponse(json.dumps({'success': False, 'user': user_struct}),
                            status=401,
                            content_type='application/json')

def get_user_struct(request):
    if request.user.is_authenticated():
        return {
            'firstName': request.user.first_name,
            'lastName': request.user.last_name,
            'isStaff': request.user.is_staff,
            'loggedIn': True,
            'links': {'logout': reverse('logout')}
            }
    else:
        return {
            'isStaff': False,
            'loggedIn': False,
            'links': {'login': reverse('login')}
            }
        
def logout(request, *args, **kwargs):
    response = authviews.logout(request, *args, **kwargs)
    if request.is_ajax():
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
    else:
        return response

def index(request):
    view = SearchView()
    return view(request)

def image(request, image_id, derivative='medium'):
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

def IMAGE_TEMPLATE():
    return {
        'data': [
            {'name': 'uri', 'value': None, 'prompt': 'Image URI'},
            {'name': 'file', 'value': None, 'prompt': 'Image File'},
            {'name': 'aspect', 'value': None, 'prompt': 'Aspect'}
            ]
        }

def SPECIMEN_TEMPLATE():
    return {
        'data': {
            {'name': 'taxon', 'value': '', 'prompt': 'Taxon'},
            {'name': 'institution', 'value': '', 'prompt': 'Institution'},
            {'name': 'specimenId', 'value': '', 'prompt': 'Specimen ID'},
            {'name': 'sex', 'value': '', 'prompt': 'Sex'},
            {'name': 'comments', 'value': '', 'prompt': 'Comments'},
            {'name': 'settings', 'value': '', 'prompt': 'Settings'},
            {'name': 'images', 'value': [], 'prompt': 'Images',
             'template': {'uri': reverse('image-template')}}
            }
        }

def image_template(request):
    return HttpResponse(json.dumps(IMAGE_TEMPLATE()), content_type='application/json')

def specimen_template(request):
    return HttpResponse(json.dumps(SPECIMEN_TEMPLATE()), content_type='application/json')

def specimen_collection(request):
    '''
    Return paginated application/vnd.collection+json item list.
    '''
    values = [{
        'taxon': {'value': 15, 'label': 'Aotus trivirgatus'},
        'institution': {'value': 1, 'label': 'Harvard'},
        'sex': {'value': 'M', 'label': 'Male'},
        'comments': {'value': 'This is a bogus comment'},
        'settings': {'value': '1.21 Gw'},
        'created': datetime.datetime.now(),
        'created_by': None,
        'last_modified': datetime.datetime.now(),
        'last_modified_by': None,
        'images': {'value': [{
            'uri': {'value': reverse('image', args=['{id}'])},
            'aspect': {'value': 'Lateral'},
            'files': {
                'medium': {'value': reverse('image', args=['{id}'], kwargs={'derivative': 'medium'})},
                'large': {'value': reverse('image', args=['{id}'], kwargs={'derivative': 'large'})},
                'full': {'value': reverse('image', args=['{id}'], kwargs={'derivative': 'full'})}
                }
            }]}
        }]

    dataval = fill_template(SPECIMEN_TEMPLATE(), values[0])

    collection =  {
        'collection': {
            'version': '1.0',
            'href': request.build_absolute_uri(),

            'items': [{
                'href': reverse('specimen', args=['{id}']),
                'data': [
                    fill_template(SPECIMEN_TEMPLATE(), values[0])
                    ],
                'links': [
                    {'rel': 'delete', 
                     'prompt': 'Delete Specimen',
                     'uri': reverse('specimen-delete', args=['{id}'])}
                    ]
                }],

            'queries': [{
                'rel': 'search', 
                'prompt': 'Search Specimens',
                'href': request.build_absolute_uri(),
                'data': [
                    {'name': 'q', 'value': '', 'prompt': 'Query'},
                    {'name': 'page', 'value': 1, 'prompt': 'Page'},
                    {'name': 'perPage', 'value': 20, 'prompt': 'Results Per Page'},
                    {'name': 'taxa', 'value': '', 'prompt': 'Taxa'},
                    {'name': 'sex', 'value': '', 'prompt': 'Sex'},
                    {'name': 'order', 'value': '', 'prompt': 'Order By'}
                    ]
                }],

            'template': SPECIMEN_TEMPLATE()
            }
        }
        
    return HttpResponse(json.dumps(template), content_type='application/json')

@user_passes_test(lambda u: u.is_staff)
def specimens(request):
    if request.method == 'POST':
        # create new specimen from values
        specimen_form = forms.SpecimenForm(request.POST)
        images_form = forms.ImageFormSet(request.POST, request.FILES, 
                                         prefix='IMAGES_new')
        import ipdb; ipdb.set_trace();
        if specimen_form.is_valid():
            new_specimen = specimen_form.save()
            return HttpResponseRedirect(reverse('specimen-edit', args=[new_specimen.id]))
    else:
        return HttpResponseNotAllowed(['POST'])

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

def build_taxa_tree():
    taxa = (models.Taxon.objects.order_by('level')
            .values_list('id', 'parent_id', 'level'))


