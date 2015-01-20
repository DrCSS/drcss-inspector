(function() {
  var Lazy;

  Lazy = require('lazy.js');

  module.exports = {
    getPropertyValueCounts: function(page) {
      return Lazy(page.declarations).groupBy('property').map(function(decls, property) {
        var valueCount;
        valueCount = Lazy(decls).pluck('value').uniq().size();
        return {
          property: property,
          valueCount: valueCount
        };
      }).toArray();
    }
  };

}).call(this);
