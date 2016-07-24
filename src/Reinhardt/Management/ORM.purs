module Reinhardt.Management.ORM where

import Control.Monad.Eff (Eff)
import Data.Exists (runExists)
import Data.Traversable (traverse)
import Prelude (Unit)
import Reinhardt.Database (DbShape(DbShape), tableName)


-- checks and syncs models, requires table name and shape
foreign import syncModel :: forall dbShape e. dbShape -> String -> Eff e Unit

unwrapAndSync = runExists (\(DbShape d)-> syncModel d.structure (d.tableName))

syncModels shapes = traverse unwrapAndSync shapes
