module Reinhardt.Management.ORM where

import App.Config (models)
import Control.Monad.Eff (Eff)
import Data.Exists (runExists, Exists)

import Data.Traversable (traverse)
import Prelude (Unit, bind, pure, unit)
import Reinhardt.Database (DbShape(DbShape))


-- checks and syncs models, requires table name and shape
foreign import syncModel :: forall dbShape e. dbShape -> String -> Eff e Unit

unwrapAndSync :: forall e. Exists DbShape -> Eff e Unit
unwrapAndSync = runExists (\(DbShape d)-> syncModel d.structure (d.tableName))

syncModels :: forall e. Array (Exists DbShape) -> Eff e (Array Unit)
syncModels shapes = traverse unwrapAndSync shapes

syncModelsCommand :: forall e. Eff e Unit
syncModelsCommand = do
  syncModels models
  pure unit
