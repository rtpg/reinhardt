module Main where

import Prelude (unit, return, (+))

import Control.Monad.Eff (Eff)

import Data.Generic (class Generic)
import Node.Express.App
import Node.Express.Response (sendJson)


handler = sendJson { greeting: "Merry Christmas!" }

app = get "/" handler

main = do
  listenHttp app 8080 (\_ -> return unit)
