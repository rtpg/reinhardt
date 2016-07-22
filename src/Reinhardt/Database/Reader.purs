module Reinhardt.Database.Reader where

import Prelude (class Monad, class Applicative, class Apply, class Bind, class Functor, ($))

import Reinhardt.Foreign (JSValue)
import Reinhardt.Database.Fields (FieldDefinition(FieldDefinition))
data Unit = Unit
--  DB Row
data DBRow = DBRow

-- reader lets you take a DB object and populate your user object
-- might be able to replace by a Reader type alias...
data DBReader a = DBReader (DBRow -> a)

runReader :: forall a. DBReader a -> DBRow -> a
runReader (DBReader f) = f

-- foreign function to let you "get" a column from a DB row
foreign import readObj :: DBRow -> String -> JSValue

instance dBReaderApply :: Apply DBReader where
  apply f x = DBReader $ \row ->
    let f_ = runReader f row
        x_ = runReader x row in
        f_ x_

instance dbReaderFunctor :: Functor DBReader where
  map f dbX = DBReader $ \row ->
    let x = runReader dbX row in
    f x

instance dBReaderBind :: Bind DBReader where
  bind previousOp nextStep = DBReader $ \row ->
    let firstResult = runReader previousOp row in
    (runReader $ nextStep firstResult) row

instance dBReaderApplicative :: Applicative DBReader where
  pure x = DBReader $ \_ -> x

instance dBReaderMonad :: Monad DBReader

-- useful functions

get :: forall a. FieldDefinition a -> DBReader a
get (FieldDefinition f) = DBReader $ \row ->
    let dbVal = readObj row f.columnName in
      f.fromDBValue dbVal
