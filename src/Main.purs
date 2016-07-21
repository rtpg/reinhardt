module Main where

import Node.Express.App
import Control.Monad.Eff.Console as Console
import Node.Process as Process
import Data.Array (slice, length)
import Data.Traversable (traverse)
import Node.Express.Response (sendJson)
import Prelude (return, ($), bind)

handler = sendJson { greeting: "Merry Christmas!" }

app = get "/" handler


main = do
  args <- Process.argv
  Console.log "Hi guys"
  traverse Console.log (slice 2 (length args) args)
  return 0
