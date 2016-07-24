module Main where

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console as Console

import Node.Process as Process
import Data.Array (slice, length, (!!))
import Data.Maybe (Maybe(Nothing, Just))
import Data.Traversable (traverse)
import Prelude (bind, (==), Unit, otherwise)

import Reinhardt.Management.ORM (syncModelsCommand)

main :: forall e. Eff
                 ( process :: Process.PROCESS
                 , console :: Console.CONSOLE
                 | e
                 )
                 Unit
main = do
  args <- Process.argv
  Console.log "Hi guys"
  traverse Console.log (slice 2 (length args) args)
  case (args !! 3) of
    Nothing -> Console.log "Please insert command"
    Just arg -> case arg of
      x | arg == "syncdb" -> syncModelsCommand
        | otherwise -> Console.log "Unknown argument"
