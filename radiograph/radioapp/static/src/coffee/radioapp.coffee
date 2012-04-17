_ = require('underscore')._
Backbone = require('backbone')
require('jquery.chosen')

class View extends Backbone.View
  templateId: null
  viewContext: -> @model?.toJSON() ? {}
  render: ->
    super
    template = require(templateId)
    templateEl = template(@viewContext())
    @$el.html(templateEl)
    @

class SpecimenForm extends View
  templateId: 'specimen-edit'
  viewContext: -> _.extend super,
    institutionChoices: ['Harvard', 'Smithsonian'],
    sexChoices: ['M', 'F', '?'],
    taxonChoices: ['', 'Foo', 'Bar', 'Baz'],
    links: {}

  render: ->
    super
    _.defer => @$('select[name=taxon]').chosen()
    new ImagesView({el: @$('.image-controls')})
    @

class SpecimenModal extends SpecimenForm
  className = 'modal specimen-modal'
  render: ->
    super
    header = $("<div class='modal-header'><h3>Edit Specimen</h3></div>")
    @$el.prepend(header)
    @$('fieldset').addClass('modal-body')
    @$('.form-actions').addClass('modal-footer')
    @$el.modal({keyboard: false})
    @

class Specimens extends Backbone.Model
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


class Specimen extends Backbone.Model
  defaults: ->
    href: null,
    institution: null,
    sex: null,
    taxon: null,
    specimen_id: null,
    settings: null,
    comments: null,

    skull_length: null,
    cranial_width: null,
    neurocranial_height: null,
    facial_height: null,
    palate_length: null,
    palate_width: null,

    images: new ImageCollection([])

    links:
      profile: null,
      edit: null,
      delete: null

class Image extends Backbone.Model
  defaults: ->
    uri: null,
    file: null,
    replacementFile: null
    aspect: null
    links:
      profile: null,
      thumb: null,
      medium: null,
      large: null,

  toJSON: -> _.extend super,
    currentFile: @get('file')?.toJSON()
    replacementFile: @get('replacementFile')?.toJSON()

class ImageCollection extends Backbone.Collection
  model: Image

class User extends Backbone.Model
  defaults: ->
    loggedIn: false,
    firstName: 'Anonymous',
    lastName: '',
    isStaff: false,
    links:
      profile: null,
      login: null,
      logout: null

class File extends Backbone.Model
  defaults: ->
    name: null
    url: null

class CollectionModel extends Backbone.Model
  itemModel: -> CollectionItemModel
  defaults: ->
    version: null
    href: null
    items: []
    links: []
    template: [
        {name: null, value: null, choices: '<URL or list>'}
    ]
    queries: []
    error: null
    pagination:
      currentPage: 1
      totalPages: 1

  initialize: (args, opts) ->
    ItemModel = @itemModel()
    itemModels = _.map args.items, (i) =>
      item = new ItemModel(i)
      item.collection = @
      return item
    @set('items', itemModels)

class CollectionItemModel extends Backbone.Model
  defaults: ->
    href: null
    data: []
    links: []

class SearchTemplate extends Backbone.Model
  defaults: ->
    resultsPerPage: 20,
    currentPage: 1,
    totalPages: 10,
    facets: [],
    query: '*:*'

class AppModel extends Backbone.Model
  defaults: ->
    user: new User(),
    search: new Search(),
    institutionChoices: [],
    links:
      createSpecimen: ''

  initialize: ->
    super
    @alerts = new Backbone.Collection()

  alert: (type, body) =>
    type ?= 'info'
    @alerts.add
      type: type
      body: body

  toJSON: -> _.extend super,
    user: @get('user').toJSON(),
    search: @get('search').toJSON(),
    alerts: @alerts.toJSON()

App = new AppModel()

class SpecimenResults extends View
  templateId: 'templates/specimen-list'

  events: ->
    'click [rel=login]': 'showLogin',
    'click [rel=logout]': 'logout',
    'click [rel=create]': 'showCreateItemForm',
    'click [rel=edit]': 'showEditItemForm'

  initialize: ->
    super
    @model.on 'change:user', @render, @

  render: ->
    super
    if @model.get('user').get('isStaff')
      @$('[rel=edit],[rel=create]').show()
    else
      @$('[rel=edit],[rel=create]').hide()
    @

  viewContext: ->
    search = @model.get('search')
    pagination = new FormPaginationView({model: search}).render().$el.html()
    _.extend super,
      pagination: pagination

  showLogin: (e) ->
    e.preventDefault()
    e.stopPropagation()
    loginForm = new LoginFormView()
    loginForm.show()
    loginForm.$('input:visible,select:visible,textarea:visible').first().focus()
    loginForm.on 'loginsuccess', (data) =>
      @model.set('user', new User(data.user, {parse: true}))

  showCreateItemForm: (e) =>
    e.preventDefault()
    e.stopPropagation()
    new SpecimenModal().render().$('input:visible,select:visible,textarea:visible').first().focus()

  showEditItemForm: (e) =>
    e.preventDefault()
    e.stopPropagation()
    new SpecimenModal().render().$('input:visible,select:visible,textarea:visible').first().focus()

  logout: (e) =>
    e.preventDefault()
    e.stopPropagation()
    $.ajax
      url: $(e.currentTarget).attr('href'),
      dataType: 'json',
      success: =>
        @model.alert('success', 'You have been logged out successfully.')
        @model.set('user', new User())

