from django import forms
from django.forms import fields, models as form_models
from radioapp import models

class InstitutionForm(forms.ModelForm):
    class Meta:
        model = models.Institution

class TaxonChoiceField(forms.ModelChoiceField):
    _label_cache = None

    @property
    def label_cache(self):
        if self._label_cache is None:
            cache = {}
            taxa = (models.Taxon.objects
                    .filter(level__gte=models.GENUS)
                    .values_list('parent__parent__name', 'parent__name', 'name',
                                 'id', 'level'))
            for ppname, pname, name, tid, tlevel in taxa:
                cache[tid] = ' '.join((ppname, pname, name)[models.SUBSPECIES - tlevel:])

            self._label_cache = cache
        return self._label_cache

    def label_from_instance(self, taxon_id):
        lc = self.label_cache
        label = self.label_cache.get(taxon_id)
        if not label:
            taxon = models.Taxon.objects.get(id=taxon_id)
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
                             queryset=(models.Taxon.objects.filter(level__gt=7)
                                       .values_list('id', flat=True)),
                             widget=forms.Select(attrs=_taxon_attrs))
    institution = InstitutionChoiceField(label="Institution",
                                         queryset=models.Institution.objects.all())

    class Meta:
        model = models.Specimen
        widgets = {
            'settings': forms.TextInput(attrs={'class': 'input-xlarge'})
        }

    @property
    def images(self):
        if self.instance:
            return ImageFormSet(instance=self.instance,
                                prefix='IMAGES_%s' % self.instance.id)

class ImageForm(forms.ModelForm):
    class Meta: 
        model = models.Image

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
                                                 extra=1)
