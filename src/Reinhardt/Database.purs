module Reinhardt.Database where

import Reinhardt.Foreign (JSValue)


-- reader lets you take a DB object and populate your user object
data DBReader a = DBReader a

-- writer lets you take an object and write the DB with it
data DBWriter a = DBWriter a

data DBField psType = RawValue psType
                    | Field (FieldDefinition psType)
data FieldDefinition psType = FieldDefinition {
  toDBValue :: psType -> JSValue, -- unfortunately existential types aren't supported yet
  fromDBVaue :: JSValue -> psType -- but when they do, we'll unify the return of toDBValue
  -- and the input of fromDBValue
}


class Model userObj dbShape where
  dbStructure :: dbShape
  fromDB :: DBReader userObj
  toDB :: userObj -> DBWriter dbShape
