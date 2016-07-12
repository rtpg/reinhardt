module App.Models where

import Prelude (bind)

import Data.Maybe
import Control.Monad.Eff (Eff)

import Reinhardt.Database.Fields (stringField)

foreign import data DB :: !

data User = User { username :: String, email :: String}

type UserM = { username :: FieldDefinition String, email :: FieldDefinition String}
userM :: UserM
userM = {
  username : stringField,
  email: stringField
}

instance userModel :: Model User UserM where
  dbStructure = userM
  fromDB = DBReader
  toDB = \elt -> DBWriter

foreign import createUser :: forall e. User -> Eff (write::DB | e) User
foreign import lookupUser :: forall e. String -> Eff (read::DB | e) (Maybe User)

createThenLookupUser:: forall e. User -> Eff (read::DB, write::DB | e) (Maybe User)
createThenLookupUser u = do
    createdUser <- createUser u
    lookupUser createdUser.username
