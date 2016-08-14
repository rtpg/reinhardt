module App.Models where

import Data.Maybe
import Control.Monad.Eff (Eff)
import Prelude (bind)
import Reinhardt.Database (class Model, class DBTable, mkShape)
import Reinhardt.Database.Fields (DBField(RawValue), stringField)
import Reinhardt.Database.Reader (val) as Reader

foreign import data DB :: !

data User = User { username :: String, email :: String}

data UserM = UserM { username :: DBField String, email :: DBField String}
userM :: UserM
userM = UserM {
  username : stringField "username",
  email: stringField "email"
}

instance userTable :: DBTable UserM where
  tableName = \_ -> "user"
  tableShape = mkShape UserM

instance userModel :: Model User UserM where
  dbStructure = userM
  fromDB = \(UserM u) ->
    User {
      username: Reader.val u.username,
      email: Reader.val u.email
    }

  toDB = \(User u) -> UserM {
    username: RawValue u.username,
    email: RawValue u.email
  }

foreign import createUser :: forall e. User -> Eff (write::DB | e) User
foreign import lookupUser :: forall e. String -> Eff (read::DB | e) (Maybe User)

createThenLookupUser:: forall e. User -> Eff (read::DB, write::DB | e) (Maybe User)
createThenLookupUser u = do
    (User createdUser) <- createUser u
    lookupUser createdUser.username
