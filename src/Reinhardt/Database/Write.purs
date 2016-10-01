module Reinhardt.Database.Write where
import Control.Monad.Aff (makeAff, Aff)
import Control.Monad.Eff (Eff)
import Data.Unit (Unit)
import Reinhardt.Database (toDB, tableName, class DBTable, class Model, sentinelObj)

foreign import rawInsertObject ::
  forall e shape.
  String ->  -- table name
  shape -> -- data itself, from model transformation
  (Unit -> Eff e Unit) -> -- callback
  Eff e Unit

insertDB :: forall obj shape e. (Model obj shape, DBTable shape) => obj -> shape -> Aff e Unit

insertDB object shape =
 let name = tableName shape
     dbObj :: shape
     dbObj = toDB object in
     makeAff
     (\error success -> rawInsertObject name dbObj success)

--
bulkUpdate :: forall obj shape e. shape -> shape -> Aff e Unit
bulkUpdate = sentinelObj

updateObject :: forall obj shape e.(Model obj shape, DBTable shape) =>
  obj -> Aff e Unit
updateObject = sentinelObj
