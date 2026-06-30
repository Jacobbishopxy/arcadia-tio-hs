{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE NamedFieldPuns #-}

module Arcadia.Tio.Ocb
  ( OcbFile
  , OcbOpenValidation(..)
  , OcbOpenOptions(..)
  , defaultOcbOpenOptions
  , OcbErrorKind(..)
  , OcbFailureCause(..)
  , OcbPhysicalType(..)
  , OcbLogicalKind(..)
  , OcbDictionaryValueKind(..)
  , OcbOrderingDirection(..)
  , OcbNullOrder(..)
  , OcbColumnDescriptor(..)
  , OcbDictionaryDescriptor(..)
  , OcbOrderingKey(..)
  , OcbMetadata(..)
  , OcbDictionaryValues(..)
  , OcbProjection(..)
  , OcbPredicateValue(..)
  , OcbRowGroupPredicate(..)
  , OcbReadRequest(..)
  , defaultOcbReadRequest
  , OcbReadReport(..)
  , OcbReadAttribution(..)
  , OcbPrimitiveValues(..)
  , OcbValidityBitmap(..)
  , OcbColumnArray(..)
  , OcbColumnBatch(..)
  , OcbReadOutcome(..)
  , OcbReadWithAttribution(..)
  , OcbReadPlan
  , OcbBodyKind(..)
  , OcbChecksumKind(..)
  , OcbChunkSummaryCodec(..)
  , OcbBodyRefSummary(..)
  , OcbColumnChunkSummary(..)
  , OcbColumnStatsSummary(..)
  , OcbRowGroupSummary(..)
  , OcbRowGroupSummaries(..)
  , open
  , openWithOptions
  , clone
  , close
  , lastErrorKind
  , lastErrorCause
  , metadata
  , dictionaryValues
  , readBatches
  , readBatchesWithAttribution
  , planRead
  , readPlanReport
  , readPlanProjectedColumnIds
  , readPlanRowGroupIds
  , readBatchesFromPlan
  , closeReadPlan
  , rowGroupSummaries
  , readPlanRowGroupSummaries
  ) where

import Control.Exception (finally)
import Data.Int (Int32, Int64)
import Data.Word (Word8, Word16, Word32, Word64)
import Foreign.C.String (CString, peekCString, withCString)
import Foreign.C.Types (CFloat(..), CInt(..), CSize(..))
import Foreign.ForeignPtr (ForeignPtr, finalizeForeignPtr, withForeignPtr)
import qualified Foreign.Concurrent as FC
import Foreign.Marshal.Alloc (alloca)
import Foreign.Marshal.Array (allocaArray, peekArray, withArray)
import Foreign.Ptr (Ptr, castPtr, nullPtr)
import Foreign.Storable (Storable, peek, poke)

import Arcadia.Tio.Error (Result, TioError, invalidArgument)
import Arcadia.Tio.Internal.CApi
  ( CArcadiaTioOcbBodyRefSummary(..)
  , CArcadiaTioOcbByteSlice(..)
  , CArcadiaTioOcbColumnChunkSummary(..)
  , CArcadiaTioOcbColumnDescriptor(..)
  , CArcadiaTioOcbDictionaryDescriptor(..)
  , CArcadiaTioOcbDictionaryValues(..)
  , CArcadiaTioOcbColumnStatsSummary(..)
  , CArcadiaTioOcbMetadata(..)
  , CArcadiaTioOcbColumnArray(..)
  , CArcadiaTioOcbColumnBatch(..)
  , CArcadiaTioOcbOpenOptions(..)
  , CArcadiaTioOcbOrderingKey(..)
  , CArcadiaTioOcbPredicateValue(..)
  , CArcadiaTioOcbPrimitiveValues(..)
  , CArcadiaTioOcbReadAttribution(..)
  , CArcadiaTioOcbReadOutcome(..)
  , CArcadiaTioOcbReadReport(..)
  , CArcadiaTioOcbReadRequest(..)
  , CArcadiaTioOcbRowGroupSummary(..)
  , CArcadiaTioOcbRowGroupSummaries(..)
  , CArcadiaTioOcbRowGroupPredicate(..)
  , CArcadiaTioOcbValidityBitmap(..)
  , COcbFile
  , COcbReadPlan
  , NativeLibrary
  , capiOcbClose
  , capiOcbDictionaryValues
  , capiOcbDictionaryValuesFree
  , capiOcbLastErrorCause
  , capiOcbLastErrorKind
  , capiOcbColumnArrayFixedBinaryWidth
  , capiOcbPlanRead
  , capiOcbMetadata
  , capiOcbMetadataFree
  , capiOcbOpen
  , capiOcbOpenWithOptions
  , capiOcbReaderClone
  , capiOcbReadAttributionFree
  , capiOcbReadAttributionInit
  , capiOcbReadBatches
  , capiOcbReadBatchesWithAttribution
  , capiOcbReadOutcomeFree
  , capiOcbReadOutcomeInit
  , capiOcbReadBatchesFromPlan
  , capiOcbReadPlanFree
  , capiOcbReadPlanProjectedColumnIds
  , capiOcbReadPlanReport
  , capiOcbReadPlanRowGroupIds
  , capiOcbReadPlanRowGroupSummaries
  , capiOcbReadReportFree
  , capiOcbReadReportInit
  , capiOcbReadRequestInit
  , capiOcbRowGroupSummaries
  , capiOcbRowGroupSummariesFree
  , capiOcbRowGroupSummariesInit
  , emptyCArcadiaTioOcbDictionaryValues
  , emptyCArcadiaTioOcbMetadata
  , emptyCArcadiaTioOcbOpenOptions
  , emptyCArcadiaTioOcbPredicateValue
  , emptyCArcadiaTioOcbReadRequest
  , emptyCArcadiaTioOcbRowGroupPredicate
  , lastError
  , okStatus
  )

-- | Selected-snapshot OCB file handle. Reopen the path to observe later appends.
data OcbFile = OcbFile
  { ocbNative :: NativeLibrary
  , ocbHandle :: ForeignPtr COcbFile
  }

-- | Native open validation depth.
data OcbOpenValidation
  = OcbOpenValidationMetadataGraph
  | OcbOpenValidationFullPayload
  | OcbOpenValidationUnknown Int
  deriving (Eq, Show)

-- | OCB open options copied to the native ABI for a single open call.
newtype OcbOpenOptions = OcbOpenOptions
  { ocbOpenValidation :: OcbOpenValidation
  }
  deriving (Eq, Show)

defaultOcbOpenOptions :: OcbOpenOptions
defaultOcbOpenOptions = OcbOpenOptions OcbOpenValidationMetadataGraph

data OcbErrorKind
  = OcbErrorKindNone
  | OcbErrorKindInvalidInput
  | OcbErrorKindUnsupportedFormat
  | OcbErrorKindCorruptFile
  | OcbErrorKindLockUnavailable
  | OcbErrorKindIo
  | OcbErrorKindUnknown Int
  deriving (Eq, Show)

data OcbFailureCause
  = OcbFailureCauseNone
  | OcbFailureCauseInvalidInput
  | OcbFailureCauseUnsupportedFormat
  | OcbFailureCauseCorruptFile
  | OcbFailureCauseLockUnavailable
  | OcbFailureCauseUnknown Int
  deriving (Eq, Show)

data OcbPhysicalType
  = OcbPhysicalI32
  | OcbPhysicalI64
  | OcbPhysicalF32
  | OcbPhysicalF64
  | OcbPhysicalFixedBinary
  | OcbPhysicalUnknown Int
  deriving (Eq, Show)

data OcbLogicalKind
  = OcbLogicalPlain
  | OcbLogicalTimestampNanosLike
  | OcbLogicalScaledInteger
  | OcbLogicalDictionaryCode
  | OcbLogicalEnumCode
  | OcbLogicalOpaqueKey
  | OcbLogicalUnknown Int
  deriving (Eq, Show)

data OcbDictionaryValueKind
  = OcbDictionaryUtf8
  | OcbDictionaryBytes
  | OcbDictionaryFixedBytes
  | OcbDictionaryEnumLabels
  | OcbDictionaryValueUnknown Int
  deriving (Eq, Show)

data OcbOrderingDirection
  = OcbOrderingAscending
  | OcbOrderingDescending
  | OcbOrderingDirectionUnknown Int
  deriving (Eq, Show)

data OcbNullOrder
  = OcbNullsFirst
  | OcbNullsLast
  | OcbNoNulls
  | OcbNullOrderUnknown Int
  deriving (Eq, Show)

-- | Stable column descriptor copied from native-owned metadata.
data OcbColumnDescriptor = OcbColumnDescriptor
  { ocbColumnId :: Word32
  , ocbColumnName :: String
  , ocbColumnPhysicalType :: OcbPhysicalType
  , ocbColumnLogicalKind :: OcbLogicalKind
  , ocbColumnDictionaryId :: Maybe Word32
  , ocbColumnScale :: Int32
  , ocbColumnNullable :: Bool
  }
  deriving (Eq, Show)

-- | Stable dictionary descriptor copied from native-owned metadata.
data OcbDictionaryDescriptor = OcbDictionaryDescriptor
  { ocbDictionaryId :: Word32
  , ocbDictionaryName :: String
  , ocbDictionaryCodePhysicalType :: OcbPhysicalType
  , ocbDictionaryValueKind :: OcbDictionaryValueKind
  , ocbDictionaryEntryCount :: Word32
  }
  deriving (Eq, Show)

-- | Stable ordering key copied from native-owned metadata.
data OcbOrderingKey = OcbOrderingKey
  { ocbOrderingColumnId :: Word32
  , ocbOrderingColumnName :: String
  , ocbOrderingDirection :: OcbOrderingDirection
  , ocbOrderingNullOrder :: OcbNullOrder
  }
  deriving (Eq, Show)

-- | Selected-snapshot OCB metadata copied into Haskell-owned values.
data OcbMetadata = OcbMetadata
  { ocbFormatName :: String
  , ocbAppendable :: Bool
  , ocbRootGeneration :: Word64
  , ocbPreviousRootGeneration :: Maybe Word64
  , ocbRowCount :: Word64
  , ocbRowGroupCount :: Word32
  , ocbColumnChunkCount :: Word32
  , ocbColumns :: [OcbColumnDescriptor]
  , ocbDictionaries :: [OcbDictionaryDescriptor]
  , ocbOrderingKeys :: [OcbOrderingKey]
  }
  deriving (Eq, Show)

-- | Dictionary values copied from native-owned buffers.
data OcbDictionaryValues = OcbDictionaryValues
  { ocbDictionaryValuesId :: Word32
  , ocbDictionaryValuesName :: String
  , ocbDictionaryValuesKind :: OcbDictionaryValueKind
  , ocbDictionaryValuesFixedWidth :: Word32
  , ocbDictionaryStringValues :: [String]
  , ocbDictionaryByteValues :: [[Word8]]
  }
  deriving (Eq, Show)


data OcbProjection
  = OcbProjectionAll
  | OcbProjectionNames [String]
  deriving (Eq, Show)

data OcbPredicateValue
  = OcbPredicateI32 Int32
  | OcbPredicateI64 Int64
  | OcbPredicateF32 Float
  | OcbPredicateF64 Double
  | OcbPredicateUnknown OcbPhysicalType
  deriving (Eq, Show)

data OcbRowGroupPredicate = OcbRowGroupPredicate
  { ocbPredicateColumn :: String
  , ocbPredicateLower :: Maybe OcbPredicateValue
  , ocbPredicateUpper :: Maybe OcbPredicateValue
  }
  deriving (Eq, Show)

data OcbReadRequest = OcbReadRequest
  { ocbReadProjection :: OcbProjection
  , ocbReadPredicates :: [OcbRowGroupPredicate]
  , ocbReadMaxThreads :: Int
  , ocbReadValidateChecksums :: Bool
  , ocbReadDecodeDictionaries :: Bool
  }
  deriving (Eq, Show)

defaultOcbReadRequest :: OcbReadRequest
defaultOcbReadRequest =
  OcbReadRequest
    { ocbReadProjection = OcbProjectionAll
    , ocbReadPredicates = []
    , ocbReadMaxThreads = 1
    , ocbReadValidateChecksums = True
    , ocbReadDecodeDictionaries = False
    }

data OcbReadReport = OcbReadReport
  { ocbReadRequestedThreads :: Int
  , ocbReadEffectiveThreads :: Int
  , ocbReadSelectedRowGroups :: Int
  , ocbReadPrunedRowGroups :: Int
  , ocbReadSelectedColumnChunks :: Int
  , ocbReadFallbackReason :: Maybe String
  }
  deriving (Eq, Show)

data OcbReadAttribution = OcbReadAttribution
  { ocbAttributionPlanNs :: Word64
  , ocbAttributionExecuteWallNs :: Word64
  , ocbAttributionRowGroupReadNs :: Word64
  , ocbAttributionReadIoNs :: Word64
  , ocbAttributionChecksumNs :: Word64
  , ocbAttributionDecompressionNs :: Word64
  , ocbAttributionPrimitiveDecodeNs :: Word64
  , ocbAttributionNativeToCCopyNs :: Maybe Word64
  , ocbAttributionWrapperCopyNs :: Maybe Word64
  , ocbAttributionBytesRead :: Word64
  , ocbAttributionCompressedBytes :: Word64
  , ocbAttributionUncompressedBytes :: Word64
  , ocbAttributionRequestedThreads :: Int
  , ocbAttributionEffectiveThreads :: Int
  , ocbAttributionSelectedRowGroups :: Int
  , ocbAttributionPrunedRowGroups :: Int
  , ocbAttributionSelectedColumnChunks :: Int
  , ocbAttributionFallbackReason :: Maybe String
  }
  deriving (Eq, Show)

data OcbPrimitiveValues
  = OcbValuesI32 [Int32]
  | OcbValuesI64 [Int64]
  | OcbValuesF32 [Float]
  | OcbValuesF64 [Double]
  | OcbValuesFixedBinary Word32 [Word8]
  | OcbValuesUnknown OcbPhysicalType Word64
  deriving (Eq, Show)

data OcbValidityBitmap = OcbValidityBitmap
  { ocbValidityBytes :: [Word8]
  , ocbValidityRowCount :: Word64
  }
  deriving (Eq, Show)

data OcbColumnArray = OcbColumnArray
  { ocbArrayColumnId :: Word32
  , ocbArrayName :: String
  , ocbArrayPhysicalType :: OcbPhysicalType
  , ocbArrayLogicalKind :: OcbLogicalKind
  , ocbArrayDictionaryId :: Maybe Word32
  , ocbArrayValues :: OcbPrimitiveValues
  , ocbArrayValidity :: Maybe OcbValidityBitmap
  }
  deriving (Eq, Show)

data OcbColumnBatch = OcbColumnBatch
  { ocbBatchRowGroupId :: Word32
  , ocbBatchBaseRow :: Word64
  , ocbBatchRowCount :: Word64
  , ocbBatchColumns :: [OcbColumnArray]
  }
  deriving (Eq, Show)

data OcbReadOutcome = OcbReadOutcome
  { ocbOutcomeBatches :: [OcbColumnBatch]
  , ocbOutcomeReport :: OcbReadReport
  }
  deriving (Eq, Show)

data OcbReadWithAttribution = OcbReadWithAttribution
  { ocbAttributedOutcome :: OcbReadOutcome
  , ocbReadAttribution :: OcbReadAttribution
  }
  deriving (Eq, Show)


-- | Owned OCB read plan handle. Close explicitly or allow the finalizer to free it.
data OcbReadPlan = OcbReadPlan
  { ocbReadPlanNative :: NativeLibrary
  , ocbReadPlanHandle :: ForeignPtr COcbReadPlan
  }

data OcbBodyKind
  = OcbBodyUnknown
  | OcbBodyRoot
  | OcbBodySchema
  | OcbBodyDictionaryIndex
  | OcbBodyDictionaryValues
  | OcbBodyRowGroupIndex
  | OcbBodyOrderingProof
  | OcbBodyColumnChunk
  | OcbBodyStringTable
  | OcbBodyDebugJsonMetadata
  | OcbBodyValidityBitmap
  | OcbBodyKeyTuple
  | OcbBodyRowGroupIndexDelta
  | OcbBodyKindUnknown Int
  deriving (Eq, Show)

data OcbChecksumKind
  = OcbChecksumNone
  | OcbChecksumCrc32c
  | OcbChecksumKindUnknown Int
  deriving (Eq, Show)

data OcbChunkSummaryCodec
  = OcbChunkSummaryCodecNone
  | OcbChunkSummaryCodecZstd
  | OcbChunkSummaryCodecUnknown Int
  deriving (Eq, Show)

data OcbBodyRefSummary = OcbBodyRefSummary
  { ocbBodyRefOffset :: Word64
  , ocbBodyRefLength :: Word64
  , ocbBodyRefKind :: OcbBodyKind
  , ocbBodyRefFlags :: Word16
  , ocbBodyRefChecksumKind :: OcbChecksumKind
  , ocbBodyRefChecksum :: Word32
  }
  deriving (Eq, Show)

data OcbColumnChunkSummary = OcbColumnChunkSummary
  { ocbChunkRowGroupId :: Word32
  , ocbChunkColumnId :: Word32
  , ocbChunkColumnName :: String
  , ocbChunkPhysicalType :: OcbPhysicalType
  , ocbChunkLogicalKind :: OcbLogicalKind
  , ocbChunkFixedBinaryWidth :: Word32
  , ocbChunkCodec :: OcbChunkSummaryCodec
  , ocbChunkRowCount :: Word64
  , ocbChunkCompressedBytes :: Word64
  , ocbChunkUncompressedBytes :: Word64
  , ocbChunkValueRef :: OcbBodyRefSummary
  , ocbChunkValidityRef :: Maybe OcbBodyRefSummary
  }
  deriving (Eq, Show)

data OcbColumnStatsSummary = OcbColumnStatsSummary
  { ocbStatsRowGroupId :: Word32
  , ocbStatsColumnId :: Word32
  , ocbStatsColumnName :: String
  , ocbStatsPhysicalType :: OcbPhysicalType
  , ocbStatsNullCount :: Word32
  , ocbStatsMin :: OcbPredicateValue
  , ocbStatsMax :: OcbPredicateValue
  }
  deriving (Eq, Show)

data OcbRowGroupSummary = OcbRowGroupSummary
  { ocbSummaryRowGroupId :: Word32
  , ocbSummaryBaseRow :: Word64
  , ocbSummaryRowCount :: Word64
  , ocbSummaryFirstKeyTupleRef :: Maybe OcbBodyRefSummary
  , ocbSummaryLastKeyTupleRef :: Maybe OcbBodyRefSummary
  , ocbSummaryChunks :: [OcbColumnChunkSummary]
  , ocbSummaryStats :: [OcbColumnStatsSummary]
  }
  deriving (Eq, Show)

newtype OcbRowGroupSummaries = OcbRowGroupSummaries
  { ocbRowGroupSummaries :: [OcbRowGroupSummary]
  }
  deriving (Eq, Show)

-- | Open an OCB selected-snapshot handle through the C ABI.
open :: NativeLibrary -> FilePath -> IO (Result OcbFile)
open native path
  | '\0' `elem` path = pure (Left (invalidArgument "path contains an interior NUL byte"))
  | otherwise = withCString path $ \cPath -> do
      handle <- capiOcbOpen native cPath
      if handle == nullPtr
        then Left <$> lastError native
        else Right <$> wrapOcb native handle

-- | Open an OCB selected-snapshot handle with validation options.
openWithOptions :: NativeLibrary -> FilePath -> OcbOpenOptions -> IO (Result OcbFile)
openWithOptions native path options
  | '\0' `elem` path = pure (Left (invalidArgument "path contains an interior NUL byte"))
  | otherwise =
      withCString path $ \cPath ->
        alloca $ \optionsPtr -> do
          poke optionsPtr (toCOpenOptions options)
          handle <- capiOcbOpenWithOptions native cPath optionsPtr
          if handle == nullPtr
            then Left <$> lastError native
            else Right <$> wrapOcb native handle

-- | Clone an OCB reader handle. The clone owns an independent native handle.
clone :: OcbFile -> IO (Result OcbFile)
clone OcbFile{ocbNative, ocbHandle} =
  withForeignPtr ocbHandle $ \handle ->
    alloca $ \outPtr -> do
      poke outPtr nullPtr
      status <- capiOcbReaderClone ocbNative handle outPtr
      if status == okStatus
        then do
          cloned <- peek outPtr
          if cloned == nullPtr
            then pure (Left (invalidArgument "OCB reader clone returned a null handle"))
            else Right <$> wrapOcb ocbNative cloned
        else Left <$> lastError ocbNative

wrapOcb :: NativeLibrary -> Ptr COcbFile -> IO OcbFile
wrapOcb native handle = do
  fp <- FC.newForeignPtr handle (capiOcbClose native handle)
  pure OcbFile{ocbNative = native, ocbHandle = fp}

-- | Eagerly close an OCB handle. Do not use the value after closing it.
close :: OcbFile -> IO ()
close OcbFile{ocbHandle} = finalizeForeignPtr ocbHandle

lastErrorKind :: NativeLibrary -> IO OcbErrorKind
lastErrorKind native = fromOcbErrorKind <$> capiOcbLastErrorKind native

lastErrorCause :: NativeLibrary -> IO OcbFailureCause
lastErrorCause native = fromOcbFailureCause <$> capiOcbLastErrorCause native

-- | Read selected-snapshot metadata and copy it into Haskell-owned values.
metadata :: OcbFile -> IO (Result OcbMetadata)
metadata OcbFile{ocbNative, ocbHandle} =
  withForeignPtr ocbHandle $ \handle ->
    alloca $ \outPtr -> do
      poke outPtr emptyCArcadiaTioOcbMetadata
      status <- capiOcbMetadata ocbNative handle outPtr
      if status == okStatus
        then (peek outPtr >>= copyOcbMetadata) `finally` capiOcbMetadataFree ocbNative outPtr
        else do
          err <- lastError ocbNative
          capiOcbMetadataFree ocbNative outPtr
          pure (Left err)

-- | Read dictionary values by dictionary id and copy native-owned data.
dictionaryValues :: OcbFile -> Word32 -> IO (Result OcbDictionaryValues)
dictionaryValues OcbFile{ocbNative, ocbHandle} dictionaryId =
  withForeignPtr ocbHandle $ \handle ->
    alloca $ \outPtr -> do
      poke outPtr emptyCArcadiaTioOcbDictionaryValues
      status <- capiOcbDictionaryValues ocbNative handle dictionaryId outPtr
      if status == okStatus
        then (peek outPtr >>= copyOcbDictionaryValues) `finally` capiOcbDictionaryValuesFree ocbNative outPtr
        else do
          err <- lastError ocbNative
          capiOcbDictionaryValuesFree ocbNative outPtr
          pure (Left err)


-- | Read projected/pruned row-group batches and copy native-owned buffers.
readBatches :: OcbFile -> OcbReadRequest -> IO (Result OcbReadOutcome)
readBatches file@OcbFile{ocbNative} request =
  case validateOcbReadRequest request of
    Just err -> pure (Left err)
    Nothing ->
      withOcbReadRequest ocbNative request $ \requestPtr ->
        withReadOutcome file $ \handle outcomePtr -> do
          status <- capiOcbReadBatches ocbNative handle requestPtr outcomePtr
          if status == okStatus
            then peek outcomePtr >>= copyOcbReadOutcome ocbNative
            else Left <$> lastError ocbNative

-- | Read batches with diagnostic attribution counters/timings copied safely.
readBatchesWithAttribution :: OcbFile -> OcbReadRequest -> IO (Result OcbReadWithAttribution)
readBatchesWithAttribution file@OcbFile{ocbNative} request =
  case validateOcbReadRequest request of
    Just err -> pure (Left err)
    Nothing ->
      withOcbReadRequest ocbNative request $ \requestPtr ->
        withReadOutcome file $ \handle outcomePtr ->
          alloca $ \attributionPtr -> do
            capiOcbReadAttributionInit ocbNative attributionPtr
            status <- capiOcbReadBatchesWithAttribution ocbNative handle requestPtr outcomePtr attributionPtr
            if status == okStatus
              then do
                outcomeResult <- peek outcomePtr >>= copyOcbReadOutcome ocbNative
                attribution <- peek attributionPtr >>= copyOcbReadAttribution
                capiOcbReadAttributionFree ocbNative attributionPtr
                pure $ OcbReadWithAttribution <$> outcomeResult <*> Right attribution
              else do
                err <- lastError ocbNative
                capiOcbReadAttributionFree ocbNative attributionPtr
                pure (Left err)

-- | Build an owned read plan for later inspection or execution.
planRead :: OcbFile -> OcbReadRequest -> IO (Result OcbReadPlan)
planRead OcbFile{ocbNative, ocbHandle} request =
  case validateOcbReadRequest request of
    Just err -> pure (Left err)
    Nothing ->
      withOcbReadRequest ocbNative request $ \requestPtr ->
        withForeignPtr ocbHandle $ \handle ->
          alloca $ \outPlanPtr -> do
            poke outPlanPtr nullPtr
            status <- capiOcbPlanRead ocbNative handle requestPtr outPlanPtr
            if status == okStatus
              then do
                planPtr <- peek outPlanPtr
                if planPtr == nullPtr
                  then pure (Left (invalidArgument "OCB plan_read returned a null plan"))
                  else do
                    fp <- FC.newForeignPtr planPtr (capiOcbReadPlanFree ocbNative planPtr)
                    pure (Right OcbReadPlan{ocbReadPlanNative = ocbNative, ocbReadPlanHandle = fp})
              else Left <$> lastError ocbNative

-- | Eagerly free an OCB read plan. Do not use it after closing.
closeReadPlan :: OcbReadPlan -> IO ()
closeReadPlan OcbReadPlan{ocbReadPlanHandle} = finalizeForeignPtr ocbReadPlanHandle

-- | Copy the diagnostic report for a read plan.
readPlanReport :: OcbReadPlan -> IO (Result OcbReadReport)
readPlanReport OcbReadPlan{ocbReadPlanNative, ocbReadPlanHandle} =
  withForeignPtr ocbReadPlanHandle $ \plan ->
    alloca $ \reportPtr -> do
      capiOcbReadReportInit ocbReadPlanNative reportPtr
      status <- capiOcbReadPlanReport ocbReadPlanNative plan reportPtr
      if status == okStatus
        then (Right <$> (peek reportPtr >>= copyOcbReadReport)) `finally` capiOcbReadReportFree ocbReadPlanNative reportPtr
        else do
          err <- lastError ocbReadPlanNative
          capiOcbReadReportFree ocbReadPlanNative reportPtr
          pure (Left err)

readPlanProjectedColumnIds :: OcbReadPlan -> IO (Result [Word32])
readPlanProjectedColumnIds = readPlanIds capiOcbReadPlanProjectedColumnIds

readPlanRowGroupIds :: OcbReadPlan -> IO (Result [Word32])
readPlanRowGroupIds = readPlanIds capiOcbReadPlanRowGroupIds

readPlanIds :: (NativeLibrary -> Ptr COcbReadPlan -> Ptr Word32 -> CSize -> Ptr CSize -> IO CInt) -> OcbReadPlan -> IO (Result [Word32])
readPlanIds selector OcbReadPlan{ocbReadPlanNative, ocbReadPlanHandle} =
  withForeignPtr ocbReadPlanHandle $ \plan ->
    alloca $ \requiredPtr -> do
      poke requiredPtr 0
      status <- selector ocbReadPlanNative plan nullPtr 0 requiredPtr
      if status /= okStatus
        then Left <$> lastError ocbReadPlanNative
        else do
          required <- peek requiredPtr
          if required == 0
            then pure (Right [])
            else allocaArray (fromIntegral required) $ \idsPtr -> do
              status2 <- selector ocbReadPlanNative plan idsPtr required requiredPtr
              if status2 == okStatus
                then Right <$> peekArray (fromIntegral required) idsPtr
                else Left <$> lastError ocbReadPlanNative

-- | Execute all planned row groups when the explicit subset is empty.
readBatchesFromPlan :: OcbFile -> OcbReadPlan -> [Word32] -> IO (Result OcbReadOutcome)
readBatchesFromPlan file@OcbFile{ocbNative} OcbReadPlan{ocbReadPlanHandle} rowGroupIds =
  withForeignPtr ocbReadPlanHandle $ \plan ->
    withPlanIds rowGroupIds $ \idsPtr idsLen ->
      withReadOutcome file $ \handle outcomePtr -> do
        status <- capiOcbReadBatchesFromPlan ocbNative handle plan idsPtr idsLen outcomePtr
        if status == okStatus
          then peek outcomePtr >>= copyOcbReadOutcome ocbNative
          else Left <$> lastError ocbNative

withPlanIds :: [Word32] -> (Ptr Word32 -> CSize -> IO a) -> IO a
withPlanIds [] action = action nullPtr 0
withPlanIds ids action = withArray ids $ \idsPtr -> action idsPtr (fromIntegral (length ids))

rowGroupSummaries :: OcbFile -> IO (Result OcbRowGroupSummaries)
rowGroupSummaries OcbFile{ocbNative, ocbHandle} =
  withForeignPtr ocbHandle $ \handle ->
    withOcbRowGroupSummaries ocbNative $ \summariesPtr -> do
      status <- capiOcbRowGroupSummaries ocbNative handle summariesPtr
      if status == okStatus
        then peek summariesPtr >>= copyOcbRowGroupSummaries
        else Left <$> lastError ocbNative

readPlanRowGroupSummaries :: OcbFile -> OcbReadPlan -> IO (Result OcbRowGroupSummaries)
readPlanRowGroupSummaries OcbFile{ocbNative, ocbHandle} OcbReadPlan{ocbReadPlanHandle} =
  withForeignPtr ocbHandle $ \handle ->
    withForeignPtr ocbReadPlanHandle $ \plan ->
      withOcbRowGroupSummaries ocbNative $ \summariesPtr -> do
        status <- capiOcbReadPlanRowGroupSummaries ocbNative handle plan summariesPtr
        if status == okStatus
          then peek summariesPtr >>= copyOcbRowGroupSummaries
          else Left <$> lastError ocbNative

withOcbRowGroupSummaries :: NativeLibrary -> (Ptr CArcadiaTioOcbRowGroupSummaries -> IO (Result a)) -> IO (Result a)
withOcbRowGroupSummaries native action =
  alloca $ \summariesPtr -> do
    capiOcbRowGroupSummariesInit native summariesPtr
    action summariesPtr `finally` capiOcbRowGroupSummariesFree native summariesPtr

withReadOutcome :: OcbFile -> (Ptr COcbFile -> Ptr CArcadiaTioOcbReadOutcome -> IO (Result a)) -> IO (Result a)
withReadOutcome OcbFile{ocbNative, ocbHandle} action =
  withForeignPtr ocbHandle $ \handle ->
    alloca $ \outcomePtr -> do
      capiOcbReadOutcomeInit ocbNative outcomePtr
      action handle outcomePtr `finally` capiOcbReadOutcomeFree ocbNative outcomePtr

validateOcbReadRequest :: OcbReadRequest -> Maybe TioError
validateOcbReadRequest request
  | ocbReadMaxThreads request < 0 = Just (invalidArgument "OCB read max_threads must be non-negative")
  | otherwise = Nothing

withOcbReadRequest :: NativeLibrary -> OcbReadRequest -> (Ptr CArcadiaTioOcbReadRequest -> IO a) -> IO a
withOcbReadRequest native request action =
  withProjection (ocbReadProjection request) $ \projectionKind namesPtr namesLen ->
    withPredicates (ocbReadPredicates request) $ \predicatesPtr predicatesLen ->
      alloca $ \requestPtr -> do
        capiOcbReadRequestInit native requestPtr
        poke requestPtr
          emptyCArcadiaTioOcbReadRequest
            { cOcbReadRequestProjectionKind = projectionKind
            , cOcbReadRequestColumnNames = namesPtr
            , cOcbReadRequestColumnNamesLen = namesLen
            , cOcbReadRequestPredicates = predicatesPtr
            , cOcbReadRequestPredicatesLen = predicatesLen
            , cOcbReadRequestMaxThreads = fromIntegral (ocbReadMaxThreads request)
            , cOcbReadRequestValidateChecksums = boolByte (ocbReadValidateChecksums request)
            , cOcbReadRequestDecodeDictionaries = boolByte (ocbReadDecodeDictionaries request)
            }
        action requestPtr

withProjection :: OcbProjection -> (CInt -> Ptr CString -> CSize -> IO a) -> IO a
withProjection OcbProjectionAll action = action 0 nullPtr 0
withProjection (OcbProjectionNames names) action = withCStringArray names (action 1)

withCStringArray :: [String] -> (Ptr CString -> CSize -> IO a) -> IO a
withCStringArray [] action = action nullPtr 0
withCStringArray values action = go values []
  where
    go [] acc = withArray (reverse acc) $ \ptr -> action ptr (fromIntegral (length acc))
    go (value:rest) acc = withCString value $ \cValue -> go rest (cValue : acc)

withPredicates :: [OcbRowGroupPredicate] -> (Ptr CArcadiaTioOcbRowGroupPredicate -> CSize -> IO a) -> IO a
withPredicates [] action = action nullPtr 0
withPredicates predicates action = go predicates []
  where
    go [] acc = withArray (reverse acc) $ \ptr -> action ptr (fromIntegral (length acc))
    go (predicate:rest) acc =
      withCString (ocbPredicateColumn predicate) $ \columnPtr ->
        go rest (toCPredicate columnPtr predicate : acc)

toCPredicate :: CString -> OcbRowGroupPredicate -> CArcadiaTioOcbRowGroupPredicate
toCPredicate columnPtr OcbRowGroupPredicate{ocbPredicateLower, ocbPredicateUpper} =
  emptyCArcadiaTioOcbRowGroupPredicate
    { cOcbRowGroupPredicateColumn = columnPtr
    , cOcbRowGroupPredicateHasLower = maybe 0 (const 1) ocbPredicateLower
    , cOcbRowGroupPredicateLower = maybe emptyCArcadiaTioOcbPredicateValue toCPredicateValue ocbPredicateLower
    , cOcbRowGroupPredicateHasUpper = maybe 0 (const 1) ocbPredicateUpper
    , cOcbRowGroupPredicateUpper = maybe emptyCArcadiaTioOcbPredicateValue toCPredicateValue ocbPredicateUpper
    }

toCPredicateValue :: OcbPredicateValue -> CArcadiaTioOcbPredicateValue
toCPredicateValue value = case value of
  OcbPredicateI32 v -> emptyCArcadiaTioOcbPredicateValue{cOcbPredicateValuePhysicalType = 0, cOcbPredicateValueI32 = v}
  OcbPredicateI64 v -> emptyCArcadiaTioOcbPredicateValue{cOcbPredicateValuePhysicalType = 1, cOcbPredicateValueI64 = v}
  OcbPredicateF32 v -> emptyCArcadiaTioOcbPredicateValue{cOcbPredicateValuePhysicalType = 2, cOcbPredicateValueF32 = CFloat v}
  OcbPredicateF64 v -> emptyCArcadiaTioOcbPredicateValue{cOcbPredicateValuePhysicalType = 3, cOcbPredicateValueF64 = v}
  OcbPredicateUnknown physical -> emptyCArcadiaTioOcbPredicateValue{cOcbPredicateValuePhysicalType = toOcbPhysicalType physical}


copyOcbRowGroupSummaries :: CArcadiaTioOcbRowGroupSummaries -> IO (Result OcbRowGroupSummaries)
copyOcbRowGroupSummaries raw = do
  rowGroups <- traverse copyOcbRowGroupSummary =<< peekArrayLen (cOcbRowGroupSummariesRowGroups raw) (cOcbRowGroupSummariesRowGroupsLen raw)
  pure (Right (OcbRowGroupSummaries rowGroups))

copyOcbRowGroupSummary :: CArcadiaTioOcbRowGroupSummary -> IO OcbRowGroupSummary
copyOcbRowGroupSummary raw = do
  firstRef <- if cOcbRowGroupSummaryHasFirstKeyTupleRef raw == 0 then pure Nothing else Just <$> copyOcbBodyRefSummary (cOcbRowGroupSummaryFirstKeyTupleRef raw)
  lastRef <- if cOcbRowGroupSummaryHasLastKeyTupleRef raw == 0 then pure Nothing else Just <$> copyOcbBodyRefSummary (cOcbRowGroupSummaryLastKeyTupleRef raw)
  chunks <- traverse copyOcbColumnChunkSummary =<< peekArrayLen (cOcbRowGroupSummaryChunks raw) (cOcbRowGroupSummaryChunksLen raw)
  stats <- traverse copyOcbColumnStatsSummary =<< peekArrayLen (cOcbRowGroupSummaryStats raw) (cOcbRowGroupSummaryStatsLen raw)
  pure
    OcbRowGroupSummary
      { ocbSummaryRowGroupId = cOcbRowGroupSummaryRowGroupId raw
      , ocbSummaryBaseRow = cOcbRowGroupSummaryBaseRow raw
      , ocbSummaryRowCount = cOcbRowGroupSummaryRowCount raw
      , ocbSummaryFirstKeyTupleRef = firstRef
      , ocbSummaryLastKeyTupleRef = lastRef
      , ocbSummaryChunks = chunks
      , ocbSummaryStats = stats
      }

copyOcbColumnChunkSummary :: CArcadiaTioOcbColumnChunkSummary -> IO OcbColumnChunkSummary
copyOcbColumnChunkSummary raw = do
  name <- peekNullableCString (cOcbColumnChunkSummaryColumnName raw)
  valueRef <- copyOcbBodyRefSummary (cOcbColumnChunkSummaryValueRef raw)
  validityRef <- if cOcbColumnChunkSummaryHasValidityRef raw == 0 then pure Nothing else Just <$> copyOcbBodyRefSummary (cOcbColumnChunkSummaryValidityRef raw)
  pure
    OcbColumnChunkSummary
      { ocbChunkRowGroupId = cOcbColumnChunkSummaryRowGroupId raw
      , ocbChunkColumnId = cOcbColumnChunkSummaryColumnId raw
      , ocbChunkColumnName = name
      , ocbChunkPhysicalType = fromOcbPhysicalType (cOcbColumnChunkSummaryPhysicalType raw)
      , ocbChunkLogicalKind = fromOcbLogicalKind (cOcbColumnChunkSummaryLogicalKind raw)
      , ocbChunkFixedBinaryWidth = cOcbColumnChunkSummaryFixedBinaryWidth raw
      , ocbChunkCodec = fromOcbChunkSummaryCodec (cOcbColumnChunkSummaryCodec raw)
      , ocbChunkRowCount = cOcbColumnChunkSummaryRowCount raw
      , ocbChunkCompressedBytes = cOcbColumnChunkSummaryCompressedBytes raw
      , ocbChunkUncompressedBytes = cOcbColumnChunkSummaryUncompressedBytes raw
      , ocbChunkValueRef = valueRef
      , ocbChunkValidityRef = validityRef
      }

copyOcbColumnStatsSummary :: CArcadiaTioOcbColumnStatsSummary -> IO OcbColumnStatsSummary
copyOcbColumnStatsSummary raw = do
  name <- peekNullableCString (cOcbColumnStatsSummaryColumnName raw)
  pure
    OcbColumnStatsSummary
      { ocbStatsRowGroupId = cOcbColumnStatsSummaryRowGroupId raw
      , ocbStatsColumnId = cOcbColumnStatsSummaryColumnId raw
      , ocbStatsColumnName = name
      , ocbStatsPhysicalType = fromOcbPhysicalType (cOcbColumnStatsSummaryPhysicalType raw)
      , ocbStatsNullCount = cOcbColumnStatsSummaryNullCount raw
      , ocbStatsMin = fromCPredicateValue (cOcbColumnStatsSummaryMin raw)
      , ocbStatsMax = fromCPredicateValue (cOcbColumnStatsSummaryMax raw)
      }

copyOcbBodyRefSummary :: CArcadiaTioOcbBodyRefSummary -> IO OcbBodyRefSummary
copyOcbBodyRefSummary raw =
  pure
    OcbBodyRefSummary
      { ocbBodyRefOffset = cOcbBodyRefSummaryOffset raw
      , ocbBodyRefLength = cOcbBodyRefSummaryLength raw
      , ocbBodyRefKind = fromOcbBodyKind (cOcbBodyRefSummaryKind raw)
      , ocbBodyRefFlags = cOcbBodyRefSummaryFlags raw
      , ocbBodyRefChecksumKind = fromOcbChecksumKind (cOcbBodyRefSummaryChecksumKind raw)
      , ocbBodyRefChecksum = cOcbBodyRefSummaryChecksum raw
      }

fromCPredicateValue :: CArcadiaTioOcbPredicateValue -> OcbPredicateValue
fromCPredicateValue raw = case fromOcbPhysicalType (cOcbPredicateValuePhysicalType raw) of
  OcbPhysicalI32 -> OcbPredicateI32 (cOcbPredicateValueI32 raw)
  OcbPhysicalI64 -> OcbPredicateI64 (cOcbPredicateValueI64 raw)
  OcbPhysicalF32 -> OcbPredicateF32 (realToFrac (cOcbPredicateValueF32 raw))
  OcbPhysicalF64 -> OcbPredicateF64 (cOcbPredicateValueF64 raw)
  other -> OcbPredicateUnknown other

copyOcbReadOutcome :: NativeLibrary -> CArcadiaTioOcbReadOutcome -> IO (Result OcbReadOutcome)
copyOcbReadOutcome native raw = do
  batches <- traverse (copyOcbColumnBatch native) =<< peekArrayLen (cOcbReadOutcomeBatches raw) (cOcbReadOutcomeBatchesLen raw)
  report <- copyOcbReadReport (cOcbReadOutcomeReport raw)
  pure (Right OcbReadOutcome{ocbOutcomeBatches = batches, ocbOutcomeReport = report})

copyOcbColumnBatch :: NativeLibrary -> CArcadiaTioOcbColumnBatch -> IO OcbColumnBatch
copyOcbColumnBatch native raw = do
  columns <- traverse (copyOcbColumnArray native) =<< peekArrayLen (cOcbColumnBatchColumns raw) (cOcbColumnBatchColumnsLen raw)
  pure
    OcbColumnBatch
      { ocbBatchRowGroupId = cOcbColumnBatchRowGroupId raw
      , ocbBatchBaseRow = cOcbColumnBatchBaseRow raw
      , ocbBatchRowCount = cOcbColumnBatchRowCount raw
      , ocbBatchColumns = columns
      }

copyOcbColumnArray :: NativeLibrary -> CArcadiaTioOcbColumnArray -> IO OcbColumnArray
copyOcbColumnArray native raw = do
  name <- peekNullableCString (cOcbColumnArrayName raw)
  values <- copyPrimitiveValues native raw (cOcbColumnArrayValues raw)
  validity <-
    if cOcbColumnArrayHasValidity raw == 0
      then pure Nothing
      else Just <$> copyValidityBitmap (cOcbColumnArrayValidity raw)
  pure
    OcbColumnArray
      { ocbArrayColumnId = cOcbColumnArrayColumnId raw
      , ocbArrayName = name
      , ocbArrayPhysicalType = fromOcbPhysicalType (cOcbColumnArrayPhysicalType raw)
      , ocbArrayLogicalKind = fromOcbLogicalKind (cOcbColumnArrayLogicalKind raw)
      , ocbArrayDictionaryId = if cOcbColumnArrayHasDictionaryId raw == 0 then Nothing else Just (cOcbColumnArrayDictionaryId raw)
      , ocbArrayValues = values
      , ocbArrayValidity = validity
      }

copyPrimitiveValues :: NativeLibrary -> CArcadiaTioOcbColumnArray -> CArcadiaTioOcbPrimitiveValues -> IO OcbPrimitiveValues
copyPrimitiveValues native column values = do
  let len = fromIntegral (cOcbPrimitiveValuesLen values)
      dataPtr = cOcbPrimitiveValuesData values
      physical = fromOcbPhysicalType (cOcbPrimitiveValuesPhysicalType values)
  if dataPtr == nullPtr && len /= (0 :: Int)
    then pure (OcbValuesUnknown physical (fromIntegral len))
    else case physical of
      OcbPhysicalI32 -> OcbValuesI32 <$> peekArray len (castPtr dataPtr)
      OcbPhysicalI64 -> OcbValuesI64 <$> peekArray len (castPtr dataPtr)
      OcbPhysicalF32 -> do
        floats <- peekArray len (castPtr dataPtr) :: IO [CFloat]
        pure (OcbValuesF32 (map realToFrac floats))
      OcbPhysicalF64 -> OcbValuesF64 <$> peekArray len (castPtr dataPtr)
      OcbPhysicalFixedBinary -> do
        width <- withArray [column] $ \columnPtr -> capiOcbColumnArrayFixedBinaryWidth native columnPtr
        bytes <- peekArray (len * fromIntegral width) (castPtr dataPtr)
        pure (OcbValuesFixedBinary width bytes)
      OcbPhysicalUnknown _ -> pure (OcbValuesUnknown physical (fromIntegral len))

copyValidityBitmap :: CArcadiaTioOcbValidityBitmap -> IO OcbValidityBitmap
copyValidityBitmap raw = do
  bytes <- peekArrayLen (cOcbValidityBitmapData raw) (cOcbValidityBitmapLen raw)
  pure OcbValidityBitmap{ocbValidityBytes = bytes, ocbValidityRowCount = cOcbValidityBitmapRowCount raw}

copyOcbReadReport :: CArcadiaTioOcbReadReport -> IO OcbReadReport
copyOcbReadReport raw = do
  fallback <- peekMaybeCString (cOcbReadReportFallbackReason raw)
  pure
    OcbReadReport
      { ocbReadRequestedThreads = fromIntegral (cOcbReadReportRequestedThreads raw)
      , ocbReadEffectiveThreads = fromIntegral (cOcbReadReportEffectiveThreads raw)
      , ocbReadSelectedRowGroups = fromIntegral (cOcbReadReportSelectedRowGroups raw)
      , ocbReadPrunedRowGroups = fromIntegral (cOcbReadReportPrunedRowGroups raw)
      , ocbReadSelectedColumnChunks = fromIntegral (cOcbReadReportSelectedColumnChunks raw)
      , ocbReadFallbackReason = fallback
      }

copyOcbReadAttribution :: CArcadiaTioOcbReadAttribution -> IO OcbReadAttribution
copyOcbReadAttribution raw = do
  fallback <- peekMaybeCString (cOcbReadAttributionFallbackReason raw)
  pure
    OcbReadAttribution
      { ocbAttributionPlanNs = cOcbReadAttributionPlanNs raw
      , ocbAttributionExecuteWallNs = cOcbReadAttributionExecuteWallNs raw
      , ocbAttributionRowGroupReadNs = cOcbReadAttributionRowGroupReadNs raw
      , ocbAttributionReadIoNs = cOcbReadAttributionReadIoNs raw
      , ocbAttributionChecksumNs = cOcbReadAttributionChecksumNs raw
      , ocbAttributionDecompressionNs = cOcbReadAttributionDecompressionNs raw
      , ocbAttributionPrimitiveDecodeNs = cOcbReadAttributionPrimitiveDecodeNs raw
      , ocbAttributionNativeToCCopyNs = if cOcbReadAttributionHasNativeToCCopyNs raw == 0 then Nothing else Just (cOcbReadAttributionNativeToCCopyNs raw)
      , ocbAttributionWrapperCopyNs = if cOcbReadAttributionHasWrapperCopyNs raw == 0 then Nothing else Just (cOcbReadAttributionWrapperCopyNs raw)
      , ocbAttributionBytesRead = cOcbReadAttributionBytesRead raw
      , ocbAttributionCompressedBytes = cOcbReadAttributionCompressedBytes raw
      , ocbAttributionUncompressedBytes = cOcbReadAttributionUncompressedBytes raw
      , ocbAttributionRequestedThreads = fromIntegral (cOcbReadAttributionRequestedThreads raw)
      , ocbAttributionEffectiveThreads = fromIntegral (cOcbReadAttributionEffectiveThreads raw)
      , ocbAttributionSelectedRowGroups = fromIntegral (cOcbReadAttributionSelectedRowGroups raw)
      , ocbAttributionPrunedRowGroups = fromIntegral (cOcbReadAttributionPrunedRowGroups raw)
      , ocbAttributionSelectedColumnChunks = fromIntegral (cOcbReadAttributionSelectedColumnChunks raw)
      , ocbAttributionFallbackReason = fallback
      }

copyOcbMetadata :: CArcadiaTioOcbMetadata -> IO (Result OcbMetadata)
copyOcbMetadata raw@CArcadiaTioOcbMetadata{cOcbMetadataFormatName}
  | cOcbMetadataFormatName == nullPtr = pure (Left (invalidArgument "OCB metadata format_name is null"))
  | otherwise = do
      formatName <- peekCString cOcbMetadataFormatName
      columns <- traverse copyOcbColumnDescriptor =<< peekArrayLen (cOcbMetadataColumns raw) (cOcbMetadataColumnsLen raw)
      dictionaries <- traverse copyOcbDictionaryDescriptor =<< peekArrayLen (cOcbMetadataDictionaries raw) (cOcbMetadataDictionariesLen raw)
      orderingKeys <- traverse copyOcbOrderingKey =<< peekArrayLen (cOcbMetadataOrderingKeys raw) (cOcbMetadataOrderingKeysLen raw)
      pure
        ( Right
            OcbMetadata
              { ocbFormatName = formatName
              , ocbAppendable = cOcbMetadataAppendable raw /= 0
              , ocbRootGeneration = cOcbMetadataRootGeneration raw
              , ocbPreviousRootGeneration =
                  if cOcbMetadataHasPreviousRootGeneration raw == 0
                    then Nothing
                    else Just (cOcbMetadataPreviousRootGeneration raw)
              , ocbRowCount = cOcbMetadataRowCount raw
              , ocbRowGroupCount = cOcbMetadataRowGroupCount raw
              , ocbColumnChunkCount = cOcbMetadataColumnChunkCount raw
              , ocbColumns = columns
              , ocbDictionaries = dictionaries
              , ocbOrderingKeys = orderingKeys
              }
        )

copyOcbColumnDescriptor :: CArcadiaTioOcbColumnDescriptor -> IO OcbColumnDescriptor
copyOcbColumnDescriptor raw = do
  name <- peekNullableCString (cOcbColumnDescriptorName raw)
  pure
    OcbColumnDescriptor
      { ocbColumnId = cOcbColumnDescriptorId raw
      , ocbColumnName = name
      , ocbColumnPhysicalType = fromOcbPhysicalType (cOcbColumnDescriptorPhysicalType raw)
      , ocbColumnLogicalKind = fromOcbLogicalKind (cOcbColumnDescriptorLogicalKind raw)
      , ocbColumnDictionaryId =
          if cOcbColumnDescriptorHasDictionaryId raw == 0
            then Nothing
            else Just (cOcbColumnDescriptorDictionaryId raw)
      , ocbColumnScale = cOcbColumnDescriptorScale raw
      , ocbColumnNullable = cOcbColumnDescriptorNullable raw /= 0
      }

copyOcbDictionaryDescriptor :: CArcadiaTioOcbDictionaryDescriptor -> IO OcbDictionaryDescriptor
copyOcbDictionaryDescriptor raw = do
  name <- peekNullableCString (cOcbDictionaryDescriptorName raw)
  pure
    OcbDictionaryDescriptor
      { ocbDictionaryId = cOcbDictionaryDescriptorDictionaryId raw
      , ocbDictionaryName = name
      , ocbDictionaryCodePhysicalType = fromOcbPhysicalType (cOcbDictionaryDescriptorCodePhysicalType raw)
      , ocbDictionaryValueKind = fromOcbDictionaryValueKind (cOcbDictionaryDescriptorValueKind raw)
      , ocbDictionaryEntryCount = cOcbDictionaryDescriptorEntryCount raw
      }

copyOcbOrderingKey :: CArcadiaTioOcbOrderingKey -> IO OcbOrderingKey
copyOcbOrderingKey raw = do
  name <- peekNullableCString (cOcbOrderingKeyColumnName raw)
  pure
    OcbOrderingKey
      { ocbOrderingColumnId = cOcbOrderingKeyColumnId raw
      , ocbOrderingColumnName = name
      , ocbOrderingDirection = fromOcbOrderingDirection (cOcbOrderingKeyDirection raw)
      , ocbOrderingNullOrder = fromOcbNullOrder (cOcbOrderingKeyNullOrder raw)
      }

copyOcbDictionaryValues :: CArcadiaTioOcbDictionaryValues -> IO (Result OcbDictionaryValues)
copyOcbDictionaryValues raw = do
  name <- peekNullableCString (cOcbDictionaryValuesName raw)
  stringValues <- traverse peekNullableCString =<< peekArrayLen (cOcbDictionaryValuesStringValues raw) (cOcbDictionaryValuesStringValuesLen raw)
  byteSlices <- peekArrayLen (cOcbDictionaryValuesByteValues raw) (cOcbDictionaryValuesByteValuesLen raw)
  byteValues <- traverse copyByteSlice byteSlices
  pure
    ( Right
        OcbDictionaryValues
          { ocbDictionaryValuesId = cOcbDictionaryValuesDictionaryId raw
          , ocbDictionaryValuesName = name
          , ocbDictionaryValuesKind = fromOcbDictionaryValueKind (cOcbDictionaryValuesValueKind raw)
          , ocbDictionaryValuesFixedWidth = cOcbDictionaryValuesFixedWidth raw
          , ocbDictionaryStringValues = stringValues
          , ocbDictionaryByteValues = byteValues
          }
    )

copyByteSlice :: CArcadiaTioOcbByteSlice -> IO [Word8]
copyByteSlice CArcadiaTioOcbByteSlice{cOcbByteSliceData, cOcbByteSliceLen}
  | cOcbByteSliceData == nullPtr && cOcbByteSliceLen /= 0 = pure []
  | otherwise = peekArray (fromIntegral cOcbByteSliceLen) cOcbByteSliceData

peekArrayLen :: Storable a => Ptr a -> CSize -> IO [a]
peekArrayLen ptr (CSize len)
  | ptr == nullPtr || len == 0 = pure []
  | otherwise = peekArray (fromIntegral len) ptr

peekNullableCString :: CString -> IO String
peekNullableCString ptr
  | ptr == nullPtr = pure ""
  | otherwise = peekCString ptr

peekMaybeCString :: CString -> IO (Maybe String)
peekMaybeCString ptr
  | ptr == nullPtr = pure Nothing
  | otherwise = do
      value <- peekCString ptr
      pure (if null value then Nothing else Just value)

boolByte :: Bool -> Word8
boolByte True = 1
boolByte False = 0

toCOpenOptions :: OcbOpenOptions -> CArcadiaTioOcbOpenOptions
toCOpenOptions OcbOpenOptions{ocbOpenValidation} =
  emptyCArcadiaTioOcbOpenOptions
    { cOcbOpenOptionsValidation = toOcbOpenValidation ocbOpenValidation
    }

toOcbOpenValidation :: OcbOpenValidation -> CInt
toOcbOpenValidation = \case
  OcbOpenValidationMetadataGraph -> 0
  OcbOpenValidationFullPayload -> 1
  OcbOpenValidationUnknown raw -> fromIntegral raw

fromOcbErrorKind :: CInt -> OcbErrorKind
fromOcbErrorKind (CInt raw) = case raw of
  0 -> OcbErrorKindNone
  1 -> OcbErrorKindInvalidInput
  2 -> OcbErrorKindUnsupportedFormat
  3 -> OcbErrorKindCorruptFile
  4 -> OcbErrorKindLockUnavailable
  5 -> OcbErrorKindIo
  _ -> OcbErrorKindUnknown (fromIntegral raw)

fromOcbFailureCause :: CInt -> OcbFailureCause
fromOcbFailureCause (CInt raw) = case raw of
  0 -> OcbFailureCauseNone
  1 -> OcbFailureCauseInvalidInput
  2 -> OcbFailureCauseUnsupportedFormat
  3 -> OcbFailureCauseCorruptFile
  4 -> OcbFailureCauseLockUnavailable
  _ -> OcbFailureCauseUnknown (fromIntegral raw)

fromOcbPhysicalType :: CInt -> OcbPhysicalType
fromOcbPhysicalType (CInt raw) = case raw of
  0 -> OcbPhysicalI32
  1 -> OcbPhysicalI64
  2 -> OcbPhysicalF32
  3 -> OcbPhysicalF64
  4 -> OcbPhysicalFixedBinary
  _ -> OcbPhysicalUnknown (fromIntegral raw)

toOcbPhysicalType :: OcbPhysicalType -> CInt
toOcbPhysicalType = \case
  OcbPhysicalI32 -> 0
  OcbPhysicalI64 -> 1
  OcbPhysicalF32 -> 2
  OcbPhysicalF64 -> 3
  OcbPhysicalFixedBinary -> 4
  OcbPhysicalUnknown raw -> fromIntegral raw

fromOcbBodyKind :: CInt -> OcbBodyKind
fromOcbBodyKind (CInt raw) = case raw of
  0 -> OcbBodyUnknown
  1 -> OcbBodyRoot
  2 -> OcbBodySchema
  3 -> OcbBodyDictionaryIndex
  4 -> OcbBodyDictionaryValues
  5 -> OcbBodyRowGroupIndex
  6 -> OcbBodyOrderingProof
  7 -> OcbBodyColumnChunk
  8 -> OcbBodyStringTable
  9 -> OcbBodyDebugJsonMetadata
  10 -> OcbBodyValidityBitmap
  11 -> OcbBodyKeyTuple
  12 -> OcbBodyRowGroupIndexDelta
  _ -> OcbBodyKindUnknown (fromIntegral raw)

fromOcbChecksumKind :: CInt -> OcbChecksumKind
fromOcbChecksumKind (CInt raw) = case raw of
  0 -> OcbChecksumNone
  1 -> OcbChecksumCrc32c
  _ -> OcbChecksumKindUnknown (fromIntegral raw)

fromOcbChunkSummaryCodec :: CInt -> OcbChunkSummaryCodec
fromOcbChunkSummaryCodec (CInt raw) = case raw of
  0 -> OcbChunkSummaryCodecNone
  1 -> OcbChunkSummaryCodecZstd
  _ -> OcbChunkSummaryCodecUnknown (fromIntegral raw)

fromOcbLogicalKind :: CInt -> OcbLogicalKind
fromOcbLogicalKind (CInt raw) = case raw of
  0 -> OcbLogicalPlain
  1 -> OcbLogicalTimestampNanosLike
  2 -> OcbLogicalScaledInteger
  3 -> OcbLogicalDictionaryCode
  4 -> OcbLogicalEnumCode
  5 -> OcbLogicalOpaqueKey
  _ -> OcbLogicalUnknown (fromIntegral raw)

fromOcbDictionaryValueKind :: CInt -> OcbDictionaryValueKind
fromOcbDictionaryValueKind (CInt raw) = case raw of
  0 -> OcbDictionaryUtf8
  1 -> OcbDictionaryBytes
  2 -> OcbDictionaryFixedBytes
  3 -> OcbDictionaryEnumLabels
  _ -> OcbDictionaryValueUnknown (fromIntegral raw)

fromOcbOrderingDirection :: CInt -> OcbOrderingDirection
fromOcbOrderingDirection (CInt raw) = case raw of
  0 -> OcbOrderingAscending
  1 -> OcbOrderingDescending
  _ -> OcbOrderingDirectionUnknown (fromIntegral raw)

fromOcbNullOrder :: CInt -> OcbNullOrder
fromOcbNullOrder (CInt raw) = case raw of
  0 -> OcbNullsFirst
  1 -> OcbNullsLast
  2 -> OcbNoNulls
  _ -> OcbNullOrderUnknown (fromIntegral raw)
