_ = require('underscore')._
fs = require('fs')
async = require('async')
zipstream = require('zipstream')
zappa = require('zappajs')
http = require('http')
url = require('url')

api_request = (opts) ->
  defaults =
    host: 'api.primate-radiograph.com'
    headers:
      accept: 'application/json'

  headers = _.extend(defaults.headers, opts.headers ? {})
  params = _.extend(defaults, opts, headers: headers)
  return params

rewriteApiUrl = (theurl) ->
  url.parse(theurl).path

# start zappa application
options =
  port: 8000

zipper = zappa.run options, ->

  @helper api_proxy: (callback) ->
    http.get api_request(path: @request.url), (res) =>
      body = ''
      res.on 'data', (data) => body += data
      res.on 'end', =>
        callback(JSON.parse(body))

  @get '/': ->
    @render 'main'
    # @render 'gallery',
    #   '_': _

  @get '/specimens': ->          # view specimen list
    @api_proxy (specimens) =>
      _.each specimens.results, (s) ->
        s.detailView = rewriteApiUrl(s.href)

      @render 'specimen-table',
        meta: specimens
        specimens: specimens.results
        scripts: [
          'http://yui.yahooapis.com/2.9.0/build/yahoo-dom-event/yahoo-dom-event'
          'http://yui.yahooapis.com/2.9.0/build/treeview/treeview-min'
          '/specimen-filters'
        ]
        stylesheets: [
          'http://yui.yahooapis.com/2.9.0/build/treeview/assets/skins/sam/treeview'
        ]

  @post '/specimens': ->         # new specimen
    @response.end()

  @get '/specimens/new': ->      # create specimen form
    console.log 'in new'
    specimen =
      new: true
      links:
        submit: '/specimens'
        discard: '/specimens'
      institutionChoices: []
      sexChoices: []
      taxonChoices: []
    console.log 'specimen: ' + JSON.stringify specimen
    @render 'specimen-edit', specimen

  # Load and transform taxon filter tree for YUI
  @get '/taxa/filter-tree.json': ->
    http.get api_request(path: "/taxa/filter-tree"), (res) =>
      body = ''
      res.on 'data', (data) => body += data
      res.on 'end', =>
        tree = JSON.parse(body)
        transform_node = (node) ->
          node.label = "#{node.name} (#{node.count})"
          delete node.name
          node.data = id: node.id
          delete node.id
          delete node.href
        traverse = (nodes) ->
            for node in nodes
                transform_node(node)
                traverse(node.children)
        traverse(tree)

        @response.writeHead 200, 'content-type': 'application/json'
        @response.write JSON.stringify(tree)
        @response.end()

  @coffee '/specimen-filters.js': ->
    $ ->
      $.ajax
        type: 'GET'
        url: '/taxa/filter-tree.json'
        success: (treeData) ->
          tree = new YAHOO.widget.TreeView 'taxon-filter-tree', treeData
          tree.subscribe 'clickEvent', tree.onEventToggleHighlight
          tree.setNodesProperty 'propagateHighlightUp', true
          tree.setNodesProperty 'propagateHighlightDown', true
          tree.render()

          $('.taxon-filter-apply').click ->
            hilit = tree.getNodesByProperty 'highlightState', 1
            console.log "#{hilit.length} nodes selected"

      sexTree = new YAHOO.widget.TreeView 'sex-filter-tree',
        [{label: 'Male'}, {label: 'Female'}, {label: 'Unknown'}]
      sexTree.subscribe 'clickEvent', sexTree.onEventToggleHighlight
      sexTree.render()

      $('.sex-filter-apply').click ->
        hilit = sexTree.getNodesByProperty 'highlightState', 1
        console.log "#{hilit.length} nodes selected"


  @get '/specimens/:id': ->      # specimen detail
    @api_proxy (specimen) =>
      @render 'specimen-detail', specimen

  @get '/specimens/:id/edit': -> # edit specimen form
    http.get api_request(path: "/specimens/#{@params.id}"), (res) =>
      body = ''
      res.on 'data', (data) => body += data
      res.on 'end', =>
        specimen = JSON.parse(body)
        opts =
          new: false
          links:
            submit: rewriteApiUrl(specimen.href)
            discard: rewriteApiUrl(specimen.href)
          institutionChoices: []
          sexChoices: []
          taxonChoices: []
        @render 'specimen-edit', _.extend(opts, specimen)

  @post '/specimens/:id': ->     # update specimen

  @get '/images/:id': ->
    @response.end()

  @get '/images/:id/:derivative': ->

  @get '/specimens/data': ->
    @response.writeHead 200
    streamZip @response, files, @response.end

  @include './views'
  @include './visualization'

  @view layout: ->
    doctype 5
    html ->
      head ->
        title @title if @title
        script src: '/js/radioapp.js'
        script src: 'https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js'
        if @scripts
          for s in @scripts
            script src: s + '.js'
        script(src: @script + '.js') if @script

        link rel: 'stylesheet', href: '/css/radioapp.css'
        # link rel: 'stylesheet', href: '/css/nv.d3.css'
        if @stylesheets
          for s in @stylesheets
            link rel: 'stylesheet', href: s + '.css'
        if @stylesheet
          link(rel: 'stylesheet', href: @stylesheet + '.css')
        style @style if @style
      body @body

  @helper icon: (name) -> 'foo' #i class: "icon-#{name}",

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


