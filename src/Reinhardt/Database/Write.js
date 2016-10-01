"use strict";

// module Reinhardt.Database.Write

var q = require('../Reinhardt.Database.Query');


function unwrapData(data){
  var returnValue = {};
  for (var key in data.value0){
    returnValue[key] = data.value0[key].value0;
  }
  return returnValue;
}
exports.rawInsertObject = function(tableName){
  return function(data){
    return function(callback){
      var unwrapped = unwrapData(data);
      return function(){
        var model = q.modelCache[tableName];
        model.create(unwrapped).then(function(){
          callback()();
        });
      }
    }
  }
};
