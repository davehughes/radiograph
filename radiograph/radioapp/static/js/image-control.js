(function() {
  this.ecoTemplates || (this.ecoTemplates = {});
  this.ecoTemplates["image-control"] = function(__obj) {
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
        var option, _i, _len, _ref;
      
        __out.push('<div>\n    ');
      
        if (this.image.id) {
          __out.push('\n        <input type=\'hidden\' value=\'');
          __out.push(__sanitize(this.image.id));
          __out.push('\' ');
          __out.push(__sanitize(this.tagAs('id')));
          __out.push('/>\n    ');
        }
      
        __out.push('\n    <select class=\'span2\' ');
      
        __out.push(__sanitize(this.tagAs('aspect')));
      
        __out.push('>\n        ');
      
        _ref = this.aspectOptions();
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          option = _ref[_i];
          __out.push('\n            <option value=\'');
          __out.push(__sanitize(option.value));
          __out.push('\' ');
          if (option.selected) __out.push('selected=\'selected\'');
          __out.push('>\n                ');
          __out.push(__sanitize(option.label));
          __out.push('\n            </option>\n        ');
        }
      
        __out.push('\n    </select>\n\n    ');
      
        if (this.image.currentFile) {
          __out.push('\n        ');
          if (!this.image.replacementFile) {
            __out.push('\n            <span class="dropdown">\n                <span class="dropdown-toggle" data-toggle="dropdown">\n                    Existing file: \n                    <a href=\'');
            __out.push(__sanitize(this.image.currentFile.url));
            __out.push('\' class="download-file">\n                        ');
            __out.push(__sanitize(this.image.currentFile.name));
            __out.push('\n                    </a>\n                    <span class="caret">&nbsp;</span>\n                </span>\n                <ul class="dropdown-menu">\n                    <li>\n                        <a href=\'');
            __out.push(__sanitize(this.image.currentFile.url));
            __out.push('\' class="download-file">\n                            <i class="icon-download"></i>\n                            Download Existing File\n                        </a>\n                    </li>\n                    <li>\n                        <a href="javascript:void(0)" class="replace-file fileinput-button">\n                            <i class="icon-random"></i>\n                            Replace File\n                            <input type=\'file\' ');
            __out.push(__sanitize(this.tagAs('image_full')));
            __out.push('/>\n                        </a>\n                    </li>\n                </ul>\n            </span>\n        ');
          } else {
            __out.push('\n            <span class="dropdown">\n                <span class="dropdown-toggle" data-toggle="dropdown">\n                    Replace\n                    <a href=\'');
            __out.push(__sanitize(this.image.currentFile.url));
            __out.push('\' class="download-file">\n                        ');
            __out.push(__sanitize(this.image.currentFile.name));
            __out.push('\n                    </a>\n                    with\n                    <a class=\'fileinput-button\' style="display:inline-block">\n                        ');
            __out.push(__sanitize(this.image.replacementFile.name));
            __out.push('\n                        <input type=\'file\' ');
            __out.push(__sanitize(this.tagAs('image_full')));
            __out.push('/>\n                    </a>\n                    <span class="caret">&nbsp;</span>\n                </span>\n                <ul class="dropdown-menu"> \n                    <li>\n                        <a href=\'');
            __out.push(__sanitize(this.image.currentFile.url));
            __out.push('\' class="download-file">\n                            <i class="icon-download"></i>\n                            Download Existing File\n                        </a>\n                    </li>\n                    <li>\n                        <a href="javascript:void(0)" class="replace-file fileinput-button">\n                            <i class="icon-random"></i>\n                            Replace File\n                            <input type=\'file\' ');
            __out.push(__sanitize(this.tagAs('image_full')));
            __out.push('/>\n                        </a>\n                    </li>\n                    <li>\n                        <a href="javascript:void(0)" class="cancel-replace">\n                            <i class="icon-remove"></i>\n                            Cancel Replacement\n                        </a>\n                    </li>\n                </ul>\n            </span>\n        ');
          }
          __out.push('\n    ');
        } else {
          __out.push('\n        ');
          if (this.image.replacementFile) {
            __out.push('\n            <span class="dropdown">\n                <span class="dropdown-toggle" data-toggle="dropdown">\n                    Upload file:\n                    <a class=\'fileinput-button\' style="display:inline-block">\n                        ');
            __out.push(__sanitize(this.image.replacementFile.name));
            __out.push('\n                        <input type=\'file\' ');
            __out.push(__sanitize(this.tagAs('image_full')));
            __out.push('/>\n                    </a>\n                    <span class="caret">&nbsp;</span>\n                </span>\n                <ul class="dropdown-menu"> \n                    <li>\n                        <a href="javascript:void(0)" class="replace-file fileinput-button">\n                            <i class="icon-random"></i>\n                            Replace File\n                            <input type=\'file\' ');
            __out.push(__sanitize(this.tagAs('image_full')));
            __out.push('/>\n                        </a>\n                    </li>\n                </ul>\n            </span>\n        ');
          } else {
            __out.push('\n            <a class=\'fileinput-button\'>\n                Upload an Image\n                <i class=\'icon-upload\'></i>\n                <input type=\'file\'>\n            </a>\n        ');
          }
          __out.push('\n    ');
        }
      
        __out.push('\n\n    <a href="javascript:void(0)" class="btn btn-small remove-image">\n        <i class="icon-remove"></i>\n    </a>\n</div>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  };
}).call(this);
