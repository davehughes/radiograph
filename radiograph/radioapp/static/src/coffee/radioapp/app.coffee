_ = require('underscore')._
Backbone = require 'backbone'
views = require 'radioapp/views'
models = require 'radioapp/models'
api = require 'radioapp/api'

createResources = (resourceMap) ->
  defaultConfig = 
    collection: api.CollectionModel
    item: api.CollectionItemModel

  output = {}
  for rName, rUrl of resourceMap
    cfg = _.extend defaultConfig, resourceConfigs[rName] ? {}
    output[rName] = createResourceCollection(rUrl, cfg.collection, cfg.item)
  return output

resourceConfigs = 
  specimens:
    collection: models.SpecimenCollection
    item: models.Specimen

createResourceCollection = (url, collectionModel=api.CollectionModel, itemModel=api.CollectionItemModel) ->
  resource = new collectionModel()
  resource.url = url
  resource.itemModel = itemModel
  return resource

class RadioappRouter extends Backbone.Router
  routes:
    '':                   'specimenList'
    'specimens':          'specimenList'
    'specimens/:id':      'specimenDetail'
    'specimens/:id/edit': 'specimenEdit'
    # 'images/:id':         'imageDetail'
    # 'images/:id/:deriv':  'imageFile'

  specimenList: ->
    # load results and display specimen list
    App.resources.specimens.fetch
      success: =>
        App.view.pushPane new views.SpecimenSearchPane(model: App.resources.specimens)

  specimenDetail: (id) ->
    model = App.resources.specimens.get(id: id) or new Specimen(id: id)
    App.view.pushPane new views.SpecimenDetailPane(model: model)

  specimenEdit: (id) ->
    model = App.resources.specimens.get(id: id) or new Specimen(id: id)
    App.view.pushPane new views.SpecimenForm({model: model})

  imageDetail: (id) ->

  imageFile: (id, deriv) ->

_.extend exports,
  'RadioappRouter': RadioappRouter
  'createResources': createResources
