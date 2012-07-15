(function() {
  var api_request, async, data, files, fs, http, options, rewriteApiUrl, streamZip, url, zappa, zipper, zipstream, _;

  _ = require('underscore')._;

  fs = require('fs');

  async = require('async');

  zipstream = require('zipstream');

  zappa = require('zappajs');

  http = require('http');

  url = require('url');

  api_request = function(opts) {
    var defaults, headers, params, _ref;
    defaults = {
      host: 'api.primate-radiograph.com',
      headers: {
        accept: 'application/json'
      }
    };
    headers = _.extend(defaults.headers, (_ref = opts.headers) != null ? _ref : {});
    params = _.extend(defaults, opts, {
      headers: headers
    });
    return params;
  };

  rewriteApiUrl = function(theurl) {
    return url.parse(theurl).path;
  };

  options = {
    port: 8000
  };

  zipper = zappa.run(options, function() {
    this.helper({
      api_proxy: function(callback) {
        var _this = this;
        return http.get(api_request({
          path: this.request.url
        }), function(res) {
          var body;
          body = '';
          res.on('data', function(data) {
            return body += data;
          });
          return res.on('end', function() {
            return callback(JSON.parse(body));
          });
        });
      }
    });
    this.get({
      '/': function() {
        return this.render('main');
      }
    });
    this.get({
      '/specimens': function() {
        var _this = this;
        return this.api_proxy(function(specimens) {
          _.each(specimens.results, function(s) {
            return s.detailView = rewriteApiUrl(s.href);
          });
          return _this.render('specimen-table', {
            meta: specimens,
            specimens: specimens.results,
            scripts: ['http://yui.yahooapis.com/2.9.0/build/yahoo-dom-event/yahoo-dom-event', 'http://yui.yahooapis.com/2.9.0/build/treeview/treeview-min', '/specimen-filters'],
            stylesheets: ['http://yui.yahooapis.com/2.9.0/build/treeview/assets/skins/sam/treeview']
          });
        });
      }
    });
    this.post({
      '/specimens': function() {
        return this.response.end();
      }
    });
    this.get({
      '/specimens/new': function() {
        var specimen;
        console.log('in new');
        specimen = {
          "new": true,
          links: {
            submit: '/specimens',
            discard: '/specimens'
          },
          institutionChoices: [],
          sexChoices: [],
          taxonChoices: []
        };
        console.log('specimen: ' + JSON.stringify(specimen));
        return this.render('specimen-edit', specimen);
      }
    });
    this.get({
      '/taxa/filter-tree.json': function() {
        var _this = this;
        return http.get(api_request({
          path: "/taxa/filter-tree"
        }), function(res) {
          var body;
          body = '';
          res.on('data', function(data) {
            return body += data;
          });
          return res.on('end', function() {
            var transform_node, traverse, tree;
            tree = JSON.parse(body);
            transform_node = function(node) {
              node.label = "" + node.name + " (" + node.count + ")";
              delete node.name;
              node.data = {
                id: node.id
              };
              delete node.id;
              return delete node.href;
            };
            traverse = function(nodes) {
              var node, _i, _len, _results;
              _results = [];
              for (_i = 0, _len = nodes.length; _i < _len; _i++) {
                node = nodes[_i];
                transform_node(node);
                _results.push(traverse(node.children));
              }
              return _results;
            };
            traverse(tree);
            _this.response.writeHead(200, {
              'content-type': 'application/json'
            });
            _this.response.write(JSON.stringify(tree));
            return _this.response.end();
          });
        });
      }
    });
    this.coffee({
      '/specimen-filters.js': function() {
        return $(function() {
          var sexTree;
          $.ajax({
            type: 'GET',
            url: '/taxa/filter-tree.json',
            success: function(treeData) {
              var tree;
              tree = new YAHOO.widget.TreeView('taxon-filter-tree', treeData);
              tree.subscribe('clickEvent', tree.onEventToggleHighlight);
              tree.setNodesProperty('propagateHighlightUp', true);
              tree.setNodesProperty('propagateHighlightDown', true);
              tree.render();
              return $('.taxon-filter-apply').click(function() {
                var hilit;
                hilit = tree.getNodesByProperty('highlightState', 1);
                return console.log("" + hilit.length + " nodes selected");
              });
            }
          });
          sexTree = new YAHOO.widget.TreeView('sex-filter-tree', [
            {
              label: 'Male'
            }, {
              label: 'Female'
            }, {
              label: 'Unknown'
            }
          ]);
          sexTree.subscribe('clickEvent', sexTree.onEventToggleHighlight);
          sexTree.render();
          return $('.sex-filter-apply').click(function() {
            var hilit;
            hilit = sexTree.getNodesByProperty('highlightState', 1);
            return console.log("" + hilit.length + " nodes selected");
          });
        });
      }
    });
    this.get({
      '/specimens/:id': function() {
        var _this = this;
        return this.api_proxy(function(specimen) {
          return _this.render('specimen-detail', specimen);
        });
      }
    });
    this.get({
      '/specimens/:id/edit': function() {
        var _this = this;
        return http.get(api_request({
          path: "/specimens/" + this.params.id
        }), function(res) {
          var body;
          body = '';
          res.on('data', function(data) {
            return body += data;
          });
          return res.on('end', function() {
            var opts, specimen;
            specimen = JSON.parse(body);
            opts = {
              "new": false,
              links: {
                submit: rewriteApiUrl(specimen.href),
                discard: rewriteApiUrl(specimen.href)
              },
              institutionChoices: [],
              sexChoices: [],
              taxonChoices: []
            };
            return _this.render('specimen-edit', _.extend(opts, specimen));
          });
        });
      }
    });
    this.post({
      '/specimens/:id': function() {}
    });
    this.get({
      '/images/:id': function() {
        return this.response.end();
      }
    });
    this.get({
      '/images/:id/:derivative': function() {}
    });
    this.get({
      '/specimens/data': function() {
        this.response.writeHead(200);
        return streamZip(this.response, files, this.response.end);
      }
    });
    this.include('./views');
    this.include('./visualization');
    this.view({
      layout: function() {
        doctype(5);
        return html(function() {
          head(function() {
            var s, _i, _j, _len, _len2, _ref, _ref2;
            if (this.title) title(this.title);
            script({
              src: '/js/radioapp.js'
            });
            script({
              src: 'https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js'
            });
            if (this.scripts) {
              _ref = this.scripts;
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                s = _ref[_i];
                script({
                  src: s + '.js'
                });
              }
            }
            if (this.script) {
              script({
                src: this.script + '.js'
              });
            }
            link({
              rel: 'stylesheet',
              href: '/css/radioapp.css'
            });
            if (this.stylesheets) {
              _ref2 = this.stylesheets;
              for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
                s = _ref2[_j];
                link({
                  rel: 'stylesheet',
                  href: s + '.css'
                });
              }
            }
            if (this.stylesheet) {
              link({
                rel: 'stylesheet',
                href: this.stylesheet + '.css'
              });
            }
            if (this.style) return style(this.style);
          });
          return body(this.body);
        });
      }
    });
    return this.helper({
      icon: function(name) {
        return 'foo';
      }
    });
  });

  data = {
    labels: {
      specimenId: 'Specimen ID',
      taxon: 'Taxon',
      sex: 'sex'
    },
    rows: [
      {
        specimenId: '1',
        sex: 'M',
        taxon: 'Alouatta belzebul',
        images: [
          {
            aspect: 'L',
            path: '/tmp/ziptest/test.txt'
          }, {
            aspect: 'S',
            path: '/tmp/ziptest/test2.txt'
          }
        ]
      }, {
        specimenId: '2',
        sex: 'F',
        taxon: 'Cebus apella apella',
        images: [
          {
            aspect: 'L',
            path: '/tmp/ziptest/test.txt'
          }, {
            aspect: 'S',
            path: '/tmp/ziptest/test2.txt'
          }
        ]
      }
    ]
  };

  streamZip = function(out, files, callback) {
    var fileSeries, zip;
    zip = zipstream.createZip({
      level: 1
    });
    zip.pipe(out);
    fileSeries = _.map(files, function(f) {
      return function(cb) {
        return zip.addFile(fs.createReadStream(f.path), {
          name: f.name
        }, cb);
      };
    });
    fileSeries.push(function(cb) {
      return zip.finalize(cb);
    });
    return async.series(fileSeries, callback);
  };

  files = [];

  _.each(data.rows, function(row) {
    return _.each(row.images, function(image) {
      return files.push({
        name: "data/" + row.taxon + "/" + image.aspect + ".txt",
        path: image.path
      });
    });
  });

}).call(this);
