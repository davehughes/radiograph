import copy
import json
import os

from django.conf import settings
from django.contrib.auth.decorators import login_required, user_passes_test
from django.core.paginator import Paginator, InvalidPage
from django.core.urlresolvers import reverse
from django.forms import fields as formfields
from django.http import HttpResponse, HttpResponseRedirect, Http404
from django.shortcuts import render_to_response, get_object_or_404
from django.template import RequestContext
from django.views.decorators.http import require_http_methods
import haystack
from haystack.query import SearchQuerySet
import haystack
from radioapp import forms, models

class SearchView(haystack.views.FacetedSearchView):
    template = 'radioapp/specimen_list.html'
    load_all = True

    def __init__(self, *args, **kwargs):
        kwargs.setdefault('form_class', SearchForm)
        super(SearchView, self).__init__(*args, **kwargs)

    def create_response(self, *args, **kwargs):
        return super(SearchView, self).create_response(*args, **kwargs)
    
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
            clauses = [u'%s:"%s"' % (field, sqs.query.clean(v)) for v in vals]
            sqs = sqs.narrow(' OR '.join(clauses))

        return sqs

def index(request):
    if request.method == 'GET':
        # do haystack search
        # list all parameters as run through specimen results template
        facets = [
            {'field': 'sex', 'label': 'Sex'},
            {'field': 'species_facet', 'label': 'Species/subspecies'}
        ]

        query = SearchQuerySet().all()
        for f in facets:
            query = query.facet(f['field'])

        facet_fields = query.facet_counts().get('fields', {})
        for facet in facets:
            facet['values'] = facet_fields.get(facet['field'], [])

        ctx = RequestContext(request, { 
                'results': query,
                'facets': facets
                })
        return render_to_response('radioapp/specimen_list.html',
                                  context_instance=ctx)


def image(request, image_id, derivative='medium'):
    if request.method == 'GET':
        image = get_object_or_404(models.Image, id=image_id)
        imgfile = getattr(image, 'image_%s' % derivative)
        if not imgfile:
            raise Http404()        

        species = "%s %s" % (image.specimen.species, 
                             image.specimen.subspecies) \
            if image.specimen.subspecies \
            else image.specimen.species
        filename = '%s - %s - %s' % (species, 
                                     image.get_aspect_display(),
                                     derivative)
        filepath = os.path.join(settings.MEDIA_ROOT, imgfile.path)
                                  
        response = HttpResponse()
        response['X-Sendfile'] = filepath
        response['Content-Length'] = imgfile.size
        response['Content-Type'] = '%s; %s' % mimetypes.guess_mime(filepath)
        
        # Browsers seem to force a download for full images, due to their large
        # size, so set an appropriate descriptive filename.
        download = request.GET.get('download', 'false').lower().startswith('t') 
        download = download or derivative == 'full'
        if download: # generate appropriate filename and set disposition
            response['Content-Disposition'] = 'attachment; filename=%s' % filename
        return response

def taxa_autocomplete(request):
    term = request.GET.get('term')
    
    sqs = SearchQuerySet().models(models.Taxon).filter(label=term)[:8]
    response = [{'id': r.pk, 'label': r.label, 'value': r.label}
                for r in sqs]
    return HttpResponse(json.dumps(response), content_type='application/json')

def specimen(request, specimen_id):
    if request.method == 'GET':
        specimen = get_object_or_404(models.Specimen, id=specimen_id)
        ctx = RequestContext(request, {'specimen': specimen})
        return render_to_response('radioapp/specimen_detail.html',
                                  context_instance=ctx)
    elif request.method == 'POST':
        specimen_form = forms.SpecimenForm(request.POST)
        if specimen_form.is_valid():
            #specimen_form.save()
            return HttpResponseRedirect(reverse('specimen-edit', args=[specimen_id]))
        else:
            import ipdb; ipdb.set_trace();
            raise Exception("Error was encountered")
    else:
        return HttpResponseNotAllowed(['GET'])

def specimens(request):
    if request.method == 'POST':
        # create new specimen from values
        specimen_form = forms.SpecimenForm(request.POST)
        if specimen_form.is_valid():
            #new_specimen = specimen_form.save()
            return HttpResponseRedirect(reverse('specimen-edit', args=[new_specimen.id]))
    else:
        return HttpResponseNotAllowed(['POST'])

@user_passes_test(lambda u: u.is_staff)
def new_specimen(request):
    if request.method == 'GET':
        specimen_form = forms.SpecimenForm()
        ctx = RequestContext(request, {'form': specimen_form})
        return render_to_response('radioapp/specimen_edit.html', context_instance=ctx)
    else:
        return HttpResponseNotAllowed(['GET'])

@user_passes_test(lambda u: u.is_staff)
def edit_specimen(request, specimen_id):
    specimen = get_object_or_404(models.Specimen, id=specimen_id)
    specimen_form = forms.SpecimenForm(instance=specimen)
    ctx = RequestContext(request, {'form': specimen_form})
    return render_to_response('radioapp/specimen_edit.html', context_instance=ctx)

def build_taxa_tree():
    taxa = (models.Taxon.objects.order_by('level')
            .values_list('id', 'parent_id', 'level'))


