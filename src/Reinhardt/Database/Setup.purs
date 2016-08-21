module Reinhardt.Database.Setup where

import Control.Monad.Eff (Eff)
import Data.Exists (runExists, Exists)
import Data.Traversable (traverse)
import Data.Unit (Unit)
import Reinhardt.Database (DbShape(DbShape), buildSequelizeDef)

import Prelude (($))

foreign import loadModelIntoCache :: forall a e. a -> String -> Eff e Unit
-- this should be in Aff
loadModels :: forall e. Array (Exists DbShape) -> Eff e (Array Unit)
loadModels = traverse $
runExists $ \(DbShape d) ->
 loadModelIntoCache (buildSequelizeDef d.structure) d.tableName
