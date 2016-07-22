module Reinhardt.Management.ORM where

import Prelude (Unit)

import Control.Monad.Eff (Eff)
import Data.Exists (runExists)
import Data.Traversable (traverse)


-- this basically
foreign import syncModel :: forall dbShape e. dbShape -> Eff e Unit

syncModels shapes = traverse (runExists syncModel) shapes
