_ = require('underscore')._
Backbone = require('backbone')
models = require('radiograph/models')
require('bootstrap')
require('jquery.chosen')
require('jquery.fileupload')

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

  ignore: (e) ->
    e.preventDefault()
    e.stopPropagation()

class SpecimenForm extends View
  templateId: 'templates/specimen-edit'

  events: ->
    'click [rel=discard]': 'discard'
    'click .dropdown.sex .dropdown-menu': 'ignore'
    'click [rel=save]': 'save'
    'click [rel=add-image]': (e) ->
      e.preventDefault()
      e.stopPropagation()
      img = new models.Image()
      @model.get('images').add(img, {silent: true})
      @addImage(img)
    'change [name=institution],
            [name=specimenId],
            [name=taxon],
            [name=sex],
            [name=skullLength],
            [name=cranialWidth],
            [name=neurocranialHeight],
            [name=facialHeight],
            [name=palateLength],
            [name=palateWidth],
            [name=comments],
            [name=settings]': (e) =>
      control = $(e.currentTarget)
      @model.set(control.attr('name'), control.val())

  viewContext: -> _.extend super,
    existing: if @model then true else false
    links: {}

  render: ->
    super

    # set select values
    @$('[name=institution]').val(@model.get('institution'))
    @$('[name=taxon]').val(@model.get('taxon'))
    @$('[name=sex]').val(@model.get('sex'))

    _.defer => @$('[name=taxon]').chosen()
    
    @model.get('images').each @addImage

    @$('form').fileupload
      url: @model.get('href') or @model.collection.get('href')
      # url: '/specimens/'
      formData: @getSpecimenData
      fileInput: null
      dropZone: null

    @

  addImage: (img) =>
    imgView = new ImageView({model: img})
    @$('.image-controls').append(imgView.render().$el)

  discard: ->
    App.view.popPane()

  save: (e) ->
    fileInputs = _.filter @$('.replacementFile input[type=file]'), (input) => $(input).val()
    if fileInputs.length == 0
      specimenData = @getSpecimenData()[0]
      ajaxData = {}
      ajaxData[specimenData.name] = specimenData.value
    
      xhr = $.ajax
        url: @model.get('href') or @model.collection.get('href')
        type: 'POST'
        data: ajaxData
    else
      files = _.map(fileInputs, (f) -> f.files[0])
      paramNames = _.map(fileInputs, (f) -> $(f).attr('name'))
      xhr = @$('form').fileupload 'send',
        files: files
        paramName: paramNames

      @$('.submission-status').show()
        .find('.bar').css('width', 0)
      @$('form').on 'fileuploadprogress', (e, data) =>
        width = "#{(data.loaded * 100) / data.total}%"
        @$('.submission-status .bar').css('width', width)
        console.log "progress: #{width}"

    @$('[rel=save], [rel=discard]').attr('disabled', 'disabled').addClass('disabled')

    xhr.done (response) =>
      console.log 'save successful'
      App.view.popPane()

    xhr.fail (response) =>
      alert 'Error saving specimen'

    xhr.always =>
      @$('.submission-status').hide()
        .find('.bar').css('width', 0)
      @$('[rel=save], [rel=discard]').removeAttr('disabled').removeClass('disabled')

  getSpecimenData: (args...) =>
    specimenData = @model.toJSON()
    _.each specimenData.images or [], (img) ->
      delete img.links
      delete img.name
      delete img.url
      if img.replacementFile
        img.replacementFile = img.replacementFile.file
      else
        delete img.replacementFile

    [{name: 'specimen', value: JSON.stringify specimenData}]

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
    'click [rel=create]': 'showCreateItemPane'
    'click .icon-search': 'setQuery'
    'keydown [name=q]': (e) => if e.keyCode == 13 then @setQuery()
    'click [rel=results-per-page]': 'setResultsPerPage'
    'click [rel=sort-field]': 'setSortField'
    'click [rel=sort-direction]': 'setSortDirection'
  
  initialize: ->
    super
    @searchMgr = new models.SearchManager()
    @searchMgr.on 'change', @loadSearch

  render: ->
    super
    @renderPagination()
    @renderResults()
    @$('.results-loading').hide()
    @

  renderPagination: ->
    if @model.get('pagination')
      _.each @$('.pagination'), (placeholder) =>
        paginationView = new PaginationView(@model.get('pagination'))
        $(placeholder).replaceWith(paginationView.render().$el)
        paginationView.on 'navigate', (page) => @searchMgr.set 'page', page

  renderResults: ->
    @$('table tbody .result-row').remove()
    _.each @model.get('items'), (s) =>
      view = new SpecimenResult({model: s})
      @$('table tbody').append(view.render().$el)

  updateAuthz: (user=App.user) ->
    if user.get('isStaff')
      @$('[rel=edit],[rel=create]').show()
    else
      @$('[rel=edit],[rel=create]').hide()

  showCreateItemPane: (e) =>
    e.preventDefault()
    e.stopPropagation()
    model = new models.Specimen()
    model.collection = @model

    App.router.navigate "/specimens/${model.id}"
    App.view.pushPane new views.SpecimenForm(model: model)

  loadSearch: (e) =>
    $('.results-loading').show()
    $('.results-placeholder').hide()
    xhr = $.ajax
      type: 'GET'
      url: @model.get('href')
      data: @searchMgr.toJSON()
      dataType: 'json'

    xhr.done (data) =>
      # TODO: update results
      @model = new models.SpecimenCollection(data, {parse: true})
      @renderPagination()
      @renderResults()
      $('.results-loading').hide()
      $('.results-placeholder').show()

  setQuery: (e) ->
    @searchMgr.set 'query', @$('input[name=q]').val()

  setResultsPerPage: (e) ->
    @searchMgr.set
      perPage: $(e.currentTarget).text()
      page: null
    $(e.currentTarget)
      .parents('.dropdown')
      .find('.dropdown-display')
      .text $(e.currentTarget).text()

  setSortField: (e) ->
    @searchMgr.set 'sortField', $(e.currentTarget).data('value')
    $(e.currentTarget)
      .parents('.dropdown')
      .find('.dropdown-display')
      .text $(e.currentTarget).text()

  setSortDirection: (e) ->
    @searchMgr.set 'sortDirection', $(e.currentTarget).data('value')
    $(e.currentTarget).hide().siblings().show()

