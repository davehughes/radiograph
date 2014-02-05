(function() {
  var AWS, S3, addLocalReadStream, addS3ReadStream, app, async, awsConfigFile, bucket, express, files, filesConfigRoot, fs, grunt, identifyFiles, keyToFile, keyToStream, listBucket, printBucketList, readStreamAdderMap, z2fConfig, zip, zip2, zipToFile, zipstream, _,
    _this = this;

  async = require('async');

  express = require('express');

  fs = require('fs');

  grunt = require('grunt');

  zipstream = require('zipstream');

  AWS = require('aws-sdk');

  _ = require('lodash');

  identifyFiles = function(files) {
    var file, _i, _len;
    for (_i = 0, _len = files.length; _i < _len; _i++) {
      file = files[_i];
      if ((file.src == null) || file.src.length === 0) {
        throw "Source file is required and must exist";
      }
      if (file.src.length > 1) {
        throw "When normalized, files must have no more than.  This record contains " + file.src.length;
      }
    }
    return files;
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

  zip2 = function(zs, config, cb) {
    var addReadStream, chain, chainableAddFile, files;
    files = config.files;
    addReadStream = readStreamAdderMap[config.type];
    chainableAddFile = function(f) {
      return function(cb) {
        return addReadStream(zs, f.src, f.dest, config.opts, cb);
      };
    };
    chain = async.compose.apply(async, _.map(files, chainableAddFile));
    return chain(function() {
      return zs.finalize(cb);
    });
  };

  addLocalReadStream = function(zs, src, dest, opts, callback) {
    var instream;
    instream = fs.createReadStream(src);
    return zs.addFile(instream, {
      name: dest
    }, callback);
  };

  addS3ReadStream = function(zs, src, dest, opts, callback) {
    var getOpts, instream;
    getOpts = {
      Bucket: opts.bucket,
      Key: src
    };
    instream = S3.getObject(getOpts).createReadStream();
    return zs.addFile(instream, {
      name: dest
    }, callback);
  };

  readStreamAdderMap = {
    s3: addS3ReadStream,
    local: addLocalReadStream
  };

  zipToFile = function(config, outfile, cb) {
    var outstream, zs;
    outstream = fs.createWriteStream(outfile);
    zs = zipstream.createZip({
      level: 1
    });
    zs.pipe(outstream);
    return zip2(zs, config, function() {
      return outstream.end(cb);
    });
  };

  z2fConfig = {
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
  };

  files = [
    {
      expand: true,
      cwd: '/Users/dave/Downloads',
      src: '**/*.pdf'
    }
  ];

  filesConfigRoot = '/tmp';

  awsConfigFile = 'aws.conf';

  AWS.config.loadFromPath(awsConfigFile);

  S3 = new AWS.S3();

  bucket = 'primate-radiograph';

  listBucket = function(bucket, prefix, cb) {
    var handleObjects, keys, opts;
    opts = {
      Bucket: bucket,
      Prefix: prefix
    };
    keys = [];
    handleObjects = function(e, data) {
      if (e) {
        return cb(e, null);
      }
      Array.prototype.push.apply(keys, data.Contents);
      if (data.IsTruncated) {
        opts.Marker = data.NextMarker || data.Contents[data.Contents.length - 1].Key;
        return S3.listObjects(opts, handleObjects);
      } else {
        return cb(null, keys);
      }
    };
    return S3.listObjects(opts, handleObjects);
  };

  printBucketList = function(bucket, prefix) {
    return listBucket(bucket, prefix, function(e, data) {
      if (e) {
        console.log(e);
      }
      return console.log(data);
    });
  };

  keyToFile = function(bucket, key, file) {
    var instream, opts, outstream;
    opts = {
      Bucket: bucket,
      Key: key
    };
    outstream = fs.createWriteStream(file);
    instream = S3.getObject(opts).createReadStream();
    return instream.pipe(outstream);
  };

  keyToStream = function(bucket, key) {
    var opts;
    opts = {
      Bucket: bucket,
      Key: key
    };
    return S3.getObject(opts).on('httpData', function(chunk) {
      return stream.write(chunk);
    }).on('complete', function() {
      return stream.end();
    }).send();
  };

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
    identifyFiles: identifyFiles,
    printBucketList: printBucketList,
    keyToFile: keyToFile,
    zipToFile: zipToFile,
    z2fConfig: z2fConfig
  });

}).call(this);
