ecoTemplates = this.ecoTemplates

class File extends Backbone.Model
  defaults:
    name: null
    url: null

class Image extends Backbone.Model
  defaults:
    id: null
    aspect: null
    currentFile: null
    replacementFile: null

  toJSON: -> _.extend super,
    currentFile: @get('currentFile')?.toJSON()
    replacementFile: @get('replacementFile')?.toJSON()

class ImageCollection extends Backbone.Collection
  model: Image
  initialize: -> 
    @cid = _.uniqueId 'IMAGES_'

class ImagesView extends Backbone.View
  initialize: (attrs, options) ->
    # run progressive enhancement, picking up existing values as appropriate
    images = _.map @$('.image-control'), (i) => 
      i = $(i)
      return new Image
        id: i.find('input[type=hidden]').val()
        aspect: i.find('select').val()
        currentFile: new File
            name: i.find('a').text()
            url: i.find('a').attr('href')
    @model = new ImageCollection(images)
    @model.on('add', @addImageView, this)
    @render()

  events: ->
    'click .add-image': 'addImage'

  render: ->
    @$el.empty()
    @$el.append($('<a class="btn add-image"><i class="icon-plus"></i>Add Image</a>'))
    @model.each (img) => @addImageView(img)

  addImage: -> @model.add(new Image())

  addImageView: (img) ->
    imgView = new ImageView({model: img})
    @$('.add-image').before(imgView.render().$el)

class ImageView extends Backbone.View
  initialize: ->
    @model.on('change', @render, this)

  events: ->
    'change input[type=file]': 'replaceFile'
    'click .cancel-replace': 'cancelReplacement'
    'click .remove-image': 'remove'

  render: -> 
    fileInput = @$('.fileinput-button input[type=file]')
    collection_prefix = @model.collection.cid
    item_prefix = @model.cid
    @$el.html ecoTemplates['image-control']
      image: @model.toJSON()
      tagAs: (prop) -> 
        propTag = "#{collection_prefix}-#{item_prefix}-#{prop}"
        return "id='id_#{propTag}' name='#{propTag}'"
      aspectOptions: => @aspectOptions()

    if fileInput.length > 0
      @$('.fileinput-button input[type=file]').replaceWith(fileInput)

    @$('.dropdown-toggle').dropdown()

    return this

  replaceFile: (e) ->
    replacementFile = new File
      name: $(e.currentTarget).val().replace("C:\\fakepath\\", "")
    @model.set('replacementFile', replacementFile)

  cancelReplacement: (e) ->
    @model.set('replacementFile', null)

  aspectOptions: ->
    options = [
      { value: '', label: '---------' }
      { value: 'L', label: 'Lateral' }
      { value: 'S', label: 'Superior' }
      ]
    _.map options, (x) => 
      x.selected = (x.value == @model.get('aspect'))
      return x

  remove: ->
    @model.collection.remove(@model)
    super

this.ImageView = ImageView
this.ImagesView = ImagesView
