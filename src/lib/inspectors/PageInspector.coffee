url = require('url')
cheerio = require('cheerio')
Lazy = require('lazy.js')
request = require('request')
fs = require('fs')
async = require('async')
util = require('../util')

# ページを調べるクラス
#
module.exports = class PageInspector

  # @private
  #
  # 指定されたページ中の link 要素と style 要素で指定された CSS ソースコードを取得します。
  #
  # @param [string] url - ページの URL
  # @param [cheerio] $ - cheerio オブジェクト
  # @param [function] cb - コールバック関数
  #
  _fetchAllCss: (url, $, cb) ->
    fetchCss = (eleWrapper, cb) =>
      ele = eleWrapper.element

      if ele.name == 'link'
        href = ele.attribs.href

        util.fetch url, href, (err, css) ->
          return cb(err) if (err)
          
          eleWrapper.css = css
          eleWrapper.href = href
          cb(null, eleWrapper)

      else
        eleWrapper.css = $(ele).text()
        cb(null, eleWrapper)

    cssElements = $('link[rel=stylesheet], style')

    styleSheets = 
      cssElements
        .map (i, ele) -> { index: i, element: ele }

    async.map util.wrapArray(styleSheets), fetchCss, (err, results) ->
      return cb(err) if (err)

      cb(null, results)


  # 指定されたページを調べます。
  #
  # @param [string] url - 読み込むページの URL
  # @param [function] cb - コールバック関数
  #
  # @example
  #
  #   pageUrl = './test/files/index.html'
  #   pageInspector = new PageInspector()
  #   pageInspector.inspect pageUrl, (err, inspectResult) ->
  #     return cb(err) if err
  #
  #     inspectResult.html
  #     inspectResult.cssCodes
  #     inspectResult.declarations
  #
  inspect: (url, cb) ->
    result = {}

    async.waterfall [
      (cb) =>
        util.fetch url, '', (err, html) =>
          return cb(err) if err

          result.html = html
          $ = cheerio.load(html)
          cb(null, $)

      ($, cb) =>
        @_fetchAllCss url, $, (err, cssCodes) =>
          return cb(err) if err

          result.cssCodes = cssCodes
          cb(null)

      (cb) =>
        parse = (code, cb) =>
          util.parseCss code.css, baseUrl: url, href: code.href, cb

        async.map result.cssCodes, parse, (err, delcs) =>
          return cb(err) if (err)

          result.declarations = Lazy(delcs).flatten().toArray()
          cb(null)

    ], (err) ->
      cb(err, result)
