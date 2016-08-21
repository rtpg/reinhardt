module Reinhardt.Database where

import Control.Monad.Eff (Eff)
import Data.Array (length, head)
import Data.Either (Either(Left, Right))
import Data.Exists (runExists, Exists, mkExists)
import Data.Maybe (Maybe(Just, Nothing))
import Prelude (bind, (>), pure, ($))

-- Reinhard DB effect types
foreign import data RDB :: !

-- foreign functions
foreign import commitObject :: forall obj shape e. (Model obj shape) => obj -> Eff ( rWriteDB :: RDB | e) (Maybe obj)
foreign import lookupObjects :: forall obj shape e. (Model obj shape) => shape -> Eff (rReadDB :: RDB | e) (Array obj)

-- helper for Model declarations
foreign import sentinelObj :: forall a. a

-- the following foreign import allows us to "cast" a javascript
-- dictionarly into a single-argument type
-- for example, castDictInto UserM {a: 1, b:2} = UserM {a: 1, b:2}
foreign import castDictInto :: forall d m a. (d -> m) -> a -> m

-- writer lets you take an object and write the DB with it
data DBWriter a = DBWriter

data DBError = DBError


foreign import data SequelizeDef :: *
-- the following will get a special SequelizeDef object
foreign import buildSequelizeDef :: forall dbShape. dbShape -> SequelizeDef


-- wrapper for table builder
data DBCons m d = DBCons (d -> m)
mkShape :: forall a b. (a -> b) -> Exists (DBCons b)
mkShape f = mkExists (DBCons f)

class DBTable dbShape where
  tableName :: dbShape -> String
  tableShape :: Exists (DBCons dbShape)

castToShape :: forall x dbShape. (DBTable dbShape) => x -> dbShape
castToShape = (runExists \(DBCons f) -> castDictInto f) (tableShape::Exists (DBCons dbShape))

class (DBTable dbShape) <= Model userObj dbShape where
  dbStructure :: dbShape
  -- TODO: figure out of tagging can make the table name not depend on anything
  -- see http://stackoverflow.com/questions/23983374/how-to-handle-functions-of-a-multi-parameter-typeclass-who-not-need-every-type
  fromDB :: (Partial) => dbShape -> userObj
  toDB :: userObj -> dbShape

data DbShape dbShape = DbShape {
  tableName :: String,
  structure :: dbShape
}
-- TODO add verification here through a functional dependency
-- this ensures that a Model instance exsts, even if its not needed
model :: forall dbShape. (DBTable dbShape) => dbShape -> Exists (DbShape)
model shape = mkExists (DbShape {
  tableName : tableName shape,
  structure : shape
})


lookupObject :: forall obj shape e. (Model obj shape) => shape -> Eff (rReadDB :: RDB | e) (Either DBError obj)
lookupObject searchParams = do
  objs <- lookupObjects searchParams
  if (length objs) > 1
    then pure (Left DBError)
    else pure $ case head objs of
        Nothing -> Left DBError
        Just obj -> Right obj
