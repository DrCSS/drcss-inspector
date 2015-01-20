expect = require('chai').expect
Page = require('../lib/Page')
CloneInspector = require('../lib/inspectors/CloneInspector')

describe 'CloneInspector', ->
  describe '.getPropertyValueCount', ->

    describe 'page1/index.html', ->
      before (cb) ->
        @pageUrl = './test/files/page1/index.html'
        @page = new Page()
        @page.load @pageUrl, (err) =>
          return cb(err) if err
          cb()


      it 'contains 1 values for all properties', ->
        valueCounts = CloneInspector.getPropertyValueCounts(@page)

        expect(valueCounts).to.deep.equal([
          { property: 'margin', valueCount: 1 }
          { property: 'padding', valueCount: 1 }
          { property: 'color', valueCount: 1 }
          { property: 'text-decoration', valueCount: 1 }
          { property: 'margin-top', valueCount: 1 }
        ])


    describe 'page2/index.html', ->

      before (cb) ->
        @pageUrl = './test/files/page2/index.html'
        @page = new Page()
        @page.load @pageUrl, (err) =>
          return cb(err) if err
          cb()

      it 'contains 2 values for margin property', ->
        valueCounts = CloneInspector.getPropertyValueCounts(@page)

        expect(valueCounts).to.include(property: 'margin', valueCount: 2)