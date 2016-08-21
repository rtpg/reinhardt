module TestApp where

import App.Models (userM, User)
import Control.Monad.Aff (Aff)

import Reinhardt.Database.Query (findAll)

runFindAll :: forall e. Aff e (Array User)
runFindAll = findAll userM []
