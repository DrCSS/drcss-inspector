url = require('url')
fs = require('fs')
request = require('request')
Lazy = require('lazy.js')
async = require('async')
{css} = require('parserlib')

module.exports =
  
  # Array ライクなオブジェクトを Array オブジェクトでラッピングして返します。
  #
  # @param [object] arrayLikeObject - Array ライクなオブジェクト
  #
  wrapArray: (arrayLikeObject) ->
    Array.prototype.slice.call(arrayLikeObject)


  # ファイルをダウンロードしてデータを返します。
  # fileUrl が '' 文字の場合、ページ URL で指定したページがダウンロードされます。
  # 
  # @param [string] baseUrl - 呼び出し元の URL
  # @param [string] fileUrl - 取得するファイル URL
  # @param [function] cb - コールバック関数
  #
  # @example
  #   # styles/style.css: 
  #   #   * { margin: 0; padding: 0 }
  # 
  #   fetch './test/files/index.html', 'styles/style.css', (err, data) ->
  #     data === "* { margin: 0; padding: 0 }" // => true
  #
  fetch: (baseUrl, fileUrl, cb) ->
    fetchUrl = url.resolve(baseUrl, fileUrl)

    fs.readFile fetchUrl, (err, data) ->
      if (err)
        request fetchUrl, (err, res, html) ->
          return cb(err) if (err)

          cb(null, html)
      else
        html = data.toString()
        cb(null, html)


  # 与えられた CSS コードを解析し、記述されている宣言を取り出します。
  #
  # @param [string] src - CSS コード
  # @param [function] cb - コールバック関数
  #
  parseCss: (src, options, cb) ->
    curlyRules = [
      'fontface'
      'keyframes'
      'media'
      'page'
      'pagemargin'
      'rule'
    ]

    parser = new css.Parser()
    ruleStack = []
    importRules = []
    declarations = []
    index = 0
    options = Lazy(options).defaults(baseUrl: '', href: '').toObject()
    cssUrl = url.resolve(options.baseUrl, options.href)

    # rules with curly brackets
    curlyRules.forEach (name) =>
      parser.addListener "start#{name}", (e) ->
        e.index = index++
        ruleStack.push(e)

      parser.addListener "end#{name}", (e) ->
        ruleStack.pop()

    # import rule
    parser.addListener 'import', (e) =>
      e.index = index++
      importRules.push(e)

    # property
    parser.addListener 'property', (e) ->
      propData = {}
      currentRule = ruleStack[ruleStack.length - 1]

      if currentRule
        propData.ruleStack = ruleStack.concat() # make clone
        propData.selectors =
          Lazy(currentRule.selectors)
            .pluck('parts')
            .map (s) ->
              Lazy(s)
                .pluck('text')
                .join(' ')
            .toArray()

      propData.property = e.property.text
      propData.value = e.value.text
      propData.line = e.property.line
      propData.col = e.property.col
      propData.href = options.href
      propData.baseUrl = cssUrl
      propData.text = "#{e.property}:#{e.value}"

      declarations.push(propData)

    # end of stylesheet
    parser.addListener 'endstylesheet', (e) =>
      
      resolveImport = (importRule, cb) =>
        @fetch cssUrl, importRule.uri, (err, css) =>
          importOptions = Lazy(options).merge(href: importRule.uri, baseUrl: cssUrl).toObject()

          @parseCss css, importOptions, (err, result) ->
            decls = 
              Lazy(result)
                .each (d) -> d.ruleStack.unshift(importRule)

            cb(err, result)

      # resolve @import
      async.map importRules, resolveImport, (err, results) ->
        importedDecls = Lazy(results).flatten()

        decls =
          Lazy(declarations)
            .concat(importedDecls)
            .sort (a, b) -> a.ruleStack[0].index - b.ruleStack[0].index # sort declarations by rule position

        cb(null, decls.toArray())

    parser.parse(src)
