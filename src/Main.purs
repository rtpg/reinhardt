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


testF x y = g y
  where g y = x + y

gOuter x y = x + y

testF2 x y = gOuter x y

-- type User = {
--   name :: String,
--   uuid :: Integer,
-- }

-- type UserForm = {
--   name :: StringField,
--   password :: IntegerField
-- }
--
-- f = do
--      name <- (F.default::FieldFor String) { prop : "name" }
--      uuid <- genName
--      return {name, uuid}
--
--
-- class S o where
--   s :: o -> String
--
-- instance sHotel :: S Hotel where
--   s h = "Hotel"
--
-- type HotelField = {
--
-- }
-- class FormFor o where
--   formFor :: forall e g. Object (e :: g | o) -> Array String
--
-- -- instance oF :: (FormFor o) => (FormFor (e::g | o))
-- class FieldFor t where
--   fieldFor :: t -> String
--
-- instance stringField :: FieldFor String where
--   fieldFor _ = "StringField"
--
-- -- instance nameF :: (FieldFor f, FormFor (Object e)) => FormFor (Object (name::f | e)) where
-- --    formFor o =
