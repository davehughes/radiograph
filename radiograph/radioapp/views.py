import os

from django.conf import settings
from django.http import HttpResponse, HttpResponseRedirect, Http404
from django.shortcuts import render_to_response, get_object_or_404
from django.template import RequestContext
from haystack.query import SearchQuerySet
import magic

from radioapp.models import Specimen, Image

MIME = magic.Magic(mime=True)


def index(request):
    if request.method == 'GET':
        # do haystack search
        # list all parameters as run through specimen results template
        query = SearchQuerySet().all().facet('sex').facet('species_facet')
        ctx = RequestContext(request, { 
                'results': query,
                'facets': query.facet_counts()
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
        download = request.GET.get('download', 'false')\
            .lower().startswith('t') 
        download = download or derivative == 'full'
        if download: # generate appropriate filename and set disposition
            response['Content-Disposition'] = 'attachment; filename=%s' % filename
        return response


