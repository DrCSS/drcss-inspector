fs = require('fs')
expect = require('chai').expect
cheerio = require('cheerio')
request = require('request')
util = require('../lib/util')

describe 'util', ->
  describe '.fetch', ->
    @timeout(5000)

    it 'util.fetch("./test/files/page1/index.html", "")', (next) ->
      fs.readFile './test/files/page1/index.html', (err, data) -> 
        return next(err) if err
        actual = data.toString()

        util.fetch './test/files/page1/index.html', '', (err, html) ->
          return next(err) if err

          expect(html).to.equal(actual)
          next()


    it 'util.fetch("http://example.com/", "")', (next) ->
      request 'http://example.com/', (err, res, body) -> 
        return next(err) if err
        actual = body

        util.fetch 'http://example.com/', '',  (err, html) ->
          return next(err) if err

          expect(html).to.equal(actual)
          next()


  describe '.parseCss', ->

    it 'util.parseCss(".a { margin: 10px; padding: 5px } .nav { margin: 10px }"', (next) ->
      util.parseCss ".a { margin: 10px; padding: 5px } .nav { margin: 10px }", {}, (err, decls) ->
        return next(err) if err

        expect(decls[0].property).to.equal('margin')
        expect(decls[0].value).to.equal('10px')

        next()
