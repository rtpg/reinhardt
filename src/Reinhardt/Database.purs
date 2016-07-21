module Reinhardt.Database where

import Prelude (bind, (>), pure, ($))

import Control.Monad.Eff (Eff)
import Data.Array (length, head)
import Data.Maybe (Maybe(Just, Nothing))
import Data.Either (Either(Left, Right))
import Data.Exists (Exists, mkExists)

import Reinhardt.Foreign (JSValue)
import Reinhardt.Database.Reader (DBReader)
import Reinhardt.Database.Fields (DBField)
-- Reinhard DB effect types
foreign import data RDB :: !

-- foreign functions
foreign import commitObject :: forall obj shape e. (Model obj shape) => obj -> Eff ( rWriteDB :: RDB | e) (Maybe obj)
foreign import lookupObjects :: forall obj shape e. (Model obj shape) => shape -> Eff (rReadDB :: RDB | e) (Array obj)

data DBRow = DBRow

-- writer lets you take an object and write the DB with it
data DBWriter a = DBWriter

data DBError = DBError

class Model userObj dbShape where
  dbStructure :: dbShape
  fromDB :: DBReader userObj
  toDB :: userObj -> DBWriter dbShape

data DbShape dbShape = DbShape dbShape
-- TODO add verification here through a functional dependency
model :: forall dbShape. dbShape -> Exists (DbShape)
model shape = mkExists (DbShape shape)


lookupObject :: forall obj shape e. (Model obj shape) => shape -> Eff (rReadDB :: RDB | e) (Either DBError obj)
lookupObject searchParams = do
  objs <- lookupObjects searchParams
  if (length objs) > 1
    then pure (Left DBError)
    else pure $ case head objs of
        Nothing -> Left DBError
        Just obj -> Right obj
