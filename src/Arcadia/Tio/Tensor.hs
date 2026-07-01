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
  , tensorToContiguous
  , tensorReshape
  , tensorFlatten
  , tensorExpandDims
  , tensorSqueeze
  , tensorSqueezeAxis
  , tensorPermuteAxes
  , tensorTranspose
  , tensorSliceAxis
  , tensorSliceAxisStep
  , tensorTakeAxis
  , tensorIndexAxis
  , someTensorDType
  , someTensorShape
  , someDenseReadDType
  , someDenseReadShape
  ) where

import Control.Exception (finally)
import Data.Int (Int32, Int64)
import Data.Proxy (Proxy(..))
import Data.Word (Word8, Word64)
import qualified Data.Vector.Storable as VS
import qualified Data.Vector.Storable.Mutable as VSM
import Foreign.C.Types (CInt, CSize(..))
import Foreign.Marshal.Alloc (alloca)
import Foreign.Marshal.Array (copyArray, peekArray, withArray)
import Foreign.Ptr (Ptr, castPtr, nullPtr)
import Foreign.Storable (Storable, peek, poke, sizeOf)

import Arcadia.Tio.Error (Result, invalidArgument)
import Arcadia.Tio.Internal.CApi
  ( CArcadiaTioTensor(..)
  , NativeLibrary
  , capiTensorExpandDims
  , capiTensorFlatten
  , capiTensorFree
  , capiTensorIndexAxis
  , capiTensorPermuteAxes
  , capiTensorReshape
  , capiTensorSliceAxis
  , capiTensorSliceAxisStep
  , capiTensorSqueeze
  , capiTensorSqueezeAxis
  , capiTensorTakeAxis
  , capiTensorToContiguous
  , capiTensorTranspose
  , emptyCArcadiaTioTensor
  , lastError
  , okStatus
  )
import Arcadia.Tio.Types (DType(..), dtypeFromRaw, dtypeSizeBytes, dtypeToRaw)

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

-- | Materialize a contiguous copy through the native C ABI tensor structural core.
tensorToContiguous :: TioElement a => NativeLibrary -> Tensor a -> IO (Result (Tensor a))
tensorToContiguous native tensor =
  callTensorOp native tensor (capiTensorToContiguous native)

-- | Reshape a tensor in row-major order through the native C ABI tensor structural core.
tensorReshape :: TioElement a => NativeLibrary -> [Word64] -> Tensor a -> IO (Result (Tensor a))
tensorReshape native shape tensor =
  withArrayLen shape $ \shapePtr rankLen ->
    callTensorOp native tensor $ \inputPtr outPtr ->
      capiTensorReshape native inputPtr shapePtr rankLen outPtr

-- | Flatten a tensor to shape @[numel]@ through the native C ABI tensor structural core.
tensorFlatten :: TioElement a => NativeLibrary -> Tensor a -> IO (Result (Tensor a))
tensorFlatten native tensor =
  callTensorOp native tensor (capiTensorFlatten native)

-- | Insert a length-1 axis through the native C ABI tensor structural core.
tensorExpandDims :: TioElement a => NativeLibrary -> Int64 -> Tensor a -> IO (Result (Tensor a))
tensorExpandDims native axis tensor =
  callTensorOp native tensor $ \inputPtr outPtr ->
    capiTensorExpandDims native inputPtr axis outPtr

-- | Remove all length-1 axes through the native C ABI tensor structural core.
tensorSqueeze :: TioElement a => NativeLibrary -> Tensor a -> IO (Result (Tensor a))
tensorSqueeze native tensor =
  callTensorOp native tensor (capiTensorSqueeze native)

-- | Remove one length-1 axis through the native C ABI tensor structural core.
tensorSqueezeAxis :: TioElement a => NativeLibrary -> Int64 -> Tensor a -> IO (Result (Tensor a))
tensorSqueezeAxis native axis tensor =
  callTensorOp native tensor $ \inputPtr outPtr ->
    capiTensorSqueezeAxis native inputPtr axis outPtr

-- | Permute axes and materialize a row-major copy through the native C ABI tensor structural core.
tensorPermuteAxes :: TioElement a => NativeLibrary -> [Int64] -> Tensor a -> IO (Result (Tensor a))
tensorPermuteAxes native axes tensor =
  withArrayLen axes $ \axesPtr axesLen ->
    callTensorOp native tensor $ \inputPtr outPtr ->
      capiTensorPermuteAxes native inputPtr axesPtr axesLen outPtr

-- | Reverse axis order and materialize a row-major copy through the native C ABI tensor structural core.
tensorTranspose :: TioElement a => NativeLibrary -> Tensor a -> IO (Result (Tensor a))
tensorTranspose native tensor =
  callTensorOp native tensor (capiTensorTranspose native)

-- | Slice one axis using @[start, end)@ through the native C ABI tensor structural core.
tensorSliceAxis :: TioElement a => NativeLibrary -> Int64 -> Word64 -> Word64 -> Tensor a -> IO (Result (Tensor a))
tensorSliceAxis native axis start end tensor =
  callTensorOp native tensor $ \inputPtr outPtr ->
    capiTensorSliceAxis native inputPtr axis start end outPtr

-- | Slice one axis with a non-zero step through the native C ABI tensor structural core.
tensorSliceAxisStep :: TioElement a => NativeLibrary -> Int64 -> Int64 -> Int64 -> Int64 -> Tensor a -> IO (Result (Tensor a))
tensorSliceAxisStep native axis start end step tensor =
  callTensorOp native tensor $ \inputPtr outPtr ->
    capiTensorSliceAxisStep native inputPtr axis start end step outPtr

