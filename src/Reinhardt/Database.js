"use strict";

var Sequelize = require('sequelize');

// module Reinhardt.Database

exports.commitObject = function(e){

};

exports.lookupObjects = function(e){

};

exports.sentinelObj = function(e){

};

exports.castDictIntoModelObj = function(f){
    return function(x){
      return f(x);
    }
};
// would enjoy being able to write this in purescript
var transformShape = function(field){
  var sType = field.value0.value0.sequelizeType;
  return Sequelize[sType];
};

exports.buildSequelizeDef = function(obj){
  var dbShape = obj.value0;
  var sequelizeObj = {}
  for(var key in dbShape){
    sequelizeObj[key] = transformShape(dbShape[key]);
  }

  return obj;
};
