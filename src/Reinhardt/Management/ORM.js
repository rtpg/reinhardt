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

//foreign import syncModel :: forall dbShape e. dbShape -> String -> Eff e Unit
exports.syncModel = function(dbShape){
  return function(tableName){
    // not sure why I gotta do this, might totally be wrong
    return function(){
      dbShape = dbShape.value0;
      console.log("Defining " + tableName);

      var sequelizeObj = {}
      for(var key in dbShape){
        sequelizeObj[key] = transformShape(dbShape[key]);
      }
      sequelize.define(tableName, sequelizeObj).sync();
    };
  };
};
