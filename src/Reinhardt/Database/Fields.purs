module Reinhardt.Database.Fields where
import Reinhardt.Foreign (JSValue(JSString))

data FieldDefinition psType = FieldDefinition {
  toDBValue :: psType -> JSValue, -- unfortunately existential types aren't supported yet
  fromDBValue :: JSValue -> psType, -- but when they do, we'll unify the return of toDBValue
  -- and the input of fromDBValue
  columnName :: String
}

data SearchParam psType = SearchParam

data DBField psType = RawValue psType
                    | Field (FieldDefinition psType)
                    | Search (SearchParam psType)

stringToDB :: String -> JSValue
stringToDB elt = JSString elt

stringFromDB :: JSValue -> String
stringFromDB (JSString elt) = elt


stringField :: String -> FieldDefinition String
stringField dbName = FieldDefinition {
  toDBValue : stringToDB,
  fromDBValue : stringFromDB,
  columnName : dbName
}
