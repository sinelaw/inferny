module Infernu.Builtins
       (builtins)
       where

import           Infernu.Types
import qualified Data.Map.Lazy              as Map
import           Data.Map.Lazy              (Map)

ts :: [TVarName] -> Type -> TypeScheme
ts tvs t = TScheme tvs t TPredTrue
           
unaryFunc :: Type -> Type -> TypeScheme
unaryFunc t1 t2 = ts [0] $ Fix $ TCons TFunc [Fix $ TBody $ TVar 0, t1, t2]

binaryFunc  :: Type -> Type -> Type -> Type -> Fix FType
binaryFunc tThis t1 t2 t3 = Fix $ TCons TFunc [tThis, t1, t2, t3]

binarySimpleFunc :: Type -> Type -> Type
binarySimpleFunc tThis t = Fix $ TCons TFunc [tThis, t, t, t]

binaryFuncS :: Type -> Type -> Type -> TypeScheme
binaryFuncS t1 t2 t3 = ts [0] $ binaryFunc (Fix $ TBody $ TVar 0) t1 t2 t3

tVar :: TVarName -> Type
tVar = Fix . TBody . TVar

tBoolean :: Type
tBoolean = Fix $ TBody TBoolean

tNumber :: Type
tNumber = Fix $ TBody TNumber

tString :: Type
tString = Fix $ TBody TString

numRelation :: TypeScheme
numRelation = binaryFuncS tNumber tNumber tBoolean

numOp :: TypeScheme
numOp = binaryFuncS tNumber tNumber tNumber

builtins :: Map EVarName TypeScheme
builtins = Map.fromList [
  ("!",            unaryFunc tBoolean tBoolean),
  ("~",            unaryFunc tNumber  tNumber),
  ("typeof",       ts [0,1] $ Fix $ TCons TFunc [Fix $ TBody $ TVar 1, Fix $ TBody $ TVar 0, tString]),
  ("+",            TScheme [0,1] (binarySimpleFunc (tVar 0) (tVar 1)) (TPredOr (TPredEq 1 $ Fix $ TBody $ TString) (TPredEq 1 $ Fix $ TBody $ TNumber))),
  ("-",            numOp),
  ("*",            numOp),
  ("/",            numOp),
  ("%",            numOp),
  ("<<",           numOp),
  (">>",           numOp),
  (">>>",          numOp),
  ("&",            numOp),
  ("^",            numOp),
  ("|",            numOp),
  ("<",            numRelation),
  ("<=",           numRelation),
  (">",            numRelation),
  (">=",           numRelation),
  ("===",          ts [0, 1, 2] $ Fix $ TCons TFunc [Fix $ TBody $ TVar 2, Fix $ TBody $ TVar 0, Fix $ TBody $ TVar 1, tBoolean]),
  ("!==",          ts [0, 1, 2] $ Fix $ TCons TFunc [Fix $ TBody $ TVar 2, Fix $ TBody $ TVar 0, Fix $ TBody $ TVar 1, tBoolean]),
  ("&&",           ts [0, 1] $ Fix $ TCons TFunc [tVar 0, tVar 1, tVar 1, tVar 1]),
  ("||",           ts [0, 1] $ Fix $ TCons TFunc [tVar 0, tVar 1, tVar 1, tVar 1]),
  -- avoid coercions on == and !=
  ("==",           ts [0, 1] $ Fix $ TCons TFunc [Fix $ TBody $ TVar 1, Fix $ TBody $ TVar 0, Fix $ TBody $ TVar 0, tBoolean]),
  ("!=",           ts [0, 1] $ Fix $ TCons TFunc [Fix $ TBody $ TVar 1, Fix $ TBody $ TVar 0, Fix $ TBody $ TVar 0, tBoolean]),
  ("RegExp",       ts [0] $ Fix $ TCons TFunc [Fix $ TBody $ TVar 0, tString, tString, Fix $ TBody $ TRegex]),
  ("String",       ts [1] $ Fix $ TCons TFunc [Fix $ TBody $ TUndefined, Fix $ TBody $ TVar 1, Fix $ TBody $ TString]),
  ("Number",       ts [1] $ Fix $ TCons TFunc [Fix $ TBody $ TUndefined, Fix $ TBody $ TVar 1, Fix $ TBody $ TNumber]),
  ("Boolean",      ts [1] $ Fix $ TCons TFunc [Fix $ TBody $ TUndefined, Fix $ TBody $ TVar 1, Fix $ TBody $ TBoolean]),
  ("NaN",          ts [] tNumber)
  ]