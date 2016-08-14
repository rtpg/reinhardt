module Reinhardt.Database.Query where

import Data.Exists (Exists, runExists)
import Data.List (List(Nil, Cons))
import Data.Tuple (Tuple(Tuple))
import Data.Tuple.Nested (Tuple2)
import Partial.Unsafe (unsafePartial)
import Prelude (map, ($))
import Reinhardt.Database (fromDB, DBCons(DBCons), tableShape, sentinelObj, class DBTable, tableName, class Model, castToShape)
import Reinhardt.Database.Fields (DBField(Field), FieldDefinition(FieldDefinition), ForeignKey)
import Reinhardt.Foreign (JSValue)
import Unsafe.Coerce (unsafeCoerce)

data QueryParam = QueryParam

-- actual findAll query, from sequelize
-- params:
-- table name (for lookup), paired with join params
-- params
foreign import sequelizeFindAll :: forall a b. a -> b -> Array FromSql

foreign import data FromSql :: *

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

rFindAll :: forall model obj. (Findable model obj, SqlInflate model obj) =>
   model -> Array QueryParam -> Array obj
rFindAll m params =
    let sequelizeModel = buildFindModel (sentinelObj::obj) m
        rawSqlData = sequelizeFindAll sequelizeModel params in
        map (sqlInflate m) rawSqlData

instance inflatableModel::(Model nativeObj model) => SqlInflate model nativeObj where
    sqlInflate m = (\x -> unsafePartial $ fromDB (castToShape x::model))

instance inflatableField:: (SqlInflate mA a, Model b mB) =>
  SqlInflate (JoinWith mA (DBField (ForeignKey mB b))) (Tuple a b) where
   sqlInflate (JoinWith mA fkB) fromSql = let t = unsafeCoerce fromSql in
      case t of
        Tuple jsA jsB -> Tuple (sqlInflate mA jsA) (sqlInflate (sentinelObj::mB) jsB)

instance findableModel::(Model nativeObj model) => Findable model nativeObj where
    buildFindModel _ m = Cons {source: (tableName m), name: (tableName m)} Nil
    -- findAll m params  = map (unsafePartial fromDB) (mFindAll m params)

data JoinWith a b = JoinWith a b

type JData = {source :: String, name :: String}

mFindAll :: forall model. (DBTable model) => model -> Array QueryParam -> Array model
mFindAll m params =
    let rawResults = sequelizeFindAll (Cons {source: (tableName m), name: (tableName m)} Nil) params in
      map castToShape rawResults

findModelFromFK :: forall obj m. DBField (ForeignKey obj m) -> JData
findModelFromFK (Field (FieldDefinition fd)) = {source: fd.refersToTable, name: fd.columnName}
findModelFromFK _ = {source: "", name: ""} -- TODO make this fail

joinedFindModel :: forall a mA f g.
  (Findable mA a) =>
  a -> JoinWith mA (DBField (ForeignKey f g)) -> List {source:: String, name:: String}
joinedFindModel a (JoinWith (mA::mA)  (fkField:: DBField (ForeignKey f g))) =
  let prevFindModel = buildFindModel a mA
      qq :: forall obj m. DBField (ForeignKey obj m) -> JData
      qq = findModelFromFK
      fieldFindModel = qq fkField  in
          Cons (fieldFindModel::JData) (prevFindModel:: List JData)

instance joinedFind::(Findable mA a, Model r mR) => Findable
  (JoinWith mA (DBField (ForeignKey r mR)))
  (Tuple a r) where
    buildFindModel a m = joinedFindModel (sentinelObj::a) m
    -- findAll m params = sentinelObj
    --  let fullModel = buildFindModel (sentinelObj::a) m
    --      rawResults :: Array JSValue
    --      rawResults = sequelizeFindAll fullModel params in
    --      map castToShape rawResults

    --sequelizeFindAll (buildFindModel m) params
