from django.shortcuts import render_to_response, get_object_or_404
from django.template import RequestContext

from radioapp.models import Specimen, Image

def specimen(request, specimen_id):
    if request.method == 'GET':
        specimen = get_object_or_404(Specimen, id=specimen_id)
        ctx = RequestContext(request, {
                'specimen': specimen,
                'images': specimen.images.all()
                })
        return render_to_response('radioapp/specimen_detail.html',
                                  context_instance=ctx)
