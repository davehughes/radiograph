(function() {
  var File, Image, ImageCollection, ImageView, ImagesView, ecoTemplates,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  ecoTemplates = this.ecoTemplates;

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

    ImageCollection.prototype.initialize = function() {
      return this.cid = _.uniqueId('IMAGES_');
    };

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
      return this.$('.add-image').before(imgView.render().$el);
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
      return {
        'change input[type=file]': 'replaceFile',
        'click .cancel-replace': 'cancelReplacement',
        'click .remove-image': 'remove'
      };
    };

    ImageView.prototype.render = function() {
      var collection_prefix, fileInput, item_prefix,
        _this = this;
      fileInput = this.$('.fileinput-button input[type=file]');
      collection_prefix = this.model.collection.cid;
      item_prefix = this.model.cid;
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
        this.$('.fileinput-button input[type=file]').replaceWith(fileInput);
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

  this.ImageView = ImageView;

  this.ImagesView = ImagesView;

}).call(this);
