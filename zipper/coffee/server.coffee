async = require 'async'
express = require 'express'
fs = require 'fs'
grunt = require 'grunt'
archiver = require 'archiver'
AWS = require 'aws-sdk'
_ = require 'lodash'


#---------------------------------
# Configuration and static setup
#---------------------------------
app = express()

run = ->
  app.listen(app.get('port'))
  console.log "Listening on port #{app.get('port')}"
  return app

defaults =
  port: 8001
  filesConfigRoot: '/tmp/zipper'
  awsConfigFile: 'aws.conf'

configure = (opts) ->
  opts = _.extend {}, defaults, opts
  for k, v of opts
    app.set(k, v)

  AWS.config.loadFromPath(app.get('awsConfigFile'))
  app.set('s3', new AWS.S3())
  return app


READ_STREAM_CREATORS =
  s3: (src, dest, opts) ->
    getOpts =
      Bucket: opts.bucket
      Key: src
    S3 = app.get('s3')
    instream = S3.getObject(getOpts).createReadStream()
    return instream

  local: (src, dest, opts) ->
    return fs.createReadStream(src)


archiveIt = (archive, config, cb) ->
  files = config.files
  createReadStream = READ_STREAM_CREATORS[config.type]
  for file in files
    readStream = createReadStream(file.src, file.dest, config.opts)
    console.log "Outputting file: #{file.src} -> #{file.dest}"
    archive.append(readStream, {name: file.dest})

  archive.finalize (err, bytes) ->
    if err
      console.log err
    else
      console.log "Wrote #{bytes} bytes"


zipToFile = (config, outfile, cb) =>
  outstream = fs.createWriteStream(outfile)
  outstream.on 'close', -> console.log 'Closed outstream'

  archive = archiver('zip')
  archive.on 'error', (err) -> console.log err
  archive.pipe(outstream)

  archiveIt archive, config, -> console.log 'Archiving finished'


sampleConfigs = [{
    type: 'local'
    opts: {}
    files: [
      {src: '/tmp/testS3.js', dest: 'tmp/testS3.js'}
    ]
  },{
    type: 's3'
    opts:
      bucket: 'primate-radiograph'
    files: [
      {src: 'static/rest_framework/js/jquery-1.8.1-min.1565a889b7d5.js', dest: 'foo/bar.js'}
    ]
  }]

#-------------------------------------------------
# Express application configuration and handlers
#-------------------------------------------------
app.get '/:zipId', (req, res) ->
  console.log 'in request'

  # Try to load file based on zip ID, 404 if it isn't found
  try
    config = require("#{app.get('filesConfigRoot')}/#{req.params.zipId}.json")
    console.log "loaded config: #{JSON.stringify(config)}"
  catch err
    console.log err
    res.status(404).end()
    return

  format = 'zip'  # TODO: support multiple formats
  console.log "Creating archive stream"
  archive = archiver(format)
  console.log "Piping stream"
  archive.pipe(res)
  res.writeHeader 200,
    'Content-Type': 'application/zip'
    'Content-Disposition': "attachment; filename=#{config.filename}"
  archiveIt archive, config

_.extend module.exports, {
  app
  configure
  run
  }
