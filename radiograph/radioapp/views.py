import json
import os

from django.conf import settings
from django.contrib.auth.decorators import login_required
from django.http import HttpResponse, HttpResponseRedirect, Http404
from django.shortcuts import render_to_response, get_object_or_404
from django.template import RequestContext
from django.views.decorators.http import require_http_methods
import haystack
from haystack.query import SearchQuerySet
import haystack
import magic

from radioapp.models import Specimen, Image, Taxon

MIME = magic.Magic(mime=True)


class SearchView(haystack.views.FacetedSearchView):
    template = 'radioapp/specimen_list.html'
    load_all = True

    def __init__(self, *args, **kwargs):
        kwargs.setdefault('form_class', SearchForm)
        super(SearchView, self).__init__(*args, **kwargs)

    def create_response(self, *args, **kwargs):
        return super(SearchView, self).create_response(*args, **kwargs)

#    def build_form(self, form_kwargs=None):
#        super(SearchView, self).build_form(form_kwargs)


class SearchForm(haystack.forms.SearchForm):
    facets = [{
        'field': 'sex', 
        'label': 'Sex',
        'multi': False
        }, {
        'field': 'species_facet', 
        'label': 'Species/subspecies',
        'multi': True
    }]

    def __init__(self, *args, **kwargs):
        self.selected_facets = kwargs.pop("selected_facets", [])
        super(SearchForm, self).__init__(*args, **kwargs)
    
    def search(self):
        sqs = super(SearchForm, self).search()

        multifacets = {}
        for facet in self.selected_facets:
            if ':' not in facet:
                continue
                
            field, value = facet.split(':', 1)
            facet = facet_map[field]
            if facet.get('multi', False):
                multifacets.setdefault(field, []).append(value)
            else:
                sqs = sqs.narrow(u'%s:"%s"' % (field, sqs.query.clean(value)))
                
        for field, vals in multifacets:
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

def specimen(request, specimen_id):
    if request.method == 'GET':
        specimen = get_object_or_404(Specimen, id=specimen_id)
        ctx = RequestContext(request, {
            'specimen': specimen,
            'images': specimen.images.all()
            })
        return render_to_response('radioapp/specimen_detail.html',
                                  context_instance=ctx)
    elif request.method == 'POST':
        # TODO: implement update handling
        pass

def image(request, image_id, derivative='medium'):
    if request.method == 'GET':
        image = get_object_or_404(Image, id=image_id)
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
        response['Content-Type'] = MIME.from_file(filepath)
        
        # Browsers seem to force a download for full images, due to their large
        # size, so set an appropriate descriptive filename.
        download = request.GET.get('download', 'false').lower().startswith('t') 
        download = download or derivative == 'full'
        if download: # generate appropriate filename and set disposition
            response['Content-Disposition'] = 'attachment; filename=%s' % filename
        return response

def taxa_autocomplete(request):
    term = request.GET.get('term')
    
    sqs = SearchQuerySet().models(Taxon).filter(label=term)[:8]
    response = [{'id': r.pk, 'label': r.label, 'value': r.label}
                for r in sqs]
    return HttpResponse(json.dumps(response), content_type='application/json')



