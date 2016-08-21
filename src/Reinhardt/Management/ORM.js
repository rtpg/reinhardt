"use strict";

var Sequelize = require('sequelize');
var sequelize = new Sequelize('test_db', 'reinhardt', '', {
  host: 'localhost',
  dialect: 'sqlite',
  storage: 'test.db',
  define:{
    // prevent pluralisation
    freezeTableName: true
  }
})
// module Reinhardt.Management.ORM

// would enjoy being able to write this in purescript
var transformShape = function(field){
  var sType = field.value0.value0.sequelizeType;
  return Sequelize[sType];
};

//foreign import syncModel :: SequelizeShape -> String -> Eff e Unit
exports.syncModel = function(shape){
  return function(tableName){
    return function(){
      sequelize.define(tableName, shape).sync();
    };
  };
};
