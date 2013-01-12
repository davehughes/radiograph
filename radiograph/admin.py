from django.contrib import admin

from radiograph import models, views


class TaxonListFilter(admin.SimpleListFilter):
    title = 'Taxon'
    parameter_name = 'taxon'

    def lookups(self, request, model_admin):
        return []
        # return views._taxon_choices()
    
    def queryset(self, request, queryset):
        if self.value():
            queryset = queryset.filter(taxon=self.value())
        return queryset

class ImageInline(admin.TabularInline):
    model = models.Image
    exclude = ('image_thumbnail', 'image_medium')

class SpecimenAdmin(admin.ModelAdmin):
    inlines = [ ImageInline ]
    list_display = ('specimen_id', 'sex')
    list_editable = ('sex',)
    list_filter = ('sex', TaxonListFilter)
    search_fields = ('specimen_id',)
    exclude = ('created_by', 'last_modified_by')
    fields = (
         'institution', 
         'specimen_id',
         'taxon',
         'sex',
         ('skull_length', 'cranial_width', 'neurocranial_height'),
         ('facial_height', 'palate_length', 'palate_width'),
         'settings',
         'comments'
    ) 
         

admin.site.register(models.Specimen, SpecimenAdmin)
admin.site.register(models.Institution, admin.ModelAdmin)
