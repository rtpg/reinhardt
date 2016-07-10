module App.Models where

import Prelude (bind)

import Data.Maybe
import Control.Monad.Eff (Eff)
foreign import data DB :: !

type User = { username :: String, email :: String, uid :: String}

foreign import createUser :: forall e. User -> Eff (write::DB | e) User
foreign import lookupUser :: forall e. String -> Eff (read::DB | e) (Maybe User)

createThenLookupUser:: forall e. User -> Eff (read::DB, write::DB | e) (Maybe User)
createThenLookupUser u = do
    createdUser <- createUser u
    lookupUser createdUser.username

foreign import data F :: # * -> *
