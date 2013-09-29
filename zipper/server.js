(function() {
  var app, async, express, files, filesConfigRoot, fs, grunt, identifyFiles, zip, zipstream, _,
    _this = this;

  async = require('async');

  express = require('express');

  fs = require('fs');

  grunt = require('grunt');

  zipstream = require('zipstream');

  _ = require('lodash');

  identifyFiles = function(files) {
    var file, normalized, _i, _len;
    normalized = grunt.task.normalizeMultiTaskFiles({
      files: files
    });
    for (_i = 0, _len = normalized.length; _i < _len; _i++) {
      file = normalized[_i];
      if ((file.src == null) || file.src.length === 0) {
        throw "Source file is required and must exist";
      }
      if (file.src.length > 1) {
        throw "When normalized, files must have no more than.  This record contains " + file.src.length;
      }
    }
    return normalized;
  };

  zip = function(zs, files, callback) {
    var chain, chainableAddFile;
    files = identifyFiles(files);
    chainableAddFile = function(f) {
      return function(callback) {
        var instream;
        instream = fs.createReadStream(f.src[0]);
        console.log("Adding file: " + f.dest);
        return zs.addFile(instream, {
          name: f.dest
        }, callback);
      };
    };
    chain = async.compose.apply(async, _.map(files, chainableAddFile));
    return chain(function() {
      return zs.finalize(callback);
    });
  };

  files = [
    {
      expand: true,
      cwd: '/Users/dave/Downloads',
      src: '**/*.pdf'
    }
  ];

  filesConfigRoot = '/tmp';

  app = express();

  app.get('/:zipId', function(req, res) {
    var downloadConfig, err, zs;
    console.log('in request');
    try {
      downloadConfig = require("" + filesConfigRoot + "/" + req.params.zipId + ".json");
      console.log("loaded config: " + (JSON.stringify(downloadConfig)));
    } catch (_error) {
      err = _error;
      console.log(err);
      res.status(404).end();
      return;
    }
    zs = zipstream.createZip({
      level: 1
    });
    zs.pipe(res);
    res.writeHeader(200, {
      'Content-Type': 'application/zip',
      'Content-Disposition': "attachment; filename=" + downloadConfig.filename
    });
    return zip(zs, downloadConfig.files, function() {
      return res.end();
    });
  });

  _.extend(module.exports, {
    zip: zip,
    app: app,
    files: files,
    identifyFiles: identifyFiles
  });

}).call(this);