class LoginFormView extends View
  templateId: 'login'
  events: ->
    'submit form': 'submit'

  viewContext: ->
    errors: []
    links:
      login: '/accounts/login/'

  show: -> @render().$el.modal({keyboard: false}) 
  hide: -> @$el.modal('hide')

  submit: (e) =>
    e.stopPropagation()
    e.preventDefault()
    form = $(e.currentTarget)
    $.ajax
      type: form.attr('method')
      url: form.attr('action')
      data: form.serialize()
      dataType: 'json'
      success: (data) =>
        @clearError()
        @trigger('loginsuccess', data)
        @hide()
      error: (xhr) =>
        if xhr.status == 401
          response = $.parseJSON(xhr.responseText)
          errorMsg = "Couldn't authenticate with the username/password combination provided"
        else
          errorMsg = "The server encountered an error while attempting to authenticate"
        @displayError(errorMsg)
        @trigger 'loginfailure', errorMsg, response, xhr

  clearError: => @displayError()
  displayError: (msg) =>
    if msg
      @$('.alert-error').html(msg).show()
    else
      @$('.alert-error').html('').hide()

class ImagesView extends Backbone.View
  initialize: ->
    images = _.map @$('.image-control'), (i) =>
      i = $(i)
      new Image
        id: i.find('input[type=hidden]').val(),
        aspect: i.find('select').val(),
        currentFile: new File
          name: i.find('a').text(),
          url: i.find('a').attr('href')

    @model = new ImageCollection(images)
    @model.on 'add', @addImageView, this
    @render()

  events: ->
    'click .add-image': 'addImage'

  render: ->
    @$el.empty()
    @$el.append($('<a class="btn add-image"><i class="icon-plus"></i>Add Image</a>'))
    @model.each (img) => addImageView(img)
  
  addImage: -> @model.add(new Image())

  addImageView: (img) ->
    imgView = new ImageView({model: img})
    @$('.add-image').before(imgView.render().$el)

class ImageView extends Backbone.View
  initialize: ->
    @model.on 'change', @render, this

  events: ->
    'change input[type=file]': 'replaceFile',
    'click .cancel-replace': 'cancelReplacement',
    'click .remove-image': 'remove'

  render: ->
    template = require('templates/image-control')
    fileInput = @$('.fileinput-button input[type=file]')
    collection_prefix = @model.collection.cid
    item_prefix = @model.cid
    @$el.html template
      image: @model.toJSON(),
      aspectOptions: @aspectOptions()
        
    if fileInput.length > 0
      @$('.fileinput-button input[type=file]').replaceWith(fileInput)
    @$('.dropdown-toggle').dropdown()
    return this

  replaceFile: ->
    replacementFile = new File
      name: $(e.currentTarget).val().replace("C:\\fakepath\\", "")
    @model.set('replacementFile', replacementFile)

  cancelReplacement: -> @model.set('replacementFile', null)

  aspectOptions: ->
    options = [
      {value: '', label: '---------'}
      {value: 'L', label: 'Lateral'}
      {value: 'S', label: 'Superior'}
    ]
    return _.map options, (x) =>
      x.selected = x.value == @model.get('aspect')

  remove: ->
    @model.collection.remove(@model)
    super

class PaginationView extends View
  templateId: 'pagination'
  viewContext: -> _.extend super,
    pages: @paginate(@model.get('currentPage'), @model.get('totalPages')),
    buildPageElement: @buildPageElement

  buildPageUrl: (page) =>
    params = {}
    params[@model.get('pageParam') ? 'page'] = page.pageNumber
    params = _.extend {}, @model.get('params'), params
    "#{@model.get('url')}?#{$.param(params)}"

  buildPageElement: (page) =>
    if not page.pageNumber
      "<a href='javascript:void(0)' class='inactive'>#{page.display}</a>"
    else
      "<a href='#{@buildPageUrl(page)}' rel='page'>#{page.display}</a>"

  paginate: (currentPage, totalPages, adjacent=2) ->
    adjacent ?= 2
    if totalPages <= 1 then return []
    
    createPaginationStruct = (pageNumber, display, isCurrent) ->
      pageNumber: pageNumber
      display: display ? pageNumber
      isCurrent: isCurrent ? false

    createPageNav = (pageIdx) ->
      createPaginationStruct(pageIdx, null, pageIdx == currentPage)

    chunkstart = currentPage - adjacent
    chunkend = currentPage + adjacent
    ellipsisPre = true
    ellipsisPost = true
    if (chunkstart <= 2)
      ellipsisPre = false
      chunkstart = 1
      chunkend = Math.max(chunkend, adjacent * 2)
    if (chunkend >= (totalPages - 1))
      ellipsisPost = false
      chunkend = totalPages
      chunkstart = Math.min(chunkstart, totalPages - (adjacent * 2) + 1)
    if (chunkstart <= 2) 
      ellipsisPre = false
      chunkstart = Math.max(chunkstart, 1)
      chunkend = Math.min(chunkend, totalPages)

    pages = _.map(_.range(chunkstart, chunkend + 1), createPageNav)
    if (ellipsisPre)
      pages.unshift(createPaginationStruct(null, '...'))
      pages.unshift(createPageNav(1))
    if (ellipsisPost)
      pages.push(createPaginationStruct(null, '...'))
      pages.push(createPageNav(totalPages))
    if (currentPage > 1)
      pages.unshift(createPaginationStruct(currentPage - 1, '&#xab;'))
    if currentPage < totalPages
      pages.push(createPaginationStruct(currentPage + 1, '&#xbb;'))
    
    return pages

class FormPaginationView extends PaginationView
  buildPageElement: (page) =>
    if not page.pageNumber
      "<a href='javascript:void(0)'>#{page.display}</a>"
    else
      "<button type='submit' name='#{@model.get('pageParam') ? 'page'}' 
        value='#{page.pageNumber}>#{page.display}</button>"

_.extend exports,
  'ImageView': ImageView
  'ImagesView': ImagesView
  'SpecimenForm': SpecimenForm
  'SpecimenModal': SpecimenModal
  'SpecimenResults': SpecimenResults
  'App': App
