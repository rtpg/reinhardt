module App.Config where

import App.Models (userM)
import Data.Exists (Exists)
import Reinhardt.Database (DbShape, model)
models :: Array (Exists DbShape)
models = [
  model userM
]
