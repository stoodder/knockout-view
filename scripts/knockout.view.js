(function() {
  var endsWith, isArray, isFunction, isObject, isString, leftTrim, rightTrim, startsWith, trim, unwrap;

  isObject = function(object) {
    return typeof object === typeof {};
  };

  isFunction = function(object) {
    return Object.prototype.toString.call(object) === "[object Function]";
  };

  isArray = function(object) {
    return Object.prototype.toString.call(object) === "[object Array]";
  };

  isString = function(object) {
    return Object.prototype.toString.call(object) === "[object String]";
  };

  trim = function(str) {
    return str.replace(/^\s\s*/, '').replace(/\s\s*$/, '');
  };

  leftTrim = function(str) {
    return str.replace(/^\s+/, '');
  };

  rightTrim = function(str) {
    return str.replace(/\s+$/, '');
  };

  startsWith = function(haystack, needle) {
    return haystack.indexOf(needle) === 0;
  };

  endsWith = function(haystack, needle) {
    return haystack.indexOf(needle, haystack.length - needle.length) !== -1;
  };

  unwrap = function(val) {
    if (isFunction(val)) {
      return val();
    } else {
      return val;
    }
  };

  ko.bindingHandlers["view"] = (function() {
    var makeTemplateValueAccessor, templates;
    templates = {};
    makeTemplateValueAccessor = function(valueAccessor) {
      return function() {
        var value;
        value = unwrap(valueAccessor);
        return {
          'if': value,
          'data': value,
          'templateEngine': ko.nativeTemplateEngine.instance
        };
      };
    };
    return {
      'init': function(element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) {
        var value;
        value = unwrap(valueAccessor);
        if (!isObject(value)) value = {};
        if (value.template == null) value.template = null;
        if (value.viewModel == null) value.viewModel = null;
        return ko.bindingHandlers['template']['init'](element, makeTemplateValueAccessor(value.viewModel));
      },
      'update': function(element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) {
        var template, value;
        value = unwrap(valueAccessor);
        if (!isObject(value)) value = {};
        if (value.template == null) value.template = null;
        if (value.viewModel == null) value.viewModel = null;
        if (value.template === null) return;
        if (value.viewModel === null) return;
        template = unwrap(value.template);
        if (!(template != null)) {
          return $(element).html("");
        } else {
          if (templates[template] != null) {
            ko.utils.domData.set(element, '__ko_anon_template__', templates[template]);
            return ko.bindingHandlers['template']['update'](element, makeTemplateValueAccessor(value.viewModel), allBindingsAccessor, viewModel, bindingContext);
          } else if (startsWith(template, '#')) {
            templates[template] = $(template).html();
            ko.utils.domData.set(element, '__ko_anon_template__', templates[template]);
            return ko.bindingHandlers['template']['update'](element, makeTemplateValueAccessor(value.viewModel), allBindingsAccessor, viewModel, bindingContext);
          } else {
            return $.get(template, function(data) {
              templates[template] = data;
              ko.utils.domData.set(element, '__ko_anon_template__', templates[template]);
              return ko.bindingHandlers['template']['update'](element, makeTemplateValueAccessor(value.viewModel), allBindingsAccessor, viewModel, bindingContext);
            });
          }
        }
      }
    };
  })();

}).call(this);