class SpecimenResult extends View
  templateId: 'templates/specimen-list-item'
  tagName: 'tr'
  className: 'result-row'

  events: ->
    'click [rel=edit]': 'showEditPane'
    'click [rel=detail]': 'showDetailPane'

  initialize: ->
    @model.on 'change', @render, @

  showEditPane: (e) =>
    e.preventDefault()
    e.stopPropagation()
    App.router.navigate "#{@model.url}/edit"
    App.view.pushPane new SpecimenForm(model: @model)

  showDetailPane: (e) =>
    e.preventDefault()
    e.stopPropagation()
    App.router.navigate "#{@model.url}"
    App.view.pushPane new SpecimenDetailPane(model: @model)

class SpecimenDetailPane extends View
  templateId: 'templates/specimen-detail'
  events: ->
    'click [rel=back]': 'back'
    'click [rel=edit]': 'showEditPane'

  back: (e) ->
    e.preventDefault()
    e.stopPropagation()
    App.view.popPane()

  showEditPane: (e) =>
    e.preventDefault()
    e.stopPropagation()
    App.router.navigate "#{@model.url}/edit"
    App.view.pushPane(new SpecimenForm(model: @model))

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

class DataView extends Backbone.View

  render: ->
    super

    w = 500
    h = 500
    
    @svg = d3.select(@el)
      .append('svg:svg')
      .attr('width', w)
      .attr('height', h)

    @chart = @svg.append('rect')
      .attr('x', 0.1 * @svg.attr('width'))
      .attr('y', 0)
      .attr('width', 0.9 * @svg.attr('width'))
      .attr('height', 0.9 * @svg.attr('height'))
      .style('fill', 'green')
    
    # Create and configure axes
    x = d3.scale.linear()
      .range([@chart.attr('x'), parseInt(@chart.attr('x')) + parseInt(@chart.attr('width'))])
    y = d3.scale.linear()
      .range([parseInt(@chart.attr('y')) + parseInt(@chart.attr('height')), @chart.attr('y')])
    xAxis = d3.svg.axis().scale(x).orient('bottom')
    yAxis = d3.svg.axis().scale(y).orient('left')

    @svg.append('svg:g')
      .call(xAxis)
      .attr('transform', "translate(0, #{0.9 * @svg.attr('height')})")

    @svg.append('svg:g')
      .call(yAxis)
      .attr('transform', "translate(#{0.1 * @svg.attr('width')}, 0)")

    data = _.map d3.range(20), -> x: Math.random(), y: Math.random()
    circles = @svg.selectAll('circle')
      .data(data)


    circles
      .enter().append('svg:circle')
        .attr('cx', (d) -> x(d.x))
        .attr('cy', (d) -> y(d.y))
        .attr('r', 3)
        .style('stroke', 'black')
        .style('fill', 'red')
        # .on('click', (d) -> console.log d)

    circles
      .exit().remove()

    @

# property = (name, gs) ->
#   if not _.isString(name) then gs = name
#   (value) ->
#     if value?
#       if gs.set then gs.set(value) else throw 'Value has no setter'
#       @
#     else
#       if gs.get then gs.get() else throw 'Value has no getter'

# class D3Chart
#   initialize: (@config) ->

#   foo: property 'foo',
#     get: -> 


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
    'click [rel=visualize]': 'showVisualizations'

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

  showVisualizations: ->
    App.view.pushPane new DataView()

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

class ImageView extends View
  templateId: 'templates/image-control'
  className: 'image-view'

  initialize: ->
    @model.on 'change', @render

  events: ->
    'change input[type=file]': 'replaceFile',
    'click .cancel-replace': 'cancelReplacement',
    'click [rel=remove-image]': 'remove'

  render: =>
    # transfer existing file inputs over to the new rendered element
    replacementInput = @$('.replacementFile input[type=file]')
    super
    @$('.replacementFile').empty().append(replacementInput)
    @$('.dropdown-toggle').dropdown()
    @

  replaceFile: (e) =>
    fileInput = $(e.currentTarget)
    fileId = "file-#{@model.cid}"
    fileInput.attr('name', fileId)
    @$('.replacementFile').empty().append(fileInput)
    @model.set 'replacementFile',
      name: fileInput.val().replace("C:\\fakepath\\", "")
      file: fileId

  cancelReplacement: =>
    @$('.replacementFile').empty()
    @model.set 'replacementFile', null

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
      "<li><a href='#' class='inactive'>#{page.display}</a></li>"
    else
      "<li><a href='#' rel='page' data-page='#{page.pageNumber}'>#{page.display}</a></li>"

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
      pages.unshift(createPaginationStruct(null, '&hellip;'))
      pages.unshift(createPageNav(1))
    if (ellipsisPost)
      pages.push(createPaginationStruct(null, '&hellip;'))
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
  'DataView': DataView
  'SpecimenForm': SpecimenForm
  'SpecimenModal': SpecimenModal
  'SpecimenSearchPane': SpecimenSearchPane
  'SpecimenDetailPane': SpecimenDetailPane
