_ = require('underscore')._
Backbone = require('backbone')
api = require('radiograph/api') 
util = require('radiograph/util')

class Specimen extends api.CollectionItemModel
  urlRoot: '/specimens'

  defaults: ->
    institution: null,
    sex: null,
    taxon: null,
    specimenId: null,
    settings: null, comments: null,

    skullLength: null,
    cranialWidth: null,
    neurocranialHeight: null,
    facialHeight: null,
    palateLength: null,
    palateWidth: null,

    images: new ImageCollection([])

  parseImages: (value) -> new ImageCollection(_.map(value, (v) -> new Image(v)))

  toJSON: -> _.extend super,
    images: @get('images').toJSON()

class SpecimenCollection extends api.CollectionModel
  itemModel: Specimen

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

class Image extends Backbone.Model
  defaults: ->
    href: null
    name: null
    url: null
    aspect: 'L'
    replacementFile: null
    links:
      profile: null
      thumb: null
      medium: null
      large: null

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

class SearchManager extends Backbone.Model
  defaults: ->
    page: null
    sortField: null
    sortDirection: null
    perPage: 20
    query: null

  toJSON: ->
    keymap = 
      sortField: 'sort_field'
      sortDirection: 'sort_direction'
      perPage: 'results_per_page'
      query: 'q'
    json = super
    for k in _.keys(json)
      if not json[k]
        delete json[k]
      else if keymap[k]
        json[keymap[k]] = json[k]
        delete json[k]
    return json

_.extend exports,
  'User': User
  'Specimen': Specimen
  'SpecimenCollection': SpecimenCollection 
  'Image': Image
  'ImageCollection': ImageCollection
  'SearchManager': SearchManager
