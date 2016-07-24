module Reinhardt.Database.Reader where

import Reinhardt.Database.Fields (DBField(RawValue))

data Unit = Unit
--  DB Row
data DBRow = DBRow

val :: forall a. (Partial) => DBField a -> a
val (RawValue r) = r
