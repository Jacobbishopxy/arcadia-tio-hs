{-# LANGUAGE ScopedTypeVariables #-}

module Arcadia.Tio.Tensor
  ( Tensor(..)
  , SomeTensor(..)
  , DenseRead(..)
  , SomeDenseRead(..)
  , TioElement(..)
  , tensorFromVector
  , tensorFromList
  , tensorElementCount
  , someTensorDType
  , someTensorShape
  , someDenseReadDType
  , someDenseReadShape
  ) where

import Data.Int (Int32, Int64)
import Data.Word (Word8, Word64)
import qualified Data.Vector.Storable as VS
import Foreign.Storable (Storable)

import Arcadia.Tio.Error (Result, invalidArgument)
import Arcadia.Tio.Types (DType(..))

-- | Dense row-major tensor stored in Haskell-owned memory.
data Tensor a = Tensor
  { tensorShape :: [Word64]
  , tensorValues :: VS.Vector a
  }
  deriving (Eq, Show)

-- | Dynamically typed tensor returned by 'Arcadia.Tio.TensorFile.readAll'.
data SomeTensor
  = SomeTensorF32 (Tensor Float)
  | SomeTensorF64 (Tensor Double)
  | SomeTensorI32 (Tensor Int32)
  | SomeTensorI64 (Tensor Int64)
  deriving (Eq, Show)

-- | Dense read result with a validity mask copied into Haskell-owned memory.
-- Mask byte value @1@ means valid/present; @0@ means null/missing.
data DenseRead a = DenseRead
  { denseReadTensor :: Tensor a
  , denseReadValidity :: VS.Vector Word8
  }
  deriving (Eq, Show)

-- | Dynamically typed dense read result with validity mask.
data SomeDenseRead
  = SomeDenseReadF32 (DenseRead Float)
  | SomeDenseReadF64 (DenseRead Double)
  | SomeDenseReadI32 (DenseRead Int32)
  | SomeDenseReadI64 (DenseRead Int64)
  deriving (Eq, Show)

-- | Element types supported by dense TensorFile append/read helpers.
class Storable a => TioElement a where
  elementDType :: proxy a -> DType
  fromSomeTensor :: SomeTensor -> Result (Tensor a)
  fromSomeDenseRead :: SomeDenseRead -> Result (DenseRead a)

instance TioElement Float where
  elementDType _ = F32
  fromSomeTensor tensor = case tensor of
    SomeTensorF32 value -> Right value
    other -> dtypeMismatch F32 other
  fromSomeDenseRead dense = case dense of
    SomeDenseReadF32 value -> Right value
    other -> denseDTypeMismatch F32 other

instance TioElement Double where
  elementDType _ = F64
  fromSomeTensor tensor = case tensor of
    SomeTensorF64 value -> Right value
    other -> dtypeMismatch F64 other
  fromSomeDenseRead dense = case dense of
    SomeDenseReadF64 value -> Right value
    other -> denseDTypeMismatch F64 other

instance TioElement Int32 where
  elementDType _ = I32
  fromSomeTensor tensor = case tensor of
    SomeTensorI32 value -> Right value
    other -> dtypeMismatch I32 other
  fromSomeDenseRead dense = case dense of
    SomeDenseReadI32 value -> Right value
    other -> denseDTypeMismatch I32 other

instance TioElement Int64 where
  elementDType _ = I64
  fromSomeTensor tensor = case tensor of
    SomeTensorI64 value -> Right value
    other -> dtypeMismatch I64 other
  fromSomeDenseRead dense = case dense of
    SomeDenseReadI64 value -> Right value
    other -> denseDTypeMismatch I64 other

dtypeMismatch :: DType -> SomeTensor -> Result (Tensor a)
dtypeMismatch expected actual =
  Left
    ( invalidArgument
        ( "read dtype mismatch: expected "
            <> show expected
            <> ", got "
            <> show (someTensorDType actual)
        )
    )

denseDTypeMismatch :: DType -> SomeDenseRead -> Result (DenseRead a)
denseDTypeMismatch expected actual =
  Left
    ( invalidArgument
        ( "dense read dtype mismatch: expected "
            <> show expected
            <> ", got "
            <> show (someDenseReadDType actual)
        )
    )

-- | Construct a dense tensor from a storable vector and validate shape/product.
tensorFromVector :: forall a. TioElement a => [Word64] -> VS.Vector a -> Result (Tensor a)
tensorFromVector shape values = do
  expected <- tensorElementCount shape
  let actual = VS.length values
  if expected == actual
    then Right (Tensor shape values)
    else
      Left
        ( invalidArgument
            ( "tensor payload length "
                <> show actual
                <> " does not match shape product "
                <> show expected
            )
        )

-- | Construct a dense tensor from a Haskell list and validate shape/product.
tensorFromList :: TioElement a => [Word64] -> [a] -> Result (Tensor a)
tensorFromList shape values = tensorFromVector shape (VS.fromList values)

-- | Compute the element count represented by a shape.
tensorElementCount :: [Word64] -> Result Int
tensorElementCount [] = Left (invalidArgument "tensor rank must be at least one")
tensorElementCount shape =
  let productInteger = product (map toInteger shape)
      maxIntInteger = toInteger (maxBound :: Int)
   in if productInteger > maxIntInteger
        then Left (invalidArgument "tensor shape product exceeds host Int range")
        else Right (fromInteger productInteger)

-- | Return the dtype of a dynamically typed tensor.
someTensorDType :: SomeTensor -> DType
someTensorDType tensor = case tensor of
  SomeTensorF32 _ -> F32
  SomeTensorF64 _ -> F64
  SomeTensorI32 _ -> I32
  SomeTensorI64 _ -> I64

-- | Return the shape of a dynamically typed tensor.
someTensorShape :: SomeTensor -> [Word64]
someTensorShape tensor = case tensor of
  SomeTensorF32 value -> tensorShape value
  SomeTensorF64 value -> tensorShape value
  SomeTensorI32 value -> tensorShape value
  SomeTensorI64 value -> tensorShape value

-- | Return the dtype of a dynamically typed dense read result.
someDenseReadDType :: SomeDenseRead -> DType
someDenseReadDType dense = case dense of
  SomeDenseReadF32 _ -> F32
  SomeDenseReadF64 _ -> F64
  SomeDenseReadI32 _ -> I32
  SomeDenseReadI64 _ -> I64

-- | Return the shape of a dynamically typed dense read result.
someDenseReadShape :: SomeDenseRead -> [Word64]
someDenseReadShape dense = case dense of
  SomeDenseReadF32 value -> tensorShape (denseReadTensor value)
  SomeDenseReadF64 value -> tensorShape (denseReadTensor value)
  SomeDenseReadI32 value -> tensorShape (denseReadTensor value)
  SomeDenseReadI64 value -> tensorShape (denseReadTensor value)
