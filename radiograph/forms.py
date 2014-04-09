from django import forms
from django.contrib.auth.models import User
from django.core.paginator import Paginator, InvalidPage
from django.core.urlresolvers import reverse
from django.forms import fields, models as form_models, widgets
from djchoices import DjangoChoices as Choices, C
from peak.util.proxies import ObjectWrapper
from radiograph import models

class InstitutionForm(forms.ModelForm):
    class Meta:
        model = models.Institution

class TaxonChoiceField(forms.ModelChoiceField):
    def label_from_instance(self, taxon):
        return taxon.label

class InstitutionChoiceField(forms.ModelChoiceField):
    def label_from_instance(self, institution):
        return institution.name

class SpecimenForm(forms.ModelForm):
    _taxon_attrs = {
        'class': 'taxon-autocomplete',
        'data-placeholder': 'Choose genus/species'
        }
    taxon = TaxonChoiceField(label='Taxon', 
                             queryset=models.Taxon.objects.filter(level__gt=7),
                             widget=forms.Select(attrs=_taxon_attrs))
    institution = InstitutionChoiceField(label="Institution",
                                         queryset=models.Institution.objects.all())
    created_by = form_models.ModelChoiceField(queryset=User.objects.all())

    specimen_id = fields.CharField(required=False)
    sex = form_models.ChoiceField(required=False,
                                  choices=models.Specimen.SexChoices.choices)
    settings = fields.CharField(required=False)
    comments = fields.CharField(required=False)

    # cranial measurements
    skull_length = fields.DecimalField(required=False)
    cranial_width = fields.DecimalField(required=False)
    neurocranial_height = fields.DecimalField(required=False)
    facial_height = fields.DecimalField(required=False)
    palate_length = fields.DecimalField(required=False)
    palate_width = fields.DecimalField(required=False)

    class Meta:
        model = models.Specimen
        widgets = {
            'settings': forms.Textarea(attrs={'rows': '', 'cols': '', 'class': 'span8'}),
            'comments': forms.Textarea(attrs={'rows': '', 'cols': '', 'class': 'span8'})
            }


class CustomFileInput(widgets.ClearableFileInput):
    template_with_initial = u'%(initial_text)s: %(initial)s %(clear_template)s | %(input_text)s: %(input)s'

    def render(self, name, value, attrs=None):
        '''
        Wraps value to override the default URL with our custom mod_xsendfile
        handler.
        '''
        url = getattr(value, 'url', None)
        if url:
            class Wrap(ObjectWrapper):
                url = reverse('image', args=[value.instance.id, 'full'])
            value = Wrap(value)
        return super(CustomFileInput, self).render(name, value, attrs=attrs)


class ImageForm(forms.ModelForm):
    class Meta:
        model = models.Image
        widgets = {
            'aspect': forms.Select(attrs={'class': 'span2'}),
            'image_full': CustomFileInput()
            }


class SpecimenFormSet(form_models.BaseInlineFormSet):
    def add_fields(self, form, index):
        super(SpecimenFormSet, self).add_fields(form, index)
        try:
            instance = self.get_queryset()[index]
            pk_value = instance.pk
        except IndexError:
            instance = None
            pk_value = hash(form.prefix)

        form.images = ImageFormSet(data=self.data,
                         instance=instance,
                         prefix='IMAGES_%s' % pk_value)


ImageFormSet = form_models.inlineformset_factory(models.Specimen,
                                                 models.Image,
                                                 form=ImageForm,
                                                 extra=0)


class SortField(Choices):
    Field1 = C('1', 'Field 1')
    Field2 = C('2', 'Field 2')


class SortDirection(Choices):
    Ascending  = C('asc')
    Descending = C('desc')


class SearchResultsView(Choices):
    StandardList = C('standard')
    CompactList  = C('compact')
    Tiles        = C('tiles')

TAXON_LABEL_CACHE = models.taxon_label_cache()
TAXON_FILTER_CHOICES = [
    (t.id, TAXON_LABEL_CACHE[t.id])
    for t in models.Taxon.objects.filter(level=models.TaxonomyLevels.Species)
]
TAXON_FILTER_CHOICES.sort(key=lambda(k, v): v)

class SpecimenSearchForm(forms.Form):
    
    taxa = forms.MultipleChoiceField(choices=TAXON_FILTER_CHOICES, required=False)
    sex = forms.MultipleChoiceField(choices=models.Specimen.SexChoices.choices,
                                    required=False)
    sort = forms.ChoiceField(choices=SortField.choices,
                             initial=SortField.Field1,
                             required=False)
    sort_direction = forms.ChoiceField(choices=SortDirection.choices,
                                       initial=SortDirection.Ascending,
                                       required=False)
    view = forms.ChoiceField(choices=SearchResultsView.choices,
                             initial=SearchResultsView.StandardList,
                             required=False)
    page = forms.IntegerField(initial=1, required=False)
    results = forms.ChoiceField(
	initial=10,
	choices=[(x, x) for x in [10, 20, 50, 100]],
	required=False,
	)

    def results_page(self):
        page = 1
        results = 10
        if self.is_bound and self.is_valid():
            page = self.cleaned_data.get('page') or 1
            results = self.cleaned_data.get('results') or 10
        paginator = Paginator(self.get_query_set(), results)
        return paginator.page(page)

    def get_query_set(self):
        qs = models.Specimen.objects.all()
        if self.is_bound and self.is_valid():
            if self.cleaned_data['taxa']:
                qs = qs.filter(taxon__in=self.cleaned_data['taxa'])
            if self.cleaned_data['sex']:
                qs = qs.filter(sex__in=self.cleaned_data['sex'])
            if self.cleaned_data['sort']:
                order_by = self.cleaned_data['sort']
                if self.cleaned_data.get('sort_direction') is SortDirection.Descending:
                    order_by = '-' + order_by
                qs = qs.order_by(order_by)
        else:
            pass

        return qs
