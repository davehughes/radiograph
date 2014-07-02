import copy
import csv
import datetime
import simplejson as json
import math
import mimetypes
import os
import types
import uuid

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
import pysolr
from radiograph import forms, models, util

#---------------------{ Context processors }-----------------------------------
def main_menu(request):
    menu_items = [
        {'label': 'About', 'link': reverse('index'), 'route': 'index'},
        {'label': 'Specimens', 'link': reverse('specimen-list'), 'route': 'specimen-list'},
        {'label': 'Download', 'link': reverse('download-dataset'), 'route': 'download-dataset'},
        ]
    try:
        route = resolve(request.path)
    except:
        route = None

    if route:
        url_name = route.url_name
        for item in menu_items:
            if item.get('route') == url_name:
                item['active'] = True
                break

    return {
        'mainmenu': menu_items,
    }


def index(request):
    return render(request, 'radiograph/about.html', {
            'specimen_count': models.Specimen.objects.count()
        })


def specimens(request):
    # TODO: read initial values from user's session
    queryset = (models.Specimen.objects
        .exclude(image_lateral__isnull=True)
        .exclude(image_superior__isnull=True))
    search_form = forms.SpecimenSearchForm(request.REQUEST, queryset=queryset)
    return render(request, 'radiograph/specimen-list.html', {
            'search_form': search_form,
        })


def specimen(request, specimen_id):
    specimen = get_object_or_404(models.Specimen, id=specimen_id)
    return http.HttpResponse('Found specimen')


def download(request):
    queryset = (models.Specimen.objects
        .exclude(image_lateral__isnull=True)
        .exclude(image_superior__isnull=True))
    return render(request, 'radiograph/download.html', {
        'sample_image': queryset[0].image_lateral,
        })


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
        'sex': dict(models.Specimen.SexChoices.choices),
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

        _, ext = os.path.splitext(imgfile.path)
        filename = '%s-%s-%s-%s%s' % (image.specimen.taxon.label,
                                      image.specimen.id,
                                      image.get_aspect_display(),
                                      derivative,
                                      ext)
        filepath = os.path.join(settings.MEDIA_ROOT, imgfile.path)

        mime = mimetypes.guess_type(filepath)[0]
        response = http.HttpResponse(mimetype=mime)
        response['X-Sendfile'] = filepath            # for mod-xsendfile
        response['X-Accel-Redirect'] = u'/private-media/{}'.format(imgfile.name) # for nginx
        print 'X-Accel-Redirect: {}'.format(response['X-Accel-Redirect'])

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


def download_zip(request):
    # Write JSON config file
    # Redirect
    # TODO: apply user specified form/filter
    # TODO: apply aspect filter
    specimens = models.Specimen.objects.filter(image_lateral__isnull=False)[:1]

    images = (models.Image.objects
              .filter(specimen__in=specimens)
              .select_related('specimen', 'specimen_taxon'))
    files = []
    size = 'full'
    for image in images:
        format_args = {
            'specimen_id': image.specimen.specimen_id,
            'taxon': image.specimen.taxon.label,
            'aspect': image.get_aspect_display(),
            'size': size,
            'ext': 'png',
            }
        image_deriv = getattr(image, 'image_{}'.format(size))
        path = os.path.join(settings.AWS_LOCATION, image_deriv.name)
        zip_path = u'Primate Radiographs/{taxon}-{specimen_id}/{aspect}-{size}.{ext}'.format(**format_args)
        files.append({'src': path, 'dest': zip_path})

    download_config = {
        'type': 's3',
        'filename': 'Primate Radiographs.zip',
        'opts': {
            'bucket': settings.AWS_STORAGE_BUCKET_NAME,
            },
        'files': files,
    }
    print u'Download config: {}'.format(download_config)

    # Dump the mappings to a file in the download config directory
    download_id = str(uuid.uuid4())
    download_config_file = os.path.join(settings.ZIPPER_DOWNLOAD_DIR, download_id) + '.json'
    json.dump(download_config, open(download_config_file, 'w'))

    # Have nginx do an internal redirect to the zipper server
    response = http.HttpResponse()
    response['X-Accel-Redirect'] = '/zipper/{}'.format(download_id)
    return response
