(function() {
  var App, AppModel, File, FormPaginationView, Image, ImageCollection, ImageView, ImagesView, LoginFormView, PaginationView, Search, Specimen, SpecimenForm, SpecimenModal, SpecimenResults, User, View,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  View = (function(_super) {

    __extends(View, _super);

    function View() {
      View.__super__.constructor.apply(this, arguments);
    }

    View.prototype.templateId = null;

    View.prototype.viewContext = function() {
      var _ref, _ref2;
      return (_ref = (_ref2 = this.model) != null ? _ref2.toJSON() : void 0) != null ? _ref : {};
    };

    View.prototype.render = function() {
      var templateEl;
      View.__super__.render.apply(this, arguments);
      templateEl = ecoTemplates[this.templateId](this.viewContext());
      this.$el.html(templateEl);
      return this;
    };

    return View;

  })(Backbone.View);

  SpecimenForm = (function(_super) {

    __extends(SpecimenForm, _super);

    function SpecimenForm() {
      SpecimenForm.__super__.constructor.apply(this, arguments);
    }

    SpecimenForm.prototype.templateId = 'specimen-edit';

    SpecimenForm.prototype.viewContext = function() {
      return _.extend(SpecimenForm.__super__.viewContext.apply(this, arguments), {
        institutionChoices: ['Harvard', 'Smithsonian'],
        sexChoices: ['M', 'F', '?'],
        taxonChoices: ['', 'Foo', 'Bar', 'Baz'],
        links: {}
      });
    };

    SpecimenForm.prototype.render = function() {
      var _this = this;
      SpecimenForm.__super__.render.apply(this, arguments);
      _.defer(function() {
        return _this.$('select[name=taxon]').chosen();
      });
      new ImagesView({
        el: this.$('.image-controls')
      });
      return this;
    };

    return SpecimenForm;

  })(View);

  SpecimenModal = (function(_super) {

    __extends(SpecimenModal, _super);

    function SpecimenModal() {
      SpecimenModal.__super__.constructor.apply(this, arguments);
    }

    SpecimenModal.prototype.className = 'modal specimen-modal';

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

  Specimen = (function(_super) {

    __extends(Specimen, _super);

    function Specimen() {
      Specimen.__super__.constructor.apply(this, arguments);
    }

    Specimen.prototype.defaults = function() {
      return {
        institution: null,
        sex: null,
        taxon: null,
        specimen_id: null,
        settings: null,
        comments: null,
        images: new ImageCollection([])
      };
    };

    return Specimen;

  })(Backbone.Model);

  User = (function(_super) {

    __extends(User, _super);

    function User() {
      User.__super__.constructor.apply(this, arguments);
    }

    User.prototype.defaults = function() {
      return {
        loggedIn: false,
        firstName: 'Anonymous',
        lastName: '',
        isStaff: false,
        links: {
          login: 'login',
          logout: 'logout'
        }
      };
    };

    return User;

  })(Backbone.Model);

  Search = (function(_super) {

    __extends(Search, _super);

    function Search() {
      Search.__super__.constructor.apply(this, arguments);
    }

    Search.prototype.defaults = function() {
      return {
        url: window.location.pathname,
        args: {},
        resultsPerPage: 20,
        currentPage: 1,
        totalPages: 10,
        facets: [],
        query: '*:*',
        results: [
          {
            sex: 'Male',
            taxon_label: '<Taxon>',
            links: {
              edit: ''
            }
          }, {
            sex: 'Female',
            taxon_label: '<Taxon>',
            links: {
              edit: ''
            }
          }
        ]
      };
    };

    return Search;

  })(Backbone.Model);

  AppModel = (function(_super) {

    __extends(AppModel, _super);

    function AppModel() {
      this.alert = __bind(this.alert, this);
      AppModel.__super__.constructor.apply(this, arguments);
    }

    AppModel.prototype.defaults = function() {
      return {
        user: new User(),
        search: new Search(),
        institutionChoices: [],
        links: {
          createSpecimen: ''
        }
      };
    };

    AppModel.prototype.initialize = function() {
      AppModel.__super__.initialize.apply(this, arguments);
      return this.alerts = new Backbone.Collection();
    };

    AppModel.prototype.alert = function(type, body) {
      if (type == null) type = 'info';
      return this.alerts.add({
        type: type,
        body: body
      });
    };

    AppModel.prototype.toJSON = function() {
      return _.extend(AppModel.__super__.toJSON.apply(this, arguments), {
        user: this.get('user').toJSON(),
        search: this.get('search').toJSON(),
        alerts: this.alerts.toJSON()
      });
    };

    return AppModel;

  })(Backbone.Model);

  App = new AppModel();

  SpecimenResults = (function(_super) {

    __extends(SpecimenResults, _super);

    function SpecimenResults() {
      this.logout = __bind(this.logout, this);
      SpecimenResults.__super__.constructor.apply(this, arguments);
    }

    SpecimenResults.prototype.templateId = 'specimen-list';

    SpecimenResults.prototype.events = function() {
      return {
        'click [rel=login]': 'showLogin',
        'click [rel=logout]': 'logout',
        'click [rel=create]': 'showCreateItemForm',
        'click [rel=edit]': 'showEditItemForm'
      };
    };

    SpecimenResults.prototype.initialize = function() {
      SpecimenResults.__super__.initialize.apply(this, arguments);
      return this.model.on('change:user', this.render, this);
    };

    SpecimenResults.prototype.render = function() {
      SpecimenResults.__super__.render.apply(this, arguments);
      if (this.model.get('user').get('isStaff')) {
        this.$('[rel=edit],[rel=create]').show();
      } else {
        this.$('[rel=edit],[rel=create]').hide();
      }
      return this;
    };

    SpecimenResults.prototype.viewContext = function() {
      var pagination, search;
      search = this.model.get('search');
      pagination = new FormPaginationView({
        model: search
      }).render().$el.html();
      return _.extend(SpecimenResults.__super__.viewContext.apply(this, arguments), {
        pagination: pagination
      });
    };

    SpecimenResults.prototype.showLogin = function(e) {
      var loginForm,
        _this = this;
      e.preventDefault();
      e.stopPropagation();
      loginForm = new LoginFormView();
      loginForm.show();
      loginForm.$('input:visible,select:visible,textarea:visible').first().focus();
      return loginForm.on('loginsuccess', function(data) {
        return _this.model.set('user', new User(data.user, {
          parse: true
        }));
      });
    };

    SpecimenResults.prototype.showCreateItemForm = function(e) {
      e.preventDefault();
      e.stopPropagation();
      return new SpecimenModal().render().$('input:visible,select:visible,textarea:visible').first().focus();
    };

    SpecimenResults.prototype.showEditItemForm = function(e) {
      e.preventDefault();
      e.stopPropagation();
      return new SpecimenModal().render().$('input:visible,select:visible,textarea:visible').first().focus();
    };

    SpecimenResults.prototype.logout = function(e) {
      var _this = this;
      e.preventDefault();
      e.stopPropagation();
      return $.ajax({
        url: $(e.currentTarget).attr('href'),
        dataType: 'json',
        success: function() {
          _this.model.alert('success', 'You have been logged out successfully.');
          return _this.model.set('user', new User());
        }
      });
    };

    return SpecimenResults;

  })(View);

  LoginFormView = (function(_super) {

    __extends(LoginFormView, _super);

    function LoginFormView() {
      this.clearError = __bind(this.clearError, this);
      this.hide = __bind(this.hide, this);
      this.show = __bind(this.show, this);
      LoginFormView.__super__.constructor.apply(this, arguments);
    }

    LoginFormView.prototype.templateId = 'login';

    LoginFormView.prototype.events = function() {
      return {
        'submit form': 'submit'
      };
    };

    LoginFormView.prototype.viewContext = function() {
      return {
        errors: [],
        links: {
          login: '/accounts/login/'
        }
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
        type: form.attr('method'),
        url: form.attr('action'),
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

  File = (function(_super) {

    __extends(File, _super);

    function File() {
      File.__super__.constructor.apply(this, arguments);
    }

    File.prototype.defaults = {
      name: null,
      url: null
    };

    return File;

  })(Backbone.Model);

  Image = (function(_super) {

    __extends(Image, _super);

    function Image() {
      Image.__super__.constructor.apply(this, arguments);
    }

    Image.prototype.defaults = {
      id: null,
      aspect: null,
      currentFile: null,
      replacementFile: null
    };

    Image.prototype.toJSON = function() {
      var _ref, _ref2;
      return _.extend(Image.__super__.toJSON.apply(this, arguments), {
        currentFile: (_ref = this.get('currentFile')) != null ? _ref.toJSON() : void 0,
        replacementFile: (_ref2 = this.get('replacementFile')) != null ? _ref2.toJSON() : void 0
      });
    };

    return Image;

  })(Backbone.Model);

  ImageCollection = (function(_super) {

    __extends(ImageCollection, _super);

    function ImageCollection() {
      ImageCollection.__super__.constructor.apply(this, arguments);
    }

    ImageCollection.prototype.model = Image;

    return ImageCollection;

  })(Backbone.Collection);

  ImagesView = (function(_super) {

    __extends(ImagesView, _super);

    function ImagesView() {
      ImagesView.__super__.constructor.apply(this, arguments);
    }

    ImagesView.prototype.initialize = function(attrs, options) {
      var images,
        _this = this;
      images = _.map(this.$('.image-control'), function(i) {
        i = $(i);
        return new Image({
          id: i.find('input[type=hidden]').val(),
          aspect: i.find('select').val(),
          currentFile: new File({
            name: i.find('a').text(),
            url: i.find('a').attr('href')
          })
        });
      });
      this.model = new ImageCollection(images);
      this.model.on('add', this.addImageView, this);
      this.model.prefix = this.$el.parent('.controls').find('input[name=prefix]').val();
      return this.render();
    };

    ImagesView.prototype.events = function() {
      return {
        'click .add-image': 'addImage'
      };
    };

    ImagesView.prototype.render = function() {
      var _this = this;
      this.$el.empty();
      this.$el.append($('<a class="btn add-image"><i class="icon-plus"></i>Add Image</a>'));
      return this.model.each(function(img) {
        return _this.addImageView(img);
      });
    };

    ImagesView.prototype.addImage = function() {
      return this.model.add(new Image());
    };

    ImagesView.prototype.addImageView = function(img) {
      var imgView;
      imgView = new ImageView({
        model: img
      });
      this.$('.add-image').before(imgView.render().$el);
      return this.$el.parents('form').on('submit', function() {
        return imgView.render();
      });
    };

    return ImagesView;

  })(Backbone.View);

  ImageView = (function(_super) {

    __extends(ImageView, _super);

    function ImageView() {
      ImageView.__super__.constructor.apply(this, arguments);
    }

    ImageView.prototype.initialize = function() {
      return this.model.on('change', this.render, this);
    };

    ImageView.prototype.events = function() {
      var _this = this;
      return {
        'change select': function(e) {
          return _this.model.set('aspect', $(e.currentTarget).val());
        },
        'change input[type=file]': 'replaceFile',
        'click .cancel-replace': 'cancelReplacement',
        'click .remove-image': 'remove'
      };
    };

    ImageView.prototype.render = function() {
      var collection_prefix, fileInput, item_prefix,
        _this = this;
      fileInput = this.$('.fileinput-button input[type=file]');
      collection_prefix = this.model.collection.prefix;
      item_prefix = this.model.collection.indexOf(this.model);
      this.$el.html(ecoTemplates['image-control']({
        image: this.model.toJSON(),
        tagAs: function(prop) {
          var propTag;
          propTag = "" + collection_prefix + "-" + item_prefix + "-" + prop;
          return "id='id_" + propTag + "' name='" + propTag + "'";
        },
        aspectOptions: function() {
          return _this.aspectOptions();
        }
      }));
      if (fileInput.length > 0) {
        this.$('.fileinput-button input[type=file]').each(function(idx, input) {
          return $(input).replaceWith(fileInput.clone(true));
        });
      }
      this.$('.dropdown-toggle').dropdown();
      return this;
    };

    ImageView.prototype.replaceFile = function(e) {
      var replacementFile;
      replacementFile = new File({
        name: $(e.currentTarget).val().replace("C:\\fakepath\\", "")
      });
      return this.model.set('replacementFile', replacementFile);
    };

    ImageView.prototype.cancelReplacement = function(e) {
      return this.model.set('replacementFile', null);
    };

    ImageView.prototype.aspectOptions = function() {
      var options,
        _this = this;
      options = [
        {
          value: '',
          label: '---------'
        }, {
          value: 'L',
          label: 'Lateral'
        }, {
          value: 'S',
          label: 'Superior'
        }
      ];
      return _.map(options, function(x) {
        x.selected = x.value === _this.model.get('aspect');
        return x;
      });
    };

    ImageView.prototype.remove = function() {
      this.model.collection.remove(this.model);
      return ImageView.__super__.remove.apply(this, arguments);
    };

    return ImageView;

  })(Backbone.View);

  PaginationView = (function(_super) {

    __extends(PaginationView, _super);

    function PaginationView() {
      this.buildPageElement = __bind(this.buildPageElement, this);
      this.buildPageUrl = __bind(this.buildPageUrl, this);
      PaginationView.__super__.constructor.apply(this, arguments);
    }

    PaginationView.prototype.templateId = 'pagination';

    PaginationView.prototype.viewContext = function() {
      return _.extend(PaginationView.__super__.viewContext.apply(this, arguments), {
        pages: this.paginate(this.model.get('currentPage'), this.model.get('totalPages')),
        buildPageElement: this.buildPageElement
      });
    };

    PaginationView.prototype.buildPageUrl = function(page) {
      var params, _ref;
      params = {};
      params[(_ref = this.model.get('pageParam')) != null ? _ref : 'page'] = page.pageNumber;
      params = _.extend({}, this.model.get('params'), params);
      return "" + (this.model.get('url')) + "?" + ($.param(params));
    };

    PaginationView.prototype.buildPageElement = function(page) {
      var url;
      if (!page.pageNumber) {
        return "<a href='javascript:void(0)' class='inactive'>" + page.display + "</a>";
      } else {
        url = this.buildPageUrl(page);
        return "<a href='" + url + "' rel='page'>" + page.display + "</a>";
      }
    };

    PaginationView.prototype.paginate = function(currentPage, totalPages, adjacent) {
      var chunkend, chunkstart, createPageNav, createPaginationStruct, ellipsisPost, ellipsisPre, pages;
      if (adjacent == null) adjacent = 2;
      if (totalPages <= 1) return [];
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
      if (chunkstart <= 2) ellipsisPre = false;
      chunkstart = Math.max(chunkstart, 1);
      chunkend = Math.min(chunkend, totalPages);
      pages = _.map(_.range(chunkstart, chunkend + 1), createPageNav);
      if (ellipsisPre) {
        pages.unshift(createPaginationStruct(null, '...'));
        pages.unshift(createPageNav(1));
      }
      if (ellipsisPost) {
        pages.push(createPaginationStruct(null, '...'));
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

  })(View);

  FormPaginationView = (function(_super) {

    __extends(FormPaginationView, _super);

    function FormPaginationView() {
      this.buildPageElement = __bind(this.buildPageElement, this);
      FormPaginationView.__super__.constructor.apply(this, arguments);
    }

    FormPaginationView.prototype.buildPageElement = function(page) {
      var pageParam, _ref;
      if (!page.pageNumber) {
        return "<a href='javascript:void(0)'>" + page.display + "</a>";
      } else {
        pageParam = (_ref = this.model.get('pageParam')) != null ? _ref : 'page';
        return "<button type='submit' name='" + pageParam + "' value='" + page.pageNumber + "'>" + page.display + "</button>";
      }
    };

    return FormPaginationView;

  })(PaginationView);

  _.extend(this, {
    ImageView: ImageView,
    ImagesView: ImagesView,
    SpecimenForm: SpecimenForm,
    SpecimenModal: SpecimenModal,
    SpecimenResults: SpecimenResults,
    App: App
  });

}).call(this);
