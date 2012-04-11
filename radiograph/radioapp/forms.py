from django import forms
from django.forms import fields, models as form_models, widgets
from django.core.urlresolvers import reverse
from peak.util.proxies import ObjectWrapper
from radioapp import models

class InstitutionForm(forms.ModelForm):
    class Meta:
        model = models.Institution

class TaxonChoiceField(forms.ModelChoiceField):
    _label_cache = None

    @property
    def label_cache(self):
        if self._label_cache is None:
            self._label_cache = {
                tid: ' '.join((ppname, pname, name)[models.SUBSPECIES - tlevel:])
                for ppname, pname, name, tid, tlevel
                in (models.Taxon.objects
                    .filter(level__gte=models.GENUS)
                    .values_list('parent__parent__name', 'parent__name', 'name', 'id', 'level'))
                }
        return self._label_cache

    def label_from_instance(self, taxon):
        label = self.label_cache.get(taxon.id)
        if not label:
            taxon = models.Taxon.objects.get(id=taxon.id)
            label = ' '.join([t.name for t in taxon.hierarchy 
                              if t.level >= models.GENUS])
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
            instance=None
            pk_value = hash(form.prefix)
                        
        form.images = ImageFormSet(data=self.data,
                         instance=instance,
                         prefix='IMAGES_%s' % pk_value)


ImageFormSet = form_models.inlineformset_factory(models.Specimen,
                                                 models.Image,
                                                 form=ImageForm,
                                                 extra=0)
