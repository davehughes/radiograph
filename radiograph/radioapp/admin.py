from django.contrib import admin

from radioapp import models 


class ImageInline(admin.TabularInline):
    model = models.Image
    exclude = ('image_thumbnail', 'image_medium')

class SpecimenAdmin(admin.ModelAdmin):
    inlines = [ ImageInline ]
    list_display = ('specimen_id', 'sex')
    list_editable = ('sex',)
    list_filter = ('sex',)

admin.site.register(models.Specimen, SpecimenAdmin)
