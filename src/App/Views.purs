module App.Views where

import App.Models (DB, createUser, lookupUser, User(User))
import Control.Monad.Eff (Eff)
import Data.Maybe (Maybe(Nothing, Just))
import Prelude (return, bind, (++), ($))

data Method = GET | POST

type Request = {
  body :: String,
  header :: String,
  method :: Method
 }

type Response = {
  body :: String,
  status :: Int
}

signupPage :: forall e. Request -> Eff (read::DB, write::DB | e) Response
signupPage req = do
  mUser <- lookupUser req.header
  case mUser of
      Just user -> return {
        body : "User with this username already exists!",
        status : 400
      }
      Nothing -> do
        createUser $ User {
          username : req.header,
          email: req.body
        }
        return {
          body : "Created User with name " ++ req.header,
          status: 200
        }

lookupEmail :: forall e. Request -> Eff (read::DB | e) Response
lookupEmail req = do
  mUser <- lookupUser req.header
  case mUser of
      Just (User u) -> return {
        body: u.email,
        status: 200
      }
      Nothing -> do
        return { status: 400, body: "Not Found"}

data Route =
    GetRoute String (forall e. Request -> Eff (read::DB | e) Response)
  | PostRoute String (forall e. Request -> Eff (read::DB,write::DB | e) Response)

routes :: Array Route
routes = [
  PostRoute "/signup" signupPage
]
