"use strict";

// module Reinhardt.Database.Query

var tuple = require("../Data.Tuple");

// TODO generalise this
function lookupModel(name){
  return exports.modelCache[name];
}

// build the include list based off of the models
function buildIncludes(models){
  var includes = [];
  for(var i=1; i<models.length; i++){
    includes.push({
      model: lookupModel(models[i].name),
      foreignKey: lookupModel(models[i].source)
    });
  }
  return includes;
}

// let's tuple up our data! and unwrap things
function unwrapModel(data, models){
  // first step: get all the objects into a list
  // so that we have [model, join1, join2 , join3]
  var base = data;
  var joinedData = [data]; // first field in the list is the model
  for(var i=1; i<models.length;i++){
    // for each field used in the join
    // get the data, and place in joinedData
    var fieldName = models[i].source;
    joinedData.append(data[fieldName]);
    // TODO replace obj with foreign key
  }

  // second step: turn from list to Tuples
  // special case: length 1 just returns the model

  // this is a right fold?? Not sure
  // return something like
  /**      /\
   *      /\F4
   *     /\F3
   *    M1F2
   * From a list [M1, F2, F3, F4]
   */
  var returnValue = data;
  for(var i=i; i<models.length; i++){
    returnValue = tuple.Tuple(returnValue, models[i]);
  }
  return returnValue;
}

exports.modelCache = {};

exports.rawSequelizeFindAll = function(models){
  return function(params){
    return function(callback){
        return function(){
        var baseModel = lookupModel(models[0].name),
            includes = buildIncludes(models);
        baseModel.findAll({
          include: includes
        }).then(
          function(data){
            var tupledData = unwrapModel(data, models);
            callback(tupledData)();
          }
        );
      }
    }
  }
};
