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
filesConfigRoot = '/tmp'
awsConfigFile = 'aws.conf'

AWS.config.loadFromPath(awsConfigFile)
S3 = new AWS.S3()
bucket = 'primate-radiograph'

READ_STREAM_CREATORS =
  s3: (src, dest, opts) ->
    getOpts =
      Bucket: opts.bucket
      Key: src
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


listBucket = (bucket, prefix, cb) ->
  opts =
    Bucket: bucket
    Prefix: prefix

  keys = []
  
  handleObjects = (e, data) ->
    if e
      return cb(e, null)

    Array::push.apply keys, data.Contents

    if data.IsTruncated
      opts.Marker = data.NextMarker or data.Contents[data.Contents.length - 1].Key
      S3.listObjects opts, handleObjects
    else
      return cb(null, keys)

  S3.listObjects opts, handleObjects


printBucketList = (bucket, prefix) ->
  listBucket bucket, prefix, (e, data) ->
    if e
      console.log e
    console.log data


#-------------------------------------------------
# Express application configuration and handlers
#-------------------------------------------------
app = express()
app.get '/:zipId', (req, res) ->
  console.log 'in request'

  # Try to load file based on zip ID, 404 if it isn't found
  try
    config = require("#{filesConfigRoot}/#{req.params.zipId}.json")
    console.log "loaded config: #{JSON.stringify(config)}"
  catch err
    console.log err
    res.status(404).end()
    return

  format = 'zip'  # TODO: support multiple formats
  archive = archiver(format)
  archive.pipe(res)
  res.writeHeader 200,
    'Content-Type': 'application/zip'
    'Content-Disposition': "attachment; filename=#{config.filename}"
  archiveIt archive, config

_.extend module.exports, {
  app

  # DEBUG, remove these
  printBucketList
  zipToFile
  }
