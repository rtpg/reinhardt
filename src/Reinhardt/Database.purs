module Reinhardt.Database where

import Prelude (bind, (>), pure, ($))

import Control.Monad.Eff (Eff)
import Data.Array (length, head)
import Data.Maybe (Maybe(Just, Nothing))
import Data.Either (Either(Left, Right))

import Reinhardt.Foreign (JSValue)
-- Reinhard DB effect types
foreign import data RDB :: !

-- foreign functions
foreign import commitObject :: forall obj shape e. (Model obj shape) => obj -> Eff ( rWriteDB :: RDB | e) (Maybe obj)
foreign import lookupObjects :: forall obj shape e. (Model obj shape) => shape -> Eff (rReadDB :: RDB | e) (Array obj)

-- reader lets you take a DB object and populate your user object
data DBReader a = DBReader

-- writer lets you take an object and write the DB with it
data DBWriter a = DBWriter

data DBField psType = RawValue psType
                    | Field (FieldDefinition psType)
                    | Search (SearchParam psType)

data SearchParam psType = SearchParam

data FieldDefinition psType = FieldDefinition {
  toDBValue :: psType -> JSValue, -- unfortunately existential types aren't supported yet
  fromDBValue :: JSValue -> psType -- but when they do, we'll unify the return of toDBValue
  -- and the input of fromDBValue
}

data DBError = DBError

class Model userObj dbShape where
  dbStructure :: dbShape
  fromDB :: DBReader userObj
  toDB :: userObj -> DBWriter dbShape



lookupObject :: forall obj shape e. (Model obj shape) => shape -> Eff (rReadDB :: RDB | e) (Either DBError obj)
lookupObject searchParams = do
  objs <- lookupObjects searchParams
  if (length objs) > 1
    then pure (Left DBError)
    else pure $ case head objs of
        Nothing -> Left DBError
        Just obj -> Right obj
