module Reinhardt.Foreign where

-- a structure we use for building Javascript values
-- this is passed to our foreign usage of things like Sequelize
-- no support for objects right now though
data JSValue = JSNumber Int
| JSString String
| JSArray (Array JSValue)
| JSNull
| JSUndefined
