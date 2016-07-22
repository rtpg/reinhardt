module Main where

import Control.Monad.Eff.Console as Console
import Node.Process as Process
import Data.Array (slice, length)
import Data.Traversable (traverse)
import Prelude (pure, ($), bind)

main = do
  args <- Process.argv
  Console.log "Hi guys"
  traverse Console.log (slice 2 (length args) args)
  pure 0
