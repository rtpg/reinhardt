module App.Models where

import Data.Maybe
import Control.Monad.Eff (Eff)
import Prelude (bind, ($))
import Reinhardt.Database (DBWriter(DBWriter), class Model)
import Reinhardt.Database.Fields (FieldDefinition(FieldDefinition), stringField)
import Reinhardt.Database.Reader (DBReader(DBPure))

foreign import data DB :: !

data User = User { username :: String, email :: String}

data UserM = UserM { username :: FieldDefinition String, email :: FieldDefinition String}
userM :: UserM
userM = UserM {
  username : stringField,
  email: stringField
}

instance userModel :: Model User UserM where
  dbStructure = userM
  fromDB = DBPure $ User {username: "a" , email: "b"}
  toDB = \elt -> DBWriter

foreign import createUser :: forall e. User -> Eff (write::DB | e) User
foreign import lookupUser :: forall e. String -> Eff (read::DB | e) (Maybe User)

createThenLookupUser:: forall e. User -> Eff (read::DB, write::DB | e) (Maybe User)
createThenLookupUser u = do
    (User createdUser) <- createUser u
    lookupUser createdUser.username
