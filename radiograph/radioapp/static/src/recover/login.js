(function() {
  this.ecoTemplates || (this.ecoTemplates = {});
  this.ecoTemplates["login"] = function(__obj) {
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
      
        __out.push('<form action="');
      
        __out.push(__sanitize(this.links.login));
      
        __out.push('" method="post" class="login-form modal">\n\n    <div class="modal-header">\n        <h3>Radiograph Database - Sign In</h3>\n    </div>\n\n    <div class="modal-body form form-horizontal">\n        <div class="alert alert-error" style="display: none;"></div>\n\n        <div class="control-group">\n            <label class="control-label" for="username">Username:</label>\n            <div class="controls">\n                <input type="text" name="username" value="');
      
        __out.push(__sanitize(this.username));
      
        __out.push('"/>\n            </div>\n        </div>\n        <div class="control-group">\n            <label class="control-label" for="password">Password:</label>\n            <div class="controls">\n                <input type="password" name="password" value="');
      
        __out.push(__sanitize(this.password));
      
        __out.push('"/>\n            </div>\n        </div>\n    </div>\n\n    <div class="modal-footer form-actions">\n        <button type="submit" class="btn btn-primary">Sign In</button>\n        <a href="#" class="btn discard">Nevermind</a>\n    </div>\n\n</form>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  };
}).call(this);
