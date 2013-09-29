(function() {
  module.exports = function(grunt) {
    grunt.initConfig({
      pkg: grunt.file.readJSON('package.json'),
      coffee: {
        compile: {
          files: [
            {
              '../static/gen/js/radiograph.js': ['**/*.coffee']
            }
          ]
        }
      },
      less: {
        development: {
          options: {
            dumpLineNumbers: true
          },
          files: {
            '../static/gen/css/radiograph.css': 'less/radiograph.less'
          }
        }
      },
      dust: {
        defaults: {
          files: [
            {
              expand: true,
              cwd: 'dust/',
              src: ['**/*.dust'],
              dest: '../static/gen/js/templates.js',
              rename: function(dest, src) {
                return dest;
              }
            }
          ],
          options: {
            relative: true,
            runtime: false,
            amd: false
          }
        }
      },
      watch: {
        options: {
          livereload: true
        },
        coffee: {
          files: 'coffee/**/*.coffee',
          tasks: ['coffee']
        },
        less: {
          files: 'less/**/*.less',
          tasks: ['less']
        },
        dust: {
          files: 'dust/**/*.dust',
          tasks: ['dust']
        },
        handlebars: {
          files: 'handlebars/**/*.hbs',
          tasks: ['handlebars']
        }
      }
    });
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-less');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-contrib-handlebars');
    grunt.loadNpmTasks('grunt-dust');
    return grunt.registerTask('default', ['coffee', 'less']);
  };

}).call(this);

