_ = require('underscore')._
fs = require('fs')
async = require('async')
zipstream = require('zipstream')
zappa = require('zappa')

# start zappa application
zipper = zappa.app ->

  @get '/': ->
    @render 'main'

  @get '/specimens': ->          # view specimen list
    helpers =
      icon: (name) -> i class: "icon-#{name}"
    @render 'image-control':
      name: 'foo.jpg'
      hardcode: helpers

  @post '/specimens': ->         # new specimen

  @get '/specimens/:id': ->      # specimen detail
    # @render 'index',
    #   name: "Specimen #{ @params.id }"
 
  @get '/specimens/new': ->      # create specimen form

  @post '/specimens/:id': ->     # update specimen

  @get '/specimens/:id/edit': -> # edit specimen form

  @get '/images/:id': ->
      
  @get '/images/:id/:derivative': ->

  @get '/specimens/data': ->
    @response.writeHead 200
    streamZip @response, files, @response.end
    
  @include './views'

  @view layout: ->
    doctype 5
    html ->
      head ->
        title @title
      body ->
        @body

  @helper icon: (name) -> 'foo' #i class: "icon-#{name}"

zipper.app.listen 8002

# template helpers
helpers = 
  menuItem: (url, text, icon, file=false) ->
    li ->
      a href: @url ->
        i class: icon
        span text 
        if file then input type: file
  
  icon: (name) -> i class: "icon-#{name}"
  caret: -> span '.caret', '&nbsp;'

data =
  labels: 
    specimenId: 'Specimen ID'
    taxon: 'Taxon'
    sex: 'sex'
  rows: [{
    specimenId: '1'
    sex: 'M'
    taxon: 'Alouatta belzebul'
    images: [
        {aspect: 'L', path: '/tmp/ziptest/test.txt'},
        {aspect: 'S', path: '/tmp/ziptest/test2.txt'}
      ]
    },{
    specimenId: '2'
    sex: 'F'
    taxon: 'Cebus apella apella'
    images: [
        {aspect: 'L', path: '/tmp/ziptest/test.txt'},
        {aspect: 'S', path: '/tmp/ziptest/test2.txt'}
      ]
    }]

streamZip = (out, files, callback) ->
  zip = zipstream.createZip level: 1
  zip.pipe(out)

  # create functions to add files to zip
  fileSeries = _.map files, (f) ->
    return (cb) -> zip.addFile(fs.createReadStream(f.path), name: f.name, cb)
  fileSeries.push (cb) -> zip.finalize(cb)

  # run the series
  async.series fileSeries, callback

files = []
_.each data.rows, (row) ->
  _.each row.images, (image) ->
    files.push
      name: "data/#{ row.taxon }/#{ image.aspect }.txt"
      path: image.path

#streamZip fs.createWriteStream('/tmp/ziptest/out.zip'), files
#testZip()


