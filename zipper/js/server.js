(function() {
  var AWS, READ_STREAM_CREATORS, app, archiveIt, archiver, async, configure, defaults, express, fs, grunt, run, sampleConfigs, zipToFile, _,
    _this = this;

  async = require('async');

  express = require('express');

  fs = require('fs');

  grunt = require('grunt');

  archiver = require('archiver');

  AWS = require('aws-sdk');

  _ = require('lodash');

  app = express();

  run = function() {
    app.listen(app.get('port'));
    return app;
  };

  defaults = {
    port: 8001,
    filesConfigRoot: '/tmp/zipper',
    awsConfigFile: 'aws.conf'
  };

  configure = function(opts) {
    var k, v;
    opts = _.extend({}, defaults, opts);
    for (k in opts) {
      v = opts[k];
      app.set(k, v);
    }
    AWS.config.loadFromPath(app.get('awsConfigFile'));
    app.set('s3', new AWS.S3());
    return app;
  };

  READ_STREAM_CREATORS = {
    s3: function(src, dest, opts) {
      var S3, getOpts, instream;
      getOpts = {
        Bucket: opts.bucket,
        Key: src
      };
      S3 = app.get('s3');
      instream = S3.getObject(getOpts).createReadStream();
      return instream;
    },
    local: function(src, dest, opts) {
      return fs.createReadStream(src);
    }
  };

  archiveIt = function(archive, config, cb) {
    var createReadStream, file, files, readStream, _i, _len;
    files = config.files;
    createReadStream = READ_STREAM_CREATORS[config.type];
    for (_i = 0, _len = files.length; _i < _len; _i++) {
      file = files[_i];
      readStream = createReadStream(file.src, file.dest, config.opts);
      console.log("Outputting file: " + file.src + " -> " + file.dest);
      archive.append(readStream, {
        name: file.dest
      });
    }
    return archive.finalize(function(err, bytes) {
      if (err) {
        return console.log(err);
      } else {
        return console.log("Wrote " + bytes + " bytes");
      }
    });
  };

  zipToFile = function(config, outfile, cb) {
    var archive, outstream;
    outstream = fs.createWriteStream(outfile);
    outstream.on('close', function() {
      return console.log('Closed outstream');
    });
    archive = archiver('zip');
    archive.on('error', function(err) {
      return console.log(err);
    });
    archive.pipe(outstream);
    return archiveIt(archive, config, function() {
      return console.log('Archiving finished');
    });
  };

  sampleConfigs = [
    {
      type: 'local',
      opts: {},
      files: [
        {
          src: '/tmp/testS3.js',
          dest: 'tmp/testS3.js'
        }
      ]
    }, {
      type: 's3',
      opts: {
        bucket: 'primate-radiograph'
      },
      files: [
        {
          src: 'static/rest_framework/js/jquery-1.8.1-min.1565a889b7d5.js',
          dest: 'foo/bar.js'
        }
      ]
    }
  ];

  app.get('/:zipId', function(req, res) {
    var archive, config, err, format;
    console.log('in request');
    try {
      config = require("" + (app.get('filesConfigRoot')) + "/" + req.params.zipId + ".json");
      console.log("loaded config: " + (JSON.stringify(config)));
    } catch (_error) {
      err = _error;
      console.log(err);
      res.status(404).end();
      return;
    }
    format = 'zip';
    archive = archiver(format);
    archive.pipe(res);
    res.writeHeader(200, {
      'Content-Type': 'application/zip',
      'Content-Disposition': "attachment; filename=" + config.filename
    });
    return archiveIt(archive, config);
  });

  _.extend(module.exports, {
    app: app,
    configure: configure,
    run: run
  });

}).call(this);
