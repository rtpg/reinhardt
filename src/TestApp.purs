module TestApp where

import Control.Monad.Eff.Console as Console
import App.Models (User(User), userM)
import App.Config as Config
import Control.Alternative (pure)
import Control.Monad.Aff (launchAff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Exception (EXCEPTION)
import Data.Traversable (traverse)
import Data.Unit (Unit, unit)
import Prelude (($), bind)
import Reinhardt.Database.Query (findAll)
import Reinhardt.Database.Setup (loadModels)

example :: forall e. Eff (console :: Console.CONSOLE, err :: EXCEPTION | e) Unit
example = do
  loadModels Config.models
  launchAff (
    do
       users <- findAll userM []
       traverse
        (\(User u) -> liftEff $ Console.log u.username)
        users
  )
  pure unit
