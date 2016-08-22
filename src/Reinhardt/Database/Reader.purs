module Reinhardt.Database.Reader where

import Reinhardt.Database.Fields (DBField)

data Unit = Unit
--  DB Row
data DBRow = DBRow

-- unwrap a raw field value
-- for performance reasons, values from DB are actually
-- already unwrapped and ready to use: this just removes the type
-- annotation
foreign import val :: forall a. DBField a -> a
