_ = require('underscore')._
Backbone = require('backbone')
models = require('radioapp/models')
require('bootstrap')
require('jquery.chosen')

class View extends Backbone.View 
  templateId: null 
  viewContext: -> @model?.toJSON() ? {}
  render: ->
    super
    template = require(@templateId)
    templateEl = template(@viewContext())
    @$el.html(templateEl)
    @updateAuthz(App.user)
    @

  initialize: ->
    super
    App.on 'change:user', @updateAuthz, @

  updateAuthz: (user) ->

class SpecimenForm extends View
  templateId: 'templates/specimen-edit'

  events: ->
    'click [rel=discard]': 'discard'

  viewContext: -> _.extend super,
    existing: if @model then true else false
    values: {}
    choices:
      institution: []
      sex: []
      taxon: []
    links: {}

  render: ->
    super
    _.defer => @$('select[name=taxon]').chosen()
    # new ImagesView({el: @$('.image-controls')})
    @

  discard: ->
    App.view.popPane()

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

class SpecimenSearchPane extends View
  templateId: 'templates/specimen-search-form'

  events: ->
    'click [rel=create]': 'showCreateItemPane',

  render: ->
    super
    if @model.get('pagination')
      _.each @$('.pagination'), (placeholder) =>
        paginationView = new PaginationView(@model.get('pagination'))
        $(placeholder).replaceWith(paginationView.render().$el)
        paginationView.on 'navigate', @navigateToPage
    _.each @model.get('items'), (s) =>
      view = new SpecimenResult({model: s})
      @$('table tbody').append(view.render().$el)
    @

  updateAuthz: (user=App.user) ->
    if user.get('isStaff')
      @$('[rel=edit],[rel=create]').show()
    else
      @$('[rel=edit],[rel=create]').hide()

  navigateToPage: (page) =>
    console.log "navigate to page #{page}"
    # TODO: fill in form template, setting page, then submit

  showCreateItemPane: (e) =>
    e.preventDefault()
    e.stopPropagation()
    App.view.pushPane(new SpecimenForm())

class SpecimenResult extends View
  templateId: 'templates/specimen-list-item'
  tagName: 'tr'

  events: ->
    'click [rel=edit]': 'showEditPane'
    'click [rel=detail]': 'showDetailPane'

  viewContext: -> _.extend super,
    choices:
      taxon: {}
      sex: {}
      institution: {}

  showEditPane: (e) =>
    e.preventDefault()
    e.stopPropagation()
    App.view.pushPane(new SpecimenForm({model: @model}))

  showDetailPane: (e) =>
    e.preventDefault()
    e.stopPropagation()
    App.view.pushPane(new SpecimenDetailPane())

class SpecimenDetailPane extends View
  templateId: 'templates/specimen-detail'
  events: ->
    'click [rel=back]': 'back'

  viewContext: -> _.extend super,
    choices:
      taxon: {}
      sex: {}
      institution: {}

  back: (e) ->
    e.preventDefault()
    e.stopPropagation()
    App.view.popPane()

class LoginFormView extends View
  templateId: 'templates/login'
  events: ->
    'submit form': 'submit'

  viewContext: ->
    errors: []

  show: -> @render().$el.modal({keyboard: false}) 
  hide: -> @$el.modal('hide')

  submit: (e) =>
    e.stopPropagation()
    e.preventDefault()
    form = $(e.currentTarget)
    $.ajax
      type: 'POST'
      url: App.links.login
      data: form.serialize()
      dataType: 'json'
      success: (data) =>
        @clearError()
        @trigger 'loginsuccess', data
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

class AlertsView extends Backbone.View
  className: 'alerts'
  alertTemplate: _.template '''
    <div class="alert alert-<%= type %>">
        <a class="close" data-dismiss="alert">×</a>
        <%= body %>
    </div>'''

  initialize: ->
    @model.on 'published', @displayAlert

  displayAlert: (alert) => @$el.append(@alertTemplate(alert))

