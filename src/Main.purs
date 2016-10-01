module Main where

import Control.Monad.Eff.Console as Console
import Node.Process as Process
import App.Config (models)
import App.Models (userM, User(User))
import Control.Alternative (pure)
import Control.Monad.Aff (launchAff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Exception (EXCEPTION)
import Data.Array ((!!))
import Data.Maybe (Maybe(Nothing, Just))
import Data.Traversable (traverse)
import Data.Unit (unit)
import Prelude (bind, (==), Unit, otherwise, ($), (<>))
import Reinhardt.Database.Query (findAll)
import Reinhardt.Database.Setup (loadModels)
import Reinhardt.Database.Write (insertDB)
import Reinhardt.Management.ORM (syncModelsCommand)

foreign import ensureDbg :: forall e. Eff e Unit

main :: forall e. Eff
                 ( err :: EXCEPTION
                 , process :: Process.PROCESS
                 , console :: Console.CONSOLE
                 | e
                 )
                 Unit
main = do
  ensureDbg
  args <- Process.argv
  case (args !! 2) of
    Nothing -> do
        Console.log "Running example..."
        loadModels models
        launchAff (
          do
            let exampleUser = User { username: "test_user", email: "test@example.com" }
            let anotherUser = User { username: "another_user", email: "test2@example.com" }
            liftEff $ Console.log "Writing Users to DB..."
            insertDB exampleUser userM
            insertDB anotherUser userM
            liftEff $ Console.log "Reading Saved Users...."
            users <- findAll userM []
            traverse
              (\(User elt) -> do
                liftEff $ Console.log ("username: " <> elt.username)
                liftEff $ Console.log ("email: " <> elt.email))
              users
        )
        pure unit
    Just arg -> case arg of
      x | arg == "syncdb" -> syncModelsCommand
        | otherwise -> Console.log "Unknown argument"
