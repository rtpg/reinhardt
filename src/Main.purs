module Main where

import Control.Monad.Eff.Console as Console
import Node.Process as Process
import App.Models (User(User))
import Control.Alternative (pure)
import Control.Monad.Aff (launchAff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Exception (EXCEPTION)
import Data.Array (slice, length, (!!))
import Data.Maybe (Maybe(Nothing, Just))
import Data.Traversable (traverse)
import Data.Unit (unit)
import Prelude (bind, (==), Unit, otherwise, ($))
import Reinhardt.Management.ORM (syncModelsCommand)
import TestApp (runFindAll)

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
  Console.log "Hi guys"
  traverse Console.log (slice 2 (length args) args)
  case (args !! 2) of
    Nothing -> do
        Console.log "Running example..."
        launchAff (
          do
            users <- runFindAll
            liftEff (Console.log "Ran findAll!")
            traverse (\(User elt) -> liftEff $ Console.log elt.username) (users)
        )
        pure unit
    Just arg -> case arg of
      x | arg == "syncdb" -> syncModelsCommand
        | otherwise -> Console.log "Unknown argument"
