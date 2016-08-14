module Reinhardt.Database.Query where

import Control.Monad.Aff (makeAff, Aff)
import Control.Monad.Eff (Eff)
import Data.List (List(Nil, Cons))
import Data.Tuple (Tuple(Tuple))
import Data.Unit (Unit)
import Partial.Unsafe (unsafePartial)
import Prelude (map, ($), bind, pure)
import Reinhardt.Database (class Model, sentinelObj, tableName, castToShape, fromDB)
import Reinhardt.Database.Fields (DBField(Field), FieldDefinition(FieldDefinition), ForeignKey)
import Unsafe.Coerce (unsafeCoerce)

data QueryParam = QueryParam

-- actual findAll query, from sequelize
-- params:
-- table name (for lookup), paired with join params
-- params
foreign import rawSequelizeFindAll ::
 forall e. List JData -> Array QueryParam -> -- params
 (Array FromSql -> Eff e Unit)  -> -- callback
 Eff e Unit

foreign import data FromSql :: *

sequelizeFindAll :: forall e. List JData -> Array QueryParam -> Aff e (Array FromSql)
sequelizeFindAll m params = makeAff
  (\error success -> rawSequelizeFindAll m params success)

class SqlInflate model obj where
    sqlInflate :: model -> FromSql -> obj

class Findable model resultShape where
    -- find model includes the properties for joining
    -- first element in the array is the base model
    -- next elements describe tables to join (via fields on first elt)
    buildFindModel :: resultShape -> model -> List {
      name   :: String,  -- name is the name of the field
      source :: String -- source is table name (corresponds to defined model)
      }
    -- findAll :: model -> Array QueryParam -> Array resultShape

findAll :: forall model obj e. (Findable model obj, SqlInflate model obj) =>
   model -> Array QueryParam -> Aff e (Array obj)
findAll m params =
    let sequelizeModel = buildFindModel (sentinelObj::obj) m in
      do
        rawSqlData <- sequelizeFindAll sequelizeModel params
        pure $ map (sqlInflate m) rawSqlData

instance inflatableModel::(Model nativeObj model) => SqlInflate model nativeObj where
    sqlInflate m = (\x -> unsafePartial $ fromDB (castToShape x::model))

instance inflatableField:: (SqlInflate mA a, Model b mB) =>
  SqlInflate (JoinWith mA (DBField (ForeignKey mB b))) (Tuple a b) where
   sqlInflate (JoinWith mA fkB) fromSql = let t = unsafeCoerce fromSql in
      case t of
        Tuple jsA jsB -> Tuple (sqlInflate mA jsA) (sqlInflate (sentinelObj::mB) jsB)

instance findableModel::(Model nativeObj model) => Findable model nativeObj where
    buildFindModel _ m = Cons {source: (tableName m), name: (tableName m)} Nil

data JoinWith a b = JoinWith a b

type JData = {source :: String, name :: String}

findModelFromFK :: forall obj m. DBField (ForeignKey obj m) -> JData
findModelFromFK (Field (FieldDefinition fd)) = {source: fd.refersToTable, name: fd.columnName}
findModelFromFK _ = {source: "", name: ""} -- TODO make this fail

joinedFindModel :: forall a mA f g.
  (Findable mA a) =>
  a -> JoinWith mA (DBField (ForeignKey f g)) -> List JData
joinedFindModel a (JoinWith (mA::mA)  (fkField:: DBField (ForeignKey f g))) =
  let prevFindModel = buildFindModel a mA
      fieldFindModel = findModelFromFK fkField  in
          Cons (fieldFindModel::JData) (prevFindModel:: List JData)

instance joinedFind::(Findable mA a, Model r mR) => Findable
  (JoinWith mA (DBField (ForeignKey r mR)))
  (Tuple a r) where
    buildFindModel a m = joinedFindModel (sentinelObj::a) m
