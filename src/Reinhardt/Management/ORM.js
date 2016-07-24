"use strict";

var Sequelize = require('sequelize');
var sequelize = new Sequelize('test_db', 'reinhardt', '', {
  host: 'localhost',
  dialect: 'sqlite',
  storage: 'test.db'
})
// module Reinhardt.Management.ORM

//foreign import syncModel :: forall dbShape e. dbShape -> String -> Eff e Unit
exports.syncModel = function(dbShape){
  return function(tableName){
    console.log("Defining " + tableName);
    for(key in dbShape){
      console.log(key);
      console.log(dbShape);
    }
  }
};
