(function() {
  var Lazy, async, css, fs, request, url;

  url = require('url');

  fs = require('fs');

  request = require('request');

  Lazy = require('lazy.js');

  async = require('async');

  css = require('parserlib').css;

  module.exports = {
    wrapArray: function(arrayLikeObject) {
      return Array.prototype.slice.call(arrayLikeObject);
    },
    fetch: function(baseUrl, fileUrl, cb) {
      var fetchUrl;
      fetchUrl = url.resolve(baseUrl, fileUrl);
      return fs.readFile(fetchUrl, function(err, data) {
        var html;
        if (err) {
          return request(fetchUrl, function(err, res, html) {
            if (err) {
              return cb(err);
            }
            return cb(null, html);
          });
        } else {
          html = data.toString();
          return cb(null, html);
        }
      });
    },
    parseCss: function(src, options, cb) {
      var cssUrl, curlyRules, declarations, importRules, index, parser, ruleStack;
      curlyRules = ['fontface', 'keyframes', 'media', 'page', 'pagemargin', 'rule'];
      parser = new css.Parser();
      ruleStack = [];
      importRules = [];
      declarations = [];
      index = 0;
      options = Lazy(options).defaults({
        baseUrl: '',
        href: ''
      }).toObject();
      cssUrl = url.resolve(options.baseUrl, options.href);
      curlyRules.forEach((function(_this) {
        return function(name) {
          parser.addListener("start" + name, function(e) {
            e.index = index++;
            return ruleStack.push(e);
          });
          return parser.addListener("end" + name, function(e) {
            return ruleStack.pop();
          });
        };
      })(this));
      parser.addListener('import', (function(_this) {
        return function(e) {
          e.index = index++;
          return importRules.push(e);
        };
      })(this));
      parser.addListener('property', function(e) {
        var currentRule, propData;
        propData = {};
        currentRule = ruleStack[ruleStack.length - 1];
        if (currentRule) {
          propData.ruleStack = ruleStack.concat();
          propData.selectors = Lazy(currentRule.selectors).pluck('parts').map(function(s) {
            return Lazy(s).pluck('text').join(' ');
          }).toArray();
        }
        propData.property = e.property.text;
        propData.value = e.value.text;
        propData.line = e.property.line;
        propData.col = e.property.col;
        propData.href = options.href;
        propData.baseUrl = cssUrl;
        propData.text = "" + e.property + ":" + e.value;
        return declarations.push(propData);
      });
      parser.addListener('endstylesheet', (function(_this) {
        return function(e) {
          var resolveImport;
          resolveImport = function(importRule, cb) {
            return _this.fetch(cssUrl, importRule.uri, function(err, css) {
              var importOptions;
              importOptions = Lazy(options).merge({
                href: importRule.uri,
                baseUrl: cssUrl
              }).toObject();
              return _this.parseCss(css, importOptions, function(err, result) {
                var decls;
                decls = Lazy(result).each(function(d) {
                  return d.ruleStack.unshift(importRule);
                });
                return cb(err, result);
              });
            });
          };
          return async.map(importRules, resolveImport, function(err, results) {
            var decls, importedDecls;
            importedDecls = Lazy(results).flatten();
            decls = Lazy(declarations).concat(importedDecls).sort(function(a, b) {
              return a.ruleStack[0].index - b.ruleStack[0].index;
            });
            return cb(null, decls.toArray());
          });
        };
      })(this));
      return parser.parse(src);
    }
  };

}).call(this);
