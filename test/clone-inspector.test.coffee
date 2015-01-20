expect = require('chai').expect
Page = require('../lib/Page')
CloneInspector = require('../lib/inspectors/CloneInspector')

describe 'CloneInspector', ->
  describe '.getPropertyValueCount', ->
    
    before (cb) ->
      @pageUrl = './test/files/page1/index.html'
      @page = new Page()
      @page.load @pageUrl, (err) =>
        return cb(err) if err
        cb()

    it '1 values for all properties', ->
      valueCounts = CloneInspector.getPropertyValueCounts(@page)

      expect(valueCounts).to.deep.equal([
        { property: 'margin', valueCount: 1 }
        { property: 'padding', valueCount: 1 }
        { property: 'color', valueCount: 1 }
        { property: 'text-decoration', valueCount: 1 }
        { property: 'margin-top', valueCount: 1 }
      ])