class AppToolbar extends View
  templateId: 'templates/app-toolbar'
  className: 'app-toolbar'
  events: ->
    'click [rel=login]': 'showLogin'
    'click [rel=logout]': 'logout'

  initialize: ->
    App.on 'change:user', @render, @

  viewContext: -> _.extend super,
    user: App.user.toJSON()

  showLogin: (e) ->
    e.preventDefault()
    e.stopPropagation()
    loginForm = new LoginFormView()
    loginForm.show()
    loginForm.$('input:visible,select:visible,textarea:visible').first().focus()
    loginForm.on 'loginsuccess', (data) =>
      App.user = new models.User(data.user, {parse: true})
      App.trigger('change:user')

  logout: (e) =>
    e.preventDefault()
    e.stopPropagation()
    $.ajax
      url: App.links.logout
      dataType: 'json'
      success: =>
        App.user = new models.User()
        App.alerts.publish('success', 'You have been logged out successfully')
        App.trigger('change:user')

class AppView extends Backbone.View
  templateId: 'templates/appview'
  className: 'appview'
  template: _.template '''
    <div class="app-toolbar"></div>
    <div class="alerts"></div>
    <div class="app-content"></div>
    '''

  initialize: ->
    @panes = []
    @toolbar = new AppToolbar(self)
    @alertsView = new AlertsView({model: App.alerts})

  render: ->
    @$el.html(@template())
    @$('.app-toolbar').replaceWith(@toolbar.render().$el)
    @$('.alerts').replaceWith(@alertsView.render().$el)
    if @pane
      @$('.app-content').append(@pane.render().$el)
    @

  pushPane: (paneView) ->
    lastPane = @pane
    @panes.push(paneView)
    @pane = paneView
    @$('.app-content').children().detach()
    @$('.app-content').append(@pane.render().$el)
    @trigger 'change:pane', {new: @pane, old: lastPane}

  popPane: ->
    lastPane = @panes.pop()
    @$('.app-content').children().detach()
    @pane = _.last(@panes)
    if @pane
      @$('.app-content').append(@pane.render().$el)
    @trigger 'change:pane', {new: @pane, old: lastPane}
    return lastPane

class SpecimenEditPane extends View
  templateId: 'templates/specimen-edit'

#class SpecimenSearchPane extends View
  # subelements: search form, results
  # data: specimens or specimens endpoint

#class SpecimenSearchForm extends View
  # subelements: pagination, results container
  # actions: go to detail, go to other page, delete, edit, create, download
  # data: pagination data, search results

#class SpecimenDetailPane extends View
  # subelements: image thumbnails, image modal (popup)
  # actions: view image detail, edit specimen
  # data: specimen, (+images)

#class SpecimenEditPane extends View
  # subelements: just edit form?
  # actions: save, discard
  # data: specimen data (+images), template and choices

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

class PaginationView extends Backbone.View
  className: 'pagination'

  initialize: (attrs) ->
    super
    @currentPage = attrs.currentPage
    @totalPages = attrs.totalPages

  events: ->
    'click [rel=page]': 'navigate'

  render: ->
    super
    paginationList = $('<ul>')
    _.each @buildPageElements(), (el) -> paginationList.append(el)
    @$el.empty().append(paginationList)
    @

  navigate: (e) ->
    e.preventDefault()
    e.stopPropagation()
    @trigger('navigate', $(e.currentTarget).data('page'))

  buildPageElements: =>
    pages = @paginate(@currentPage, @totalPages)
    _.map(pages, @buildPageElement)

  buildPageElement: (page) =>
    if not page.pageNumber
      "<a href='#' class='inactive'>#{page.display}</a>"
    else
      "<a href='#' rel='page' data-page='#{page.pageNumber}'>#{page.display}</a>"

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
  'AppView': AppView
  'ImageView': ImageView
  'ImagesView': ImagesView
  'SpecimenForm': SpecimenForm
  'SpecimenModal': SpecimenModal
  'SpecimenSearchPane': SpecimenSearchPane
