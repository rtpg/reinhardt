module App.Config where

import App.Models (User(User), userM)
import Data.Exists (Exists)
import Reinhardt.Database (model, DbShape, sentinelObj)
models :: Array (Exists DbShape)
models = [
  model userM (sentinelObj::User)
]