-- | Take explicit indices on one axis through the native C ABI tensor structural core.
tensorTakeAxis :: TioElement a => NativeLibrary -> Int64 -> [Word64] -> Tensor a -> IO (Result (Tensor a))
tensorTakeAxis native axis indices tensor =
  withArrayLen indices $ \indicesPtr indicesLen ->
    callTensorOp native tensor $ \inputPtr outPtr ->
      capiTensorTakeAxis native inputPtr axis indicesPtr indicesLen outPtr

-- | Select one index on an axis, preserving rank with axis length 1.
tensorIndexAxis :: TioElement a => NativeLibrary -> Int64 -> Word64 -> Tensor a -> IO (Result (Tensor a))
tensorIndexAxis native axis index tensor =
  callTensorOp native tensor $ \inputPtr outPtr ->
    capiTensorIndexAxis native inputPtr axis index outPtr

callTensorOp :: forall a. TioElement a => NativeLibrary -> Tensor a -> (Ptr CArcadiaTioTensor -> Ptr CArcadiaTioTensor -> IO CInt) -> IO (Result (Tensor a))
callTensorOp native tensor nativeCall =
  withBorrowedTensor tensor $ \inputPtr ->
    alloca $ \outPtr -> do
      poke outPtr emptyCArcadiaTioTensor
      status <- nativeCall inputPtr outPtr
      if status == okStatus
        then (peek outPtr >>= copyTypedTensor expectedDType) `finally` capiTensorFree native outPtr
        else do
          err <- lastError native
          capiTensorFree native outPtr
          pure (Left err)
 where
  expectedDType = elementDType (Proxy :: Proxy a)

withBorrowedTensor :: forall a b. TioElement a => Tensor a -> (Ptr CArcadiaTioTensor -> IO (Result b)) -> IO (Result b)
withBorrowedTensor tensor@Tensor{tensorShape, tensorValues} action =
  case validateTensorInput tensor of
    Left err -> pure (Left err)
    Right () ->
      case tensorByteLength tensorValues of
        Left err -> pure (Left err)
        Right lenBytes ->
          withArray tensorShape $ \shapePtr ->
            VS.unsafeWith tensorValues $ \valuesPtr ->
              alloca $ \tensorPtr -> do
                poke
                  tensorPtr
                  CArcadiaTioTensor
                    { cTensorData = castPtr valuesPtr
                    , cTensorLenBytes = lenBytes
                    , cTensorRank = CSize (fromIntegral (length tensorShape))
                    , cTensorShape = shapePtr
                    , cTensorDType = dtypeToRaw (elementDType (Proxy :: Proxy a))
                    }
                action tensorPtr

tensorByteLength :: forall a. Storable a => VS.Vector a -> Result CSize
tensorByteLength values =
  let count = VS.length values
      bytes = toInteger count * toInteger (sizeOf (undefined :: a))
      maxBytes = toInteger (maxBound :: CSize)
   in if bytes > maxBytes
        then Left (invalidArgument "tensor byte length exceeds C size_t range")
        else Right (fromInteger bytes)

validateTensorInput :: TioElement a => Tensor a -> Result ()
validateTensorInput Tensor{tensorShape, tensorValues} = do
  expected <- tensorElementCount tensorShape
  let actual = VS.length tensorValues
  if expected == actual
    then Right ()
    else
      Left
        ( invalidArgument
            ( "tensor payload length "
                <> show actual
                <> " does not match shape product "
                <> show expected
            )
        )

copyTypedTensor :: Storable a => DType -> CArcadiaTioTensor -> IO (Result (Tensor a))
copyTypedTensor expectedDType CArcadiaTioTensor{cTensorData, cTensorLenBytes, cTensorRank, cTensorShape, cTensorDType} =
  case dtypeFromRaw cTensorDType of
    Just actualDType | actualDType == expectedDType -> copyMatchingDType
    Just actualDType -> pure (Left (invalidArgument ("native tensor dtype mismatch: expected " <> show expectedDType <> ", got " <> show actualDType)))
    Nothing -> pure (Left (invalidArgument "native tensor has unknown dtype"))
 where
  copyMatchingDType = do
    let tensorRank = fromIntegral cTensorRank
        lenBytes = fromIntegral cTensorLenBytes
        scalarBytes = dtypeSizeBytes expectedDType
    if tensorRank > 0 && cTensorShape == nullPtr
      then pure (Left (invalidArgument "native tensor shape pointer is null"))
      else if lenBytes > 0 && cTensorData == nullPtr
        then pure (Left (invalidArgument "native tensor data pointer is null"))
        else if lenBytes `mod` scalarBytes /= 0
          then pure (Left (invalidArgument "native tensor byte length is not a whole number of elements"))
          else do
            shape <- peekArray tensorRank cTensorShape
            let count = lenBytes `div` scalarBytes
            values <- copyVector count (castPtr cTensorData)
            pure $ case tensorElementCount shape of
              Left err -> Left err
              Right expected
                | expected == count -> Right (Tensor shape values)
                | otherwise -> Left (invalidArgument "native tensor byte length does not match shape product")

copyVector :: Storable a => Int -> Ptr a -> IO (VS.Vector a)
copyVector count src
  | count <= 0 = pure VS.empty
  | otherwise = do
      mutable <- VSM.unsafeNew count
      VSM.unsafeWith mutable $ \dst -> copyArray dst src count
      VS.unsafeFreeze mutable

withArrayLen :: Storable a => [a] -> (Ptr a -> CSize -> IO b) -> IO b
withArrayLen values action = withArray values $ \ptr -> action ptr (CSize (fromIntegral (length values)))

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
