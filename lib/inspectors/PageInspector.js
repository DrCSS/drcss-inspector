(function() {
  var Lazy, PageInspector, async, cheerio, fs, request, url, util;

  url = require('url');

  cheerio = require('cheerio');

  Lazy = require('lazy.js');

  request = require('request');

  fs = require('fs');

  async = require('async');

  util = require('../util');

  module.exports = PageInspector = (function() {
    function PageInspector() {}

    PageInspector.prototype._fetchAllCss = function(url, $, cb) {
      var cssElements, fetchCss, styleSheets;
      fetchCss = (function(_this) {
        return function(eleWrapper, cb) {
          var ele, href;
          ele = eleWrapper.element;
          if (ele.name === 'link') {
            href = ele.attribs.href;
            return util.fetch(url, href, function(err, css) {
              if (err) {
                return cb(err);
              }
              eleWrapper.css = css;
              eleWrapper.href = href;
              return cb(null, eleWrapper);
            });
          } else {
            eleWrapper.css = $(ele).text();
            return cb(null, eleWrapper);
          }
        };
      })(this);
      cssElements = $('link[rel=stylesheet], style');
      styleSheets = cssElements.map(function(i, ele) {
        return {
          index: i,
          element: ele
        };
      });
      return async.map(util.wrapArray(styleSheets), fetchCss, function(err, results) {
        if (err) {
          return cb(err);
        }
        return cb(null, results);
      });
    };

    PageInspector.prototype.inspect = function(url, cb) {
      var result;
      result = {};
      return async.waterfall([
        (function(_this) {
          return function(cb) {
            return util.fetch(url, '', function(err, html) {
              var $;
              if (err) {
                return cb(err);
              }
              result.html = html;
              $ = cheerio.load(html);
              return cb(null, $);
            });
          };
        })(this), (function(_this) {
          return function($, cb) {
            return _this._fetchAllCss(url, $, function(err, cssCodes) {
              if (err) {
                return cb(err);
              }
              result.cssCodes = cssCodes;
              return cb(null);
            });
          };
        })(this), (function(_this) {
          return function(cb) {
            var parse;
            parse = function(code, cb) {
              return util.parseCss(code.css, {
                baseUrl: url,
                href: code.href
              }, cb);
            };
            return async.map(result.cssCodes, parse, function(err, delcs) {
              if (err) {
                return cb(err);
              }
              result.declarations = Lazy(delcs).flatten().toArray();
              return cb(null);
            });
          };
        })(this)
      ], function(err) {
        return cb(err, result);
      });
    };

    return PageInspector;

  })();

}).call(this);
