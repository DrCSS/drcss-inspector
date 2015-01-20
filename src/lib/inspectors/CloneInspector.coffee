Lazy = require('lazy.js')

module.exports =
  getPropertyValueCounts: (page) ->
    Lazy(page.declarations)
      .groupBy('property')
      .map (decls, property) ->
        valueCount = Lazy(decls).pluck('value').uniq().size()
        { property: property, valueCount: valueCount }
      .toArray()