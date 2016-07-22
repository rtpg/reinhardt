module Reinhardt.Database.Fields where
import Partial.Unsafe (unsafePartial)
import Reinhardt.Foreign (JSValue(JSString))

data FieldDefinition psType = FieldDefinition {
  toDBValue :: psType -> JSValue, -- unfortunately existential types aren't supported yet
  -- here, the partial is to deal with the fact that only a specific
  -- JSValue will be used
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

safeStringFromDB (JSString elt) = elt

stringFromDB :: JSValue -> String
stringFromDB = unsafePartial (safeStringFromDB)


stringField :: String -> FieldDefinition String
stringField dbName = FieldDefinition {
  toDBValue : stringToDB,
  fromDBValue : stringFromDB,
  columnName : dbName
}
