module App.Config where

import App.Models (userM)
import Data.Exists (Exists)
import Reinhardt.Database (model, DbShape)
models :: Array (Exists DbShape)
models = [
  model userM
]
