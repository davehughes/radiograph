(function() {
  this.ecoTemplates || (this.ecoTemplates = {});
  this.ecoTemplates["specimen-edit"] = function(__obj) {
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
        var choice, _i, _j, _k, _len, _len2, _len3, _ref, _ref2, _ref3;
      
        __out.push('<form class="form-horizontal specimen-form" method="post"\n    action="');
      
        __out.push(__sanitize(this.links.save));
      
        __out.push('"\n    enctype="multipart/form-data">\n    \n    <fieldset>\n    ');
      
        __out.push(__sanitize(this.csrf_token));
      
        __out.push('\n\n    ');
      
        __out.push('\n    <div class="control-group institution">\n        <label class="control-label" for="institution">Institution</label>\n        <div class="controls">\n            <select name="institution">\n            ');
      
        _ref = this.institutionChoices;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          choice = _ref[_i];
          __out.push('\n                <option value="');
          __out.push(__sanitize(choice.value));
          __out.push('">');
          __out.push(__sanitize(choice.label));
          __out.push('</option>\n            ');
        }
      
        __out.push('\n            </select>\n        </div>\n    </div>\n\n    ');
      
        __out.push('\n    <div class="control-group specimen-id">\n        <label class="control-label" for="specimen_id">Specimen ID</label>\n        <div class="controls">\n            <input type="text" name="specimen_id" value="');
      
        __out.push(__sanitize(this.specimen_id));
      
        __out.push('"/>\n        </div>\n    </div>\n\n    ');
      
        __out.push('\n    <div class="control-group taxon">\n        <label class="control-label" for="taxon">Taxon</label>\n        <div class="controls">\n            <select name="taxon">\n            ');
      
        _ref2 = this.taxonChoices;
        for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
          choice = _ref2[_j];
          __out.push('\n                <option value="');
          __out.push(__sanitize(choice.value));
          __out.push('">');
          __out.push(__sanitize(choice.label));
          __out.push('</option>\n            ');
        }
      
        __out.push('\n            </select>\n        </div>\n    </div>\n\n    ');
      
        __out.push('\n    <div class="control-group sex">\n        <label class="control-label" for="sex">Sex</label>\n        <div class="controls">\n            <select name="sex">\n            ');
      
        _ref3 = this.sexChoices;
        for (_k = 0, _len3 = _ref3.length; _k < _len3; _k++) {
          choice = _ref3[_k];
          __out.push('\n                <option value="');
          __out.push(__sanitize(choice.value));
          __out.push('">');
          __out.push(__sanitize(choice.label));
          __out.push('</option>\n            ');
        }
      
        __out.push('\n            </select>\n        </div>\n    </div>\n\n    ');
      
        __out.push('\n    <div class="control-group settings">\n        <label class="control-label" for="settings">Settings</label>\n        <div class="controls">\n            <input type="text" name="settings" value="');
      
        __out.push(__sanitize(this.settings));
      
        __out.push('"/>\n        </div>\n    </div>\n\n    ');
      
        __out.push('\n    <div class="control-group comments">\n        <label class="control-label" for="comments">Comments</label>\n        <div class="controls">\n            <textarea name="comments">');
      
        __out.push(__sanitize(this.comments));
      
        __out.push('</textarea>\n        </div>\n    </div>\n\n\n    ');
      
        __out.push('\n    <div class="control-group images">\n        <label class="control-label">Images</label>\n        <div class="controls form-inline image-controls">\n            <div class="image-controls"></div>\n        </div>\n    </div>\n\n    </fieldset>\n\n    <div class="form-actions">\n        <button type="submit" class="btn btn-primary" name="save">Save</button>\n        <button class="btn btn-primary" name="save-and-continue">Save and Enter Another</button>\n        <a class="btn" href="');
      
        __out.push(__sanitize(this.links.discard));
      
        __out.push('">Discard</a>\n    </div>\n\n</form>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  };
}).call(this);
