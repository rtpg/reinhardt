module Reinhardt.Database.Fields where

import Prelude (($))

import Reinhardt.Foreign (JSValue(JSString))

data FieldDefinition psType = FieldDefinition {
  toDBValue :: psType -> JSValue, -- unfortunately existential types aren't supported yet
  -- here, the partial is to deal with the fact that only a specific
  -- JSValue will be used
  fromDBValue :: (Partial) => JSValue -> psType, -- but when they do, we'll unify the return of toDBValue
  -- and the input of fromDBValue
  columnName :: String
}

data SearchParam psType = SearchParam

data DBField psType = RawValue psType
                    | Field (FieldDefinition psType)
                    | Search (SearchParam psType)

stringToDB :: String -> JSValue
stringToDB elt = JSString elt

stringFromDB :: (Partial) => JSValue -> String
stringFromDB (JSString elt) = elt

stringField :: String -> DBField String
stringField dbName = Field $ FieldDefinition {
  toDBValue : stringToDB,
  fromDBValue : stringFromDB,
  columnName : dbName
}
