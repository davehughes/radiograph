from django import forms
from django.contrib.auth.models import User
from django.core.urlresolvers import reverse
from django.forms import fields, models as form_models, widgets
from djchoices import DjangoChoices as Choices, C
from peak.util.proxies import ObjectWrapper
from radiograph import models

class InstitutionForm(forms.ModelForm):
    class Meta:
        model = models.Institution

class TaxonChoiceField(forms.ModelChoiceField):
    _label_cache = None

    @property
    def label_cache(self):
        if self._label_cache is None:
            self._label_cache = {
                tid: ' '.join((ppname, pname, name)[models.TaxonomyLevels.Subspecies - tlevel:])
                for ppname, pname, name, tid, tlevel
                in (models.Taxon.objects
                    .filter(level__gte=models.TaxonomyLevels.Genus)
                    .values_list('parent__parent__name', 'parent__name', 'name', 'id', 'level'))
                }
        return self._label_cache

    def label_from_instance(self, taxon):
        label = self.label_cache.get(taxon.id)
        if not label:
            taxon = models.Taxon.objects.get(id=taxon.id)
            label = ' '.join([t.name for t in taxon.hierarchy 
                              if t.level >= models.TaxonomyLevels.Genus])
        return label

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


class SortFieldChoices(Choices):
    Field1 = C('1', 'Field 1')
    Field2 = C('2', 'Field 2')


class SortDirectionChoices(Choices):
    Ascending  = C('asc')
    Descending = C('desc')


class SpecimenSearchForm(forms.Form):
    
    taxon_filter = forms.ModelMultipleChoiceField(queryset=models.Taxon.objects.all(),
                                                  required=False)
    sex_filter = forms.MultipleChoiceField(choices=models.Specimen.SexChoices.choices
                                           required=False)
    sort_field = forms.ChoiceField(choices=SortFieldChoices.choices,
                                   initial=SortFieldChoices.Field1)
    sort_direction = forms.ChoiceField(choices=SortDirectionChoices.choices,
                                       initial=SortDirectionChoices.Ascending)
