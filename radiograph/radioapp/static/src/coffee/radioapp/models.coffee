_ = require('underscore')._
Backbone = require('backbone')
api = require('radioapp/api') 
util = require('radioapp/util')

class SpecimenCollection extends api.CollectionModel
  itemModel: -> Specimen

  defaults: ->
    items: []
    queries: [{
      rel: 'search'
      href: '...'
      prompt: 'Search specimens'
      data: [
        {name: 'results_per_page', value: 20, prompt: 'Results per page'}
        {name: 'sex_filter', value: [], prompt: 'Sex filter'}
        {name: 'taxa_filter', value: [], prompt: 'Taxa filter'}
        {name: 'query', value: '*:*', prompt: 'Search string'}
      ]
    }]
    links:
      profile: null
      template: null
  
  toJSON: -> _.extend super,
    items: _.map(@get('items'), (i) -> i.toJSON())

class Specimen extends api.CollectionItemModel
  defaults: ->
    institution: null,
    sex: null,
    taxon: null,
    specimen_id: null,
    settings: null, comments: null,

    skull_length: null,
    cranial_width: null,
    neurocranial_height: null,
    facial_height: null,
    palate_length: null,
    palate_width: null,

    images: new ImageCollection([])

  parseImages: (value) ->
    console.log 'parsing images'
    value

class Image extends Backbone.Model
  defaults: ->
    uri: null
    file: null
    replacementFile: null
    aspect: null
    links:
      profile: null
      thumb: null
      medium: null
      large: null

  toJSON: -> _.extend super,
    currentFile: @get('file')?.toJSON()
    replacementFile: @get('replacementFile')?.toJSON()

class ImageCollection extends Backbone.Collection
  model: Image

class User extends Backbone.Model
  defaults: ->
    loggedIn: false
    firstName: 'Anonymous'
    lastName: ''
    isStaff: false
    links:
      profile: null
      login: null
      logout: null

class File extends Backbone.Model
  defaults: ->
    name: null
    url: null

_.extend exports,
  'User': User
  'Specimen': Specimen
  'SpecimenCollection': SpecimenCollection 
  'Image': Image
  'ImageCollection': ImageCollection
