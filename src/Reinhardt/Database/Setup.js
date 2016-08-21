// module Reinhardt.Database.Setup
var q = require('../Reinhardt.Database.Query');

var Sequelize = require('sequelize');
// duplicated in ORM...
var sequelize = new Sequelize('test_db', 'reinhardt', '', {
  host: 'localhost',
  dialect: 'sqlite',
  storage: 'test.db',
  define:{
    // prevent pluralisation
    freezeTableName: true,
    // no timestamps
    timestamps: false
  }
});

exports.loadModelIntoCache = function(shape){
  return function(tableName){
    return function(){
      console.log("Loading table " + tableName + " into cache");
      shape = shape.value0;

      q.modelCache[tableName] = sequelize.define(tableName, shape);
    }
  }
};
