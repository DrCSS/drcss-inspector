(function() {
  var Lazy, Page, async, cheerio, fs, request, url, util;

  url = require('url');

  cheerio = require('cheerio');

  Lazy = require('lazy.js');

  request = require('request');

  fs = require('fs');

  async = require('async');

  util = require('./util');

  module.exports = Page = (function() {
    function Page() {}

    Page.prototype._fetchAllCss = function(url, $, cb) {
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

    Page.prototype.load = function(url, cb) {
      return async.waterfall([
        (function(_this) {
          return function(cb) {
            return util.fetch(url, '', function(err, html) {
              if (err) {
                return cb(err);
              }
              _this.html = html;
              _this.$ = cheerio.load(html);
              return cb(null, _this.$);
            });
          };
        })(this), (function(_this) {
          return function($, cb) {
            return _this._fetchAllCss(url, $, function(err, cssCodes) {
              if (err) {
                return cb(err);
              }
              _this.cssCodes = cssCodes;
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
            return async.map(_this.cssCodes, parse, function(err, delcs) {
              if (err) {
                return cb(err);
              }
              _this.declarations = Lazy(delcs).flatten().toArray();
              return cb(null);
            });
          };
        })(this)
      ], function(err) {
        return cb(err);
      });
    };

    return Page;

  })();

}).call(this);
