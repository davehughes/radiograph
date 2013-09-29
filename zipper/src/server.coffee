async = require 'async'
express = require 'express'
fs = require 'fs'
grunt = require 'grunt'
zipstream = require 'zipstream'
_ = require 'lodash'

identifyFiles = (files) ->
  normalized = grunt.task.normalizeMultiTaskFiles(files: files)
  for file in normalized
    if not file.src? or file.src.length == 0
      throw "Source file is required and must exist"
    if file.src.length > 1
      throw "When normalized, files must have no more than.  This record contains #{file.src.length}"
  return normalized

zip = (zs, files, callback) =>
  files = identifyFiles(files)
  
  chainableAddFile = (f) =>
    (callback) ->
      instream = fs.createReadStream(f.src[0])
      console.log "Adding file: #{f.dest}"
      zs.addFile(instream, {name: f.dest}, callback)
  
  chain = async.compose.apply(async, _.map(files, chainableAddFile))
  chain => zs.finalize(callback)

# Use grunt-style files object to determing which files to zip and what their
# names should be in the zip file
files = [{
  expand: true
  cwd: '/Users/dave/Downloads'
  src: '**/*.pdf'
}]

filesConfigRoot = '/tmp'

app = express()
app.get '/:zipId', (req, res) ->
  console.log 'in request'

  # Try to load file based on zip ID, 404 if it isn't found
  try
    downloadConfig = require("#{filesConfigRoot}/#{req.params.zipId}.json")
    console.log "loaded config: #{JSON.stringify(downloadConfig)}"
  catch err
    console.log err
    res.status(404).end()
    return

  zs = zipstream.createZip(level:1)
  zs.pipe(res)

  res.writeHeader 200,
    'Content-Type': 'application/zip'
    'Content-Disposition': "attachment; filename=#{downloadConfig.filename}"
  zip(zs, downloadConfig.files, -> res.end())

_.extend module.exports, {
  zip
  app

  # DEBUG, remove these
  files
  identifyFiles
  }
