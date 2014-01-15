(function() {
  var SpecimenSearch, SpecimenSearchForm, _ref, _ref1, _ref2, _ref3, _ref4,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  SpecimenSearch = (function(_super) {
    __extends(SpecimenSearch, _super);

    function SpecimenSearch() {
      _ref = SpecimenSearch.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    SpecimenSearch.prototype.url = '/specimens';

    SpecimenSearch.prototype.defaults = {
      page: 1,
      results: 10,
      view: 'standard'
    };

    return SpecimenSearch;

  })(Backbone.Model);

  SpecimenSearchForm = (function(_super) {
    __extends(SpecimenSearchForm, _super);

    function SpecimenSearchForm() {
      this.selectPage = __bind(this.selectPage, this);
      this.selectView = __bind(this.selectView, this);
      this.render = __bind(this.render, this);
      this.events = __bind(this.events, this);      _ref1 = SpecimenSearchForm.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    SpecimenSearchForm.prototype.events = function() {
      return {
        'click .select-view a': 'selectView',
        'click .pagination a': 'selectPage'
      };
    };

    SpecimenSearchForm.prototype.render = function() {
      var resultsValue;

      resultsValue = this.$('[name=results]').val();
      this.$(".results li").removeClass('active');
      return this.$(".results [data-value=" + resultsValue + "]").closest('li').addClass('active');
    };

    SpecimenSearchForm.prototype.selectView = function(e) {
      return this.model.set('view', $(e.currentTarget).data('value'));
    };

    SpecimenSearchForm.prototype.selectPage = function(e) {
      e.preventDefault();
      e.stopPropagation();
      return this.model.set('page', $(e.currentTarget).data('value'));
    };

    return SpecimenSearchForm;

  })(Backbone.View);

  if ((_ref2 = this.Radiograph) == null) {
    this.Radiograph = {};
  }

  this.Radiograph.Models = _.extend((_ref3 = this.Radiograph.Models) != null ? _ref3 : {}, {
    SpecimenSearch: SpecimenSearch
  });

  this.Radiograph.Views = _.extend((_ref4 = this.Radiograph.Views) != null ? _ref4 : {}, {
    SpecimenSearchForm: SpecimenSearchForm
  });

}).call(this);