(function() {
  var Backbone, CollectionItemModel, CollectionModel, _, _ref, _ref1,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  _ = require('underscore')._;

  Backbone = require('backbone');

  CollectionItemModel = (function(_super) {
    __extends(CollectionItemModel, _super);

    function CollectionItemModel() {
      _ref = CollectionItemModel.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    CollectionItemModel.prototype.defaults = function() {
      return {
        href: null,
        links: []
      };
    };

    CollectionItemModel.prototype.initialize = function() {
      CollectionItemModel.__super__.initialize.apply(this, arguments);
      return this.url = this.get('href');
    };

    /*
    Map from collection+json style data fields (e.g. [{name: 'foo', value: 'bar'}, ...])
    to a dictionary (e.g. {'foo': 'bar', ...}), optionally using a parse function.
    
    Parse functions should be named by concatenating the string 'parse' and the 
    capitalized name of the field to be transformed (e.g., to specify a function to
    transform the field 'foo', the class should provide a 'parseFoo' method).
    */


    CollectionItemModel.prototype.parse = function(input) {
      var fieldValues, mapField,
        _this = this;

      mapField = function(memo, field) {
        var parseFunc;

        parseFunc = _this["parse" + (field.name.charAt(0).toUpperCase()) + (field.name.slice(1))];
        memo[field.name] = parseFunc ? parseFunc(field.value) : field.value;
        return memo;
      };
      fieldValues = _.reduce(input.data, mapField, {});
      return _.extend(fieldValues, {
        href: input.href,
        links: input.links
      });
    };

    return CollectionItemModel;

  })(Backbone.Model);

  CollectionModel = (function(_super) {
    __extends(CollectionModel, _super);

    function CollectionModel() {
      _ref1 = CollectionModel.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    CollectionModel.prototype.itemModel = CollectionItemModel;

    CollectionModel.prototype.defaults = function() {
      return {
        version: null,
        href: null,
        items: [],
        links: [],
        template: null,
        queries: [],
        error: null,
        pagination: {
          currentPage: 1,
          totalPages: 1
        }
      };
    };

    CollectionModel.prototype.parse = function(input) {
      var collection,
        _this = this;

      collection = input.collection;
      collection.items = _.map(collection.items, function(i) {
        var item;

        item = new _this.itemModel(i, {
          parse: true
        });
        item.collection = _this;
        return item;
      });
      return collection;
    };

    CollectionModel.prototype.getLink = function(rel) {
      return _.find(this.links, function(l) {
        return l.rel === rel;
      });
    };

    CollectionModel.prototype.fetchTemplate = function(callback) {
      if (this.get('template')) {
        callback(this.get('template'));
      }
      if (this.getLink('template')) {
        if (!this._templateXHR) {
          this._templateXHR = $.ajax({
            url: this.getLink('template'),
            dataType: 'json'
          });
        }
        this._templateXHR.done(callback);
      }
      return null;
    };

    CollectionModel.prototype.fetchChoices = function(url, callback) {
      return $.ajax({
        type: 'GET',
        dataType: 'json'
      });
    };

    return CollectionModel;

  })(Backbone.Model);

  _.extend(exports, {
    'CollectionModel': CollectionModel,
    'CollectionItemModel': CollectionItemModel
  });

}).call(this);

(function() {
  var Backbone, RadioappRouter, api, createResourceCollection, createResources, models, resourceConfigs, views, _, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  _ = require('underscore')._;

  Backbone = require('backbone');

  views = require('radiograph/views');

  models = require('radiograph/models');

  api = require('radiograph/api');

  createResources = function(resourceMap) {
    var cfg, defaultConfig, output, rName, rUrl, _ref;

    defaultConfig = {
      collection: api.CollectionModel,
      item: api.CollectionItemModel
    };
    output = {};
    for (rName in resourceMap) {
      rUrl = resourceMap[rName];
      cfg = _.extend(defaultConfig, (_ref = resourceConfigs[rName]) != null ? _ref : {});
      output[rName] = createResourceCollection(rUrl, cfg.collection, cfg.item);
    }
    return output;
  };

  resourceConfigs = {
    specimens: {
      collection: models.SpecimenCollection,
      item: models.Specimen
    }
  };

  createResourceCollection = function(url, collectionModel, itemModel) {
    var resource;

    if (collectionModel == null) {
      collectionModel = api.CollectionModel;
    }
    if (itemModel == null) {
      itemModel = api.CollectionItemModel;
    }
    resource = new collectionModel();
    resource.url = url;
    resource.itemModel = itemModel;
    return resource;
  };

  RadioappRouter = (function(_super) {
    __extends(RadioappRouter, _super);

    function RadioappRouter() {
      _ref = RadioappRouter.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    RadioappRouter.prototype.routes = {
      '': 'specimenList',
      'specimens': 'specimenList',
      'specimens/:id': 'specimenDetail',
      'specimens/:id/edit': 'specimenEdit'
    };

    RadioappRouter.prototype.specimenList = function() {
      var _this = this;

      return App.resources.specimens.fetch({
        success: function() {
          return App.view.pushPane(new views.SpecimenSearchPane({
            model: App.resources.specimens
          }));
        }
      });
    };

    RadioappRouter.prototype.specimenDetail = function(id) {
      var model;

      model = App.resources.specimens.get({
        id: id
      }) || new Specimen({
        id: id
      });
      return App.view.pushPane(new views.SpecimenDetailPane({
        model: model
      }));
    };

    RadioappRouter.prototype.specimenEdit = function(id) {
      var model;

      model = App.resources.specimens.get({
        id: id
      }) || new Specimen({
        id: id
      });
      return App.view.pushPane(new views.SpecimenForm({
        model: model
      }));
    };

    RadioappRouter.prototype.imageDetail = function(id) {};

    RadioappRouter.prototype.imageFile = function(id, deriv) {};

    return RadioappRouter;

  })(Backbone.Router);

  _.extend(exports, {
    'RadioappRouter': RadioappRouter,
    'createResources': createResources
  });

}).call(this);

(function() {
  var Backbone, Image, ImageCollection, SearchManager, Specimen, SpecimenCollection, User, api, util, _, _ref, _ref1, _ref2, _ref3, _ref4, _ref5,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  _ = require('underscore')._;

  Backbone = require('backbone');

  api = require('radiograph/api');

  util = require('radiograph/util');

  Specimen = (function(_super) {
    __extends(Specimen, _super);

    function Specimen() {
      _ref = Specimen.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Specimen.prototype.urlRoot = '/specimens';

    Specimen.prototype.defaults = function() {
      return {
        institution: null,
        sex: null,
        taxon: null,
        specimenId: null,
        settings: null,
        comments: null,
        skullLength: null,
        cranialWidth: null,
        neurocranialHeight: null,
        facialHeight: null,
        palateLength: null,
        palateWidth: null,
        images: new ImageCollection([])
      };
    };

    Specimen.prototype.parseImages = function(value) {
      return new ImageCollection(_.map(value, function(v) {
        return new Image(v);
      }));
    };

    Specimen.prototype.toJSON = function() {
      return _.extend(Specimen.__super__.toJSON.apply(this, arguments), {
        images: this.get('images').toJSON()
      });
    };

    return Specimen;

  })(api.CollectionItemModel);

  SpecimenCollection = (function(_super) {
    __extends(SpecimenCollection, _super);

    function SpecimenCollection() {
      _ref1 = SpecimenCollection.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    SpecimenCollection.prototype.itemModel = Specimen;

    SpecimenCollection.prototype.defaults = function() {
      return {
        items: [],
        queries: [
          {
            rel: 'search',
            href: '...',
            prompt: 'Search specimens',
            data: [
              {
                name: 'results_per_page',
                value: 20,
                prompt: 'Results per page'
              }, {
                name: 'sex_filter',
                value: [],
                prompt: 'Sex filter'
              }, {
                name: 'taxa_filter',
                value: [],
                prompt: 'Taxa filter'
              }, {
                name: 'query',
                value: '*:*',
                prompt: 'Search string'
              }
            ]
          }
        ],
        links: {
          profile: null,
          template: null
        }
      };
    };

    SpecimenCollection.prototype.toJSON = function() {
      return _.extend(SpecimenCollection.__super__.toJSON.apply(this, arguments), {
        items: _.map(this.get('items'), function(i) {
          return i.toJSON();
        })
      });
    };

    return SpecimenCollection;

  })(api.CollectionModel);

  Image = (function(_super) {
    __extends(Image, _super);

    function Image() {
      _ref2 = Image.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    Image.prototype.defaults = function() {
      return {
        href: null,
        name: null,
        url: null,
        aspect: 'L',
        replacementFile: null,
        links: {
          profile: null,
          thumb: null,
          medium: null,
          large: null
        }
      };
    };

    return Image;

  })(Backbone.Model);

  ImageCollection = (function(_super) {
    __extends(ImageCollection, _super);

    function ImageCollection() {
      _ref3 = ImageCollection.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    ImageCollection.prototype.model = Image;

    return ImageCollection;

  })(Backbone.Collection);

  User = (function(_super) {
    __extends(User, _super);

    function User() {
      _ref4 = User.__super__.constructor.apply(this, arguments);
      return _ref4;
    }

    User.prototype.defaults = function() {
      return {
        loggedIn: false,
        firstName: 'Anonymous',
        lastName: '',
        isStaff: false,
        links: {
          profile: null,
          login: null,
          logout: null
        }
      };
    };

    return User;

  })(Backbone.Model);

  SearchManager = (function(_super) {
    __extends(SearchManager, _super);

    function SearchManager() {
      _ref5 = SearchManager.__super__.constructor.apply(this, arguments);
      return _ref5;
    }

    SearchManager.prototype.defaults = function() {
      return {
        page: null,
        sortField: null,
        sortDirection: null,
        perPage: 20,
        query: null
      };
    };

    SearchManager.prototype.toJSON = function() {
      var json, k, keymap, _i, _len, _ref6;

      keymap = {
        sortField: 'sort_field',
        sortDirection: 'sort_direction',
        perPage: 'results_per_page',
        query: 'q'
      };
      json = SearchManager.__super__.toJSON.apply(this, arguments);
      _ref6 = _.keys(json);
      for (_i = 0, _len = _ref6.length; _i < _len; _i++) {
        k = _ref6[_i];
        if (!json[k]) {
          delete json[k];
        } else if (keymap[k]) {
          json[keymap[k]] = json[k];
          delete json[k];
        }
      }
      return json;
    };

    return SearchManager;

  })(Backbone.Model);

  _.extend(exports, {
    'User': User,
    'Specimen': Specimen,
    'SpecimenCollection': SpecimenCollection,
    'Image': Image,
    'ImageCollection': ImageCollection,
    'SearchManager': SearchManager
  });

}).call(this);

(function() {
  var Alerts, Backbone, _, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  _ = require('underscore')._;

  Backbone = require('backbone');

  Alerts = (function(_super) {
    __extends(Alerts, _super);

    function Alerts() {
      _ref = Alerts.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Alerts.prototype.Types = {
      SUCCESS: 'success',
      INFO: 'info',
      WARNING: 'warning',
      ERROR: 'error'
    };

    Alerts.prototype.publish = function(type, body) {
      if (type == null) {
        type = Alerts.Types.INFO;
      }
      return this.trigger('published', {
        type: type,
        body: body
      });
    };

    return Alerts;

  })(Backbone.Model);

  _.extend(exports, {
    'Alerts': Alerts
  });

}).call(this);

(function() {
  var AlertsView, AppToolbar, AppView, Backbone, DataView, FormPaginationView, ImageView, LoginFormView, PaginationView, SpecimenDetailPane, SpecimenEditPane, SpecimenForm, SpecimenModal, SpecimenResult, SpecimenSearchPane, View, models, _, _ref, _ref1, _ref10, _ref11, _ref12, _ref13, _ref14, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __slice = [].slice;

  _ = require('underscore')._;

  Backbone = require('backbone');

  models = require('radiograph/models');

  require('bootstrap');

  require('jquery.chosen');

  require('jquery.fileupload');

  View = (function(_super) {
    __extends(View, _super);

    function View() {
      _ref = View.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    View.prototype.templateId = null;

    View.prototype.viewContext = function() {
      var _ref1, _ref2;

      return (_ref1 = (_ref2 = this.model) != null ? _ref2.toJSON() : void 0) != null ? _ref1 : {};
    };

    View.prototype.render = function() {
      var template, templateEl;

      View.__super__.render.apply(this, arguments);
      template = require(this.templateId);
      templateEl = template(this.viewContext());
      this.$el.html(templateEl);
      this.updateAuthz(App.user);
      return this;
    };

    View.prototype.initialize = function() {
      View.__super__.initialize.apply(this, arguments);
      return App.on('change:user', this.updateAuthz, this);
    };

    View.prototype.updateAuthz = function(user) {};

    View.prototype.ignore = function(e) {
      e.preventDefault();
      return e.stopPropagation();
    };

    return View;

  })(Backbone.View);

  SpecimenForm = (function(_super) {
    __extends(SpecimenForm, _super);

    function SpecimenForm() {
      this.getSpecimenData = __bind(this.getSpecimenData, this);
      this.addImage = __bind(this.addImage, this);      _ref1 = SpecimenForm.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    SpecimenForm.prototype.templateId = 'templates/specimen-edit';

    SpecimenForm.prototype.events = function() {
      var _this = this;

      return {
        'click [rel=discard]': 'discard',
        'click .dropdown.sex .dropdown-menu': 'ignore',
        'click [rel=save]': 'save',
        'click [rel=add-image]': function(e) {
          var img;

          e.preventDefault();
          e.stopPropagation();
          img = new models.Image();
          this.model.get('images').add(img, {
            silent: true
          });
          return this.addImage(img);
        },
        'change [name=institution],\
            [name=specimenId],\
            [name=taxon],\
            [name=sex],\
            [name=skullLength],\
            [name=cranialWidth],\
            [name=neurocranialHeight],\
            [name=facialHeight],\
            [name=palateLength],\
            [name=palateWidth],\
            [name=comments],\
            [name=settings]': function(e) {
          var control;

          control = $(e.currentTarget);
          return _this.model.set(control.attr('name'), control.val());
        }
      };
    };

    SpecimenForm.prototype.viewContext = function() {
      return _.extend(SpecimenForm.__super__.viewContext.apply(this, arguments), {
        existing: this.model ? true : false,
        links: {}
      });
    };

    SpecimenForm.prototype.render = function() {
      var _this = this;

      SpecimenForm.__super__.render.apply(this, arguments);
      this.$('[name=institution]').val(this.model.get('institution'));
      this.$('[name=taxon]').val(this.model.get('taxon'));
      this.$('[name=sex]').val(this.model.get('sex'));
      _.defer(function() {
        return _this.$('[name=taxon]').chosen();
      });
      this.model.get('images').each(this.addImage);
      this.$('form').fileupload({
        url: this.model.get('href') || this.model.collection.get('href'),
        formData: this.getSpecimenData,
        fileInput: null,
        dropZone: null
      });
      return this;
    };

    SpecimenForm.prototype.addImage = function(img) {
      var imgView;

      imgView = new ImageView({
        model: img
      });
      return this.$('.image-controls').append(imgView.render().$el);
    };

    SpecimenForm.prototype.discard = function() {
      return App.view.popPane();
    };

    SpecimenForm.prototype.save = function(e) {
      var ajaxData, fileInputs, files, paramNames, specimenData, xhr,
        _this = this;

      fileInputs = _.filter(this.$('.replacementFile input[type=file]'), function(input) {
        return $(input).val();
      });
      if (fileInputs.length === 0) {
        specimenData = this.getSpecimenData()[0];
        ajaxData = {};
        ajaxData[specimenData.name] = specimenData.value;
        xhr = $.ajax({
          url: this.model.get('href') || this.model.collection.get('href'),
          type: 'POST',
          data: ajaxData
        });
      } else {
        files = _.map(fileInputs, function(f) {
          return f.files[0];
        });
        paramNames = _.map(fileInputs, function(f) {
          return $(f).attr('name');
        });
        xhr = this.$('form').fileupload('send', {
          files: files,
          paramName: paramNames
        });
        this.$('.submission-status').show().find('.bar').css('width', 0);
        this.$('form').on('fileuploadprogress', function(e, data) {
          var width;

          width = "" + ((data.loaded * 100) / data.total) + "%";
          _this.$('.submission-status .bar').css('width', width);
          return console.log("progress: " + width);
        });
      }
      this.$('[rel=save], [rel=discard]').attr('disabled', 'disabled').addClass('disabled');
      xhr.done(function(response) {
        console.log('save successful');
        return App.view.popPane();
      });
      xhr.fail(function(response) {
        return alert('Error saving specimen');
      });
      return xhr.always(function() {
        _this.$('.submission-status').hide().find('.bar').css('width', 0);
        return _this.$('[rel=save], [rel=discard]').removeAttr('disabled').removeClass('disabled');
      });
    };

    SpecimenForm.prototype.getSpecimenData = function() {
      var args, specimenData;

      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      specimenData = this.model.toJSON();
      _.each(specimenData.images || [], function(img) {
        delete img.links;
        delete img.name;
        delete img.url;
        if (img.replacementFile) {
          return img.replacementFile = img.replacementFile.file;
        } else {
          return delete img.replacementFile;
        }
      });
      return [
        {
          name: 'specimen',
          value: JSON.stringify(specimenData)
        }
      ];
    };

    return SpecimenForm;

  })(View);

  SpecimenModal = (function(_super) {
    var className;

    __extends(SpecimenModal, _super);

    function SpecimenModal() {
      _ref2 = SpecimenModal.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    className = 'modal specimen-modal';

    SpecimenModal.prototype.render = function() {
      var header;

      SpecimenModal.__super__.render.apply(this, arguments);
      header = $("<div class='modal-header'><h3>Edit Specimen</h3></div>");
      this.$el.prepend(header);
      this.$('fieldset').addClass('modal-body');
      this.$('.form-actions').addClass('modal-footer');
      this.$el.modal({
        keyboard: false
      });
      return this;
    };

    return SpecimenModal;

  })(SpecimenForm);

  SpecimenSearchPane = (function(_super) {
    __extends(SpecimenSearchPane, _super);

    function SpecimenSearchPane() {
      this.loadSearch = __bind(this.loadSearch, this);
      this.showCreateItemPane = __bind(this.showCreateItemPane, this);      _ref3 = SpecimenSearchPane.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    SpecimenSearchPane.prototype.templateId = 'templates/specimen-search-form';

    SpecimenSearchPane.prototype.events = function() {
      var _this = this;

      return {
        'click [rel=create]': 'showCreateItemPane',
        'click .icon-search': 'setQuery',
        'keydown [name=q]': function(e) {
          if (e.keyCode === 13) {
            return _this.setQuery();
          }
        },
        'click [rel=results-per-page]': 'setResultsPerPage',
        'click [rel=sort-field]': 'setSortField',
        'click [rel=sort-direction]': 'setSortDirection'
      };
    };

    SpecimenSearchPane.prototype.initialize = function() {
      SpecimenSearchPane.__super__.initialize.apply(this, arguments);
      this.searchMgr = new models.SearchManager();
      return this.searchMgr.on('change', this.loadSearch);
    };

    SpecimenSearchPane.prototype.render = function() {
      SpecimenSearchPane.__super__.render.apply(this, arguments);
      this.renderPagination();
      this.renderResults();
      this.$('.results-loading').hide();
      return this;
    };

    SpecimenSearchPane.prototype.renderPagination = function() {
      var _this = this;

      if (this.model.get('pagination')) {
        return _.each(this.$('.pagination'), function(placeholder) {
          var paginationView;

          paginationView = new PaginationView(_this.model.get('pagination'));
          $(placeholder).replaceWith(paginationView.render().$el);
          return paginationView.on('navigate', function(page) {
            return _this.searchMgr.set('page', page);
          });
        });
      }
    };

    SpecimenSearchPane.prototype.renderResults = function() {
      var _this = this;

      this.$('table tbody .result-row').remove();
      return _.each(this.model.get('items'), function(s) {
        var view;

        view = new SpecimenResult({
          model: s
        });
        return _this.$('table tbody').append(view.render().$el);
      });
    };

    SpecimenSearchPane.prototype.updateAuthz = function(user) {
      if (user == null) {
        user = App.user;
      }
      if (user.get('isStaff')) {
        return this.$('[rel=edit],[rel=create]').show();
      } else {
        return this.$('[rel=edit],[rel=create]').hide();
      }
    };

    SpecimenSearchPane.prototype.showCreateItemPane = function(e) {
      var model;

      e.preventDefault();
      e.stopPropagation();
      model = new models.Specimen();
      model.collection = this.model;
      App.router.navigate("/specimens/${model.id}");
      return App.view.pushPane(new views.SpecimenForm({
        model: model
      }));
    };

    SpecimenSearchPane.prototype.loadSearch = function(e) {
      var xhr,
        _this = this;

      $('.results-loading').show();
      $('.results-placeholder').hide();
      xhr = $.ajax({
        type: 'GET',
        url: this.model.get('href'),
        data: this.searchMgr.toJSON(),
        dataType: 'json'
      });
      return xhr.done(function(data) {
        _this.model = new models.SpecimenCollection(data, {
          parse: true
        });
        _this.renderPagination();
        _this.renderResults();
        $('.results-loading').hide();
        return $('.results-placeholder').show();
      });
    };

    SpecimenSearchPane.prototype.setQuery = function(e) {
      return this.searchMgr.set('query', this.$('input[name=q]').val());
    };

    SpecimenSearchPane.prototype.setResultsPerPage = function(e) {
      this.searchMgr.set({
        perPage: $(e.currentTarget).text(),
        page: null
      });
      return $(e.currentTarget).parents('.dropdown').find('.dropdown-display').text($(e.currentTarget).text());
    };

    SpecimenSearchPane.prototype.setSortField = function(e) {
      this.searchMgr.set('sortField', $(e.currentTarget).data('value'));
      return $(e.currentTarget).parents('.dropdown').find('.dropdown-display').text($(e.currentTarget).text());
    };

    SpecimenSearchPane.prototype.setSortDirection = function(e) {
      this.searchMgr.set('sortDirection', $(e.currentTarget).data('value'));
      return $(e.currentTarget).hide().siblings().show();
    };

    return SpecimenSearchPane;

  })(View);

  SpecimenResult = (function(_super) {
    __extends(SpecimenResult, _super);

    function SpecimenResult() {
      this.showDetailPane = __bind(this.showDetailPane, this);
      this.showEditPane = __bind(this.showEditPane, this);      _ref4 = SpecimenResult.__super__.constructor.apply(this, arguments);
      return _ref4;
    }

    SpecimenResult.prototype.templateId = 'templates/specimen-list-item';

    SpecimenResult.prototype.tagName = 'tr';

    SpecimenResult.prototype.className = 'result-row';

    SpecimenResult.prototype.events = function() {
      return {
        'click [rel=edit]': 'showEditPane',
        'click [rel=detail]': 'showDetailPane'
      };
    };

    SpecimenResult.prototype.initialize = function() {
      return this.model.on('change', this.render, this);
    };

    SpecimenResult.prototype.showEditPane = function(e) {
      e.preventDefault();
      e.stopPropagation();
      App.router.navigate("" + this.model.url + "/edit");
      return App.view.pushPane(new SpecimenForm({
        model: this.model
      }));
    };

    SpecimenResult.prototype.showDetailPane = function(e) {
      e.preventDefault();
      e.stopPropagation();
      App.router.navigate("" + this.model.url);
      return App.view.pushPane(new SpecimenDetailPane({
        model: this.model
      }));
    };

    return SpecimenResult;

  })(View);

  SpecimenDetailPane = (function(_super) {
    __extends(SpecimenDetailPane, _super);

    function SpecimenDetailPane() {
      this.showEditPane = __bind(this.showEditPane, this);      _ref5 = SpecimenDetailPane.__super__.constructor.apply(this, arguments);
      return _ref5;
    }

    SpecimenDetailPane.prototype.templateId = 'templates/specimen-detail';

    SpecimenDetailPane.prototype.events = function() {
      return {
        'click [rel=back]': 'back',
        'click [rel=edit]': 'showEditPane'
      };
    };

    SpecimenDetailPane.prototype.back = function(e) {
      e.preventDefault();
      e.stopPropagation();
      return App.view.popPane();
    };

    SpecimenDetailPane.prototype.showEditPane = function(e) {
      e.preventDefault();
      e.stopPropagation();
      App.router.navigate("" + this.model.url + "/edit");
      return App.view.pushPane(new SpecimenForm({
        model: this.model
      }));
    };

    return SpecimenDetailPane;

  })(View);

  LoginFormView = (function(_super) {
    __extends(LoginFormView, _super);

    function LoginFormView() {
      this.displayError = __bind(this.displayError, this);
      this.clearError = __bind(this.clearError, this);
      this.submit = __bind(this.submit, this);      _ref6 = LoginFormView.__super__.constructor.apply(this, arguments);
      return _ref6;
    }

    LoginFormView.prototype.templateId = 'templates/login';

    LoginFormView.prototype.events = function() {
      return {
        'submit form': 'submit'
      };
    };

    LoginFormView.prototype.viewContext = function() {
      return {
        errors: []
      };
    };

    LoginFormView.prototype.show = function() {
      return this.render().$el.modal({
        keyboard: false
      });
    };

    LoginFormView.prototype.hide = function() {
      return this.$el.modal('hide');
    };

    LoginFormView.prototype.submit = function(e) {
      var form,
        _this = this;

      e.stopPropagation();
      e.preventDefault();
      form = $(e.currentTarget);
      return $.ajax({
        type: 'POST',
        url: App.links.login,
        data: form.serialize(),
        dataType: 'json',
        success: function(data) {
          _this.clearError();
          _this.trigger('loginsuccess', data);
          return _this.hide();
        },
        error: function(xhr) {
          var errorMsg, response;

          if (xhr.status === 401) {
            response = $.parseJSON(xhr.responseText);
            errorMsg = "Couldn't authenticate with the username/password combination provided";
          } else {
            errorMsg = "The server encountered an error while attempting to authenticate";
          }
          _this.displayError(errorMsg);
          return _this.trigger('loginfailure', errorMsg, response, xhr);
        }
      });
    };

    LoginFormView.prototype.clearError = function() {
      return this.displayError();
    };

    LoginFormView.prototype.displayError = function(msg) {
      if (msg) {
        return this.$('.alert-error').html(msg).show();
      } else {
        return this.$('.alert-error').html('').hide();
      }
    };

    return LoginFormView;

  })(View);

  DataView = (function(_super) {
    __extends(DataView, _super);

    function DataView() {
      _ref7 = DataView.__super__.constructor.apply(this, arguments);
      return _ref7;
    }

    DataView.prototype.render = function() {
      var circles, data, h, w, x, xAxis, y, yAxis;

      DataView.__super__.render.apply(this, arguments);
      w = 500;
      h = 500;
      this.svg = d3.select(this.el).append('svg:svg').attr('width', w).attr('height', h);
      this.chart = this.svg.append('rect').attr('x', 0.1 * this.svg.attr('width')).attr('y', 0).attr('width', 0.9 * this.svg.attr('width')).attr('height', 0.9 * this.svg.attr('height')).style('fill', 'green');
      x = d3.scale.linear().range([this.chart.attr('x'), parseInt(this.chart.attr('x')) + parseInt(this.chart.attr('width'))]);
      y = d3.scale.linear().range([parseInt(this.chart.attr('y')) + parseInt(this.chart.attr('height')), this.chart.attr('y')]);
      xAxis = d3.svg.axis().scale(x).orient('bottom');
      yAxis = d3.svg.axis().scale(y).orient('left');
      this.svg.append('svg:g').call(xAxis).attr('transform', "translate(0, " + (0.9 * this.svg.attr('height')) + ")");
      this.svg.append('svg:g').call(yAxis).attr('transform', "translate(" + (0.1 * this.svg.attr('width')) + ", 0)");
      data = _.map(d3.range(20), function() {
        return {
          x: Math.random(),
          y: Math.random()
        };
      });
      circles = this.svg.selectAll('circle').data(data);
      circles.enter().append('svg:circle').attr('cx', function(d) {
        return x(d.x);
      }).attr('cy', function(d) {
        return y(d.y);
      }).attr('r', 3).style('stroke', 'black').style('fill', 'red');
      circles.exit().remove();
      return this;
    };

    return DataView;

  })(Backbone.View);

  AlertsView = (function(_super) {
    __extends(AlertsView, _super);

    function AlertsView() {
      this.displayAlert = __bind(this.displayAlert, this);      _ref8 = AlertsView.__super__.constructor.apply(this, arguments);
      return _ref8;
    }

    AlertsView.prototype.className = 'alerts';

    AlertsView.prototype.alertTemplate = _.template('<div class="alert alert-<%= type %>">\n    <a class="close" data-dismiss="alert">×</a>\n    <%= body %>\n</div>');

    AlertsView.prototype.initialize = function() {
      return this.model.on('published', this.displayAlert);
    };

    AlertsView.prototype.displayAlert = function(alert) {
      return this.$el.append(this.alertTemplate(alert));
    };

    return AlertsView;

  })(Backbone.View);

  AppToolbar = (function(_super) {
    __extends(AppToolbar, _super);

    function AppToolbar() {
      this.logout = __bind(this.logout, this);      _ref9 = AppToolbar.__super__.constructor.apply(this, arguments);
      return _ref9;
    }

    AppToolbar.prototype.templateId = 'templates/app-toolbar';

    AppToolbar.prototype.className = 'app-toolbar';

    AppToolbar.prototype.events = function() {
      return {
        'click [rel=login]': 'showLogin',
        'click [rel=logout]': 'logout',
        'click [rel=visualize]': 'showVisualizations'
      };
    };

    AppToolbar.prototype.initialize = function() {
      return App.on('change:user', this.render, this);
    };

    AppToolbar.prototype.viewContext = function() {
      return _.extend(AppToolbar.__super__.viewContext.apply(this, arguments), {
        user: App.user.toJSON()
      });
    };

    AppToolbar.prototype.showLogin = function(e) {
      var loginForm,
        _this = this;

      e.preventDefault();
      e.stopPropagation();
      loginForm = new LoginFormView();
      loginForm.show();
      loginForm.$('input:visible,select:visible,textarea:visible').first().focus();
      return loginForm.on('loginsuccess', function(data) {
        App.user = new models.User(data.user, {
          parse: true
        });
        return App.trigger('change:user');
      });
    };

    AppToolbar.prototype.logout = function(e) {
      var _this = this;

      e.preventDefault();
      e.stopPropagation();
      return $.ajax({
        url: App.links.logout,
        dataType: 'json',
        success: function() {
          App.user = new models.User();
          App.alerts.publish('success', 'You have been logged out successfully');
          return App.trigger('change:user');
        }
      });
    };

    AppToolbar.prototype.showVisualizations = function() {
      return App.view.pushPane(new DataView());
    };

    return AppToolbar;

  })(View);

  AppView = (function(_super) {
    __extends(AppView, _super);

    function AppView() {
      _ref10 = AppView.__super__.constructor.apply(this, arguments);
      return _ref10;
    }

    AppView.prototype.templateId = 'templates/appview';

    AppView.prototype.className = 'appview';

    AppView.prototype.template = _.template('<div class="app-toolbar"></div>\n<div class="alerts"></div>\n<div class="app-content"></div>');

    AppView.prototype.initialize = function() {
      this.panes = [];
      this.toolbar = new AppToolbar(self);
      return this.alertsView = new AlertsView({
        model: App.alerts
      });
    };

    AppView.prototype.render = function() {
      this.$el.html(this.template());
      this.$('.app-toolbar').replaceWith(this.toolbar.render().$el);
      this.$('.alerts').replaceWith(this.alertsView.render().$el);
      if (this.pane) {
        this.$('.app-content').append(this.pane.render().$el);
      }
      return this;
    };

    AppView.prototype.pushPane = function(paneView) {
      var lastPane;

      lastPane = this.pane;
      this.panes.push(paneView);
      this.pane = paneView;
      this.$('.app-content').children().detach();
      this.$('.app-content').append(this.pane.render().$el);
      return this.trigger('change:pane', {
        "new": this.pane,
        old: lastPane
      });
    };

    AppView.prototype.popPane = function() {
      var lastPane;

      lastPane = this.panes.pop();
      this.$('.app-content').children().detach();
      this.pane = _.last(this.panes);
      if (this.pane) {
        this.$('.app-content').append(this.pane.render().$el);
      }
      this.trigger('change:pane', {
        "new": this.pane,
        old: lastPane
      });
      return lastPane;
    };

    return AppView;

  })(Backbone.View);

  SpecimenEditPane = (function(_super) {
    __extends(SpecimenEditPane, _super);

    function SpecimenEditPane() {
      _ref11 = SpecimenEditPane.__super__.constructor.apply(this, arguments);
      return _ref11;
    }

    SpecimenEditPane.prototype.templateId = 'templates/specimen-edit';

    return SpecimenEditPane;

  })(View);

  ImageView = (function(_super) {
    __extends(ImageView, _super);

    function ImageView() {
      this.cancelReplacement = __bind(this.cancelReplacement, this);
      this.replaceFile = __bind(this.replaceFile, this);
      this.render = __bind(this.render, this);      _ref12 = ImageView.__super__.constructor.apply(this, arguments);
      return _ref12;
    }

    ImageView.prototype.templateId = 'templates/image-control';

    ImageView.prototype.className = 'image-view';

    ImageView.prototype.initialize = function() {
      return this.model.on('change', this.render);
    };

    ImageView.prototype.events = function() {
      return {
        'change input[type=file]': 'replaceFile',
        'click .cancel-replace': 'cancelReplacement',
        'click [rel=remove-image]': 'remove'
      };
    };

    ImageView.prototype.render = function() {
      var replacementInput;

      replacementInput = this.$('.replacementFile input[type=file]');
      ImageView.__super__.render.apply(this, arguments);
      this.$('.replacementFile').empty().append(replacementInput);
      this.$('.dropdown-toggle').dropdown();
      return this;
    };

    ImageView.prototype.replaceFile = function(e) {
      var fileId, fileInput;

      fileInput = $(e.currentTarget);
      fileId = "file-" + this.model.cid;
      fileInput.attr('name', fileId);
      this.$('.replacementFile').empty().append(fileInput);
      return this.model.set('replacementFile', {
        name: fileInput.val().replace("C:\\fakepath\\", ""),
        file: fileId
      });
    };

    ImageView.prototype.cancelReplacement = function() {
      this.$('.replacementFile').empty();
      return this.model.set('replacementFile', null);
    };

    ImageView.prototype.remove = function() {
      this.model.collection.remove(this.model);
      return ImageView.__super__.remove.apply(this, arguments);
    };

    return ImageView;

  })(View);

  PaginationView = (function(_super) {
    __extends(PaginationView, _super);

    function PaginationView() {
      this.buildPageElement = __bind(this.buildPageElement, this);
      this.buildPageElements = __bind(this.buildPageElements, this);      _ref13 = PaginationView.__super__.constructor.apply(this, arguments);
      return _ref13;
    }

    PaginationView.prototype.className = 'pagination';

    PaginationView.prototype.initialize = function(attrs) {
      PaginationView.__super__.initialize.apply(this, arguments);
      this.currentPage = attrs.currentPage;
      return this.totalPages = attrs.totalPages;
    };

    PaginationView.prototype.events = function() {
      return {
        'click [rel=page]': 'navigate'
      };
    };

    PaginationView.prototype.render = function() {
      var paginationList;

      PaginationView.__super__.render.apply(this, arguments);
      paginationList = $('<ul>');
      _.each(this.buildPageElements(), function(el) {
        return paginationList.append(el);
      });
      this.$el.empty().append(paginationList);
      return this;
    };

    PaginationView.prototype.navigate = function(e) {
      e.preventDefault();
      e.stopPropagation();
      return this.trigger('navigate', $(e.currentTarget).data('page'));
    };

    PaginationView.prototype.buildPageElements = function() {
      var pages;

      pages = this.paginate(this.currentPage, this.totalPages);
      return _.map(pages, this.buildPageElement);
    };

    PaginationView.prototype.buildPageElement = function(page) {
      if (!page.pageNumber) {
        return "<li><a href='#' class='inactive'>" + page.display + "</a></li>";
      } else {
        return "<li><a href='#' rel='page' data-page='" + page.pageNumber + "'>" + page.display + "</a></li>";
      }
    };

    PaginationView.prototype.paginate = function(currentPage, totalPages, adjacent) {
      var chunkend, chunkstart, createPageNav, createPaginationStruct, ellipsisPost, ellipsisPre, pages;

      if (adjacent == null) {
        adjacent = 2;
      }
      if (adjacent == null) {
        adjacent = 2;
      }
      if (totalPages <= 1) {
        return [];
      }
      createPaginationStruct = function(pageNumber, display, isCurrent) {
        return {
          pageNumber: pageNumber,
          display: display != null ? display : pageNumber,
          isCurrent: isCurrent != null ? isCurrent : false
        };
      };
      createPageNav = function(pageIdx) {
        return createPaginationStruct(pageIdx, null, pageIdx === currentPage);
      };
      chunkstart = currentPage - adjacent;
      chunkend = currentPage + adjacent;
      ellipsisPre = true;
      ellipsisPost = true;
      if (chunkstart <= 2) {
        ellipsisPre = false;
        chunkstart = 1;
        chunkend = Math.max(chunkend, adjacent * 2);
      }
      if (chunkend >= (totalPages - 1)) {
        ellipsisPost = false;
        chunkend = totalPages;
        chunkstart = Math.min(chunkstart, totalPages - (adjacent * 2) + 1);
      }
      if (chunkstart <= 2) {
        ellipsisPre = false;
        chunkstart = Math.max(chunkstart, 1);
        chunkend = Math.min(chunkend, totalPages);
      }
      pages = _.map(_.range(chunkstart, chunkend + 1), createPageNav);
      if (ellipsisPre) {
        pages.unshift(createPaginationStruct(null, '&hellip;'));
        pages.unshift(createPageNav(1));
      }
      if (ellipsisPost) {
        pages.push(createPaginationStruct(null, '&hellip;'));
        pages.push(createPageNav(totalPages));
      }
      if (currentPage > 1) {
        pages.unshift(createPaginationStruct(currentPage - 1, '&#xab;'));
      }
      if (currentPage < totalPages) {
        pages.push(createPaginationStruct(currentPage + 1, '&#xbb;'));
      }
      return pages;
    };

    return PaginationView;

  })(Backbone.View);

  FormPaginationView = (function(_super) {
    __extends(FormPaginationView, _super);

    function FormPaginationView() {
      this.buildPageElement = __bind(this.buildPageElement, this);      _ref14 = FormPaginationView.__super__.constructor.apply(this, arguments);
      return _ref14;
    }

    FormPaginationView.prototype.buildPageElement = function(page) {
      var _ref15;

      if (!page.pageNumber) {
        return "<a href='javascript:void(0)'>" + page.display + "</a>";
      } else {
        return "<button type='submit' name='" + ((_ref15 = this.model.get('pageParam')) != null ? _ref15 : 'page') + "'         value='" + page.pageNumber + ">" + page.display + "</button>";
      }
    };

    return FormPaginationView;

  })(PaginationView);

  _.extend(exports, {
    'AppView': AppView,
    'ImageView': ImageView,
    'DataView': DataView,
    'SpecimenForm': SpecimenForm,
    'SpecimenModal': SpecimenModal,
    'SpecimenSearchPane': SpecimenSearchPane,
    'SpecimenDetailPane': SpecimenDetailPane
  });

}).call(this);

(function() {


}).call(this);

(function() {


}).call(this);

(function() {
  var HelloWorld;

  HelloWorld = (function() {
    function HelloWorld() {}

    HelloWorld.test = 'test';

    return HelloWorld;

  })();

  console.log('hi');

}).call(this);

(function() {
  var HelloWorld;

  HelloWorld = (function() {
    function HelloWorld() {}

    HelloWorld.test = 'test';

    return HelloWorld;

  })();

  console.log('hi');

}).call(this);

(function() {
  var HelloWorld;

  HelloWorld = (function() {
    function HelloWorld() {}

    HelloWorld.test = 'test';

    return HelloWorld;

  })();

}).call(this);

(function() {
  console.log('hi');

}).call(this);

(function() {
  var cli, middleware;

  cli = require('cli');

  cli.enable('daemon', 'status').setUsage('static.coffee [OPTIONS]');

  cli.parse({
    log: ['l', 'Enable logging'],
    port: ['p', 'Listen on this port', 'number', 8080],
    serve: [false, 'Serve static files from PATH', 'path', './public']
  });

  middleware = [];

  cli.main(function(args, options) {
    var server;

    if (options.log) {
      this.debug('Enabling logging');
      middleware.push(require('creationix/log')());
    }
    this.debug('Serving files from ' + options.serve);
    middleware.push(require('creationix/static')('/', options.serve, 'index.html'));
    server = this.createServer(middleware).listen(options.port);
    return this.ok('Listening on port ' + options.port);
  });

}).call(this);

(function() {
  var cubes, list, math, num, number, opposite, race, square,
    __slice = [].slice;

  number = 42;

  opposite = true;

  if (opposite) {
    number = -42;
  }

  square = function(x) {
    return x * x;
  };

  list = [1, 2, 3, 4, 5];

  math = {
    root: Math.sqrt,
    square: square,
    cube: function(x) {
      return x * square(x);
    }
  };

  race = function() {
    var runners, winner;

    winner = arguments[0], runners = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    return print(winner, runners);
  };

  if (typeof elvis !== "undefined" && elvis !== null) {
    alert("I knew it!");
  }

  cubes = (function() {
    var _i, _len, _results;

    _results = [];
    for (_i = 0, _len = list.length; _i < _len; _i++) {
      num = list[_i];
      _results.push(math.cube(num));
    }
    return _results;
  })();

}).call(this);

(function() {
  var cubes, list, math, num, number, opposite, race, square,
    __slice = [].slice;

  number = 42;

  opposite = true;

  if (opposite) {
    number = -42;
  }

  square = function(x) {
    return x * x;
  };

  list = [1, 2, 3, 4, 5];

  math = {
    root: Math.sqrt,
    square: square,
    cube: function(x) {
      return x * square(x);
    }
  };

  race = function() {
    var runners, winner;

    winner = arguments[0], runners = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    return print(winner, runners);
  };

  if (typeof elvis !== "undefined" && elvis !== null) {
    alert("I knew it!");
  }

  cubes = (function() {
    var _i, _len, _results;

    _results = [];
    for (_i = 0, _len = list.length; _i < _len; _i++) {
      num = list[_i];
      _results.push(math.cube(num));
    }
    return _results;
  })();

}).call(this);

(function() {
  module.exports.init = function(grunt) {
    return function(content, deps, name) {
      var depsString, packageString;

      if (deps == null) {
        deps = [];
      }
      if (name == null) {
        name = null;
      }
      if (deps.constructor === Array && deps.length) {
        depsString = "['" + (deps.join('\', \'')) + "'], ";
      }
      if (typeof deps === 'string' && name === null) {
        packageString = "'" + deps + "', ";
      } else if (typeof name === 'string' && name.length) {
        packageString = "'" + name + "', ";
      }
      return "define(" + (packageString != null ? packageString : '') + (depsString != null ? depsString : '') + "function () {\n\t" + (content.split('\n').join('\n\t')) + "\n});";
    };
  };

}).call(this);

/*
# grunt-dust
# https://github.com/vtsvang/grunt-dust
#
# Copyright (c) 2013 Vladimir Tsvang
# Licensed under the MIT license.
*/


(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  module.exports = function(grunt) {
    var amdHelper, dust, dustjsVersion, fs, path, runtime, _;

    _ = grunt.util._;
    dust = require("dustjs-linkedin");
    path = require("path");
    fs = require("fs");
    amdHelper = require("../helpers/amd").init(grunt);
    runtime = {
      version: (dustjsVersion = require("dustjs-linkedin/package.json").version),
      path: require.resolve("dustjs-linkedin/dist/dust-core-" + dustjsVersion + ".js"),
      file: "dust-runtime.js",
      amdName: "dust-runtime"
    };
    return grunt.registerMultiTask("dust", "Task to compile dustjs templates.", function() {
      var e, file, options, output, runtimeDestDir, source, tplName, tplRelativePath, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _results;

      options = this.options({
        runtime: true,
        relative: false,
        amd: {
          packageName: null,
          deps: [runtime.amdName]
        }
      });
      grunt.verbose.writeflags(options, "Options");
      if (!(options.runtime || (((_ref = this.data.options) != null ? (_ref1 = _ref.amd) != null ? _ref1.deps : void 0 : void 0) != null) && (_ref2 = runtime.amdName, __indexOf.call(this.data.options.amd.deps, _ref2) >= 0))) {
        options.amd.deps = _.without(options.amd.deps, runtime.amdName);
      }
      _ref3 = this.files;
      _results = [];
      for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
        file = _ref3[_i];
        output = [];
        _ref4 = file.src;
        for (_j = 0, _len1 = _ref4.length; _j < _len1; _j++) {
          source = _ref4[_j];
          tplRelativePath = (file.orig.cwd != null) && options.relative ? path.relative(file.orig.cwd, source) : source;
          tplName = tplRelativePath.replace(new RegExp("\\" + (path.extname(tplRelativePath)) + "$"), "");
          try {
            output.push(("// " + tplRelativePath + "\n") + dust.compile(grunt.file.read(source), tplName));
          } catch (_error) {
            e = _error;
            grunt.log.error().writeln(e.toString());
            grunt.warn("DustJS found errors.", 10);
          }
        }
        if (output.length > 0) {
          grunt.file.write(file.dest, options.amd ? amdHelper(output.join("\n"), (_ref5 = options.amd.deps) != null ? _ref5 : [], (_ref6 = options.amd.packageName) != null ? _ref6 : "") : (_ref7 = output.join("\n")) != null ? _ref7 : "");
        }
        if (options.runtime) {
          runtimeDestDir = file.orig.dest[file.orig.dest.length] === path.sep ? file.orig.dest : path.dirname(file.orig.dest);
          _results.push(grunt.file.write(path.join(runtimeDestDir, runtime.file), grunt.file.read(runtime.path)));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    });
  };

}).call(this);

(function() {
  global.shld = require("should");

  global.grunt = require("grunt");

  global.fs = require("fs");

  global.wrench = require("wrench");

  global.path = require("path");

  global.exec = require("child_process").exec;

  global.string = require("string");

  global.pkgRoot = path.join(__dirname, "..", "..");

  global.tmp = path.join(__dirname, "..", "tmp");

  global.dst = path.join(tmp, "dst");

}).call(this);

(function() {
  describe("grunt-dust", function() {
    before(function(done) {
      var _this = this;

      grunt.file.mkdir(tmp);
      grunt.file.copy(path.join(__dirname, "..", "..", "..", "examples", "Gruntfile.js"), path.join(tmp, "Gruntfile.js"));
      wrench.copyDirSyncRecursive(path.join(__dirname, "..", "..", "..", "examples", "src"), path.join(tmp, "src"));
      return exec("cd " + tmp + " && TEST=1 " + (path.join(pkgRoot, "node_modules", "grunt-cli", "bin", "grunt")), function(error, stdout, stderr) {
        var req, structure;

        if (error) {
          done(stderr);
        }
        _this.structure = structure = {};
        req = function(content) {
          var define, dust, e, raw, result;

          result = {
            name: null,
            deps: [],
            templates: [],
            raw: ""
          };
          dust = (function() {
            function dust() {}

            dust.register = function(name) {
              return result.templates.push(name);
            };

            return dust;

          })();
          define = function(name, deps, callback) {
            if (arguments.length === 1) {
              return name();
            } else {
              if (name.constructor === Array) {
                result.deps = name;
                return deps();
              } else if (typeof name === "string" && typeof deps === "function") {
                result.name = name;
                return deps();
              } else {
                result.name = name;
                result.deps = deps;
                return callback();
              }
            }
          };
          try {
            eval(content);
          } catch (_error) {
            e = _error;
            null;
          }
          raw = content;
          return result;
        };
        grunt.file.recurse(dst, function(abspath, rootdir, subdir, filename) {
          return structure["" + subdir + path.sep + filename] = filename === "views.js" ? req(grunt.file.read(abspath)) : {
            raw: grunt.file.read(abspath)
          };
        });
        return done();
      });
    });
    after(function() {
      wrench.rmdirSyncRecursive(tmp);
      return delete this.structure;
    });
    describe("by default", function() {
      it("should create runtime file", function() {
        return (this.structure[path.join("default", "dust-runtime.js")] != null).should.be["true"];
      });
      return it("should define runtime dependency", function() {
        return this.structure[path.join("default", "views.js")].deps.should.include("dust-runtime");
      });
    });
    describe("cwd syntax", function() {
      return it("shouldn't create runtimes in subdirectories", function() {
        return (this.structure[path.join("many-targets", "nested", "dust-runtime.js")] != null).should.be["false"];
      });
    });
    describe("no amd", function() {
      it("shouldn't define name", function() {
        return shld.not.exist(this.structure[path.join("views_no_amd", "views.js")].name);
      });
      it("shouldn't define deps", function() {
        return this.structure[path.join("views_no_amd", "views.js")].deps.length.should.eql(0);
      });
      return it("should register several templates", function() {
        return this.structure[path.join("views_no_amd", "views.js")].templates.length.should.be.above(0);
      });
    });
    describe("no runtime", function() {
      it("shouldn't create runtime file", function() {
        var _ref;

        return (_ref = this.structure[path.join("views_no_runtime", "dust-runtime.js")]) != null ? _ref.should.be["false"] : void 0;
      });
      return it("shouldn't define runtime dependency", function() {
        return this.structure[path.join("views_no_runtime", "views.js")].deps.should.not.include("dust-runtime");
      });
    });
    return describe("with package name", function() {
      return it("should define package name", function() {
        return this.structure[path.join("views_amd_with_package_name", "views.js")].name.should.equal("views");
      });
    });
  });

}).call(this);
