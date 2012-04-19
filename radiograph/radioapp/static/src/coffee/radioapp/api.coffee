_ = require('underscore')._
Backbone = require('backbone')

class CollectionModel extends Backbone.Model
  itemModel: -> CollectionItemModel
  defaults: ->
    version: null
    href: null
    items: []
    links: []
    template: null
    queries: []
    error: null
    pagination:
      currentPage: 1
      totalPages: 1

  parse: (input) ->
    collection = input.collection
    ItemModel = @itemModel()
    collection.items = _.map collection.items, (i) =>
      item = new ItemModel(i, {parse: true})
      item.collection = @
      return item
    return collection

  getLink: (rel) -> _.find(@links, (l) -> l.rel == rel)
  fetchTemplate: (callback) ->
    if @get('template') then callback(@get('template'))
    if @getLink('template')
      if not @_templateXHR
        @_templateXHR = $.ajax
          url: @getLink('template')
          dataType: 'json'
      @_templateXHR.done(callback)
    return null 

class CollectionItemModel extends Backbone.Model
  defaults: ->
    href: null
    links: []

  ###
  Map from collection+json style data fields (e.g. [{name: 'foo', value: 'bar'}, ...])
  to a dictionary (e.g. {'foo': 'bar', ...}), optionally using a parse function.

  Parse functions should be named by concatenating the string 'parse' and the 
  capitalized name of the field to be transformed (e.g., to specify a function to
  transform the field 'foo', the class should provide a 'parseFoo' method).
  ###
  parse: (input) ->
    mapField = (memo, field) =>
      parseFunc = @["parse#{field.name.charAt(0).toUpperCase()}#{field.name.slice(1)}"]
      memo[field.name] = if parseFunc then parseFunc(field.value) else field.value
      return memo
    fieldValues = _.reduce(input.data, mapField, {})
         
    return _.extend fieldValues,
      href: input.href
      links: input.links

_.extend exports,
  'CollectionModel': CollectionModel
  'CollectionItemModel': CollectionItemModel
