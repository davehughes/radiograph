(function() {
  this.ecoTemplates || (this.ecoTemplates = {});
  this.ecoTemplates["specimen-list"] = function(__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
        var alert, choice, specimen, _i, _j, _k, _len, _len2, _len3, _ref, _ref2, _ref3;
      
        __out.push('<div class="btn-toolbar">\n    <div class="btn-group">\n        <a class="btn btn-small" href="#">\n            <i class="icon-download"></i>\n            Download\n        </a>\n    </div>\n    <div class="btn-group">\n        ');
      
        if (this.user.loggedIn) {
          __out.push('\n        <a class="btn btn-small dropdown-toggle" data-toggle="dropdown">\n            <i class="icon-user"></i>\n            ');
          __out.push(__sanitize(this.user.firstName));
          __out.push('\n            <span class="caret"></span>\n        </a>\n        <ul class="dropdown-menu">\n            <li>\n            <a rel="logout" href="');
          __out.push(__sanitize(this.user.links.logout));
          __out.push('">\n                <i class="icon-off"></i>Log Out\n            </a>\n            </li>\n        </ul>\n        ');
        } else {
          __out.push('\n        <a class="btn btn-small" rel="login" href="');
          __out.push(__sanitize(this.user.links.login));
          __out.push('">\n            <i class="icon-user"></i>Sign In\n        </a>\n        ');
        }
      
        __out.push('\n    </div>\n</div>\n\n<div class="alerts">\n    ');
      
        _ref = this.alerts;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          alert = _ref[_i];
          __out.push('\n        <div class="alert ');
          __out.push(__sanitize("alert-" + alert.type));
          __out.push('">\n            <a class="close" data-dismiss="alert" href="#">×</a>\n            ');
          __out.push(__sanitize(alert.body));
          __out.push('\n        </div>\n    ');
        }
      
        __out.push('\n</div>\n\n<div class="pagination-toolbar">\n    ');
      
        __out.push(this.pagination);
      
        __out.push('\n\n    Showing \n    <span class="dropdown">\n        <a class="dropdown-toggle" data-toggle="dropdown">\n            <span class="results-per-page">\n                ');
      
        __out.push(__sanitize(this.search.resultsPerPage));
      
        __out.push('\n            </span>\n            <span class="caret"></span>\n        </a>\n        \n        <ul class="dropdown-menu">\n            <li><a href="#">10</a></li>\n            <li><a href="#">20</a></li>\n            <li><a href="#">50</a></li>\n            <li><a href="#">100</a></li>\n            <li><a href="#">&#x221e;</a></li>\n        </ul>\n    </span> results per page\n</div>\n\n<table class="table table-condensed table-striped">\n    <col width="10%"/>\n    <col/>\n    <col width="10%"/>\n    <col width="20%"/>\n    <col width="25"/>\n    <tr>\n        <th>\n            <span class="dropdown">\n                <a href="#" class="dropdown-toggle" data-toggle="dropdown">\n                    <input type="checkbox" class="item-selector"/>\n                    <span class="caret"></span>\n                </a>\n                <ul class="dropdown-menu">\n                    <li>\n                        <a href="#" class="item-selection-all">\n                            <i class="icon-ok"></i>\n                            Select All\n                        </a>\n                    </li>\n                    <li>\n                        <a href="#" class="item-selection-none">\n                            <i class="icon-remove"></i>\n                            Select None\n                        </a>\n                    </li>\n                    <li>\n                        <a href="#" class="item-selection-invert">\n                            <i class="icon-resize-full"></i>\n                            Invert Selection\n                        </a>\n                    </li>\n                </ul>\n            </span>\n        </th>\n        <th>\n            <span class="dropdown">\n                <a href="#" class="dropdown-toggle" data-toggle="dropdown">\n                    Taxon\n                    <span class="caret"></span>\n                </a>\n                <div class="dropdown-menu">\n                    <h1>Surprise!!!</h1>\n                </div>\n                <!--ul class="dropdown-menu">\n                    <li>Sort</li>\n                    <li>Filter</li>\n                </ul-->\n            </span>\n        </th>\n        <th>\n            <span class="dropdown">\n                <a href="#" class="dropdown-toggle" data-toggle="dropdown">\n                    Sex\n                    <span class="caret"></span>\n                </a>\n                <ul class="dropdown-menu">\n                    ');
      
        _ref2 = this.institutionChoices;
        for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
          choice = _ref2[_j];
          __out.push('\n                        <li>\n                        <input type="checkbox" name="filter-sex-');
          __out.push(__sanitize(choice.value));
          __out.push('"/>\n                        <label for="filter-sex-');
          __out.push(__sanitize(choice.value));
          __out.push('">');
          __out.push(__sanitize(choice.label));
          __out.push('</label>\n                        </li>\n                    ');
        }
      
        __out.push('\n                </ul>\n            </span>\n        </th>\n        <th>Images</th>\n        <th>\n            <a class="btn btn-small" \n               rel="create"\n               href="');
      
        __out.push(__sanitize(this.links.createSpecimen));
      
        __out.push('"\n               title="Create New Specimen">\n                <i class="icon-plus"></i>\n            </a>\n        </th>\n    </tr>\n\n    ');
      
        _ref3 = this.search.results;
        for (_k = 0, _len3 = _ref3.length; _k < _len3; _k++) {
          specimen = _ref3[_k];
          __out.push('\n    <tr>\n        <td class="selection">\n            <input type="checkbox" class="item-selection"\n                value="');
          specimen.id;
          __out.push('"/>\n        </td>\n        <td class="taxon">');
          __out.push(__sanitize(specimen.taxon_label));
          __out.push('</td>\n        <td class="sex">');
          __out.push(__sanitize(specimen.sex));
          __out.push('</td>\n        <td class="images">\n            <a href="#">Lateral</a>\n            <a href="#">Superior</a>\n        </td>\n        <td class="actions">\n\n            <a class="btn" title="Edit Specimen" rel="edit"\n               href="');
          __out.push(__sanitize(specimen.links.edit));
          __out.push('">\n                <i class="icon-edit"></i> \n            </a>\n        </td>\n    </tr>\n    ');
        }
      
        __out.push('\n</table>\n');
      
        __out.push(this.pagination);
      
        __out.push('\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  };
}).call(this);
