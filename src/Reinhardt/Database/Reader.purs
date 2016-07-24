module Reinhardt.Database.Reader where

import Partial.Unsafe (unsafePartial)
import Prelude (class Monad, class Applicative, class Apply, class Bind, class Functor, ($))
import Reinhardt.Database.Fields (DBField(RawValue), FieldDefinition(FieldDefinition))
import Reinhardt.Foreign (JSValue)
data Unit = Unit
--  DB Row
data DBRow = DBRow

val :: forall a. (Partial) => DBField a -> a
val (RawValue r) = r
