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
        response['X-Sendfile'] = filepath            # for mod-xsendfile
        response['X-Accel-Redirect'] = '/private-media/%s' % imgfile.path  # for nginx
        
        # Browsers seem to force a download for full images, due to their large
        # size, so set an appropriate descriptive filename.
        download = request.GET.get('download', 'false').lower().startswith('t') 
        download = download or derivative == 'full'
        if download: # generate appropriate filename and set disposition
            response['Content-Disposition'] = 'attachment; filename=%s' % filename
        return response

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
