fs = require('fs')
expect = require('chai').expect
cheerio = require('cheerio')
request = require('request')
PageInspector = require('../lib/inspectors/PageInspector')

describe 'PageInspector', ->
  describe '#inspect', ->
    
    before (cb) ->
      @pageUrl = './test/files/index.html'
      @pageInspector = new PageInspector()
      @pageInspector.inspect @pageUrl, (err, result) =>
        return cb(err) if err

        @result = result
        cb()


    it 'inspectResult.cssCodes', ->
      cssCodes = @result.cssCodes
      actualCss = "@import 'style/theme.css';"
      expect(cssCodes[0].css).to.deep.equal(actualCss)
      expect(cssCodes[0].index).to.equal(0)
      expect(cssCodes[1].css).to.deep.equal('/* inline style */')
      expect(cssCodes[1].index).to.equal(1)


    it 'inspectResult.declarations', ->
      decls = @result.declarations

      expect(decls[0].property).to.equal('margin')
      expect(decls[0].value).to.equal("0")
      expect(decls[0].href).to.equal('base.css')

      expect(decls[1].property).to.equal('padding')
      expect(decls[1].value).to.equal("0")
      expect(decls[1].href).to.equal('base.css')

      expect(decls[2].property).to.equal('color')
      expect(decls[2].value).to.equal("#f00")
      expect(decls[2].href).to.equal('style/theme.css')

      expect(decls[3].property).to.equal('text-decoration')
      expect(decls[3].value).to.equal("none")
      expect(decls[3].href).to.equal('style/theme.css')

      expect(decls[4].property).to.equal('margin-top')
      expect(decls[4].value).to.equal("16px")
      expect(decls[4].href).to.equal('style/theme.css')