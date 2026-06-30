{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Arcadia.Tio.TensorFile
  ( TensorFile
  , AppendRange(..)
  , ArrowCData
  , arrowArrayLength
  , arrowSchemaFormat
  , releaseArrowCData
  , createStreaming
  , createStreamingWithMetadata
  , createStreamingWithCoordinates
  , createRandomAccessWithCoordinates
  , createInferredWithCoordinates
  , createWithPolicyWithCoordinates
  , createStreamingWithCoordinatesV2
  , createRandomAccessWithCoordinatesV2
  , createInferredWithCoordinatesV2
  , createWithPolicyWithCoordinatesV2
  , createStreamingWithUniverse
  , createRandomAccessWithUniverse
  , createWithPolicyWithUniverse
  , coordinateMeta
  , loadCoordinateMeta
  , coordinateMetaV2
  , loadCoordinateMetaV2
  , readAxisCoordinates
  , coordinateIndexI32
  , coordinateIndexI64
  , coordinateRangeI32
  , coordinateRangeI64
  , readAxisCoordinatesV2
  , coordinateDictionaryV2
  , coordinateLookupV2
  , coordinateLookupRangeV2
  , createRandomAccess
  , createRandomAccessWithMetadata
  , createInferred
  , createInferredWithMetadata
  , createWithPolicy
  , createWithPolicyWithMetadata
  , open
  , close
  , rank
  , dtype
  , appendAxis
  , dimLens
  , chunkPlan
  , filePath
  , loadMeta
  , setDimName
  , setSymbols
  , setChannels
  , setUserKv
  , setCompressionConfig
  , getCompressionConfig
  , headCommit
  , listCommits
  , pop
  , popBatched
  , revertCommit
  , readAtCommit
  , readAtCommitSelected
  , readAtCommitDense
  , readAtCommitDenseSelected
  , readWithOptions
  , readWithOptionsDense
  , readWithShapePolicy
  , readWithShapePolicyDense
  , readWithOptionsAttributed
  , readWithOptionsDenseAttributed
  , readAtCommitWithOptions
  , readAtCommitWithOptionsDense
  , readAtCommitWithShapePolicy
  , readAtCommitWithShapePolicyDense
  , readIndex
  , getIndexCheckpointEveryCommits
  , setIndexCheckpointEveryCommits
  , analyzeCompaction
  , analyzeV4Compaction
  , analyzeV4CompactionPrecise
  , compactTo
  , compactV4RetainedHistoryTo
  , compactV4RetainedHistoryToPrecise
  , reformTo
  , reformToEx
  , maybeCompact
  , getAutoCompactionConfig
  , setAutoCompactionConfig
  , compactionState
  , maybeCompactAuto
  , v4Diagnostics
  , v4DiagnosticsPrecise
  , analyzeSparseAppend
  , analyzeSparseAppendF32
  , analyzeSparseAppendF64
  , analyzeSparseAppendI32
  , analyzeSparseAppendI64
  , appendSparse
  , appendSparseF32
  , appendSparseF64
  , appendSparseI32
  , appendSparseI64
  , appendDense
  , appendDenseF32
  , appendDenseF64
  , appendDenseI32
  , appendDenseI64
  , appendDenseWithCoordinatesV2
  , appendDenseF32WithCoordinatesV2
  , appendDenseF64WithCoordinatesV2
  , appendDenseI32WithCoordinatesV2
  , appendDenseI64WithCoordinatesV2
  , appendDenseWithUniverse
  , appendDenseF32WithUniverse
  , appendDenseF64WithUniverse
  , appendDenseI32WithUniverse
  , appendDenseI64WithUniverse
  , readAll
  , readAllAs
  , readAllF32
  , readAllF64
  , readAllI32
  , readAllI64
  , readAllDense
  , readAllDenseAs
  , readAllDenseF32
  , readAllDenseF64
  , readAllDenseI32
  , readAllDenseI64
  , readAxisRange
  , readAxisTake
  , readAxisOne
  , readEntryRange
  , takeEntries
  , readScalar
  , rewriteF32
  , rewriteF64
  , rewriteSliceF32
  , rewriteSliceF64
  , clearBlocks
  , readValuesArrow
  ) where

import Control.Exception (finally)
import Data.Bits ((.|.), shiftL)
import Data.Int (Int32, Int64)
import Data.Proxy (Proxy(..))
import Data.Word (Word8, Word32, Word64)
import Foreign.C.String (CString, peekCString, withCString)
import Foreign.C.Types (CInt(..), CSize(..))
import Foreign.ForeignPtr (ForeignPtr, finalizeForeignPtr, withForeignPtr)
import qualified Foreign.Concurrent as FC
import Foreign.Marshal.Alloc (alloca, free, malloc)
import Foreign.Marshal.Array (allocaArray, copyArray, peekArray, withArray)
import Foreign.Ptr (Ptr, castPtr, nullFunPtr, nullPtr)
import Foreign.Storable (Storable, peek, poke)
import qualified Data.Vector.Storable as VS
import qualified Data.Vector.Storable.Mutable as VSM

import Arcadia.Tio.Error (Result, TioError(..), invalidArgument)
import Arcadia.Tio.Internal.CApi
  ( CArcadiaTioAxisLabel(..)
  , CArcadiaTioAxisCoordinateInput(..)
  , CArcadiaTioAxisCoordinateMeta(..)
  , CArcadiaTioAxisCoordinateMetaV2(..)
  , CArcadiaTioAxisCoordinateInputV2(..)
  , CArcadiaTioCoordinateFixedTextLayoutV2(..)
  , CArcadiaTioCoordinateDictionaryEntryV2(..)
  , CArcadiaTioCoordinateDictionarySummaryV2(..)
  , CArcadiaTioCoordinateDictionaryV2(..)
  , CArcadiaTioCoordinateExternalBindingV2(..)
  , CArcadiaTioCoordinateIndexSourceBindingV2(..)
  , CArcadiaTioCoordinateIndexSummaryV2(..)
  , CArcadiaTioCoordinateValueSliceV2(..)
  , CArcadiaTioCoordinateLookupKeyV2(..)
  , CArcadiaTioCoordinateLookupResultV2(..)
  , CArcadiaTioAppendCoordinateEntryV2(..)
  , CArcadiaTioAppendCoordinateBatchV2(..)
  , CArcadiaTioCoordinateV2Options(..)
  , emptyCArcadiaTioCoordinateFixedTextLayoutV2
  , emptyCArcadiaTioCoordinateV2Options
  , emptyCArcadiaTioCoordinateLookupKeyV2
  , emptyCArcadiaTioCoordinateLookupResultV2
  , CArcadiaTioCommitInfo(..)
  , CArcadiaTioCommitList(..)
  , CArcadiaTioAutoCompactionConfig(..)
  , CArcadiaTioChunkKey(..)
  , CArcadiaTioChunkPlan(..)
  , CArcadiaTioCompactionMode(..)
  , CArcadiaTioCompactionState(..)
  , CArcadiaTioCompactionStats(..)
  , CArcadiaTioV4CurrentHeadBytes(..)
  , CArcadiaTioV4AuditBytes(..)
  , CArcadiaTioV4PayloadReuseBytes(..)
  , CArcadiaTioV4SupersededBytes(..)
  , CArcadiaTioV4PreciseAccountingOptions(..)
  , CArcadiaTioV4OmittedPreciseAccountingField(..)
  , CArcadiaTioV4PreciseAccountingBytes(..)
  , CArcadiaTioV4DiagnosticsReport(..)
  , CArcadiaTioV4DiagnosticsPreciseReport(..)
  , CArcadiaTioV4CompactionAnalysisReport(..)
  , CArcadiaTioV4CompactionAnalysisPreciseReport(..)
  , CArcadiaTioV4RetainedHistoryCompactionOptions(..)
  , CArcadiaTioV4RetainedHistoryCompactionReport(..)
  , CArcadiaTioV4RetainedHistoryCompactionPreciseReport(..)
  , CArcadiaTioReformOptions(..)
  , CArcadiaTioReformReport(..)
  , CArcadiaTioCompressionConfig(..)
  , CArcadiaTioDimSpec(..)
  , CArcadiaTioEntrySelector(..)
  , CArcadiaTioExplicitUniverseAxisTarget(..)
  , CArcadiaTioAxisIdentityInput(..)
  , CArcadiaTioUniverseBindingInput(..)
  , CArcadiaTioSlotUniverseBindingInput(..)
  , CArcadiaTioUniverseRemapInput(..)
  , CArcadiaTioSlotUniverseRemapInput(..)
  , CArcadiaTioCreateWithUniverseOptions(..)
  , CArcadiaTioAppendWithUniverseOptions(..)
  , CArcadiaTioExplicitExtentAxisTarget(..)
  , CArcadiaTioReadShapePolicyOptions(..)
  , CArcadiaTioReadWithShapePolicyOptions(..)
  , CArcadiaTioReadWithOptionsOptions(..)
  , CArcadiaTioReadExecutionReport(..)
  , CArcadiaTioQueryTraceContext(..)
  , CArcadiaTioQueryTraceJson(..)
  , CArcadiaTioReadIndexItem(..)
  , CArcadiaTioReadIndexReport(..)
  , CArcadiaTioHistoricalReadExecutionReport(..)
  , CArcadiaTioFileMeta(..)
  , CArcadiaTioMask(..)
  , CArcadiaTioScalar(..)
  , CArcadiaTioSparseAppendAnalysis(..)
  , CArcadiaTioSparseRuleV2(..)
  , CArcadiaTioSparseValuePredicateV2(..)
  , CArcadiaTioTensor(..)
  , CArcadiaTioUserKv(..)
  , CArrowArray(..)
  , CArrowSchema(..)
  , CHandle
  , NativeLibrary
  , capiAnalyzeCompaction
  , capiAnalyzeSparseAppendF32V2
  , capiAnalyzeSparseAppendF64V2
  , capiAnalyzeSparseAppendI32V2
  , capiAnalyzeSparseAppendI64V2
  , capiAppendAxis
  , capiAppendF32WithRange
  , capiAppendF64WithRange
  , compressionConfigStructSize
  , capiAppendI32WithRange
  , capiAppendI64WithRange
  , capiAppendSparseF32WithRangeV2
  , capiAppendSparseF64WithRangeV2
  , capiAppendSparseI32WithRangeV2
  , capiAppendSparseI64WithRangeV2
  , capiClose
  , capiChunkPlan
  , capiChunkPlanFree
  , capiCommitListFree
  , capiCompactTo
  , capiCompactionState
  , capiCreateRandomAccess
  , capiCreateRandomAccessWithUniverse
  , capiCreateStreamingWithUniverse
  , capiCreateWithPolicyWithUniverse
  , capiCreateInferred
  , capiCreateInferredEx
  , capiCreateRandomAccessEx
  , capiCreateStreaming
  , capiCreateStreamingEx
  , capiCreateWithPolicy
  , capiCreateWithPolicyEx
  , capiCreateWithPolicyWithCoordinates
  , capiCreateInferredWithCoordinates
  , capiCreateRandomAccessWithCoordinates
  , capiCreateStreamingWithCoordinates
  , capiCreateWithPolicyWithCoordinatesV2
  , capiCreateInferredWithCoordinatesV2
  , capiCreateRandomAccessWithCoordinatesV2
  , capiCreateStreamingWithCoordinatesV2
  , capiCoordinateMeta
  , capiLoadCoordinateMeta
  , capiAxisCoordinateMetaFree
  , capiCoordinateMetaV2
  , capiLoadCoordinateMetaV2
  , capiAxisCoordinateMetaV2Free
  , capiReadAxisCoordinates
  , capiCoordinateIndexI32
  , capiCoordinateIndexI64
  , capiCoordinateRangeI32
  , capiCoordinateRangeI64
  , capiReadAxisCoordinatesV2
  , capiCoordinateValueSliceV2Free
  , capiCoordinateDictionaryV2
  , capiCoordinateDictionaryV2Free
  , capiCoordinateLookupV2
  , capiCoordinateLookupRangeV2
  , capiCoordinateLookupResultV2Free
  , capiAppendF32WithCoordinatesV2
  , capiAppendF64WithCoordinatesV2
  , capiAppendI32WithCoordinatesV2
  , capiAppendI64WithCoordinatesV2
  , capiAppendF32WithUniverse
  , capiAppendF64WithUniverse
  , capiAppendI32WithUniverse
  , capiAppendI64WithUniverse
  , capiDType
  , capiDimLens
  , capiFileMetaFree
  , capiGetAutoCompactionConfig
  , capiGetCompressionConfig
  , capiHeadCommit
  , capiListCommits
  , capiLoadMeta
  , capiMaskFree
  , capiMaybeCompact
  , capiMaybeCompactAuto
  , capiV4Diagnostics
  , capiV4DiagnosticsReportFree
  , capiV4DiagnosticsPrecise
  , capiV4DiagnosticsPreciseReportFree
  , capiAnalyzeV4Compaction
  , capiV4CompactionAnalysisReportFree
  , capiAnalyzeV4CompactionPrecise
  , capiV4CompactionAnalysisPreciseReportFree
  , capiCompactV4RetainedHistoryTo
  , capiV4RetainedHistoryCompactionReportFree
  , capiCompactV4RetainedHistoryToPrecise
  , capiV4RetainedHistoryCompactionPreciseReportFree
  , capiReformTo
  , capiReformToEx
  , capiReformReportFree
  , capiOpen
  , capiPop
  , capiPopBatched
  , capiRank
  , capiReadAll
  , capiReadAllDense
  , capiReadAtCommit
  , capiReadAtCommitDense
  , capiReadAtCommitWithOptions
  , capiReadAtCommitWithOptionsDense
  , capiReadAtCommitWithShapePolicy
  , capiReadAtCommitWithShapePolicyDense
  , capiReadExecutionReportFree
  , capiQueryTraceJsonFree
  , capiHistoricalReadExecutionReportFree
  , capiReadIndexReportFree
  , capiReadIndex
  , capiReadWithOptions
  , capiReadWithOptionsDense
  , capiReadWithOptionsAttributed
  , capiReadWithOptionsDenseAttributed
  , capiReadWithShapePolicy
  , capiReadWithShapePolicyDense
  , capiRewriteF32
  , capiRewriteF64
  , capiRewriteSliceF32
  , capiRewriteSliceF64
  , capiClearBlocks
  , capiReadValuesArrow
  , capiGetIndexCheckpointEveryCommits
  , capiSetIndexCheckpointEveryCommits
  , capiReadAxisOne
  , capiReadAxisRange
  , capiReadAxisTake
  , capiReadEntryRange
  , capiReadScalar
  , capiRevertCommit
  , capiSetAutoCompactionConfig
  , capiSetChannels
  , capiSetDimName
  , capiSetSymbols
  , capiSetCompressionConfig
  , capiSetUserKv
  , capiSparseAppendAnalysisFree
  , capiPath
  , capiStringFree
  , capiTakeEntries
  , capiTensorFree
  , emptyCArcadiaTioChunkPlan
  , emptyCArcadiaTioCommitList
  , emptyCArcadiaTioFileMeta
  , emptyCArcadiaTioMask
  , emptyCArcadiaTioReadExecutionReport
  , emptyCArcadiaTioQueryTraceJson
  , emptyCArcadiaTioReadIndexReport
  , emptyCArcadiaTioHistoricalReadExecutionReport
  , emptyCArcadiaTioV4PreciseAccountingOptions
  , emptyCArcadiaTioV4DiagnosticsReport
  , emptyCArcadiaTioV4DiagnosticsPreciseReport
  , emptyCArcadiaTioV4CompactionAnalysisReport
  , emptyCArcadiaTioV4CompactionAnalysisPreciseReport
  , emptyCArcadiaTioV4RetainedHistoryCompactionOptions
  , emptyCArcadiaTioV4RetainedHistoryCompactionReport
  , emptyCArcadiaTioV4RetainedHistoryCompactionPreciseReport
  , emptyCArcadiaTioReformOptions
  , emptyCArcadiaTioReformReport
  , emptyCArcadiaTioReadShapePolicyOptions
  , emptyCArrowArray
  , emptyCArrowSchema
  , arrowArrayRelease
  , arrowSchemaRelease
  , emptyCArcadiaTioSparseAppendAnalysis
  , emptyCArcadiaTioTensor
  , lastError
  , okStatus
  , sparseRuleV2StructSize
  )
import Arcadia.Tio.Tensor
  ( DenseRead(..)
  , SomeDenseRead(..)
  , SomeTensor(..)
  , Tensor(..)
  , TioElement(..)
  , tensorElementCount
  , tensorFromVector
  )
import Arcadia.Tio.Types
  ( AxisLabel(..)
  , CreateMetadata(..)
  , DType(..)
  , DimMeta(..)
  , EntrySelector(..)
  , TioUuid(..)
  , AxisIdentityInput(..)
  , UniverseBindingInput(..)
  , SlotUniverseBindingInput(..)
  , UniverseRemapInput(..)
  , SlotUniverseRemapInput(..)
  , CreateWithUniverseOptions(..)
  , AppendWithUniverseOptions(..)
  , ExplicitUniverseAxisTarget(..)
  , ExplicitExtentAxisTarget(..)
  , ReadExecutionMode(..)
  , ReadOptions(..)
  , ReadShapePolicy(..)
  , ReadExecutionReport(..)
  , QueryTraceContext(..)
  , QueryTraceJson(..)
  , ReadIndexItem(..)
  , ReadIndexLoweringKind(..)
  , ReadIndexReport(..)
  , HistoricalQuerySourceKind(..)
  , HistoricalReadExecutionReport(..)
  , DimSpec(..)
  , CompressionCodec(..)
  , AutoCompactionConfig(..)
  , CompressionConfig(..)
  , CompressionMode(..)
  , ChunkPlan(..)
  , CommitInfo(..)
  , CompactionMode(..)
  , CompactionState(..)
  , CreateInferredOptions(..)
  , CreatePolicyOptions(..)
  , CompactionStats(..)
  , V4ReportStatus(..)
  , V4CurrentHeadBytes(..)
  , V4AuditBytes(..)
  , V4PayloadReuseBytes(..)
  , V4SupersededBytes(..)
  , V4PreciseAccountingField(..)
  , V4PreciseAccountingOptions(..)
  , V4OmittedPreciseAccountingField(..)
  , V4PreciseAccountingBytes(..)
  , V4DiagnosticsReport(..)
  , V4DiagnosticsPreciseReport(..)
  , V4CompactionAnalysisPolicy(..)
  , V4CompactionAnalysisReport(..)
  , V4CompactionAnalysisPreciseReport(..)
  , V4RetainedHistoryPolicy(..)
  , V4RetainedHistoryCompactionOptions(..)
  , V4RetainedHistoryCompactionReport(..)
  , V4RetainedHistoryCompactionPreciseReport(..)
  , ReformTargetLayout(..)
  , ReformOptions(..)
  , ReformReport(..)
  , FileMeta(..)
  , FilePopulation(..)
  , MetadataStability(..)
  , OpenPattern(..)
  , ScalarValue(..)
  , SparseAppendAnalysis(..)
  , SparseAppendOutcome(..)
  , SparseAppendReason(..)
  , SparseDetector(..)
  , SparseFallbackPolicy(..)
  , SparseRule(..)
  , SparseValuePredicate(..)
  , StorageAccessKind(..)
  , StorageProfile(..)
  , UserKv(..)
  , axisKindFromRaw
  , axisKindToRaw
  , dtypeFromRaw
  , dtypeSizeBytes
  , dtypeToRaw
  , AxisCoordinateInputV2(..)
  , AxisCoordinateMeta(..)
  , AxisCoordinateMetaV2(..)
  , CoordinateDType(..)
  , CoordinateDictionaryEntryV2(..)
  , CoordinateDictionarySummaryV2(..)
  , CoordinateDictionaryV2(..)
  , CoordinateExternalBindingV2(..)
  , CoordinateIndexSourceBindingV2(..)
  , CoordinateIndexSummaryV2(..)
  , CoordinateV2Options(..)
  , CoordinateV2Values(..)
  , AppendCoordinateEntryV2(..)
  , CoordinateKeyDomainV2(..)
  , CoordinateLookupKeyV2(..)
  , CoordinateLookupResultV2(..)
  , CoordinateLookupResultStatusV2(..)
  , CoordinateValueDomainV2(..)
  , CoordinateValueSliceV2(..)
  , coordinateAvailabilityV2FromRaw
  , coordinateCodeDTypeV2FromRaw
  , coordinateDTypeFromRaw
  , coordinateDTypeToRaw
  , coordinateEncodingFromRaw
  , coordinateEncodingToRaw
  , coordinateKindFromRaw
  , coordinateKindToRaw
  , coordinateIndexFallbackV2FromRaw
  , coordinateIndexKindV2FromRaw
  , coordinateIndexUseV2FromRaw
  , coordinateIndexValidationStatusV2FromRaw
  , coordinateKeyDomainV2FromRaw
  , coordinateKeyDomainV2ToRaw
  , coordinateLookupResultStatusV2FromRaw
  , coordinateMonotonicityFromRaw
  , coordinateMonotonicityToRaw
  , coordinateSortednessFromRaw
  , coordinateSortednessToRaw
  , coordinateStatusCategoryV2FromRaw
  , coordinateStorageKindFromRaw
  , coordinateSourceKindFromRaw
  , coordinateSourceKindV2FromRaw
  , coordinateUniquenessFromRaw
  , coordinateUniquenessToRaw
  , coordinateValidationStatusFromRaw
  , coordinateValueDomainV2FromRaw
  , coordinateValueDomainV2ToRaw
  , headerProfileFromRaw
  )
import qualified Arcadia.Tio.Types as Types

-- | Safe TensorFile handle. The native handle is closed by a finalizer and can
-- also be closed eagerly with 'close'.
data TensorFile = TensorFile
  { tensorFileNative :: NativeLibrary
  , tensorFileHandle :: ForeignPtr CHandle
  }

-- | Half-open append-axis entry range assigned by a successful append.
data AppendRange = AppendRange
  { appendStart :: Word32
  , appendEnd :: Word32
  }
  deriving (Eq, Show)

-- | Owned Arrow C Data export. The release callbacks remain encapsulated and
-- are invoked by 'releaseArrowCData' or by the Haskell finalizer.
data ArrowCData = ArrowCData
  { arrowArrayForeignPtr :: ForeignPtr CArrowArray
  , arrowSchemaForeignPtr :: ForeignPtr CArrowSchema
  }

-- | Copy the exported ArrowArray length field for lightweight smoke tests.
arrowArrayLength :: ArrowCData -> IO Int64
arrowArrayLength ArrowCData{arrowArrayForeignPtr} = withForeignPtr arrowArrayForeignPtr $ \ptr -> cArrowArrayLength <$> peek ptr

-- | Copy the exported ArrowSchema format string, when present.
arrowSchemaFormat :: ArrowCData -> IO (Maybe String)
arrowSchemaFormat ArrowCData{arrowSchemaForeignPtr} = withForeignPtr arrowSchemaForeignPtr $ \ptr -> peek ptr >>= peekOptionalCString . cArrowSchemaFormat

-- | Explicitly release Arrow C Data callbacks. Safe to call more than once.
releaseArrowCData :: ArrowCData -> IO ()
releaseArrowCData ArrowCData{arrowArrayForeignPtr, arrowSchemaForeignPtr} = do
  finalizeForeignPtr arrowArrayForeignPtr
  finalizeForeignPtr arrowSchemaForeignPtr

-- | Create a streaming '.tio' file through the C ABI.
createStreaming :: NativeLibrary -> FilePath -> DType -> [DimSpec] -> Int -> IO (Result TensorFile)
createStreaming = createWith capiCreateStreaming

-- | Create a streaming '.tio' file with optional dimension names, symbols,
-- channels, and user key/value metadata.
createStreamingWithMetadata :: NativeLibrary -> FilePath -> DType -> [DimSpec] -> Int -> CreateMetadata -> IO (Result TensorFile)
createStreamingWithMetadata = createWithMetadata capiCreateStreamingEx

-- | Create a streaming file with additive universe-aware axis identities.
createStreamingWithUniverse :: NativeLibrary -> FilePath -> DType -> [DimSpec] -> Int -> CreateMetadata -> CreateWithUniverseOptions -> IO (Result TensorFile)
createStreamingWithUniverse = createWithUniverse capiCreateStreamingWithUniverse

-- | Create a random-access file with additive universe-aware axis identities.
createRandomAccessWithUniverse :: NativeLibrary -> FilePath -> DType -> [DimSpec] -> Int -> CreateMetadata -> CreateWithUniverseOptions -> IO (Result TensorFile)
createRandomAccessWithUniverse = createWithUniverse capiCreateRandomAccessWithUniverse

-- | Create a policy-selected file with additive universe-aware axis identities.
createWithPolicyWithUniverse :: NativeLibrary -> FilePath -> DType -> [DimSpec] -> Int -> CreateMetadata -> CreatePolicyOptions -> CreateWithUniverseOptions -> IO (Result TensorFile)
createWithPolicyWithUniverse native path payloadDType dims appendDim metadata policyOptions universeOptions = do
  case validateCreateInputs path dims appendDim *> validateCreateMetadata (length dims) metadata *> validatePolicyOptions policyOptions *> validateCreateUniverseOptions (length dims) universeOptions of
    Left err -> pure (Left err)
    Right () -> withPath path $ \cPath ->
      withCreateCoordinateCommon dims appendDim metadata $ \kindsPtr lensPtr rankLen appendLen dimNamesPtr dimNamesLen symbolsPtr symbolsLen channelsPtr channelsLen keysPtr valuesPtr userKvLen ->
        withCSizeArray (map (CSize . fromIntegral) (policyChunkAxes policyOptions)) $ \chunkAxesPtr chunkAxesLen ->
          withWord32Array (policyTypicalQuerySizes policyOptions) $ \typicalPtr typicalLen ->
            withCreateUniverseOptions universeOptions $ \optionsPtr -> do
              handle <- capiCreateWithPolicyWithUniverse native cPath (dtypeToRaw payloadDType) kindsPtr lensPtr rankLen appendLen dimNamesPtr dimNamesLen symbolsPtr symbolsLen channelsPtr channelsLen keysPtr valuesPtr userKvLen chunkAxesPtr chunkAxesLen (storageProfileToRaw (policyStorageProfile policyOptions)) typicalPtr typicalLen optionsPtr
              wrapCreatedHandle native handle

type CreateUniverseInvoker = NativeLibrary -> CString -> CInt -> Ptr CInt -> Ptr Word32 -> CSize -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> Ptr CString -> CSize -> Ptr CArcadiaTioCreateWithUniverseOptions -> IO (Ptr CHandle)

createWithUniverse :: CreateUniverseInvoker -> NativeLibrary -> FilePath -> DType -> [DimSpec] -> Int -> CreateMetadata -> CreateWithUniverseOptions -> IO (Result TensorFile)
createWithUniverse createFn native path payloadDType dims appendDim metadata universeOptions = do
  case validateCreateInputs path dims appendDim *> validateCreateMetadata (length dims) metadata *> validateCreateUniverseOptions (length dims) universeOptions of
    Left err -> pure (Left err)
    Right () -> withPath path $ \cPath ->
      withCreateCoordinateCommon dims appendDim metadata $ \kindsPtr lensPtr rankLen appendLen dimNamesPtr dimNamesLen symbolsPtr symbolsLen channelsPtr channelsLen keysPtr valuesPtr userKvLen ->
        withCreateUniverseOptions universeOptions $ \optionsPtr -> do
          handle <- createFn native cPath (dtypeToRaw payloadDType) kindsPtr lensPtr rankLen appendLen dimNamesPtr dimNamesLen symbolsPtr symbolsLen channelsPtr channelsLen keysPtr valuesPtr userKvLen optionsPtr
          wrapCreatedHandle native handle

-- | Create a streaming file with Coordinate v1 descriptors.
createStreamingWithCoordinates :: NativeLibrary -> FilePath -> DType -> [DimSpec] -> Int -> CreateMetadata -> [AxisCoordinateInputV2] -> IO (Result TensorFile)
createStreamingWithCoordinates = createBasicWithCoordinates capiCreateStreamingWithCoordinates withAxisCoordinateInputArray

-- | Create a random-access file with Coordinate v1 descriptors.
createRandomAccessWithCoordinates :: NativeLibrary -> FilePath -> DType -> [DimSpec] -> Int -> CreateMetadata -> [AxisCoordinateInputV2] -> IO (Result TensorFile)
createRandomAccessWithCoordinates = createBasicWithCoordinates capiCreateRandomAccessWithCoordinates withAxisCoordinateInputArray

-- | Create an inferred-layout file with Coordinate v1 descriptors.
createInferredWithCoordinates :: NativeLibrary -> FilePath -> DType -> [DimSpec] -> Int -> CreateMetadata -> CreateInferredOptions -> [AxisCoordinateInputV2] -> IO (Result TensorFile)
createInferredWithCoordinates native path payloadDType dims appendDim metadata options coordinates =
  createInferredWithCoordinatesImpl capiCreateInferredWithCoordinates withAxisCoordinateInputArray native path payloadDType dims appendDim metadata options coordinates

-- | Create a policy-selected file with Coordinate v1 descriptors.
createWithPolicyWithCoordinates :: NativeLibrary -> FilePath -> DType -> [DimSpec] -> Int -> CreateMetadata -> CreatePolicyOptions -> [AxisCoordinateInputV2] -> IO (Result TensorFile)
createWithPolicyWithCoordinates native path payloadDType dims appendDim metadata options coordinates =
  createPolicyWithCoordinatesImpl capiCreateWithPolicyWithCoordinates withAxisCoordinateInputArray native path payloadDType dims appendDim metadata options coordinates

-- | Create a streaming file with Coordinate v2 descriptors.
createStreamingWithCoordinatesV2 :: NativeLibrary -> FilePath -> DType -> [DimSpec] -> Int -> CreateMetadata -> [AxisCoordinateInputV2] -> CoordinateV2Options -> IO (Result TensorFile)
createStreamingWithCoordinatesV2 = createBasicWithCoordinatesV2 capiCreateStreamingWithCoordinatesV2

-- | Create a random-access file with Coordinate v2 descriptors.
createRandomAccessWithCoordinatesV2 :: NativeLibrary -> FilePath -> DType -> [DimSpec] -> Int -> CreateMetadata -> [AxisCoordinateInputV2] -> CoordinateV2Options -> IO (Result TensorFile)
createRandomAccessWithCoordinatesV2 = createBasicWithCoordinatesV2 capiCreateRandomAccessWithCoordinatesV2

-- | Create an inferred-layout file with Coordinate v2 descriptors.
createInferredWithCoordinatesV2 :: NativeLibrary -> FilePath -> DType -> [DimSpec] -> Int -> CreateMetadata -> CreateInferredOptions -> [AxisCoordinateInputV2] -> CoordinateV2Options -> IO (Result TensorFile)
createInferredWithCoordinatesV2 native path payloadDType dims appendDim metadata options coordinates coordinateOptions =
  createInferredWithCoordinatesV2Impl capiCreateInferredWithCoordinatesV2 native path payloadDType dims appendDim metadata options coordinates coordinateOptions

-- | Create a policy-selected file with Coordinate v2 descriptors.
createWithPolicyWithCoordinatesV2 :: NativeLibrary -> FilePath -> DType -> [DimSpec] -> Int -> CreateMetadata -> CreatePolicyOptions -> [AxisCoordinateInputV2] -> CoordinateV2Options -> IO (Result TensorFile)
createWithPolicyWithCoordinatesV2 native path payloadDType dims appendDim metadata options coordinates coordinateOptions =
  createPolicyWithCoordinatesV2Impl capiCreateWithPolicyWithCoordinatesV2 native path payloadDType dims appendDim metadata options coordinates coordinateOptions

type CreateCoordinatesInvoker c = NativeLibrary -> CString -> CInt -> Ptr CInt -> Ptr Word32 -> CSize -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> Ptr CString -> CSize -> Ptr c -> CSize -> IO (Ptr CHandle)

createBasicWithCoordinates :: CreateCoordinatesInvoker c -> ([AxisCoordinateInputV2] -> (Ptr c -> CSize -> IO (Result TensorFile)) -> IO (Result TensorFile)) -> NativeLibrary -> FilePath -> DType -> [DimSpec] -> Int -> CreateMetadata -> [AxisCoordinateInputV2] -> IO (Result TensorFile)
createBasicWithCoordinates createFn withCoordinates native path payloadDType dims appendDim metadata coordinates = do
  case validateCreateInputs path dims appendDim *> validateCoordinateCreateInputs dims appendDim metadata coordinates of
    Left err -> pure (Left err)
    Right () -> withPath path $ \cPath ->
      withCreateCoordinateCommon dims appendDim metadata $ \kindsPtr lensPtr rankLen appendLen dimNamesPtr dimNamesLen symbolsPtr symbolsLen channelsPtr channelsLen keysPtr valuesPtr userKvLen ->
        withCoordinates coordinates $ \coordinatesPtr coordinatesLen -> do
          handle <- createFn native cPath (dtypeToRaw payloadDType) kindsPtr lensPtr rankLen appendLen dimNamesPtr dimNamesLen symbolsPtr symbolsLen channelsPtr channelsLen keysPtr valuesPtr userKvLen coordinatesPtr coordinatesLen
          wrapCreatedHandle native handle

type CreateCoordinatesV2Invoker = NativeLibrary -> CString -> CInt -> Ptr CInt -> Ptr Word32 -> CSize -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> Ptr CString -> CSize -> Ptr CArcadiaTioAxisCoordinateInputV2 -> CSize -> Ptr CArcadiaTioCoordinateV2Options -> IO (Ptr CHandle)

createBasicWithCoordinatesV2 :: CreateCoordinatesV2Invoker -> NativeLibrary -> FilePath -> DType -> [DimSpec] -> Int -> CreateMetadata -> [AxisCoordinateInputV2] -> CoordinateV2Options -> IO (Result TensorFile)
createBasicWithCoordinatesV2 createFn native path payloadDType dims appendDim metadata coordinates coordinateOptions = do
  case validateCreateInputs path dims appendDim *> validateCoordinateCreateInputs dims appendDim metadata coordinates of
    Left err -> pure (Left err)
    Right () -> withPath path $ \cPath ->
      withCreateCoordinateCommon dims appendDim metadata $ \kindsPtr lensPtr rankLen appendLen dimNamesPtr dimNamesLen symbolsPtr symbolsLen channelsPtr channelsLen keysPtr valuesPtr userKvLen ->
        withAxisCoordinateInputV2Array coordinates $ \coordinatesPtr coordinatesLen ->
          withCoordinateV2Options coordinateOptions $ \optionsPtr -> do
            handle <- createFn native cPath (dtypeToRaw payloadDType) kindsPtr lensPtr rankLen appendLen dimNamesPtr dimNamesLen symbolsPtr symbolsLen channelsPtr channelsLen keysPtr valuesPtr userKvLen coordinatesPtr coordinatesLen optionsPtr
            wrapCreatedHandle native handle

type CreatePolicyCoordinatesInvoker c = NativeLibrary -> CString -> CInt -> Ptr CInt -> Ptr Word32 -> CSize -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> Ptr CString -> CSize -> Ptr CSize -> CSize -> CInt -> Ptr Word32 -> CSize -> Ptr c -> CSize -> IO (Ptr CHandle)

createPolicyWithCoordinatesImpl :: CreatePolicyCoordinatesInvoker c -> ([AxisCoordinateInputV2] -> (Ptr c -> CSize -> IO (Result TensorFile)) -> IO (Result TensorFile)) -> NativeLibrary -> FilePath -> DType -> [DimSpec] -> Int -> CreateMetadata -> CreatePolicyOptions -> [AxisCoordinateInputV2] -> IO (Result TensorFile)
createPolicyWithCoordinatesImpl createFn withCoordinates native path payloadDType dims appendDim metadata options coordinates = do
  case validateCreateInputs path dims appendDim *> validateCoordinateCreateInputs dims appendDim metadata coordinates *> validatePolicyOptions options of
    Left err -> pure (Left err)
    Right () -> withPath path $ \cPath ->
      withCreateCoordinateCommon dims appendDim metadata $ \kindsPtr lensPtr rankLen appendLen dimNamesPtr dimNamesLen symbolsPtr symbolsLen channelsPtr channelsLen keysPtr valuesPtr userKvLen ->
        withCSizeArray (map (CSize . fromIntegral) (policyChunkAxes options)) $ \chunkAxesPtr chunkAxesLen ->
          withWord32Array (policyTypicalQuerySizes options) $ \typicalPtr typicalLen ->
            withCoordinates coordinates $ \coordinatesPtr coordinatesLen -> do
              handle <- createFn native cPath (dtypeToRaw payloadDType) kindsPtr lensPtr rankLen appendLen dimNamesPtr dimNamesLen symbolsPtr symbolsLen channelsPtr channelsLen keysPtr valuesPtr userKvLen chunkAxesPtr chunkAxesLen (storageProfileToRaw (policyStorageProfile options)) typicalPtr typicalLen coordinatesPtr coordinatesLen
              wrapCreatedHandle native handle

type CreatePolicyCoordinatesV2Invoker = NativeLibrary -> CString -> CInt -> Ptr CInt -> Ptr Word32 -> CSize -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> Ptr CString -> CSize -> Ptr CSize -> CSize -> CInt -> Ptr Word32 -> CSize -> Ptr CArcadiaTioAxisCoordinateInputV2 -> CSize -> Ptr CArcadiaTioCoordinateV2Options -> IO (Ptr CHandle)

createPolicyWithCoordinatesV2Impl :: CreatePolicyCoordinatesV2Invoker -> NativeLibrary -> FilePath -> DType -> [DimSpec] -> Int -> CreateMetadata -> CreatePolicyOptions -> [AxisCoordinateInputV2] -> CoordinateV2Options -> IO (Result TensorFile)
createPolicyWithCoordinatesV2Impl createFn native path payloadDType dims appendDim metadata options coordinates coordinateOptions = do
  case validateCreateInputs path dims appendDim *> validateCoordinateCreateInputs dims appendDim metadata coordinates *> validatePolicyOptions options of
    Left err -> pure (Left err)
    Right () -> withPath path $ \cPath ->
      withCreateCoordinateCommon dims appendDim metadata $ \kindsPtr lensPtr rankLen appendLen dimNamesPtr dimNamesLen symbolsPtr symbolsLen channelsPtr channelsLen keysPtr valuesPtr userKvLen ->
        withCSizeArray (map (CSize . fromIntegral) (policyChunkAxes options)) $ \chunkAxesPtr chunkAxesLen ->
          withWord32Array (policyTypicalQuerySizes options) $ \typicalPtr typicalLen ->
            withAxisCoordinateInputV2Array coordinates $ \coordinatesPtr coordinatesLen ->
              withCoordinateV2Options coordinateOptions $ \optionsPtr -> do
                handle <- createFn native cPath (dtypeToRaw payloadDType) kindsPtr lensPtr rankLen appendLen dimNamesPtr dimNamesLen symbolsPtr symbolsLen channelsPtr channelsLen keysPtr valuesPtr userKvLen chunkAxesPtr chunkAxesLen (storageProfileToRaw (policyStorageProfile options)) typicalPtr typicalLen coordinatesPtr coordinatesLen optionsPtr
                wrapCreatedHandle native handle

type CreateInferredCoordinatesInvoker c = NativeLibrary -> CString -> CInt -> Ptr CInt -> Ptr Word32 -> CSize -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> Ptr CString -> CSize -> CInt -> CInt -> CInt -> CInt -> Ptr c -> CSize -> IO (Ptr CHandle)

createInferredWithCoordinatesImpl :: CreateInferredCoordinatesInvoker c -> ([AxisCoordinateInputV2] -> (Ptr c -> CSize -> IO (Result TensorFile)) -> IO (Result TensorFile)) -> NativeLibrary -> FilePath -> DType -> [DimSpec] -> Int -> CreateMetadata -> CreateInferredOptions -> [AxisCoordinateInputV2] -> IO (Result TensorFile)
createInferredWithCoordinatesImpl createFn withCoordinates native path payloadDType dims appendDim metadata options coordinates = do
  case validateCreateInputs path dims appendDim *> validateCoordinateCreateInputs dims appendDim metadata coordinates of
    Left err -> pure (Left err)
    Right () -> withPath path $ \cPath ->
      withCreateCoordinateCommon dims appendDim metadata $ \kindsPtr lensPtr rankLen appendLen dimNamesPtr dimNamesLen symbolsPtr symbolsLen channelsPtr channelsLen keysPtr valuesPtr userKvLen ->
        withCoordinates coordinates $ \coordinatesPtr coordinatesLen -> do
          handle <- createFn native cPath (dtypeToRaw payloadDType) kindsPtr lensPtr rankLen appendLen dimNamesPtr dimNamesLen symbolsPtr symbolsLen channelsPtr channelsLen keysPtr valuesPtr userKvLen (storageAccessToRaw (inferredStorageAccess options)) (openPatternToRaw (inferredOpenPattern options)) (filePopulationToRaw (inferredFilePopulation options)) (metadataStabilityToRaw (inferredMetadataStability options)) coordinatesPtr coordinatesLen
          wrapCreatedHandle native handle

type CreateInferredCoordinatesV2Invoker = NativeLibrary -> CString -> CInt -> Ptr CInt -> Ptr Word32 -> CSize -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> Ptr CString -> CSize -> CInt -> CInt -> CInt -> CInt -> Ptr CArcadiaTioAxisCoordinateInputV2 -> CSize -> Ptr CArcadiaTioCoordinateV2Options -> IO (Ptr CHandle)

createInferredWithCoordinatesV2Impl :: CreateInferredCoordinatesV2Invoker -> NativeLibrary -> FilePath -> DType -> [DimSpec] -> Int -> CreateMetadata -> CreateInferredOptions -> [AxisCoordinateInputV2] -> CoordinateV2Options -> IO (Result TensorFile)
createInferredWithCoordinatesV2Impl createFn native path payloadDType dims appendDim metadata options coordinates coordinateOptions = do
  case validateCreateInputs path dims appendDim *> validateCoordinateCreateInputs dims appendDim metadata coordinates of
    Left err -> pure (Left err)
    Right () -> withPath path $ \cPath ->
      withCreateCoordinateCommon dims appendDim metadata $ \kindsPtr lensPtr rankLen appendLen dimNamesPtr dimNamesLen symbolsPtr symbolsLen channelsPtr channelsLen keysPtr valuesPtr userKvLen ->
        withAxisCoordinateInputV2Array coordinates $ \coordinatesPtr coordinatesLen ->
          withCoordinateV2Options coordinateOptions $ \optionsPtr -> do
            handle <- createFn native cPath (dtypeToRaw payloadDType) kindsPtr lensPtr rankLen appendLen dimNamesPtr dimNamesLen symbolsPtr symbolsLen channelsPtr channelsLen keysPtr valuesPtr userKvLen (storageAccessToRaw (inferredStorageAccess options)) (openPatternToRaw (inferredOpenPattern options)) (filePopulationToRaw (inferredFilePopulation options)) (metadataStabilityToRaw (inferredMetadataStability options)) coordinatesPtr coordinatesLen optionsPtr
            wrapCreatedHandle native handle

withCreateCoordinateCommon :: [DimSpec] -> Int -> CreateMetadata -> (Ptr CInt -> Ptr Word32 -> CSize -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> Ptr CString -> CSize -> IO a) -> IO a
withCreateCoordinateCommon dims appendDim metadata action =
  withArray (map (axisKindToRaw . dimKind) dims) $ \kindsPtr ->
    withArray (map dimLength dims) $ \lensPtr ->
      withOptionalCStringArray (createDimNames metadata) $ \dimNamesPtr dimNamesLen ->
        withCStringArray (createSymbols metadata) $ \symbolsPtr symbolsLen ->
          withCStringArray (createChannels metadata) $ \channelsPtr channelsLen ->
            withUserKvArrays (createUserKv metadata) $ \keysPtr valuesPtr userKvLen ->
              action kindsPtr lensPtr (CSize (fromIntegral (length dims))) (CSize (fromIntegral appendDim)) dimNamesPtr dimNamesLen symbolsPtr symbolsLen channelsPtr channelsLen keysPtr valuesPtr userKvLen

wrapCreatedHandle :: NativeLibrary -> Ptr CHandle -> IO (Result TensorFile)
wrapCreatedHandle native handle =
  if handle == nullPtr
    then Left <$> lastError native
    else Right <$> wrapHandle native handle

validateCoordinateCreateInputs :: [DimSpec] -> Int -> CreateMetadata -> [AxisCoordinateInputV2] -> Result ()
validateCoordinateCreateInputs dims appendDim metadata coordinates = do
  validateCreateMetadata (length dims) metadata
  if hasDuplicateAxes (map axisCoordinateInputV2Axis coordinates)
    then Left (invalidArgument "coordinate axes must be unique")
    else do
      mapM_ (validateRequiredString "coordinate descriptor id" . axisCoordinateInputV2DescriptorId) coordinates
      mapM_ (validateRequiredString "coordinate name" . axisCoordinateInputV2Name) coordinates
      mapM_ validateAxis coordinates
 where
  hasDuplicateAxes [] = False
  hasDuplicateAxes (axis : axes) = axis `elem` axes || hasDuplicateAxes axes
  validateAxis coordinate = do
    let axis = axisCoordinateInputV2Axis coordinate
    if axis < 0 || axis >= length dims
      then Left (invalidArgument "coordinate axis is out of range")
      else
        if axis == appendDim
          then case axisCoordinateInputV2Values coordinate of
            CoordinateV2AppendSequenceValues _ -> Right ()
            _ -> Left (invalidArgument "coordinate append-axis storage is deferred; use append-axis coordinate APIs")
          else case axisCoordinateInputV2Values coordinate of
            CoordinateV2I32 values -> validateLength axis (length values)
            CoordinateV2I64 values -> validateLength axis (length values)
            CoordinateV2AppendSequenceValues _ -> Left (invalidArgument "coordinate append-sequence descriptors must target the append axis")
  validateLength axis valuesLen =
    let expected = fromIntegral (dimLength (dims !! axis))
     in if valuesLen == expected
          then Right ()
          else Left (invalidArgument "coordinate value length must match dimension length")


withAxisCoordinateInputArray :: [AxisCoordinateInputV2] -> (Ptr CArcadiaTioAxisCoordinateInput -> CSize -> IO a) -> IO a
withAxisCoordinateInputArray [] action = action nullPtr 0
withAxisCoordinateInputArray coordinates action =
  withCoordinateInputsV1 coordinates $ \raw ->
    withArray raw $ \ptr -> action ptr (CSize (fromIntegral (length raw)))

withCoordinateInputsV1 :: [AxisCoordinateInputV2] -> ([CArcadiaTioAxisCoordinateInput] -> IO a) -> IO a
withCoordinateInputsV1 [] action = action []
withCoordinateInputsV1 (coordinate : rest) action =
  withCString (axisCoordinateInputV2Name coordinate) $ \namePtr ->
    withCoordinateValues (axisCoordinateInputV2Values coordinate) $ \coordDType valuesPtr valuesLen ->
      withCoordinateInputsV1 rest $ \restRaw ->
        action (coordinateToCV1 namePtr coordDType valuesPtr valuesLen coordinate : restRaw)

coordinateToCV1 :: CString -> CoordinateDType -> Ptr Word8 -> CSize -> AxisCoordinateInputV2 -> CArcadiaTioAxisCoordinateInput
coordinateToCV1 namePtr coordDType valuesPtr valuesLen AxisCoordinateInputV2{axisCoordinateInputV2Axis, axisCoordinateInputV2Kind, axisCoordinateInputV2Encoding, axisCoordinateInputV2Sorted, axisCoordinateInputV2Monotonicity, axisCoordinateInputV2Uniqueness, axisCoordinateInputV2Required} =
  CArcadiaTioAxisCoordinateInput
    { cAxisCoordinateInputVersion = 1
    , cAxisCoordinateInputAxis = CSize (fromIntegral axisCoordinateInputV2Axis)
    , cAxisCoordinateInputName = namePtr
    , cAxisCoordinateInputKind = coordinateKindToRaw axisCoordinateInputV2Kind
    , cAxisCoordinateInputDType = coordinateDTypeToRaw coordDType
    , cAxisCoordinateInputEncoding = coordinateEncodingToRaw axisCoordinateInputV2Encoding
    , cAxisCoordinateInputValues = valuesPtr
    , cAxisCoordinateInputValuesLen = valuesLen
    , cAxisCoordinateInputSorted = coordinateSortednessToRaw axisCoordinateInputV2Sorted
    , cAxisCoordinateInputMonotonicity = coordinateMonotonicityToRaw axisCoordinateInputV2Monotonicity
    , cAxisCoordinateInputUniqueness = coordinateUniquenessToRaw axisCoordinateInputV2Uniqueness
    , cAxisCoordinateInputStorageKind = 0
    , cAxisCoordinateInputExternalSourceKind = 0
    , cAxisCoordinateInputExternalUri = nullPtr
    , cAxisCoordinateInputExternalDType = coordinateDTypeToRaw coordDType
    , cAxisCoordinateInputExternalLength = fromIntegral (fromIntegralCSize valuesLen)
    , cAxisCoordinateInputRequired = boolToWord8 axisCoordinateInputV2Required
    }

withCoordinateV2Options :: CoordinateV2Options -> (Ptr CArcadiaTioCoordinateV2Options -> IO a) -> IO a
withCoordinateV2Options CoordinateV2Options{coordinateAllowAuthoritativeScan, coordinateIncludeDictionaryEntries, coordinateIncludeIndexSummaries, coordinateAllowExternalResolution} action =
  alloca $ \optionsPtr -> do
    poke optionsPtr emptyCArcadiaTioCoordinateV2Options
      { cCoordinateV2OptionsAllowAuthoritativeScan = boolToWord8 coordinateAllowAuthoritativeScan
      , cCoordinateV2OptionsIncludeDictionaryEntries = boolToWord8 coordinateIncludeDictionaryEntries
      , cCoordinateV2OptionsIncludeIndexSummaries = boolToWord8 coordinateIncludeIndexSummaries
      , cCoordinateV2OptionsAllowExternalResolution = boolToWord8 coordinateAllowExternalResolution
      }
    action optionsPtr

withAxisCoordinateInputV2Array :: [AxisCoordinateInputV2] -> (Ptr CArcadiaTioAxisCoordinateInputV2 -> CSize -> IO a) -> IO a
withAxisCoordinateInputV2Array [] action = action nullPtr 0
withAxisCoordinateInputV2Array coordinates action =
  withCoordinateInputs coordinates $ \raw ->
    withArray raw $ \ptr -> action ptr (CSize (fromIntegral (length raw)))

withCoordinateInputs :: [AxisCoordinateInputV2] -> ([CArcadiaTioAxisCoordinateInputV2] -> IO a) -> IO a
withCoordinateInputs [] action = action []
withCoordinateInputs (coordinate : rest) action =
  withCString (axisCoordinateInputV2DescriptorId coordinate) $ \descriptorPtr ->
    withCString (axisCoordinateInputV2Name coordinate) $ \namePtr ->
      withCoordinateValues (axisCoordinateInputV2Values coordinate) $ \dtype valuesPtr valuesLen ->
        withCoordinateInputs rest $ \restRaw ->
          action (coordinateToC descriptorPtr namePtr dtype valuesPtr valuesLen coordinate : restRaw)

withCoordinateValues :: CoordinateV2Values -> (CoordinateDType -> Ptr Word8 -> CSize -> IO a) -> IO a
withCoordinateValues values action = case values of
  CoordinateV2I32 [] -> action CoordinateI32 nullPtr 0
  CoordinateV2I32 xs -> withArray xs $ \ptr -> action CoordinateI32 (castPtr ptr) (CSize (fromIntegral (length xs)))
  CoordinateV2I64 [] -> action CoordinateI64 nullPtr 0
  CoordinateV2I64 xs -> withArray xs $ \ptr -> action CoordinateI64 (castPtr ptr) (CSize (fromIntegral (length xs)))
  CoordinateV2AppendSequenceValues dtype -> action dtype nullPtr 0

coordinateValueDomainFor :: CoordinateV2Values -> CoordinateValueDomainV2
coordinateValueDomainFor values = case values of
  CoordinateV2AppendSequenceValues _ -> CoordinateV2AppendSequence
  _ -> CoordinateV2InlineNumeric

coordinateFixedTextFor :: CoordinateV2Values -> CArcadiaTioCoordinateFixedTextLayoutV2
coordinateFixedTextFor values = case values of
  CoordinateV2AppendSequenceValues _ -> CArcadiaTioCoordinateFixedTextLayoutV2 0 0 0 0 0 0 0
  _ -> emptyCArcadiaTioCoordinateFixedTextLayoutV2

coordinateToC :: CString -> CString -> CoordinateDType -> Ptr Word8 -> CSize -> AxisCoordinateInputV2 -> CArcadiaTioAxisCoordinateInputV2
coordinateToC descriptorPtr namePtr dtype valuesPtr valuesLen AxisCoordinateInputV2{axisCoordinateInputV2Axis, axisCoordinateInputV2Kind, axisCoordinateInputV2Values, axisCoordinateInputV2Encoding, axisCoordinateInputV2Sorted, axisCoordinateInputV2Monotonicity, axisCoordinateInputV2Uniqueness, axisCoordinateInputV2Required} =
  CArcadiaTioAxisCoordinateInputV2
    { cAxisCoordinateInputV2Version = 1
    , cAxisCoordinateInputV2StructSize = 224
    , cAxisCoordinateInputV2Axis = CSize (fromIntegral axisCoordinateInputV2Axis)
    , cAxisCoordinateInputV2DescriptorId = descriptorPtr
    , cAxisCoordinateInputV2Name = namePtr
    , cAxisCoordinateInputV2Kind = coordinateKindToRaw axisCoordinateInputV2Kind
    , cAxisCoordinateInputV2ValueDomain = coordinateValueDomainV2ToRaw (coordinateValueDomainFor axisCoordinateInputV2Values)
    , cAxisCoordinateInputV2NumericDType = coordinateDTypeToRaw dtype
    , cAxisCoordinateInputV2NumericEncoding = coordinateEncodingToRaw axisCoordinateInputV2Encoding
    , cAxisCoordinateInputV2FixedText = coordinateFixedTextFor axisCoordinateInputV2Values
    , cAxisCoordinateInputV2CodeDType = 0
    , cAxisCoordinateInputV2Values = valuesPtr
    , cAxisCoordinateInputV2ValuesLen = valuesLen
    , cAxisCoordinateInputV2Dictionary = nullPtr
    , cAxisCoordinateInputV2DictionaryEntries = nullPtr
    , cAxisCoordinateInputV2DictionaryEntriesLen = 0
    , cAxisCoordinateInputV2ExternalBinding = nullPtr
    , cAxisCoordinateInputV2Sorted = coordinateSortednessToRaw axisCoordinateInputV2Sorted
    , cAxisCoordinateInputV2Monotonicity = coordinateMonotonicityToRaw axisCoordinateInputV2Monotonicity
    , cAxisCoordinateInputV2Uniqueness = coordinateUniquenessToRaw axisCoordinateInputV2Uniqueness
    , cAxisCoordinateInputV2Required = boolToWord8 axisCoordinateInputV2Required
    }

boolToWord8 :: Bool -> Word8
boolToWord8 flag = if flag then 1 else 0


-- | Create a random-access '.tio' file through the C ABI.
createRandomAccess :: NativeLibrary -> FilePath -> DType -> [DimSpec] -> Int -> IO (Result TensorFile)
createRandomAccess = createWith capiCreateRandomAccess

-- | Create a random-access '.tio' file with optional dimension names, symbols,
-- channels, and user key/value metadata.
createRandomAccessWithMetadata :: NativeLibrary -> FilePath -> DType -> [DimSpec] -> Int -> CreateMetadata -> IO (Result TensorFile)
createRandomAccessWithMetadata = createWithMetadata capiCreateRandomAccessEx

-- | Create a '.tio' file using native inferred layout-family selection.
createInferred :: NativeLibrary -> FilePath -> DType -> [DimSpec] -> Int -> CreateInferredOptions -> IO (Result TensorFile)
createInferred native path payloadDType dims appendDim options = do
  case validateCreateInputs path dims appendDim of
    Left err -> pure (Left err)
    Right () -> withPath path $ \cPath -> do
      let rawKinds = map (axisKindToRaw . dimKind) dims
          rawLens = map dimLength dims
          fileRank = length dims
      withArray rawKinds $ \kindsPtr ->
        withArray rawLens $ \lensPtr -> do
          handle <-
            capiCreateInferred
              native
              cPath
              (dtypeToRaw payloadDType)
              kindsPtr
              lensPtr
              (CSize (fromIntegral fileRank))
              (CSize (fromIntegral appendDim))
              (storageAccessToRaw (inferredStorageAccess options))
              (openPatternToRaw (inferredOpenPattern options))
              (filePopulationToRaw (inferredFilePopulation options))
              (metadataStabilityToRaw (inferredMetadataStability options))
          if handle == nullPtr
            then Left <$> lastError native
            else Right <$> wrapHandle native handle

-- | Create an inferred '.tio' file with optional metadata.
createInferredWithMetadata :: NativeLibrary -> FilePath -> DType -> [DimSpec] -> Int -> CreateMetadata -> CreateInferredOptions -> IO (Result TensorFile)
createInferredWithMetadata native path payloadDType dims appendDim metadata options = do
  case validateCreateInputs path dims appendDim *> validateCreateMetadata (length dims) metadata of
    Left err -> pure (Left err)
    Right () -> withPath path $ \cPath -> do
      let rawKinds = map (axisKindToRaw . dimKind) dims
          rawLens = map dimLength dims
          fileRank = length dims
      withArray rawKinds $ \kindsPtr ->
        withArray rawLens $ \lensPtr ->
          withOptionalCStringArray (createDimNames metadata) $ \dimNamesPtr dimNamesLen ->
            withCStringArray (createSymbols metadata) $ \symbolsPtr symbolsLen ->
              withCStringArray (createChannels metadata) $ \channelsPtr channelsLen ->
                withUserKvArrays (createUserKv metadata) $ \keysPtr valuesPtr userKvLen -> do
                  handle <-
                    capiCreateInferredEx
                      native
                      cPath
                      (dtypeToRaw payloadDType)
                      kindsPtr
                      lensPtr
                      (CSize (fromIntegral fileRank))
                      (CSize (fromIntegral appendDim))
                      dimNamesPtr
                      dimNamesLen
                      symbolsPtr
                      symbolsLen
                      channelsPtr
                      channelsLen
                      keysPtr
                      valuesPtr
                      userKvLen
                      (storageAccessToRaw (inferredStorageAccess options))
                      (openPatternToRaw (inferredOpenPattern options))
                      (filePopulationToRaw (inferredFilePopulation options))
                      (metadataStabilityToRaw (inferredMetadataStability options))
                  if handle == nullPtr
                    then Left <$> lastError native
                    else Right <$> wrapHandle native handle

-- | Create a '.tio' file using native policy-based layout selection.
createWithPolicy :: NativeLibrary -> FilePath -> DType -> [DimSpec] -> Int -> CreatePolicyOptions -> IO (Result TensorFile)
createWithPolicy native path payloadDType dims appendDim options = do
  case validateCreateInputs path dims appendDim *> validatePolicyOptions options of
    Left err -> pure (Left err)
    Right () -> withPath path $ \cPath -> do
      let rawKinds = map (axisKindToRaw . dimKind) dims
          rawLens = map dimLength dims
          chunkAxes = map (CSize . fromIntegral) (policyChunkAxes options)
          typical = policyTypicalQuerySizes options
          fileRank = length dims
      withArray rawKinds $ \kindsPtr ->
        withArray rawLens $ \lensPtr ->
          withCSizeArray chunkAxes $ \chunkAxesPtr chunkAxesLen ->
            withWord32Array typical $ \typicalPtr typicalLen -> do
              handle <-
                capiCreateWithPolicy
                  native
                  cPath
                  (dtypeToRaw payloadDType)
                  kindsPtr
                  lensPtr
                  (CSize (fromIntegral fileRank))
                  (CSize (fromIntegral appendDim))
                  chunkAxesPtr
                  chunkAxesLen
                  (storageProfileToRaw (policyStorageProfile options))
                  typicalPtr
                  typicalLen
              if handle == nullPtr
                then Left <$> lastError native
                else Right <$> wrapHandle native handle

-- | Create a policy-selected '.tio' file with optional metadata.
createWithPolicyWithMetadata :: NativeLibrary -> FilePath -> DType -> [DimSpec] -> Int -> CreateMetadata -> CreatePolicyOptions -> IO (Result TensorFile)
createWithPolicyWithMetadata native path payloadDType dims appendDim metadata options = do
  case validateCreateInputs path dims appendDim *> validateCreateMetadata (length dims) metadata *> validatePolicyOptions options of
    Left err -> pure (Left err)
    Right () -> withPath path $ \cPath -> do
      let rawKinds = map (axisKindToRaw . dimKind) dims
          rawLens = map dimLength dims
          chunkAxes = map (CSize . fromIntegral) (policyChunkAxes options)
          typical = policyTypicalQuerySizes options
          fileRank = length dims
      withArray rawKinds $ \kindsPtr ->
        withArray rawLens $ \lensPtr ->
          withOptionalCStringArray (createDimNames metadata) $ \dimNamesPtr dimNamesLen ->
            withCStringArray (createSymbols metadata) $ \symbolsPtr symbolsLen ->
              withCStringArray (createChannels metadata) $ \channelsPtr channelsLen ->
                withUserKvArrays (createUserKv metadata) $ \keysPtr valuesPtr userKvLen ->
                  withCSizeArray chunkAxes $ \chunkAxesPtr chunkAxesLen ->
                    withWord32Array typical $ \typicalPtr typicalLen -> do
                      handle <-
                        capiCreateWithPolicyEx
                          native
                          cPath
                          (dtypeToRaw payloadDType)
                          kindsPtr
                          lensPtr
                          (CSize (fromIntegral fileRank))
                          (CSize (fromIntegral appendDim))
                          dimNamesPtr
                          dimNamesLen
                          symbolsPtr
                          symbolsLen
                          channelsPtr
                          channelsLen
                          keysPtr
                          valuesPtr
                          userKvLen
                          chunkAxesPtr
                          chunkAxesLen
                          (storageProfileToRaw (policyStorageProfile options))
                          typicalPtr
                          typicalLen
                      if handle == nullPtr
                        then Left <$> lastError native
                        else Right <$> wrapHandle native handle

createWith :: (NativeLibrary -> CString -> CInt -> Ptr CInt -> Ptr Word32 -> CSize -> CSize -> IO (Ptr CHandle)) -> NativeLibrary -> FilePath -> DType -> [DimSpec] -> Int -> IO (Result TensorFile)
createWith createFn native path payloadDType dims appendDim = do
  case validateCreateInputs path dims appendDim of
    Left err -> pure (Left err)
    Right () -> withPath path $ \cPath -> do
      let rawKinds = map (axisKindToRaw . dimKind) dims
          rawLens = map dimLength dims
          fileRank = fromIntegral (length dims)
      withArray rawKinds $ \kindsPtr ->
        withArray rawLens $ \lensPtr -> do
          handle <- createFn native cPath (dtypeToRaw payloadDType) kindsPtr lensPtr (CSize fileRank) (CSize (fromIntegral appendDim))
          if handle == nullPtr
            then Left <$> lastError native
            else Right <$> wrapHandle native handle

type CreateExInvoker = NativeLibrary -> CString -> CInt -> Ptr CInt -> Ptr Word32 -> CSize -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> Ptr CString -> CSize -> IO (Ptr CHandle)

createWithMetadata :: CreateExInvoker -> NativeLibrary -> FilePath -> DType -> [DimSpec] -> Int -> CreateMetadata -> IO (Result TensorFile)
createWithMetadata createFn native path payloadDType dims appendDim metadata = do
  case validateCreateInputs path dims appendDim *> validateCreateMetadata (length dims) metadata of
    Left err -> pure (Left err)
    Right () -> withPath path $ \cPath -> do
      let rawKinds = map (axisKindToRaw . dimKind) dims
          rawLens = map dimLength dims
          fileRank = length dims
      withArray rawKinds $ \kindsPtr ->
        withArray rawLens $ \lensPtr ->
          withOptionalCStringArray (createDimNames metadata) $ \dimNamesPtr dimNamesLen ->
            withCStringArray (createSymbols metadata) $ \symbolsPtr symbolsLen ->
              withCStringArray (createChannels metadata) $ \channelsPtr channelsLen ->
                withUserKvArrays (createUserKv metadata) $ \keysPtr valuesPtr userKvLen -> do
                  handle <-
                    createFn
                      native
                      cPath
                      (dtypeToRaw payloadDType)
                      kindsPtr
                      lensPtr
                      (CSize (fromIntegral fileRank))
                      (CSize (fromIntegral appendDim))
                      dimNamesPtr
                      dimNamesLen
                      symbolsPtr
                      symbolsLen
                      channelsPtr
                      channelsLen
                      keysPtr
                      valuesPtr
                      userKvLen
                  if handle == nullPtr
                    then Left <$> lastError native
                    else Right <$> wrapHandle native handle

validateCreateMetadata :: Int -> CreateMetadata -> Result ()
validateCreateMetadata fileRank CreateMetadata{createDimNames, createSymbols, createChannels, createUserKv}
  | not (null createDimNames) && length createDimNames /= fileRank = Left (invalidArgument "dimension names length must match rank")
  | otherwise = do
      mapM_ validateOptionalName createDimNames
      mapM_ (validateRequiredString "symbol") createSymbols
      mapM_ (validateRequiredString "channel") createChannels
      mapM_ validateUserKv createUserKv
 where
  validateOptionalName Nothing = Right ()
  validateOptionalName (Just value) = validateRequiredString "dimension name" value
  validateUserKv (key, value) = do
    validateRequiredString "user metadata key" key
    validateString "user metadata value" value

validatePolicyOptions :: CreatePolicyOptions -> Result ()
validatePolicyOptions CreatePolicyOptions{policyChunkAxes, policyTypicalQuerySizes}
  | any (< 0) policyChunkAxes = Left (invalidArgument "policy chunk axes must be non-negative")
  | otherwise = do
      let _ = policyTypicalQuerySizes
      Right ()

storageAccessToRaw :: StorageAccessKind -> CInt
storageAccessToRaw value = case value of
  StorageAccessSeekableMounted -> 0
  StorageAccessRemoteRangeRead -> 1
  StorageAccessForwardOnly -> 2

openPatternToRaw :: OpenPattern -> CInt
openPatternToRaw value = case value of
  OpenPatternMetadataHot -> 0
  OpenPatternDataHot -> 1
  OpenPatternMixed -> 2

filePopulationToRaw :: FilePopulation -> CInt
filePopulationToRaw value = case value of
  FilePopulationFewLongLived -> 0
  FilePopulationManyShards -> 1

metadataStabilityToRaw :: MetadataStability -> CInt
metadataStabilityToRaw value = case value of
  MetadataStable -> 0
  MetadataGrowing -> 1

storageProfileToRaw :: StorageProfile -> CInt
storageProfileToRaw value = case value of
  StorageBalanced -> 0
  StorageNvme -> 1
  StorageHdd -> 2

validateRequiredString :: String -> String -> Result ()
validateRequiredString label value
  | null value = Left (invalidArgument (label <> " cannot be empty"))
  | otherwise = validateString label value

validateString :: String -> String -> Result ()
validateString label value
  | '\0' `elem` value = Left (invalidArgument (label <> " contains an interior NUL byte"))
  | otherwise = Right ()

withCStringArray :: [String] -> (Ptr CString -> CSize -> IO a) -> IO a
withCStringArray [] action = action nullPtr 0
withCStringArray values action =
  withManyCStrings values $ \ptrs ->
    withArray ptrs $ \arrayPtr -> action arrayPtr (CSize (fromIntegral (length values)))

withOptionalCStringArray :: [Maybe String] -> (Ptr CString -> CSize -> IO a) -> IO a
withOptionalCStringArray [] action = action nullPtr 0
withOptionalCStringArray values action =
  withManyOptionalCStrings values $ \ptrs ->
    withArray ptrs $ \arrayPtr -> action arrayPtr (CSize (fromIntegral (length values)))

withUserKvArrays :: [(String, String)] -> (Ptr CString -> Ptr CString -> CSize -> IO a) -> IO a
withUserKvArrays [] action = action nullPtr nullPtr 0
withUserKvArrays pairs action =
  withManyCStrings (map fst pairs) $ \keyPtrs ->
    withManyCStrings (map snd pairs) $ \valuePtrs ->
      withArray keyPtrs $ \keysPtr ->
        withArray valuePtrs $ \valuesPtr -> action keysPtr valuesPtr (CSize (fromIntegral (length pairs)))

withCSizeArray :: [CSize] -> (Ptr CSize -> CSize -> IO a) -> IO a
withCSizeArray [] action = action nullPtr 0
withCSizeArray values action = withArray values $ \ptr -> action ptr (CSize (fromIntegral (length values)))

withWord32Array :: [Word32] -> (Ptr Word32 -> CSize -> IO a) -> IO a
withWord32Array [] action = action nullPtr 0
withWord32Array values action = withArray values $ \ptr -> action ptr (CSize (fromIntegral (length values)))

withWord8Array :: [Word8] -> (Ptr Word8 -> CSize -> IO a) -> IO a
withWord8Array [] action = action nullPtr 0
withWord8Array values action = withArray values $ \ptr -> action ptr (CSize (fromIntegral (length values)))

uuidBytes16 :: TioUuid -> [Word8]
uuidBytes16 (TioUuid bytes) = take 16 (bytes <> repeat 0)

validateUuid :: String -> TioUuid -> Result ()
validateUuid label (TioUuid bytes)
  | length bytes == 16 = Right ()
  | otherwise = Left (invalidArgument (label <> " must contain exactly 16 bytes"))

validateAxisIndex :: String -> Int -> Result ()
validateAxisIndex label axis
  | axis < 0 = Left (invalidArgument (label <> " axis must be non-negative"))
  | otherwise = Right ()

validateCreateUniverseOptions :: Int -> CreateWithUniverseOptions -> Result ()
validateCreateUniverseOptions rank CreateWithUniverseOptions{createUniverseAxisIdentities} = mapM_ validateIdentity createUniverseAxisIdentities
 where
  validateIdentity AxisIdentityInput{axisIdentityAxis}
    | axisIdentityAxis < 0 || axisIdentityAxis >= rank = Left (invalidArgument "universe axis identity axis is out of range")
    | otherwise = Right ()

withCreateUniverseOptions :: CreateWithUniverseOptions -> (Ptr CArcadiaTioCreateWithUniverseOptions -> IO a) -> IO a
withCreateUniverseOptions CreateWithUniverseOptions{createUniverseAxisIdentities} action =
  withAxisIdentityInputs createUniverseAxisIdentities $ \identitiesPtr identitiesLen ->
    alloca $ \optionsPtr -> do
      poke optionsPtr CArcadiaTioCreateWithUniverseOptions
        { cCreateWithUniverseOptionsVersion = 1
        , cCreateWithUniverseOptionsStructSize = 32
        , cCreateWithUniverseOptionsAxisIdentities = identitiesPtr
        , cCreateWithUniverseOptionsAxisIdentitiesLen = identitiesLen
        }
      action optionsPtr

withAxisIdentityInputs :: [AxisIdentityInput] -> (Ptr CArcadiaTioAxisIdentityInput -> CSize -> IO a) -> IO a
withAxisIdentityInputs [] action = action nullPtr 0
withAxisIdentityInputs identities action = withArray (map axisIdentityToC identities) $ \ptr -> action ptr (CSize (fromIntegral (length identities)))

axisIdentityToC :: AxisIdentityInput -> CArcadiaTioAxisIdentityInput
axisIdentityToC AxisIdentityInput{axisIdentityAxis, axisIdentityMode} =
  CArcadiaTioAxisIdentityInput 1 24 (fromIntegral axisIdentityAxis) (Types.axisIdentityModeToRaw axisIdentityMode)

withEntrySelectors :: [EntrySelector] -> (Ptr CArcadiaTioEntrySelector -> CSize -> IO a) -> IO a
withEntrySelectors [] action = action nullPtr 0
withEntrySelectors selectors action = go selectors []
 where
  go [] acc = withArray (reverse acc) $ \selectorsPtr -> action selectorsPtr (CSize (fromIntegral (length selectors)))
  go (selector : rest) acc = case selector of
    SelectAll -> go rest (CArcadiaTioEntrySelector 0 0 0 nullPtr 0 : acc)
    SelectRange start end -> go rest (CArcadiaTioEntrySelector 1 start end nullPtr 0 : acc)
    SelectTake [] -> go rest (CArcadiaTioEntrySelector 2 0 0 nullPtr 0 : acc)
    SelectTake indices ->
      withArray indices $ \indicesPtr ->
        go rest (CArcadiaTioEntrySelector 2 0 0 indicesPtr (CSize (fromIntegral (length indices))) : acc)

withReadOptions :: ReadOptions -> (Ptr CArcadiaTioReadWithOptionsOptions -> IO a) -> IO a
withReadOptions options action =
  alloca $ \optionsPtr -> do
    poke optionsPtr (readOptionsToC options)
    action optionsPtr

withShapeReadOptions :: ReadOptions -> ReadShapePolicy -> (Ptr CArcadiaTioReadWithShapePolicyOptions -> IO a) -> IO a
withShapeReadOptions options policy action =
  withShapePolicy policy $ \shapePolicy ->
    alloca $ \optionsPtr -> do
      poke optionsPtr CArcadiaTioReadWithShapePolicyOptions
        { cShapeReadOptionsVersion = 1
        , cShapeReadOptionsStructSize = 104
        , cShapeReadOptionsMode = readExecutionModeToRaw (readOptionMode options)
        , cShapeReadOptionsMaxThreads = CSize (fromIntegral (max 0 (readOptionMaxThreads options)))
        , cShapeReadOptionsShapePolicy = shapePolicy
        }
      action optionsPtr

withShapePolicy :: ReadShapePolicy -> (CArcadiaTioReadShapePolicyOptions -> IO a) -> IO a
withShapePolicy policy action =
  case policy of
    ReadShapeExplicitExtents extents ->
      withArray extents $ \extentsPtr ->
        action emptyCArcadiaTioReadShapePolicyOptions
          { cReadShapePolicyPolicy = readShapePolicyToRaw policy
          , cReadShapePolicyExplicitExtents = if null extents then nullPtr else extentsPtr
          , cReadShapePolicyExplicitExtentsLen = CSize (fromIntegral (length extents))
          }
    ReadShapeExplicitUniverse universeAxes ->
      withExplicitUniverseTargets universeAxes $ \universePtr universeLen ->
        action emptyCArcadiaTioReadShapePolicyOptions
          { cReadShapePolicyPolicy = readShapePolicyToRaw policy
          , cReadShapePolicyExplicitUniverseAxes = castPtr universePtr
          , cReadShapePolicyExplicitUniverseAxesLen = universeLen
          }
    ReadShapeExplicitUniverseAndExtents universeAxes extentAxes ->
      withExplicitUniverseTargets universeAxes $ \universePtr universeLen ->
        withExplicitExtentTargets extentAxes $ \extentPtr extentLen ->
          action emptyCArcadiaTioReadShapePolicyOptions
            { cReadShapePolicyPolicy = readShapePolicyToRaw policy
            , cReadShapePolicyExplicitUniverseAxes = castPtr universePtr
            , cReadShapePolicyExplicitUniverseAxesLen = universeLen
            , cReadShapePolicyExplicitExtentAxes = castPtr extentPtr
            , cReadShapePolicyExplicitExtentAxesLen = extentLen
            }
    _ -> action emptyCArcadiaTioReadShapePolicyOptions{cReadShapePolicyPolicy = readShapePolicyToRaw policy}

withExplicitUniverseTargets :: [ExplicitUniverseAxisTarget] -> (Ptr CArcadiaTioExplicitUniverseAxisTarget -> CSize -> IO a) -> IO a
withExplicitUniverseTargets [] action = action nullPtr 0
withExplicitUniverseTargets targets action = withArray (map explicitUniverseTargetToC targets) $ \ptr -> action ptr (CSize (fromIntegral (length targets)))

explicitUniverseTargetToC :: ExplicitUniverseAxisTarget -> CArcadiaTioExplicitUniverseAxisTarget
explicitUniverseTargetToC ExplicitUniverseAxisTarget{explicitUniverseAxis, explicitUniverseFamilyUuid, explicitUniverseVersionUuid, explicitUniverseLength} =
  CArcadiaTioExplicitUniverseAxisTarget (fromIntegral explicitUniverseAxis) (uuidBytes16 explicitUniverseFamilyUuid) (uuidBytes16 explicitUniverseVersionUuid) explicitUniverseLength

withExplicitExtentTargets :: [ExplicitExtentAxisTarget] -> (Ptr CArcadiaTioExplicitExtentAxisTarget -> CSize -> IO a) -> IO a
withExplicitExtentTargets [] action = action nullPtr 0
withExplicitExtentTargets targets action = withArray (map explicitExtentTargetToC targets) $ \ptr -> action ptr (CSize (fromIntegral (length targets)))

explicitExtentTargetToC :: ExplicitExtentAxisTarget -> CArcadiaTioExplicitExtentAxisTarget
explicitExtentTargetToC ExplicitExtentAxisTarget{explicitExtentAxis, explicitExtentLength} = CArcadiaTioExplicitExtentAxisTarget (fromIntegral explicitExtentAxis) explicitExtentLength

withQueryTraceContext :: QueryTraceContext -> (Ptr CArcadiaTioQueryTraceContext -> IO a) -> IO a
withQueryTraceContext QueryTraceContext{queryTraceRunId, queryTraceRowId, queryTraceRepeatIndex, queryTracePhase, queryTraceLanguage, queryTraceApiSurface, queryTraceOperation, queryTraceClock} action =
  withCString queryTraceRunId $ \runIdPtr ->
    withCString queryTraceRowId $ \rowIdPtr ->
      withCString queryTracePhase $ \phasePtr ->
        withCString queryTraceLanguage $ \languagePtr ->
          withCString queryTraceApiSurface $ \apiSurfacePtr ->
            withCString queryTraceOperation $ \operationPtr ->
              withCString queryTraceClock $ \traceClockPtr ->
                alloca $ \tracePtr -> do
                  poke tracePtr CArcadiaTioQueryTraceContext
                    { cTraceContextVersion = 1
                    , cTraceContextStructSize = 80
                    , cTraceContextRunId = runIdPtr
                    , cTraceContextRowId = rowIdPtr
                    , cTraceContextRepeatIndex = queryTraceRepeatIndex
                    , cTraceContextPhase = phasePtr
                    , cTraceContextLanguage = languagePtr
                    , cTraceContextApiSurface = apiSurfacePtr
                    , cTraceContextOperation = operationPtr
                    , cTraceContextTraceClock = traceClockPtr
                    }
                  action tracePtr

readOptionsToC :: ReadOptions -> CArcadiaTioReadWithOptionsOptions
readOptionsToC ReadOptions{readOptionMode, readOptionMaxThreads} =
  CArcadiaTioReadWithOptionsOptions
    { cReadOptionsVersion = 1
    , cReadOptionsStructSize = 32
    , cReadOptionsMode = readExecutionModeToRaw readOptionMode
    , cReadOptionsMaxThreads = CSize (fromIntegral (max 0 readOptionMaxThreads))
    }

readExecutionModeToRaw :: ReadExecutionMode -> CInt
readExecutionModeToRaw = Types.readExecutionModeToRaw

readExecutionModeFromRaw :: CInt -> Result ReadExecutionMode
readExecutionModeFromRaw raw =
  maybe (Left (invalidArgument "native read report has unknown execution mode")) Right (Types.readExecutionModeFromRaw raw)

validateReadShapePolicy :: ReadShapePolicy -> Result ()
validateReadShapePolicy policy = case policy of
  ReadShapeExplicitUniverse targets -> mapM_ validateUniverseTarget targets
  ReadShapeExplicitUniverseAndExtents universeTargets extentTargets -> mapM_ validateUniverseTarget universeTargets *> mapM_ validateExtentTarget extentTargets
  _ -> Right ()
 where
  validateUniverseTarget ExplicitUniverseAxisTarget{explicitUniverseAxis, explicitUniverseFamilyUuid, explicitUniverseVersionUuid} = do
    validateAxisIndex "explicit universe target" explicitUniverseAxis
    validateUuid "explicit universe family UUID" explicitUniverseFamilyUuid
    validateUuid "explicit universe version UUID" explicitUniverseVersionUuid
  validateExtentTarget ExplicitExtentAxisTarget{explicitExtentAxis} = validateAxisIndex "explicit extent target" explicitExtentAxis

readShapePolicyToRaw :: ReadShapePolicy -> CInt
readShapePolicyToRaw = Types.readShapePolicyTagToRaw . Types.readShapePolicyTag

validateQueryTraceContext :: QueryTraceContext -> Result ()
validateQueryTraceContext QueryTraceContext{queryTraceRunId, queryTraceRowId, queryTracePhase, queryTraceLanguage, queryTraceApiSurface, queryTraceOperation, queryTraceClock} = do
  validateRequiredString "query trace run_id" queryTraceRunId
  validateRequiredString "query trace row_id" queryTraceRowId
  validateRequiredString "query trace phase" queryTracePhase
  validateRequiredString "query trace language" queryTraceLanguage
  validateRequiredString "query trace api_surface" queryTraceApiSurface
  validateRequiredString "query trace operation" queryTraceOperation
  validateRequiredString "query trace clock" queryTraceClock

validateReadIndexItems :: [ReadIndexItem] -> Result ()
validateReadIndexItems items
  | null items = Left (invalidArgument "read index items must not be empty")
  | otherwise = mapM_ validateReadIndexItem items
 where
  validateReadIndexItem item = case item of
    ReadIndexSlice _ _ step | step == 0 -> Left (invalidArgument "read index slice step must not be zero")
    _ -> Right ()

readIndexItemToC :: ReadIndexItem -> CArcadiaTioReadIndexItem
readIndexItemToC item = case item of
  ReadIndexAll -> CArcadiaTioReadIndexItem (rawTag item) 0 0 0 0 1 0
  ReadIndexSlice maybeStart maybeEnd step ->
    CArcadiaTioReadIndexItem
      (rawTag item)
      (maybe 0 (const 1) maybeStart)
      (maybe 0 id maybeStart)
      (maybe 0 (const 1) maybeEnd)
      (maybe 0 id maybeEnd)
      step
      0
  ReadIndexIndex index -> CArcadiaTioReadIndexItem (rawTag item) 0 0 0 0 1 index
  ReadIndexNewAxis -> CArcadiaTioReadIndexItem (rawTag item) 0 0 0 0 1 0
  ReadIndexEllipsis -> CArcadiaTioReadIndexItem (rawTag item) 0 0 0 0 1 0
 where
  rawTag = Types.readIndexItemTagToRaw . Types.readIndexItemTag

readIndexLoweringFromRaw :: CInt -> Result ReadIndexLoweringKind
readIndexLoweringFromRaw raw =
  maybe (Left (invalidArgument "native read-index report has unknown lowering kind")) Right (Types.readIndexLoweringKindFromRaw raw)

historicalQuerySourceKindFromRaw :: CInt -> Result HistoricalQuerySourceKind
historicalQuerySourceKindFromRaw raw =
  maybe (Left (invalidArgument "native historical read report has unknown source kind")) Right (Types.historicalQuerySourceKindFromRaw raw)

withManyCStrings :: [String] -> ([CString] -> IO a) -> IO a
withManyCStrings [] action = action []
withManyCStrings (value : rest) action =
  withCString value $ \valuePtr -> withManyCStrings rest $ \restPtrs -> action (valuePtr : restPtrs)

withManyOptionalCStrings :: [Maybe String] -> ([CString] -> IO a) -> IO a
withManyOptionalCStrings [] action = action []
withManyOptionalCStrings (value : rest) action =
  case value of
    Nothing -> withManyOptionalCStrings rest $ \restPtrs -> action (nullPtr : restPtrs)
    Just text -> withCString text $ \valuePtr -> withManyOptionalCStrings rest $ \restPtrs -> action (valuePtr : restPtrs)

-- | Open an existing '.tio' file through the C ABI.
open :: NativeLibrary -> FilePath -> IO (Result TensorFile)
open native path = withPath path $ \cPath -> do
  handle <- capiOpen native cPath
  if handle == nullPtr
    then Left <$> lastError native
    else Right <$> wrapHandle native handle

-- | Eagerly close a TensorFile handle. The operation is idempotent with respect
-- to the Haskell finalizer; do not use the value after closing it.
close :: TensorFile -> IO ()
close TensorFile{tensorFileHandle} = finalizeForeignPtr tensorFileHandle

wrapHandle :: NativeLibrary -> Ptr CHandle -> IO TensorFile
wrapHandle native handle = do
  fp <- FC.newForeignPtr handle (capiClose native handle)
  pure TensorFile{tensorFileNative = native, tensorFileHandle = fp}

validateCreateInputs :: FilePath -> [DimSpec] -> Int -> Result ()
validateCreateInputs path dims appendDim
  | '\0' `elem` path = Left (invalidArgument "path contains an interior NUL byte")
  | null dims = Left (invalidArgument "rank must be at least one")
  | appendDim < 0 || appendDim >= length dims = Left (invalidArgument "append dimension is out of bounds")
  | otherwise = Right ()

withPath :: FilePath -> (CString -> IO (Result b)) -> IO (Result b)
withPath path action
  | '\0' `elem` path = pure (Left (invalidArgument "path contains an interior NUL byte"))
  | otherwise = withCString path action

-- | Return the tensor rank for an open file.
rank :: TensorFile -> IO (Result Int)
rank file = withHandleOutput file (capiRank (tensorFileNative file)) (Right . fromIntegralCSize)

-- | Return the payload dtype for an open file.
dtype :: TensorFile -> IO (Result DType)
dtype file = withHandleOutput file (capiDType (tensorFileNative file)) $ \raw ->
  maybe (Left (invalidArgument "native file has unknown dtype")) Right (dtypeFromRaw raw)

-- | Return the append-axis index for an open file.
appendAxis :: TensorFile -> IO (Result Int)
appendAxis file = withHandleOutput file (capiAppendAxis (tensorFileNative file)) (Right . fromIntegralCSize)

-- | Return current dimension lengths for an open file.
dimLens :: TensorFile -> IO (Result [Word32])
dimLens file@TensorFile{tensorFileNative, tensorFileHandle} = do
  rankResult <- rank file
  case rankResult of
    Left err -> pure (Left err)
    Right fileRank ->
      withForeignPtr tensorFileHandle $ \handle ->
        allocaArray fileRank $ \lensPtr -> do
          status <- capiDimLens tensorFileNative handle lensPtr (CSize (fromIntegral fileRank))
          if status == okStatus
            then Right <$> peekArray fileRank lensPtr
            else Left <$> lastError tensorFileNative

-- | Return the native chunk-plan block sizes for an open file.
chunkPlan :: TensorFile -> IO (Result ChunkPlan)
chunkPlan TensorFile{tensorFileNative, tensorFileHandle} =
  withForeignPtr tensorFileHandle $ \handle ->
    alloca $ \planPtr -> do
      poke planPtr emptyCArcadiaTioChunkPlan
      status <- capiChunkPlan tensorFileNative handle planPtr
      if status == okStatus
        then (peek planPtr >>= copyChunkPlan) `finally` capiChunkPlanFree tensorFileNative planPtr
        else do
          err <- lastError tensorFileNative
          capiChunkPlanFree tensorFileNative planPtr
          pure (Left err)

copyChunkPlan :: CArcadiaTioChunkPlan -> IO (Result ChunkPlan)
copyChunkPlan CArcadiaTioChunkPlan{cChunkPlanBlockSizes, cChunkPlanLen} = do
  let len = fromIntegralCSize cChunkPlanLen
  if len > 0 && cChunkPlanBlockSizes == nullPtr
    then pure (Left (invalidArgument "native chunk plan block-size pointer is null"))
    else Right . ChunkPlan <$> peekArray len cChunkPlanBlockSizes

-- | Return the native path associated with an open file handle.
filePath :: TensorFile -> IO (Result FilePath)
filePath TensorFile{tensorFileNative, tensorFileHandle} =
  withForeignPtr tensorFileHandle $ \handle ->
    alloca $ \outPathPtr -> do
      poke outPathPtr nullPtr
      status <- capiPath tensorFileNative handle outPathPtr
      pathPtr <- peek outPathPtr
      if status == okStatus
        then
          if pathPtr == nullPtr
            then pure (Left (invalidArgument "native path pointer is null"))
            else Right <$> peekCString pathPtr `finally` capiStringFree tensorFileNative pathPtr
        else do
          if pathPtr == nullPtr then pure () else capiStringFree tensorFileNative pathPtr
          Left <$> lastError tensorFileNative

withHandleOutput :: Storable a => TensorFile -> (Ptr CHandle -> Ptr a -> IO CInt) -> (a -> Result b) -> IO (Result b)
withHandleOutput TensorFile{tensorFileNative, tensorFileHandle} nativeCall convert =
  withForeignPtr tensorFileHandle $ \handle ->
    alloca $ \outPtr -> do
      status <- nativeCall handle outPtr
      if status == okStatus
        then convert <$> peek outPtr
        else Left <$> lastError tensorFileNative

fromIntegralCSize :: CSize -> Int
fromIntegralCSize (CSize value) = fromIntegral value

-- | Load metadata from a path without keeping the file open.
loadMeta :: NativeLibrary -> FilePath -> IO (Result FileMeta)
loadMeta native path = withPath path $ \cPath ->
  alloca $ \metaPtr -> do
    poke metaPtr emptyCArcadiaTioFileMeta
    status <- capiLoadMeta native cPath metaPtr
    if status == okStatus
      then (peek metaPtr >>= copyFileMeta) `finally` capiFileMetaFree native metaPtr
      else do
        err <- lastError native
        capiFileMetaFree native metaPtr
        pure (Left err)

copyFileMeta :: CArcadiaTioFileMeta -> IO (Result FileMeta)
copyFileMeta raw = case (dtypeFromRaw (cFileMetaDType raw), headerProfileFromRaw (cFileMetaEffectiveProfile raw)) of
  (Nothing, _) -> pure (Left (invalidArgument "metadata has unknown dtype"))
  (_, Nothing) -> pure (Left (invalidArgument "metadata has unknown header profile"))
  (Just metaDType, Just profile) -> do
    dimsResult <- copyCArray "metadata dims" (cFileMetaDims raw) (fromIntegralCSize (cFileMetaRank raw)) copyDimMeta
    symbolsResult <- copyCArray "metadata symbols" (cFileMetaSymbols raw) (fromIntegralCSize (cFileMetaSymbolsLen raw)) copyAxisLabel
    channelsResult <- copyCArray "metadata channels" (cFileMetaChannels raw) (fromIntegralCSize (cFileMetaChannelsLen raw)) copyAxisLabel
    userKvResult <- copyCArray "metadata user_kv" (cFileMetaUserKv raw) (fromIntegralCSize (cFileMetaUserKvLen raw)) copyUserKv
    pure $ do
      dims <- dimsResult
      symbols <- symbolsResult
      channels <- channelsResult
      userKv <- userKvResult
      Right
        FileMeta
          { fileMetaDType = metaDType
          , fileMetaDims = dims
          , fileMetaAppendDim = fromIntegralCSize (cFileMetaAppendDim raw)
          , fileMetaSymbols = symbols
          , fileMetaChannels = channels
          , fileMetaUserKv = userKv
          , fileMetaEffectiveProfile = profile
          , fileMetaCommitSeq = cFileMetaCommitSeq raw
          }

copyDimMeta :: CArcadiaTioDimSpec -> IO (Result DimMeta)
copyDimMeta CArcadiaTioDimSpec{cDimKind, cDimLen, cDimName} =
  case axisKindFromRaw cDimKind of
    Nothing -> pure (Left (invalidArgument "metadata dim has unknown axis kind"))
    Just kind -> do
      name <- peekOptionalCString cDimName
      pure (Right DimMeta{dimMetaKind = kind, dimMetaLength = cDimLen, dimMetaName = name})

copyAxisLabel :: CArcadiaTioAxisLabel -> IO (Result AxisLabel)
copyAxisLabel CArcadiaTioAxisLabel{cAxisLabelId, cAxisLabelName} = do
  name <- peekRequiredCString cAxisLabelName
  pure (Right AxisLabel{axisLabelId = cAxisLabelId, axisLabelName = name})

copyUserKv :: CArcadiaTioUserKv -> IO (Result UserKv)
copyUserKv CArcadiaTioUserKv{cUserKvKey, cUserKvValue} = do
  key <- peekRequiredCString cUserKvKey
  value <- peekRequiredCString cUserKvValue
  pure (Right UserKv{userKvKey = key, userKvValue = value})

-- | Set or clear a dimension name on an open file.
setDimName :: TensorFile -> Int -> Maybe String -> IO (Result ())
setDimName file@TensorFile{tensorFileNative} axis maybeName
  | axis < 0 = pure (Left (invalidArgument "axis must be non-negative"))
  | otherwise = case maybeName of
      Nothing -> callStatus file $ \handle -> capiSetDimName tensorFileNative handle (CSize (fromIntegral axis)) nullPtr 0
      Just name -> case validateRequiredString "dimension name" name of
        Left err -> pure (Left err)
        Right () -> withCString name $ \namePtr ->
          callStatus file $ \handle -> capiSetDimName tensorFileNative handle (CSize (fromIntegral axis)) namePtr 1

-- | Replace symbol labels on an open file.
setSymbols :: TensorFile -> [String] -> IO (Result ())
setSymbols file@TensorFile{tensorFileNative} values = case mapM_ (validateRequiredString "symbol") values of
  Left err -> pure (Left err)
  Right () -> withCStringArray values $ \valuesPtr valuesLen ->
    callStatus file $ \handle -> capiSetSymbols tensorFileNative handle valuesPtr valuesLen

-- | Replace channel labels on an open file.
setChannels :: TensorFile -> [String] -> IO (Result ())
setChannels file@TensorFile{tensorFileNative} values = case mapM_ (validateRequiredString "channel") values of
  Left err -> pure (Left err)
  Right () -> withCStringArray values $ \valuesPtr valuesLen ->
    callStatus file $ \handle -> capiSetChannels tensorFileNative handle valuesPtr valuesLen

-- | Replace user key/value metadata on an open file.
setUserKv :: TensorFile -> [(String, String)] -> IO (Result ())
setUserKv file@TensorFile{tensorFileNative} values = case mapM_ validateUserKv values of
  Left err -> pure (Left err)
  Right () -> withUserKvArrays values $ \keysPtr valuesPtr valuesLen ->
    callStatus file $ \handle -> capiSetUserKv tensorFileNative handle keysPtr valuesPtr valuesLen
 where
  validateUserKv (key, value) = do
    validateRequiredString "user metadata key" key
    validateString "user metadata value" value

callStatus :: TensorFile -> (Ptr CHandle -> IO CInt) -> IO (Result ())
callStatus TensorFile{tensorFileNative, tensorFileHandle} nativeCall =
  withForeignPtr tensorFileHandle $ \handle -> do
    status <- nativeCall handle
    if status == okStatus
      then pure (Right ())
      else Left <$> lastError tensorFileNative

-- | Set the write-forward compression configuration for future dense appends.
setCompressionConfig :: TensorFile -> CompressionConfig -> IO (Result ())
setCompressionConfig file@TensorFile{tensorFileNative} config =
  alloca $ \configPtr -> do
    poke configPtr (compressionConfigToC config)
    callStatus file $ \handle -> capiSetCompressionConfig tensorFileNative handle configPtr

-- | Get the current write-forward compression configuration.
getCompressionConfig :: TensorFile -> IO (Result CompressionConfig)
getCompressionConfig TensorFile{tensorFileNative, tensorFileHandle} =
  withForeignPtr tensorFileHandle $ \handle ->
    alloca $ \configPtr -> do
      poke configPtr (compressionConfigToC (CompressionConfig CompressionForceOff CompressionZstd 0 0))
      status <- capiGetCompressionConfig tensorFileNative handle configPtr
      if status == okStatus
        then compressionConfigFromC <$> peek configPtr
        else Left <$> lastError tensorFileNative

compressionConfigToC :: CompressionConfig -> CArcadiaTioCompressionConfig
compressionConfigToC CompressionConfig{compressionMode, compressionCodec, compressionMinPayloadBytes, compressionZstdLevel} =
  CArcadiaTioCompressionConfig
    { cCompressionVersion = 1
    , cCompressionStructSize = compressionConfigStructSize
    , cCompressionMode = compressionModeToRaw compressionMode
    , cCompressionCodec = compressionCodecToRaw compressionCodec
    , cCompressionMinPayloadBytes = compressionMinPayloadBytes
    , cCompressionZstdLevel = compressionZstdLevel
    }

compressionConfigFromC :: CArcadiaTioCompressionConfig -> Result CompressionConfig
compressionConfigFromC CArcadiaTioCompressionConfig{cCompressionMode, cCompressionCodec, cCompressionMinPayloadBytes, cCompressionZstdLevel} = do
  mode <- maybe (Left (invalidArgument "native compression config has unknown mode")) Right (compressionModeFromRaw cCompressionMode)
  codec <- maybe (Left (invalidArgument "native compression config has unknown codec")) Right (compressionCodecFromRaw cCompressionCodec)
  Right CompressionConfig{compressionMode = mode, compressionCodec = codec, compressionMinPayloadBytes = cCompressionMinPayloadBytes, compressionZstdLevel = cCompressionZstdLevel}

compressionModeToRaw :: CompressionMode -> CInt
compressionModeToRaw mode = case mode of
  CompressionForceOff -> 0
  CompressionAuto -> 1
  CompressionForceOn -> 2

compressionModeFromRaw :: CInt -> Maybe CompressionMode
compressionModeFromRaw raw = case raw of
  0 -> Just CompressionForceOff
  1 -> Just CompressionAuto
  2 -> Just CompressionForceOn
  _ -> Nothing

compressionCodecToRaw :: CompressionCodec -> CInt
compressionCodecToRaw codec = case codec of
  CompressionZstd -> 0
  CompressionLz4 -> 1

compressionCodecFromRaw :: CInt -> Maybe CompressionCodec
compressionCodecFromRaw raw = case raw of
  0 -> Just CompressionZstd
  1 -> Just CompressionLz4
  _ -> Nothing

-- | Return the current head commit metadata.
headCommit :: TensorFile -> IO (Result CommitInfo)
headCommit file = withHandleOutput file (capiHeadCommit (tensorFileNative file)) (Right . commitInfoFromC)

-- | List visible commits newest-to-oldest up to the native limit.
listCommits :: TensorFile -> Word32 -> IO (Result [CommitInfo])
listCommits TensorFile{tensorFileNative, tensorFileHandle} limit =
  withForeignPtr tensorFileHandle $ \handle ->
    alloca $ \listPtr -> do
      poke listPtr emptyCArcadiaTioCommitList
      status <- capiListCommits tensorFileNative handle limit listPtr
      if status == okStatus
        then (peek listPtr >>= copyCommitList) `finally` capiCommitListFree tensorFileNative listPtr
        else do
          err <- lastError tensorFileNative
          capiCommitListFree tensorFileNative listPtr
          pure (Left err)

copyCommitList :: CArcadiaTioCommitList -> IO (Result [CommitInfo])
copyCommitList CArcadiaTioCommitList{cCommitListItems, cCommitListLen} =
  let count = fromIntegralCSize cCommitListLen
   in if count == 0
        then pure (Right [])
        else if cCommitListItems == nullPtr
          then pure (Left (invalidArgument "native commit list pointer is null"))
          else Right . map commitInfoFromC <$> peekArray count cCommitListItems

commitInfoFromC :: CArcadiaTioCommitInfo -> CommitInfo
commitInfoFromC CArcadiaTioCommitInfo{cCommitSeq, cCommitFooterOffset, cCommitPrevFooterOffset} =
  CommitInfo
    { commitSeq = cCommitSeq
    , commitFooterOffset = cCommitFooterOffset
    , commitPrevFooterOffset = cCommitPrevFooterOffset
    }

-- | Publish a metadata-only pop marker where supported by the native runtime.
pop :: TensorFile -> IO (Result ())
pop file@TensorFile{tensorFileNative} = callStatus file (capiPop tensorFileNative)

-- | Publish a metadata-only batched pop marker where supported by the native runtime.
popBatched :: TensorFile -> Word32 -> IO (Result ())
popBatched file@TensorFile{tensorFileNative} n = callStatus file $ \handle -> capiPopBatched tensorFileNative handle n

-- | Publish an append-only revert marker to the requested commit where supported.
revertCommit :: TensorFile -> Word64 -> IO (Result ())
revertCommit file@TensorFile{tensorFileNative} commitSeqValue = callStatus file $ \handle -> capiRevertCommit tensorFileNative handle commitSeqValue

-- | Read a full retained visible commit snapshot.
readAtCommit :: TensorFile -> Word64 -> IO (Result SomeTensor)
readAtCommit file commitSeqValue = readAtCommitSelected file commitSeqValue []

-- | Read a retained visible commit snapshot with per-axis selectors. An empty
-- selector list asks the native library for the full snapshot.
readAtCommitSelected :: TensorFile -> Word64 -> [EntrySelector] -> IO (Result SomeTensor)
readAtCommitSelected file@TensorFile{tensorFileNative} commitSeqValue selectors =
  withEntrySelectors selectors $ \selectorsPtr selectorsLen ->
    readTensor file $ \handle outPtr -> capiReadAtCommit tensorFileNative handle commitSeqValue selectorsPtr selectorsLen outPtr

-- | Read a full retained visible commit snapshot with fill-value materialization
-- and a copied validity mask.
readAtCommitDense :: TensorFile -> Word64 -> Double -> IO (Result SomeDenseRead)
readAtCommitDense file commitSeqValue fillValue = readAtCommitDenseSelected file commitSeqValue [] fillValue

-- | Read a retained visible commit snapshot with selectors, fill-value
-- materialization, and a copied validity mask.
readAtCommitDenseSelected :: TensorFile -> Word64 -> [EntrySelector] -> Double -> IO (Result SomeDenseRead)
readAtCommitDenseSelected TensorFile{tensorFileNative, tensorFileHandle} commitSeqValue selectors fillValue =
  withEntrySelectors selectors $ \selectorsPtr selectorsLen ->
    withForeignPtr tensorFileHandle $ \handle ->
      alloca $ \tensorPtr ->
        alloca $ \maskPtr -> do
          poke tensorPtr emptyCArcadiaTioTensor
          poke maskPtr emptyCArcadiaTioMask
          status <- capiReadAtCommitDense tensorFileNative handle commitSeqValue selectorsPtr selectorsLen fillValue tensorPtr maskPtr
          if status == okStatus
            then (copySomeDenseReadFromPtrs tensorPtr maskPtr) `finally` freeDenseOutputs tensorPtr maskPtr
            else do
              err <- lastError tensorFileNative
              freeDenseOutputs tensorPtr maskPtr
              pure (Left err)
 where
  freeDenseOutputs tensorPtr maskPtr = do
    capiTensorFree tensorFileNative tensorPtr
    capiMaskFree tensorFileNative maskPtr

-- | Read current visible data with selectors and execution options, returning a
-- copied tensor and copied execution report.

-- | Read Coordinate v1 metadata from an open file and copy all strings before freeing native memory.
coordinateMeta :: TensorFile -> IO (Result [AxisCoordinateMeta])
coordinateMeta TensorFile{tensorFileNative, tensorFileHandle} =
  withForeignPtr tensorFileHandle $ \handle ->
    alloca $ \metaPtrPtr ->
      alloca $ \lenPtr -> do
        poke metaPtrPtr nullPtr
        poke lenPtr 0
        status <- capiCoordinateMeta tensorFileNative handle metaPtrPtr lenPtr
        metaPtr <- peek metaPtrPtr
        len <- peek lenPtr
        if status == okStatus
          then (fmap sequence (mapM copyAxisCoordinateMeta =<< peekArray (fromIntegralCSize len) metaPtr)) `finally` freeCoordinateMetaIfNeeded tensorFileNative metaPtr len
          else do
            err <- lastError tensorFileNative
            freeCoordinateMetaIfNeeded tensorFileNative metaPtr len
            pure (Left err)

-- | Load Coordinate v1 metadata from a file path without opening a mutable handle.
loadCoordinateMeta :: NativeLibrary -> FilePath -> IO (Result [AxisCoordinateMeta])
loadCoordinateMeta native path =
  withCString path $ \cPath ->
    alloca $ \metaPtrPtr ->
      alloca $ \lenPtr -> do
        poke metaPtrPtr nullPtr
        poke lenPtr 0
        status <- capiLoadCoordinateMeta native cPath metaPtrPtr lenPtr
        metaPtr <- peek metaPtrPtr
        len <- peek lenPtr
        if status == okStatus
          then (fmap sequence (mapM copyAxisCoordinateMeta =<< peekArray (fromIntegralCSize len) metaPtr)) `finally` freeCoordinateMetaIfNeeded native metaPtr len
          else do
            err <- lastError native
            freeCoordinateMetaIfNeeded native metaPtr len
            pure (Left err)


freeCoordinateMetaIfNeeded :: NativeLibrary -> Ptr CArcadiaTioAxisCoordinateMeta -> CSize -> IO ()
freeCoordinateMetaIfNeeded native ptr len = if ptr == nullPtr then pure () else capiAxisCoordinateMetaFree native ptr len

freeCoordinateMetaV2IfNeeded :: NativeLibrary -> Ptr CArcadiaTioAxisCoordinateMetaV2 -> CSize -> IO ()
freeCoordinateMetaV2IfNeeded native ptr len = if ptr == nullPtr then pure () else capiAxisCoordinateMetaV2Free native ptr len

copyAxisCoordinateMeta :: CArcadiaTioAxisCoordinateMeta -> IO (Result AxisCoordinateMeta)
copyAxisCoordinateMeta CArcadiaTioAxisCoordinateMeta{cAxisCoordinateMetaAxis, cAxisCoordinateMetaAxisNameSnapshot, cAxisCoordinateMetaName, cAxisCoordinateMetaKind, cAxisCoordinateMetaDType, cAxisCoordinateMetaEncoding, cAxisCoordinateMetaLength, cAxisCoordinateMetaSorted, cAxisCoordinateMetaMonotonicity, cAxisCoordinateMetaUniqueness, cAxisCoordinateMetaStorageKind, cAxisCoordinateMetaExternalSourceKind, cAxisCoordinateMetaExternalUri, cAxisCoordinateMetaRequired, cAxisCoordinateMetaValidationStatus} = do
  axisName <- peekOptionalCString cAxisCoordinateMetaAxisNameSnapshot
  name <- peekOptionalCString cAxisCoordinateMetaName
  externalUri <- peekOptionalCString cAxisCoordinateMetaExternalUri
  pure $ Right AxisCoordinateMeta
    { axisCoordinateMetaAxis = fromIntegralCSize cAxisCoordinateMetaAxis
    , axisCoordinateMetaAxisNameSnapshot = axisName
    , axisCoordinateMetaName = name
    , axisCoordinateMetaKind = coordinateKindFromRaw cAxisCoordinateMetaKind
    , axisCoordinateMetaDType = coordinateDTypeFromRaw cAxisCoordinateMetaDType
    , axisCoordinateMetaEncoding = coordinateEncodingFromRaw cAxisCoordinateMetaEncoding
    , axisCoordinateMetaLength = cAxisCoordinateMetaLength
    , axisCoordinateMetaSorted = coordinateSortednessFromRaw cAxisCoordinateMetaSorted
    , axisCoordinateMetaMonotonicity = coordinateMonotonicityFromRaw cAxisCoordinateMetaMonotonicity
    , axisCoordinateMetaUniqueness = coordinateUniquenessFromRaw cAxisCoordinateMetaUniqueness
    , axisCoordinateMetaStorageKind = coordinateStorageKindFromRaw cAxisCoordinateMetaStorageKind
    , axisCoordinateMetaExternalSourceKind = coordinateSourceKindFromRaw cAxisCoordinateMetaExternalSourceKind
    , axisCoordinateMetaExternalUri = externalUri
    , axisCoordinateMetaRequired = cAxisCoordinateMetaRequired /= 0
    , axisCoordinateMetaValidationStatus = coordinateValidationStatusFromRaw cAxisCoordinateMetaValidationStatus
    }

coordinateMetaV2 :: TensorFile -> CoordinateV2Options -> IO (Result [AxisCoordinateMetaV2])
coordinateMetaV2 TensorFile{tensorFileNative, tensorFileHandle} _options =
  withForeignPtr tensorFileHandle $ \handle ->
    alloca $ \metaPtrPtr ->
      alloca $ \lenPtr -> do
        poke metaPtrPtr nullPtr
        poke lenPtr 0
        status <- capiCoordinateMetaV2 tensorFileNative handle metaPtrPtr lenPtr
        metaPtr <- peek metaPtrPtr
        len <- peek lenPtr
        if status == okStatus
          then (fmap sequence (mapM copyAxisCoordinateMetaV2 =<< peekArray (fromIntegralCSize len) metaPtr)) `finally` freeCoordinateMetaV2IfNeeded tensorFileNative metaPtr len
          else do
            err <- lastError tensorFileNative
            freeCoordinateMetaV2IfNeeded tensorFileNative metaPtr len
            pure (Left err)

loadCoordinateMetaV2 :: NativeLibrary -> FilePath -> IO (Result [AxisCoordinateMetaV2])
loadCoordinateMetaV2 native path =
  withCString path $ \cPath ->
    alloca $ \metaPtrPtr ->
      alloca $ \lenPtr -> do
        poke metaPtrPtr nullPtr
        poke lenPtr 0
        status <- capiLoadCoordinateMetaV2 native cPath metaPtrPtr lenPtr
        metaPtr <- peek metaPtrPtr
        len <- peek lenPtr
        if status == okStatus
          then (fmap sequence (mapM copyAxisCoordinateMetaV2 =<< peekArray (fromIntegralCSize len) metaPtr)) `finally` freeCoordinateMetaV2IfNeeded native metaPtr len
          else do
            err <- lastError native
            freeCoordinateMetaV2IfNeeded native metaPtr len
            pure (Left err)

copyAxisCoordinateMetaV2 :: CArcadiaTioAxisCoordinateMetaV2 -> IO (Result AxisCoordinateMetaV2)
copyAxisCoordinateMetaV2 raw@CArcadiaTioAxisCoordinateMetaV2{cAxisCoordinateMetaV2IndexSummaries, cAxisCoordinateMetaV2IndexSummariesLen} = do
  axisName <- peekOptionalCString (cAxisCoordinateMetaV2AxisNameSnapshot raw)
  descriptorId <- peekOptionalCString (cAxisCoordinateMetaV2DescriptorId raw)
  name <- peekOptionalCString (cAxisCoordinateMetaV2Name raw)
  reason <- peekOptionalCString (cAxisCoordinateMetaV2Reason raw)
  dictionary <- copyDictionarySummary (cAxisCoordinateMetaV2Dictionary raw)
  external <- copyExternalBinding (cAxisCoordinateMetaV2ExternalBinding raw)
  indexes <- mapM copyIndexSummary =<< peekArray (fromIntegralCSize cAxisCoordinateMetaV2IndexSummariesLen) cAxisCoordinateMetaV2IndexSummaries
  pure $ AxisCoordinateMetaV2
    <$> pure (fromIntegralCSize (cAxisCoordinateMetaV2Axis raw))
    <*> pure axisName
    <*> pure descriptorId
    <*> pure (cAxisCoordinateMetaV2DescriptorRevision raw)
    <*> pure name
    <*> pure (coordinateKindFromRaw (cAxisCoordinateMetaV2Kind raw))
    <*> pure (coordinateValueDomainV2FromRaw (cAxisCoordinateMetaV2ValueDomain raw))
    <*> pure (coordinateDTypeFromRaw (cAxisCoordinateMetaV2NumericDType raw))
    <*> pure (coordinateEncodingFromRaw (cAxisCoordinateMetaV2NumericEncoding raw))
    <*> pure (coordinateCodeDTypeV2FromRaw (cAxisCoordinateMetaV2CodeDType raw))
    <*> pure (cAxisCoordinateMetaV2Length raw)
    <*> pure (coordinateSortednessFromRaw (cAxisCoordinateMetaV2Sorted raw))
    <*> pure (coordinateMonotonicityFromRaw (cAxisCoordinateMetaV2Monotonicity raw))
    <*> pure (coordinateUniquenessFromRaw (cAxisCoordinateMetaV2Uniqueness raw))
    <*> pure (cAxisCoordinateMetaV2Required raw /= 0)
    <*> pure (coordinateAvailabilityV2FromRaw (cAxisCoordinateMetaV2Availability raw))
    <*> pure (coordinateStatusCategoryV2FromRaw (cAxisCoordinateMetaV2StatusCategory raw))
    <*> pure reason
    <*> dictionary
    <*> external
    <*> sequence indexes

copyDictionarySummary :: CArcadiaTioCoordinateDictionarySummaryV2 -> IO (Result CoordinateDictionarySummaryV2)
copyDictionarySummary CArcadiaTioCoordinateDictionarySummaryV2{cCoordinateDictionarySummaryDictionaryId, cCoordinateDictionarySummaryRevision, cCoordinateDictionarySummaryCodeDType, cCoordinateDictionarySummaryEntryCount, cCoordinateDictionarySummaryStableIdsUnique, cCoordinateDictionarySummaryDisplayLabelsUnique, cCoordinateDictionarySummaryAliasesUnique, cCoordinateDictionarySummaryCodesStableAcrossRevisions, cCoordinateDictionarySummaryContentId} = do
  dictionaryId <- peekOptionalCString cCoordinateDictionarySummaryDictionaryId
  contentId <- peekOptionalCString cCoordinateDictionarySummaryContentId
  pure $ Right CoordinateDictionarySummaryV2
    { coordinateDictionarySummaryId = dictionaryId
    , coordinateDictionarySummaryRevision = cCoordinateDictionarySummaryRevision
    , coordinateDictionarySummaryCodeDType = coordinateCodeDTypeV2FromRaw cCoordinateDictionarySummaryCodeDType
    , coordinateDictionarySummaryEntryCount = cCoordinateDictionarySummaryEntryCount
    , coordinateDictionarySummaryStableIdsUnique = cCoordinateDictionarySummaryStableIdsUnique /= 0
    , coordinateDictionarySummaryDisplayLabelsUnique = cCoordinateDictionarySummaryDisplayLabelsUnique /= 0
    , coordinateDictionarySummaryAliasesUnique = cCoordinateDictionarySummaryAliasesUnique /= 0
    , coordinateDictionarySummaryCodesStableAcrossRevisions = cCoordinateDictionarySummaryCodesStableAcrossRevisions /= 0
    , coordinateDictionarySummaryContentId = contentId
    }

copyExternalBinding :: CArcadiaTioCoordinateExternalBindingV2 -> IO (Result CoordinateExternalBindingV2)
copyExternalBinding CArcadiaTioCoordinateExternalBindingV2{cCoordinateExternalBindingSourceKind, cCoordinateExternalBindingLogicalId, cCoordinateExternalBindingPrivacySafeDisplay, cCoordinateExternalBindingContentId, cCoordinateExternalBindingValueDomain, cCoordinateExternalBindingLength, cCoordinateExternalBindingAvailability, cCoordinateExternalBindingStatusCategory, cCoordinateExternalBindingRequired} = do
  logicalId <- peekOptionalCString cCoordinateExternalBindingLogicalId
  display <- peekOptionalCString cCoordinateExternalBindingPrivacySafeDisplay
  contentId <- peekOptionalCString cCoordinateExternalBindingContentId
  pure $ Right CoordinateExternalBindingV2
    { coordinateExternalBindingSourceKind = coordinateSourceKindV2FromRaw cCoordinateExternalBindingSourceKind
    , coordinateExternalBindingLogicalId = logicalId
    , coordinateExternalBindingPrivacySafeDisplay = display
    , coordinateExternalBindingContentId = contentId
    , coordinateExternalBindingValueDomain = coordinateValueDomainV2FromRaw cCoordinateExternalBindingValueDomain
    , coordinateExternalBindingLength = cCoordinateExternalBindingLength
    , coordinateExternalBindingAvailability = coordinateAvailabilityV2FromRaw cCoordinateExternalBindingAvailability
    , coordinateExternalBindingStatusCategory = coordinateStatusCategoryV2FromRaw cCoordinateExternalBindingStatusCategory
    , coordinateExternalBindingRequired = cCoordinateExternalBindingRequired /= 0
    }

copyIndexSummary :: CArcadiaTioCoordinateIndexSummaryV2 -> IO (Result CoordinateIndexSummaryV2)
copyIndexSummary raw = do
  indexId <- peekOptionalCString (cCoordinateIndexSummaryIndexId raw)
  reason <- peekOptionalCString (cCoordinateIndexSummaryReason raw)
  source <- copyIndexSourceBinding (cCoordinateIndexSummarySourceBinding raw)
  pure $ CoordinateIndexSummaryV2
    <$> pure indexId
    <*> pure (coordinateIndexKindV2FromRaw (cCoordinateIndexSummaryIndexKind raw))
    <*> pure (coordinateKeyDomainV2FromRaw (cCoordinateIndexSummaryKeyDomain raw))
    <*> source
    <*> pure (coordinateSortednessFromRaw (cCoordinateIndexSummarySorted raw))
    <*> pure (coordinateMonotonicityFromRaw (cCoordinateIndexSummaryMonotonicity raw))
    <*> pure (coordinateUniquenessFromRaw (cCoordinateIndexSummaryUniqueness raw))
    <*> pure (cCoordinateIndexSummaryFormatVersion raw)
    <*> pure (cCoordinateIndexSummaryBuildVersion raw)
    <*> pure (coordinateIndexValidationStatusV2FromRaw (cCoordinateIndexSummaryValidationStatus raw))
    <*> pure (coordinateIndexFallbackV2FromRaw (cCoordinateIndexSummaryFallback raw))
    <*> pure (coordinateIndexUseV2FromRaw (cCoordinateIndexSummarySelectedUse raw))
    <*> pure (cCoordinateIndexSummaryRequired raw /= 0)
    <*> pure reason

copyIndexSourceBinding :: CArcadiaTioCoordinateIndexSourceBindingV2 -> IO (Result CoordinateIndexSourceBindingV2)
copyIndexSourceBinding raw = do
  descriptorId <- peekOptionalCString (cCoordinateIndexSourceDescriptorId raw)
  valueObjectId <- peekOptionalCString (cCoordinateIndexSourceValueObjectId raw)
  dictionaryId <- peekOptionalCString (cCoordinateIndexSourceDictionaryId raw)
  dictionaryContentId <- peekOptionalCString (cCoordinateIndexSourceDictionaryContentId raw)
  externalLogicalId <- peekOptionalCString (cCoordinateIndexSourceExternalLogicalId raw)
  externalContentId <- peekOptionalCString (cCoordinateIndexSourceExternalContentId raw)
  rootId <- peekOptionalCString (cCoordinateIndexSourceRootId raw)
  pure $ Right CoordinateIndexSourceBindingV2
    { coordinateIndexSourceDescriptorId = descriptorId
    , coordinateIndexSourceDescriptorRevision = cCoordinateIndexSourceDescriptorRevision raw
    , coordinateIndexSourceValueDomain = coordinateValueDomainV2FromRaw (cCoordinateIndexSourceValueDomain raw)
    , coordinateIndexSourceValueObjectId = valueObjectId
    , coordinateIndexSourceDictionaryId = dictionaryId
    , coordinateIndexSourceDictionaryRevision = cCoordinateIndexSourceDictionaryRevision raw
    , coordinateIndexSourceDictionaryContentId = dictionaryContentId
    , coordinateIndexSourceExternalSourceKind = coordinateSourceKindV2FromRaw (cCoordinateIndexSourceExternalSourceKind raw)
    , coordinateIndexSourceExternalLogicalId = externalLogicalId
    , coordinateIndexSourceExternalContentId = externalContentId
    , coordinateIndexSourceRootId = rootId
    , coordinateIndexSourceAxis = fromIntegralCSize (cCoordinateIndexSourceAxis raw)
    , coordinateIndexSourceRootExtent = cCoordinateIndexSourceRootExtent raw
    , coordinateIndexSourceAppendStart = cCoordinateIndexSourceAppendStart raw
    , coordinateIndexSourceAppendCount = cCoordinateIndexSourceAppendCount raw
    }

-- | Read Coordinate v1 inline values as an owned tensor. Native tensor memory is always freed.
readAxisCoordinates :: TensorFile -> Int -> IO (Result SomeTensor)
readAxisCoordinates file@TensorFile{tensorFileNative} axis
  | axis < 0 = pure (Left (invalidArgument "coordinate axis must be non-negative"))
  | otherwise = readTensor file $ \handle outPtr -> capiReadAxisCoordinates tensorFileNative handle (CSize (fromIntegral axis)) outPtr

-- | Return the unique index for a validated inline i32 coordinate value.
coordinateIndexI32 :: TensorFile -> Int -> Int32 -> IO (Result Word32)
coordinateIndexI32 TensorFile{tensorFileNative, tensorFileHandle} axis value
  | axis < 0 = pure (Left (invalidArgument "coordinate axis must be non-negative"))
  | otherwise =
      withForeignPtr tensorFileHandle $ \handle ->
        alloca $ \outPtr -> do
          poke outPtr 0
          status <- capiCoordinateIndexI32 tensorFileNative handle (CSize (fromIntegral axis)) value outPtr
          if status == okStatus
            then Right <$> peek outPtr
            else Left <$> lastError tensorFileNative

-- | Return the unique index for a validated inline i64 coordinate value.
coordinateIndexI64 :: TensorFile -> Int -> Int64 -> IO (Result Word32)
coordinateIndexI64 TensorFile{tensorFileNative, tensorFileHandle} axis value
  | axis < 0 = pure (Left (invalidArgument "coordinate axis must be non-negative"))
  | otherwise =
      withForeignPtr tensorFileHandle $ \handle ->
        alloca $ \outPtr -> do
          poke outPtr 0
          status <- capiCoordinateIndexI64 tensorFileNative handle (CSize (fromIntegral axis)) value outPtr
          if status == okStatus
            then Right <$> peek outPtr
            else Left <$> lastError tensorFileNative

-- | Return the half-open index range overlapping an inclusive i32 coordinate interval.
coordinateRangeI32 :: TensorFile -> Int -> Int32 -> Int32 -> IO (Result (Word32, Word32))
coordinateRangeI32 TensorFile{tensorFileNative, tensorFileHandle} axis start end
  | axis < 0 = pure (Left (invalidArgument "coordinate axis must be non-negative"))
  | start > end = pure (Left (invalidArgument "coordinate range start must be <= end"))
  | otherwise =
      withForeignPtr tensorFileHandle $ \handle ->
        alloca $ \startPtr ->
          alloca $ \endPtr -> do
            poke startPtr 0
            poke endPtr 0
            status <- capiCoordinateRangeI32 tensorFileNative handle (CSize (fromIntegral axis)) start end startPtr endPtr
            if status == okStatus
              then (,) <$> peek startPtr <*> peek endPtr >>= pure . Right
              else Left <$> lastError tensorFileNative

-- | Return the half-open index range overlapping an inclusive i64 coordinate interval.
coordinateRangeI64 :: TensorFile -> Int -> Int64 -> Int64 -> IO (Result (Word32, Word32))
coordinateRangeI64 TensorFile{tensorFileNative, tensorFileHandle} axis start end
  | axis < 0 = pure (Left (invalidArgument "coordinate axis must be non-negative"))
  | start > end = pure (Left (invalidArgument "coordinate range start must be <= end"))
  | otherwise =
      withForeignPtr tensorFileHandle $ \handle ->
        alloca $ \startPtr ->
          alloca $ \endPtr -> do
            poke startPtr 0
            poke endPtr 0
            status <- capiCoordinateRangeI64 tensorFileNative handle (CSize (fromIntegral axis)) start end startPtr endPtr
            if status == okStatus
              then (,) <$> peek startPtr <*> peek endPtr >>= pure . Right
              else Left <$> lastError tensorFileNative

readAxisCoordinatesV2 :: TensorFile -> Int -> CoordinateV2Options -> IO (Result CoordinateValueSliceV2)
readAxisCoordinatesV2 TensorFile{tensorFileNative, tensorFileHandle} axis options
  | axis < 0 = pure (Left (invalidArgument "coordinate axis must be non-negative"))
  | otherwise =
      withForeignPtr tensorFileHandle $ \handle ->
        withCoordinateV2Options options $ \optionsPtr ->
          alloca $ \valuesPtr -> do
            poke valuesPtr (CArcadiaTioCoordinateValueSliceV2 1 112 0 0 0 0 nullPtr 0 0 0 0 0 nullPtr)
            status <- capiReadAxisCoordinatesV2 tensorFileNative handle (CSize (fromIntegral axis)) optionsPtr valuesPtr
            if status == okStatus
              then (peek valuesPtr >>= copyCoordinateValueSlice) `finally` capiCoordinateValueSliceV2Free tensorFileNative valuesPtr
              else do
                err <- lastError tensorFileNative
                capiCoordinateValueSliceV2Free tensorFileNative valuesPtr
                pure (Left err)

copyCoordinateValueSlice :: CArcadiaTioCoordinateValueSliceV2 -> IO (Result CoordinateValueSliceV2)
copyCoordinateValueSlice raw = do
  reason <- peekOptionalCString (cCoordinateValueSliceReason raw)
  let bytesLen = fromIntegralCSize (cCoordinateValueSliceLen raw) * max 0 (fromIntegralCSize (cCoordinateValueSliceElementSize raw))
  bytes <- if cCoordinateValueSliceData raw == nullPtr || bytesLen <= 0 then pure [] else peekArray bytesLen (cCoordinateValueSliceData raw)
  pure $ Right CoordinateValueSliceV2
    { coordinateValueSliceDomain = coordinateValueDomainV2FromRaw (cCoordinateValueSliceValueDomain raw)
    , coordinateValueSliceNumericDType = coordinateDTypeFromRaw (cCoordinateValueSliceNumericDType raw)
    , coordinateValueSliceNumericEncoding = coordinateEncodingFromRaw (cCoordinateValueSliceNumericEncoding raw)
    , coordinateValueSliceCodeDType = coordinateCodeDTypeV2FromRaw (cCoordinateValueSliceCodeDType raw)
    , coordinateValueSliceBytes = bytes
    , coordinateValueSliceLen = fromIntegralCSize (cCoordinateValueSliceLen raw)
    , coordinateValueSliceElementSize = fromIntegralCSize (cCoordinateValueSliceElementSize raw)
    , coordinateValueSliceFixedTextWidth = fromIntegralCSize (cCoordinateValueSliceFixedTextWidth raw)
    , coordinateValueSliceAvailability = coordinateAvailabilityV2FromRaw (cCoordinateValueSliceAvailability raw)
    , coordinateValueSliceStatusCategory = coordinateStatusCategoryV2FromRaw (cCoordinateValueSliceStatusCategory raw)
    , coordinateValueSliceReason = reason
    }

coordinateDictionaryV2 :: TensorFile -> Int -> CoordinateV2Options -> IO (Result CoordinateDictionaryV2)
coordinateDictionaryV2 TensorFile{tensorFileNative, tensorFileHandle} axis options
  | axis < 0 = pure (Left (invalidArgument "coordinate axis must be non-negative"))
  | otherwise =
      withForeignPtr tensorFileHandle $ \handle ->
        withCoordinateV2Options options $ \optionsPtr ->
          alloca $ \dictionaryPtr -> do
            poke dictionaryPtr (CArcadiaTioCoordinateDictionaryV2 1 160 emptyDictionarySummary nullPtr 0 0 nullPtr)
            status <- capiCoordinateDictionaryV2 tensorFileNative handle (CSize (fromIntegral axis)) optionsPtr dictionaryPtr
            if status == okStatus
              then (peek dictionaryPtr >>= copyCoordinateDictionary) `finally` capiCoordinateDictionaryV2Free tensorFileNative dictionaryPtr
              else do
                err <- lastError tensorFileNative
                capiCoordinateDictionaryV2Free tensorFileNative dictionaryPtr
                pure (Left err)
 where
  emptyDictionarySummary = CArcadiaTioCoordinateDictionarySummaryV2 1 80 nullPtr 0 0 0 0 0 0 0 nullPtr

copyCoordinateDictionary :: CArcadiaTioCoordinateDictionaryV2 -> IO (Result CoordinateDictionaryV2)
copyCoordinateDictionary raw = do
  summary <- copyDictionarySummary (cCoordinateDictionarySummary raw)
  entries <- mapM copyDictionaryEntry =<< peekArray (fromIntegralCSize (cCoordinateDictionaryEntriesLen raw)) (cCoordinateDictionaryEntries raw)
  reason <- peekOptionalCString (cCoordinateDictionaryReason raw)
  pure $ CoordinateDictionaryV2 <$> summary <*> sequence entries <*> pure (coordinateStatusCategoryV2FromRaw (cCoordinateDictionaryStatusCategory raw)) <*> pure reason

copyDictionaryEntry :: CArcadiaTioCoordinateDictionaryEntryV2 -> IO (Result CoordinateDictionaryEntryV2)
copyDictionaryEntry raw = do
  stableId <- peekOptionalCString (cCoordinateDictionaryEntryStableId raw)
  display <- peekOptionalCString (cCoordinateDictionaryEntryDisplayLabel raw)
  aliases <- peekCStringArray (cCoordinateDictionaryEntryAliases raw) (cCoordinateDictionaryEntryAliasesLen raw)
  pure $ Right CoordinateDictionaryEntryV2
    { coordinateDictionaryEntryCode = cCoordinateDictionaryEntryCode raw
    , coordinateDictionaryEntryStableId = stableId
    , coordinateDictionaryEntryDisplayLabel = display
    , coordinateDictionaryEntryAliases = aliases
    }

peekCStringArray :: Ptr CString -> CSize -> IO [String]
peekCStringArray ptr len
  | ptr == nullPtr || len == 0 = pure []
  | otherwise = mapM peekCString =<< peekArray (fromIntegralCSize len) ptr

-- | Perform an exact Coordinate v2 lookup and copy the native result carrier.
coordinateLookupV2 :: TensorFile -> Int -> CoordinateLookupKeyV2 -> CoordinateV2Options -> IO (Result CoordinateLookupResultV2)
coordinateLookupV2 TensorFile{tensorFileNative, tensorFileHandle} axis key options
  | axis < 0 = pure (Left (invalidArgument "coordinate axis must be non-negative"))
  | otherwise = withValidatedLookupKey key $ \withKey ->
      withForeignPtr tensorFileHandle $ \handle ->
        withKey $ \keyPtr ->
          withCoordinateV2Options options $ \optionsPtr ->
            alloca $ \resultPtr -> do
              poke resultPtr emptyCArcadiaTioCoordinateLookupResultV2
              status <- capiCoordinateLookupV2 tensorFileNative handle (CSize (fromIntegral axis)) keyPtr optionsPtr resultPtr
              finishCoordinateLookup tensorFileNative status resultPtr

-- | Perform a half-open Coordinate v2 range lookup and copy the native result carrier.
coordinateLookupRangeV2 :: TensorFile -> Int -> CoordinateLookupKeyV2 -> CoordinateLookupKeyV2 -> CoordinateV2Options -> IO (Result CoordinateLookupResultV2)
coordinateLookupRangeV2 TensorFile{tensorFileNative, tensorFileHandle} axis lower upper options
  | axis < 0 = pure (Left (invalidArgument "coordinate axis must be non-negative"))
  | otherwise = withValidatedLookupKey lower $ \withLower ->
      withValidatedLookupKey upper $ \withUpper ->
        withForeignPtr tensorFileHandle $ \handle ->
          withLower $ \lowerPtr ->
            withUpper $ \upperPtr ->
              withCoordinateV2Options options $ \optionsPtr ->
                alloca $ \resultPtr -> do
                  poke resultPtr emptyCArcadiaTioCoordinateLookupResultV2
                  status <- capiCoordinateLookupRangeV2 tensorFileNative handle (CSize (fromIntegral axis)) lowerPtr upperPtr optionsPtr resultPtr
                  finishCoordinateLookup tensorFileNative status resultPtr

withValidatedLookupKey :: CoordinateLookupKeyV2 -> (((Ptr CArcadiaTioCoordinateLookupKeyV2 -> IO (Result CoordinateLookupResultV2)) -> IO (Result CoordinateLookupResultV2)) -> IO (Result CoordinateLookupResultV2)) -> IO (Result CoordinateLookupResultV2)
withValidatedLookupKey key action =
  case validateLookupKey key of
    Left err -> pure (Left err)
    Right () -> action (withCoordinateLookupKey key)

validateLookupKey :: CoordinateLookupKeyV2 -> Result ()
validateLookupKey key = case key of
  CoordinateLookupKeyText _ value -> validateString "coordinate lookup text" value
  CoordinateLookupKeyBytes _ _ width | width < 0 -> Left (invalidArgument "coordinate lookup fixed-text width must be non-negative")
  _ -> Right ()

withCoordinateLookupKey :: CoordinateLookupKeyV2 -> (Ptr CArcadiaTioCoordinateLookupKeyV2 -> IO a) -> IO a
withCoordinateLookupKey key action = case key of
  CoordinateLookupKeyI32 value -> pokeLookup emptyCArcadiaTioCoordinateLookupKeyV2{cCoordinateLookupKeyDomain = coordinateKeyDomainV2ToRaw CoordinateKeyI32, cCoordinateLookupKeyI32Value = value}
  CoordinateLookupKeyI64 value -> pokeLookup emptyCArcadiaTioCoordinateLookupKeyV2{cCoordinateLookupKeyDomain = coordinateKeyDomainV2ToRaw CoordinateKeyI64, cCoordinateLookupKeyI64Value = value}
  CoordinateLookupKeyDictionaryCode value -> pokeLookup emptyCArcadiaTioCoordinateLookupKeyV2{cCoordinateLookupKeyDomain = coordinateKeyDomainV2ToRaw CoordinateKeyDictionaryCode, cCoordinateLookupKeyCodeValue = value}
  CoordinateLookupKeyText domain value -> withCString value $ \textPtr -> pokeLookup emptyCArcadiaTioCoordinateLookupKeyV2{cCoordinateLookupKeyDomain = coordinateKeyDomainV2ToRaw domain, cCoordinateLookupKeyText = textPtr}
  CoordinateLookupKeyBytes domain bytes width -> withWord8Array bytes $ \bytesPtr bytesLen -> pokeLookup emptyCArcadiaTioCoordinateLookupKeyV2{cCoordinateLookupKeyDomain = coordinateKeyDomainV2ToRaw domain, cCoordinateLookupKeyBytes = bytesPtr, cCoordinateLookupKeyBytesLen = bytesLen, cCoordinateLookupKeyFixedTextWidth = CSize (fromIntegral width)}
 where
  pokeLookup raw = alloca $ \keyPtr -> poke keyPtr raw >> action keyPtr

finishCoordinateLookup :: NativeLibrary -> CInt -> Ptr CArcadiaTioCoordinateLookupResultV2 -> IO (Result CoordinateLookupResultV2)
finishCoordinateLookup native status resultPtr =
  ( if status == okStatus
      then peek resultPtr >>= copyCoordinateLookupResult
      else Left <$> lastError native
  ) `finally` capiCoordinateLookupResultV2Free native resultPtr

copyCoordinateLookupResult :: CArcadiaTioCoordinateLookupResultV2 -> IO (Result CoordinateLookupResultV2)
copyCoordinateLookupResult raw = do
  reason <- peekOptionalCString (cCoordinateLookupResultReason raw)
  positions <- if cCoordinateLookupResultPositions raw == nullPtr || cCoordinateLookupResultPositionsLen raw == 0 then pure [] else peekArray (fromIntegralCSize (cCoordinateLookupResultPositionsLen raw)) (cCoordinateLookupResultPositions raw)
  let status = coordinateLookupResultStatusV2FromRaw (cCoordinateLookupResultStatus raw)
      uniquePosition = if status == CoordinateLookupUniqueV2 then Just (cCoordinateLookupResultUniquePosition raw) else Nothing
      rangeValue = if status == CoordinateLookupRangeV2 then Just (cCoordinateLookupResultRangeStart raw, cCoordinateLookupResultRangeEnd raw) else Nothing
  pure $ Right CoordinateLookupResultV2
    { coordinateLookupStatus = status
    , coordinateLookupStatusCategory = coordinateStatusCategoryV2FromRaw (cCoordinateLookupResultStatusCategory raw)
    , coordinateLookupUniquePosition = uniquePosition
    , coordinateLookupRange = rangeValue
    , coordinateLookupPositions = positions
    , coordinateLookupAvailability = coordinateAvailabilityV2FromRaw (cCoordinateLookupResultAvailability raw)
    , coordinateLookupReason = reason
    }

readWithOptions :: TensorFile -> [EntrySelector] -> ReadOptions -> IO (Result (SomeTensor, ReadExecutionReport))
readWithOptions file@TensorFile{tensorFileNative} selectors options =
  withEntrySelectors selectors $ \selectorsPtr selectorsLen ->
    withReadOptions options $ \optionsPtr ->
      readTensorWithReport file $ \handle tensorPtr reportPtr ->
        capiReadWithOptions tensorFileNative handle selectorsPtr selectorsLen optionsPtr tensorPtr reportPtr

-- | Dense variant of 'readWithOptions'.
readWithOptionsDense :: TensorFile -> [EntrySelector] -> ReadOptions -> Double -> IO (Result (SomeDenseRead, ReadExecutionReport))
readWithOptionsDense file@TensorFile{tensorFileNative} selectors options fillValue =
  withEntrySelectors selectors $ \selectorsPtr selectorsLen ->
    withReadOptions options $ \optionsPtr ->
      readDenseWithReport file $ \handle tensorPtr maskPtr reportPtr ->
        capiReadWithOptionsDense tensorFileNative handle selectorsPtr selectorsLen optionsPtr fillValue tensorPtr maskPtr reportPtr

-- | Read current visible data with an explicit shape policy.
readWithShapePolicy :: TensorFile -> [EntrySelector] -> ReadOptions -> ReadShapePolicy -> IO (Result (SomeTensor, ReadExecutionReport))
readWithShapePolicy file@TensorFile{tensorFileNative} selectors options policy =
  case validateReadShapePolicy policy of
    Left err -> pure (Left err)
    Right () -> withEntrySelectors selectors $ \selectorsPtr selectorsLen ->
      withShapeReadOptions options policy $ \optionsPtr ->
        readTensorWithReport file $ \handle tensorPtr reportPtr ->
          capiReadWithShapePolicy tensorFileNative handle selectorsPtr selectorsLen optionsPtr tensorPtr reportPtr

-- | Dense variant of 'readWithShapePolicy'.
readWithShapePolicyDense :: TensorFile -> [EntrySelector] -> ReadOptions -> ReadShapePolicy -> Double -> IO (Result (SomeDenseRead, ReadExecutionReport))
readWithShapePolicyDense file@TensorFile{tensorFileNative} selectors options policy fillValue =
  case validateReadShapePolicy policy of
    Left err -> pure (Left err)
    Right () -> withEntrySelectors selectors $ \selectorsPtr selectorsLen ->
      withShapeReadOptions options policy $ \optionsPtr ->
        readDenseWithReport file $ \handle tensorPtr maskPtr reportPtr ->
          capiReadWithShapePolicyDense tensorFileNative handle selectorsPtr selectorsLen optionsPtr fillValue tensorPtr maskPtr reportPtr

-- | Attributed current read that also returns native query-trace JSON.
readWithOptionsAttributed :: TensorFile -> [EntrySelector] -> ReadOptions -> QueryTraceContext -> IO (Result (SomeTensor, ReadExecutionReport, QueryTraceJson))
readWithOptionsAttributed TensorFile{tensorFileNative, tensorFileHandle} selectors options traceContext =
  case validateQueryTraceContext traceContext of
    Left err -> pure (Left err)
    Right () ->
      withEntrySelectors selectors $ \selectorsPtr selectorsLen ->
        withReadOptions options $ \optionsPtr ->
          withQueryTraceContext traceContext $ \tracePtr ->
            withForeignPtr tensorFileHandle $ \handle ->
              alloca $ \tensorPtr ->
                alloca $ \reportPtr ->
                  alloca $ \traceJsonPtr -> do
                    poke tensorPtr emptyCArcadiaTioTensor
                    poke reportPtr emptyCArcadiaTioReadExecutionReport
                    poke traceJsonPtr emptyCArcadiaTioQueryTraceJson
                    status <- capiReadWithOptionsAttributed tensorFileNative handle selectorsPtr selectorsLen optionsPtr tracePtr tensorPtr reportPtr traceJsonPtr
                    finishAttributedRead tensorFileNative status tensorPtr reportPtr traceJsonPtr copySomeTensor

-- | Dense attributed current read variant.
readWithOptionsDenseAttributed :: TensorFile -> [EntrySelector] -> ReadOptions -> QueryTraceContext -> Double -> IO (Result (SomeDenseRead, ReadExecutionReport, QueryTraceJson))
readWithOptionsDenseAttributed TensorFile{tensorFileNative, tensorFileHandle} selectors options traceContext fillValue =
  case validateQueryTraceContext traceContext of
    Left err -> pure (Left err)
    Right () ->
      withEntrySelectors selectors $ \selectorsPtr selectorsLen ->
        withReadOptions options $ \optionsPtr ->
          withQueryTraceContext traceContext $ \tracePtr ->
            withForeignPtr tensorFileHandle $ \handle ->
              alloca $ \tensorPtr ->
                alloca $ \maskPtr ->
                  alloca $ \reportPtr ->
                    alloca $ \traceJsonPtr -> do
                      poke tensorPtr emptyCArcadiaTioTensor
                      poke maskPtr emptyCArcadiaTioMask
                      poke reportPtr emptyCArcadiaTioReadExecutionReport
                      poke traceJsonPtr emptyCArcadiaTioQueryTraceJson
                      status <- capiReadWithOptionsDenseAttributed tensorFileNative handle selectorsPtr selectorsLen optionsPtr tracePtr fillValue tensorPtr maskPtr reportPtr traceJsonPtr
                      finishAttributedDenseRead tensorFileNative status tensorPtr maskPtr reportPtr traceJsonPtr

-- | Historical read with selectors and execution options.
readAtCommitWithOptions :: TensorFile -> Word64 -> [EntrySelector] -> ReadOptions -> IO (Result (SomeTensor, HistoricalReadExecutionReport))
readAtCommitWithOptions file@TensorFile{tensorFileNative} commitSeqValue selectors options =
  withEntrySelectors selectors $ \selectorsPtr selectorsLen ->
    withReadOptions options $ \optionsPtr ->
      readHistoricalTensorWithReport file $ \handle tensorPtr reportPtr ->
        capiReadAtCommitWithOptions tensorFileNative handle commitSeqValue selectorsPtr selectorsLen optionsPtr tensorPtr reportPtr

-- | Dense historical read with selectors and execution options.
readAtCommitWithOptionsDense :: TensorFile -> Word64 -> [EntrySelector] -> ReadOptions -> Double -> IO (Result (SomeDenseRead, HistoricalReadExecutionReport))
readAtCommitWithOptionsDense file@TensorFile{tensorFileNative} commitSeqValue selectors options fillValue =
  withEntrySelectors selectors $ \selectorsPtr selectorsLen ->
    withReadOptions options $ \optionsPtr ->
      readHistoricalDenseWithReport file $ \handle tensorPtr maskPtr reportPtr ->
        capiReadAtCommitWithOptionsDense tensorFileNative handle commitSeqValue selectorsPtr selectorsLen optionsPtr fillValue tensorPtr maskPtr reportPtr

-- | Historical read with an explicit shape policy.
readAtCommitWithShapePolicy :: TensorFile -> Word64 -> [EntrySelector] -> ReadOptions -> ReadShapePolicy -> IO (Result (SomeTensor, HistoricalReadExecutionReport))
readAtCommitWithShapePolicy file@TensorFile{tensorFileNative} commitSeqValue selectors options policy =
  case validateReadShapePolicy policy of
    Left err -> pure (Left err)
    Right () -> withEntrySelectors selectors $ \selectorsPtr selectorsLen ->
      withShapeReadOptions options policy $ \optionsPtr ->
        readHistoricalTensorWithReport file $ \handle tensorPtr reportPtr ->
          capiReadAtCommitWithShapePolicy tensorFileNative handle commitSeqValue selectorsPtr selectorsLen optionsPtr tensorPtr reportPtr

-- | Dense historical read with an explicit shape policy.
readAtCommitWithShapePolicyDense :: TensorFile -> Word64 -> [EntrySelector] -> ReadOptions -> ReadShapePolicy -> Double -> IO (Result (SomeDenseRead, HistoricalReadExecutionReport))
readAtCommitWithShapePolicyDense file@TensorFile{tensorFileNative} commitSeqValue selectors options policy fillValue =
  case validateReadShapePolicy policy of
    Left err -> pure (Left err)
    Right () -> withEntrySelectors selectors $ \selectorsPtr selectorsLen ->
      withShapeReadOptions options policy $ \optionsPtr ->
        readHistoricalDenseWithReport file $ \handle tensorPtr maskPtr reportPtr ->
          capiReadAtCommitWithShapePolicyDense tensorFileNative handle commitSeqValue selectorsPtr selectorsLen optionsPtr fillValue tensorPtr maskPtr reportPtr

-- | Read by Python-style index items and return the native lowering report.
readIndex :: TensorFile -> [ReadIndexItem] -> IO (Result (SomeTensor, ReadIndexReport))
readIndex TensorFile{tensorFileNative, tensorFileHandle} items =
  case validateReadIndexItems items of
    Left err -> pure (Left err)
    Right () ->
      withArray (map readIndexItemToC items) $ \itemsPtr ->
        withForeignPtr tensorFileHandle $ \handle ->
          alloca $ \tensorPtr ->
            alloca $ \reportPtr -> do
              poke tensorPtr emptyCArcadiaTioTensor
              poke reportPtr emptyCArcadiaTioReadIndexReport
              status <- capiReadIndex tensorFileNative handle itemsPtr (CSize (fromIntegral (length items))) tensorPtr reportPtr
              if status == okStatus
                then do
                  tensor <- peek tensorPtr >>= copySomeTensor
                  report <- peek reportPtr >>= readIndexReportFromC
                  capiTensorFree tensorFileNative tensorPtr
                  capiReadIndexReportFree tensorFileNative reportPtr
                  pure $ (,) <$> tensor <*> report
                else do
                  err <- lastError tensorFileNative
                  capiTensorFree tensorFileNative tensorPtr
                  capiReadIndexReportFree tensorFileNative reportPtr
                  pure (Left err)

-- | Read the native index-checkpoint cadence metadata.
getIndexCheckpointEveryCommits :: TensorFile -> IO (Result Word32)
getIndexCheckpointEveryCommits file = withHandleOutput file (capiGetIndexCheckpointEveryCommits (tensorFileNative file)) Right

-- | Set the native index-checkpoint cadence metadata.
setIndexCheckpointEveryCommits :: TensorFile -> Word32 -> IO (Result ())
setIndexCheckpointEveryCommits file@TensorFile{tensorFileNative} everyCommits =
  callStatus file $ \handle -> capiSetIndexCheckpointEveryCommits tensorFileNative handle everyCommits

-- | Rewrite one selector with an f32 tensor.
rewriteF32 :: TensorFile -> EntrySelector -> Tensor Float -> IO (Result ())
rewriteF32 file@TensorFile{tensorFileNative} selector tensor@Tensor{tensorShape, tensorValues} =
  case validateTensor tensor of
    Left err -> pure (Left err)
    Right () -> withEntrySelectors [selector] $ \selectorPtr _ ->
      withForeignPtr (tensorFileHandle file) $ \handle ->
        VS.unsafeWith tensorValues $ \valuesPtr ->
          withArray tensorShape $ \shapePtr ->
            callStatus file $ \_ -> capiRewriteF32 tensorFileNative handle selectorPtr (castPtr valuesPtr) shapePtr (CSize (fromIntegral (length tensorShape)))

-- | Rewrite one selector with an f64 tensor.
rewriteF64 :: TensorFile -> EntrySelector -> Tensor Double -> IO (Result ())
rewriteF64 file@TensorFile{tensorFileNative} selector tensor@Tensor{tensorShape, tensorValues} =
  case validateTensor tensor of
    Left err -> pure (Left err)
    Right () -> withEntrySelectors [selector] $ \selectorPtr _ ->
      withForeignPtr (tensorFileHandle file) $ \handle ->
        VS.unsafeWith tensorValues $ \valuesPtr ->
          withArray tensorShape $ \shapePtr ->
            callStatus file $ \_ -> capiRewriteF64 tensorFileNative handle selectorPtr valuesPtr shapePtr (CSize (fromIntegral (length tensorShape)))

-- | Rewrite a selector slice with an f32 tensor.
rewriteSliceF32 :: TensorFile -> [EntrySelector] -> Tensor Float -> IO (Result ())
rewriteSliceF32 file@TensorFile{tensorFileNative} selectors tensor@Tensor{tensorShape, tensorValues} =
  case validateTensor tensor *> validateRewriteSelectors selectors of
    Left err -> pure (Left err)
    Right () -> withEntrySelectors selectors $ \selectorsPtr selectorsLen ->
      withForeignPtr (tensorFileHandle file) $ \handle ->
        VS.unsafeWith tensorValues $ \valuesPtr ->
          withArray tensorShape $ \shapePtr ->
            callStatus file $ \_ -> capiRewriteSliceF32 tensorFileNative handle selectorsPtr selectorsLen (castPtr valuesPtr) shapePtr (CSize (fromIntegral (length tensorShape)))

-- | Rewrite a selector slice with an f64 tensor.
rewriteSliceF64 :: TensorFile -> [EntrySelector] -> Tensor Double -> IO (Result ())
rewriteSliceF64 file@TensorFile{tensorFileNative} selectors tensor@Tensor{tensorShape, tensorValues} =
  case validateTensor tensor *> validateRewriteSelectors selectors of
    Left err -> pure (Left err)
    Right () -> withEntrySelectors selectors $ \selectorsPtr selectorsLen ->
      withForeignPtr (tensorFileHandle file) $ \handle ->
        VS.unsafeWith tensorValues $ \valuesPtr ->
          withArray tensorShape $ \shapePtr ->
            callStatus file $ \_ -> capiRewriteSliceF64 tensorFileNative handle selectorsPtr selectorsLen valuesPtr shapePtr (CSize (fromIntegral (length tensorShape)))

-- | Clear native sparse chunks by chunk keys.
clearBlocks :: TensorFile -> [[Word32]] -> IO (Result ())
clearBlocks file@TensorFile{tensorFileNative} keys =
  case validateChunkKeys keys of
    Left err -> pure (Left err)
    Right () -> withChunkKeys keys $ \keysPtr keysLen ->
      callStatus file $ \handle -> capiClearBlocks tensorFileNative handle keysPtr keysLen

-- | Export the full visible values through the Arrow C Data Interface. The
-- returned release callbacks are owned by 'ArrowCData'.
readValuesArrow :: TensorFile -> IO (Result ArrowCData)
readValuesArrow TensorFile{tensorFileNative, tensorFileHandle} =
  withForeignPtr tensorFileHandle $ \handle -> do
    arrayPtr <- malloc
    schemaPtr <- malloc
    poke arrayPtr emptyCArrowArray
    poke schemaPtr emptyCArrowSchema
    status <- capiReadValuesArrow tensorFileNative handle arrayPtr schemaPtr
    if status == okStatus
      then Right <$> wrapArrowCData arrayPtr schemaPtr
      else do
        err <- lastError tensorFileNative
        releaseArrowArrayPtr arrayPtr
        releaseArrowSchemaPtr schemaPtr
        free arrayPtr
        free schemaPtr
        pure (Left err)

-- | Return shallow compaction analysis stats.
analyzeCompaction :: TensorFile -> IO (Result CompactionStats)
analyzeCompaction file = withHandleOutput file (capiAnalyzeCompaction (tensorFileNative file)) (Right . compactionStatsFromC)

compactionStatsFromC :: CArcadiaTioCompactionStats -> CompactionStats
compactionStatsFromC CArcadiaTioCompactionStats{cCompactionLiveBytes, cCompactionDeadBytes, cCompactionDeadRatio, cCompactionCommitCount} =
  CompactionStats
    { compactionLiveBytes = cCompactionLiveBytes
    , compactionDeadBytes = cCompactionDeadBytes
    , compactionDeadRatio = cCompactionDeadRatio
    , compactionCommitCount = cCompactionCommitCount
    }

-- | Compact live chunks into a destination path using the native compaction helper.
compactTo :: TensorFile -> FilePath -> Word32 -> CompactionMode -> IO (Result ())
compactTo file@TensorFile{tensorFileNative} dstPath retainCommits mode = withPath dstPath $ \cPath ->
  callStatus file $ \handle -> capiCompactTo tensorFileNative handle cPath retainCommits (compactionModeToRawWord64 mode)

-- | Conditionally compact into a destination path and return whether compaction occurred.
maybeCompact :: TensorFile -> FilePath -> Double -> Word64 -> Word32 -> CompactionMode -> IO (Result Bool)
maybeCompact TensorFile{tensorFileNative, tensorFileHandle} dstPath deadRatioThreshold minDeadBytes retainCommits mode = withPath dstPath $ \cPath ->
  withForeignPtr tensorFileHandle $ \handle ->
    alloca $ \outCompactedPtr -> do
      poke outCompactedPtr 0
      status <- capiMaybeCompact tensorFileNative handle cPath deadRatioThreshold minDeadBytes retainCommits (compactionModeToRawWord64 mode) outCompactedPtr
      if status == okStatus
        then Right . (/= 0) <$> peek outCompactedPtr
        else Left <$> lastError tensorFileNative

-- | Read auto-compaction metadata configuration, when present.
getAutoCompactionConfig :: TensorFile -> IO (Result (Maybe AutoCompactionConfig))
getAutoCompactionConfig TensorFile{tensorFileNative, tensorFileHandle} =
  withForeignPtr tensorFileHandle $ \handle ->
    alloca $ \configPtr ->
      alloca $ \hasConfigPtr -> do
        poke hasConfigPtr 0
        status <- capiGetAutoCompactionConfig tensorFileNative handle configPtr hasConfigPtr
        if status == okStatus
          then do
            hasConfig <- peek hasConfigPtr
            if hasConfig == 0
              then pure (Right Nothing)
              else do
                raw <- peek configPtr
                pure (Just <$> autoCompactionConfigFromC raw)
          else Left <$> lastError tensorFileNative

-- | Set or clear auto-compaction metadata configuration. Native V4 may report
-- this operation as unsupported; the wrapper surfaces that status unchanged.
setAutoCompactionConfig :: TensorFile -> Maybe AutoCompactionConfig -> IO (Result ())
setAutoCompactionConfig file@TensorFile{tensorFileNative} maybeConfig = case maybeConfig of
  Nothing -> callStatus file $ \handle -> capiSetAutoCompactionConfig tensorFileNative handle nullPtr 0
  Just config -> alloca $ \configPtr -> do
    poke configPtr (autoCompactionConfigToC config)
    callStatus file $ \handle -> capiSetAutoCompactionConfig tensorFileNative handle configPtr 1

-- | Read native auto-compaction state metadata, when present.
compactionState :: TensorFile -> IO (Result (Maybe CompactionState))
compactionState TensorFile{tensorFileNative, tensorFileHandle} =
  withForeignPtr tensorFileHandle $ \handle ->
    alloca $ \statePtr ->
      alloca $ \hasStatePtr -> do
        poke hasStatePtr 0
        status <- capiCompactionState tensorFileNative handle statePtr hasStatePtr
        if status == okStatus
          then do
            hasState <- peek hasStatePtr
            if hasState == 0
              then pure (Right Nothing)
              else Right . Just . compactionStateFromC <$> peek statePtr
          else Left <$> lastError tensorFileNative

-- | Run native auto-compaction policy if metadata configuration is available.
maybeCompactAuto :: TensorFile -> IO (Result Bool)
maybeCompactAuto TensorFile{tensorFileNative, tensorFileHandle} =
  withForeignPtr tensorFileHandle $ \handle ->
    alloca $ \outCompactedPtr -> do
      poke outCompactedPtr 0
      status <- capiMaybeCompactAuto tensorFileNative handle outCompactedPtr
      if status == okStatus
        then Right . (/= 0) <$> peek outCompactedPtr
        else Left <$> lastError tensorFileNative


-- | Return detailed V4 source-file diagnostics, including in-band report status.
v4Diagnostics :: TensorFile -> IO (Result V4DiagnosticsReport)
v4Diagnostics TensorFile{tensorFileNative, tensorFileHandle} =
  withForeignPtr tensorFileHandle $ \handle ->
    alloca $ \reportPtr -> do
      poke reportPtr emptyCArcadiaTioV4DiagnosticsReport
      status <- capiV4Diagnostics tensorFileNative handle reportPtr
      if status == okStatus
        then (peek reportPtr >>= copyV4DiagnosticsReport) `finally` capiV4DiagnosticsReportFree tensorFileNative reportPtr
        else do
          err <- lastError tensorFileNative
          capiV4DiagnosticsReportFree tensorFileNative reportPtr
          pure (Left err)

-- | Return detailed V4 source-file diagnostics with precise accounting validity.
v4DiagnosticsPrecise :: TensorFile -> V4PreciseAccountingOptions -> IO (Result V4DiagnosticsPreciseReport)
v4DiagnosticsPrecise TensorFile{tensorFileNative, tensorFileHandle} options =
  withForeignPtr tensorFileHandle $ \handle ->
    alloca $ \optionsPtr ->
      alloca $ \reportPtr -> do
        poke optionsPtr (v4PreciseAccountingOptionsToC options)
        poke reportPtr emptyCArcadiaTioV4DiagnosticsPreciseReport
        status <- capiV4DiagnosticsPrecise tensorFileNative handle optionsPtr reportPtr
        if status == okStatus
          then (peek reportPtr >>= copyV4DiagnosticsPreciseReport) `finally` capiV4DiagnosticsPreciseReportFree tensorFileNative reportPtr
          else do
            err <- lastError tensorFileNative
            capiV4DiagnosticsPreciseReportFree tensorFileNative reportPtr
            pure (Left err)

v4PreciseAccountingOptionsToC :: V4PreciseAccountingOptions -> CArcadiaTioV4PreciseAccountingOptions
v4PreciseAccountingOptionsToC V4PreciseAccountingOptions{v4PreciseRequestedFields, v4PreciseIncludeOmittedFieldReasons} =
  emptyCArcadiaTioV4PreciseAccountingOptions
    { cV4PreciseAccountingOptionsRequestedFieldsMask = foldr ((.|.) . v4PreciseAccountingFieldMask) 0 v4PreciseRequestedFields
    , cV4PreciseAccountingOptionsIncludeOmittedFieldReasons = boolToWord8 v4PreciseIncludeOmittedFieldReasons
    }

v4PreciseAccountingFieldMask :: V4PreciseAccountingField -> Word32
v4PreciseAccountingFieldMask field =
  let CInt raw = Types.v4PreciseAccountingFieldToRaw field
  in if raw >= 0 && raw < 32 then 1 `shiftL` fromIntegral raw else 0

v4ReportStatusFromRaw :: CInt -> V4ReportStatus
v4ReportStatusFromRaw = Types.v4ReportStatusFromRaw

v4PreciseAccountingFieldFromRaw :: CInt -> V4PreciseAccountingField
v4PreciseAccountingFieldFromRaw = Types.v4PreciseAccountingFieldFromRaw

copyV4DiagnosticsReport :: CArcadiaTioV4DiagnosticsReport -> IO (Result V4DiagnosticsReport)
copyV4DiagnosticsReport raw = do
  reason <- peekOptionalCString (cV4DiagnosticsReportReason raw)
  omittedReason <- peekOptionalCString (cV4DiagnosticsReportOmittedUnreachableBytesReason raw)
  pure $ Right V4DiagnosticsReport
    { v4DiagnosticsStatus = v4ReportStatusFromRaw (cV4DiagnosticsReportStatus raw)
    , v4DiagnosticsReason = reason
    , v4DiagnosticsCurrentHead = copyV4CurrentHeadBytes (cV4DiagnosticsReportCurrentHead raw)
    , v4DiagnosticsVisibleChainAudit = copyV4AuditBytes (cV4DiagnosticsReportVisibleChainAudit raw)
    , v4DiagnosticsPayloadReuse = copyV4PayloadReuseBytes (cV4DiagnosticsReportPayloadReuse raw)
    , v4DiagnosticsSuperseded = copyV4SupersededBytes (cV4DiagnosticsReportSuperseded raw)
    , v4DiagnosticsUnknownBytes = cV4DiagnosticsReportUnknownBytes raw
    , v4DiagnosticsOmittedUnreachableBytes = cV4DiagnosticsReportOmittedUnreachableBytes raw /= 0
    , v4DiagnosticsOmittedUnreachableBytesReason = omittedReason
    }

copyV4DiagnosticsPreciseReport :: CArcadiaTioV4DiagnosticsPreciseReport -> IO (Result V4DiagnosticsPreciseReport)
copyV4DiagnosticsPreciseReport raw = do
  reason <- peekOptionalCString (cV4DiagnosticsPreciseReportReason raw)
  reasonCode <- peekOptionalCString (cV4DiagnosticsPreciseReportReasonCode raw)
  precise <- copyV4PreciseAccountingBytes (cV4DiagnosticsPreciseReportPreciseAccounting raw)
  pure $ do
    preciseAccounting <- precise
    Right V4DiagnosticsPreciseReport
      { v4DiagnosticsPreciseStatus = v4ReportStatusFromRaw (cV4DiagnosticsPreciseReportStatus raw)
      , v4DiagnosticsPreciseReason = reason
      , v4DiagnosticsPreciseCurrentHead = copyV4CurrentHeadBytes (cV4DiagnosticsPreciseReportCurrentHead raw)
      , v4DiagnosticsPreciseVisibleChainAudit = copyV4AuditBytes (cV4DiagnosticsPreciseReportVisibleChainAudit raw)
      , v4DiagnosticsPrecisePayloadReuse = copyV4PayloadReuseBytes (cV4DiagnosticsPreciseReportPayloadReuse raw)
      , v4DiagnosticsPreciseSuperseded = copyV4SupersededBytes (cV4DiagnosticsPreciseReportSuperseded raw)
      , v4DiagnosticsPreciseUnknownBytes = cV4DiagnosticsPreciseReportUnknownBytes raw
      , v4DiagnosticsPreciseAccounting = preciseAccounting
      , v4DiagnosticsPreciseReasonCode = reasonCode
      }

copyV4CurrentHeadBytes :: CArcadiaTioV4CurrentHeadBytes -> V4CurrentHeadBytes
copyV4CurrentHeadBytes CArcadiaTioV4CurrentHeadBytes{cV4CurrentHeadPayloadBytes, cV4CurrentHeadIndexBytes, cV4CurrentHeadEpochBytes, cV4CurrentHeadAuxBytes, cV4CurrentHeadCommitBytes} =
  V4CurrentHeadBytes cV4CurrentHeadPayloadBytes cV4CurrentHeadIndexBytes cV4CurrentHeadEpochBytes cV4CurrentHeadAuxBytes cV4CurrentHeadCommitBytes

copyV4AuditBytes :: CArcadiaTioV4AuditBytes -> V4AuditBytes
copyV4AuditBytes CArcadiaTioV4AuditBytes{cV4AuditCommitBytes, cV4AuditIndexBytes, cV4AuditEpochBytes, cV4AuditAuxBytes} =
  V4AuditBytes cV4AuditCommitBytes cV4AuditIndexBytes cV4AuditEpochBytes cV4AuditAuxBytes

copyV4PayloadReuseBytes :: CArcadiaTioV4PayloadReuseBytes -> V4PayloadReuseBytes
copyV4PayloadReuseBytes CArcadiaTioV4PayloadReuseBytes{cV4PayloadReuseResurrectedPayloadBytes, cV4PayloadReuseSharedPayloadBytes} =
  V4PayloadReuseBytes cV4PayloadReuseResurrectedPayloadBytes cV4PayloadReuseSharedPayloadBytes

copyV4SupersededBytes :: CArcadiaTioV4SupersededBytes -> V4SupersededBytes
copyV4SupersededBytes CArcadiaTioV4SupersededBytes{cV4SupersededPayloadBytes, cV4SupersededIndexBytes, cV4SupersededEpochBytes, cV4SupersededAuxBytes} =
  V4SupersededBytes cV4SupersededPayloadBytes cV4SupersededIndexBytes cV4SupersededEpochBytes cV4SupersededAuxBytes

copyV4PreciseAccountingBytes :: CArcadiaTioV4PreciseAccountingBytes -> IO (Result V4PreciseAccountingBytes)
copyV4PreciseAccountingBytes raw = do
  omitted <- copyV4OmittedPreciseFields raw
  pure $ do
    omittedFields <- omitted
    Right V4PreciseAccountingBytes
      { v4PreciseUnreachableBytes = present (cV4PreciseAccountingHasUnreachableBytes raw) (cV4PreciseAccountingUnreachableBytes raw)
      , v4PreciseRetainedHistoryRequiredBytes = present (cV4PreciseAccountingHasRetainedHistoryRequiredBytes raw) (cV4PreciseAccountingRetainedHistoryRequiredBytes raw)
      , v4PrecisePoppedSkippedBytes = present (cV4PreciseAccountingHasPoppedSkippedBytes raw) (cV4PreciseAccountingPoppedSkippedBytes raw)
      , v4PreciseReclaimableBytes = present (cV4PreciseAccountingHasReclaimableBytes raw) (cV4PreciseAccountingReclaimableBytes raw)
      , v4PreciseOmittedFields = omittedFields
      }
 where
  present flag value = if flag == 0 then Nothing else Just value

copyV4OmittedPreciseFields :: CArcadiaTioV4PreciseAccountingBytes -> IO (Result [V4OmittedPreciseAccountingField])
copyV4OmittedPreciseFields raw = do
  let fieldsLen = fromIntegralCSize (cV4PreciseAccountingOmittedFieldsLen raw)
      codesLen = fromIntegralCSize (cV4PreciseAccountingOmittedFieldReasonCodesLen raw)
  fieldRows <- copyCArray "V4 omitted precise accounting fields" (cV4PreciseAccountingOmittedFields raw) fieldsLen pureOmittedField
  case fieldRows of
    Left err -> pure (Left err)
    Right rows -> do
      codes <- copyOptionalCStringSlots (cV4PreciseAccountingOmittedFieldReasonCodes raw) codesLen
      pure $ case codes of
        Left err -> Left err
        Right codeSlots ->
          if not (null codeSlots) && length codeSlots /= length rows
            then Left (invalidArgument "V4 omitted precise field reason-code count does not match omitted field count")
            else Right (zipWith attachCode rows (codeSlots <> repeat Nothing))
 where
  pureOmittedField row = do
    reason <- peekOptionalCString (cV4OmittedPreciseAccountingFieldReason row)
    pure $ Right V4OmittedPreciseAccountingField
      { v4OmittedPreciseField = v4PreciseAccountingFieldFromRaw (cV4OmittedPreciseAccountingFieldField row)
      , v4OmittedPreciseReason = reason
      , v4OmittedPreciseReasonCode = Nothing
      }
  attachCode row code = row{v4OmittedPreciseReasonCode = code}

copyOptionalCStringSlots :: Ptr CString -> Int -> IO (Result [Maybe String])
copyOptionalCStringSlots ptr len
  | len < 0 = pure (Left (invalidArgument "CString slot array length is negative"))
  | len == 0 = pure (Right [])
  | ptr == nullPtr = pure (Left (invalidArgument "CString slot array pointer is null"))
  | otherwise = Right <$> (mapM peekOptionalCString =<< peekArray len ptr)


-- | Return detailed V4 ordinary current-state compaction analysis.
analyzeV4Compaction :: TensorFile -> IO (Result V4CompactionAnalysisReport)
analyzeV4Compaction TensorFile{tensorFileNative, tensorFileHandle} =
  withForeignPtr tensorFileHandle $ \handle ->
    alloca $ \reportPtr -> do
      poke reportPtr emptyCArcadiaTioV4CompactionAnalysisReport
      status <- capiAnalyzeV4Compaction tensorFileNative handle reportPtr
      if status == okStatus
        then (peek reportPtr >>= copyV4CompactionAnalysisReport) `finally` capiV4CompactionAnalysisReportFree tensorFileNative reportPtr
        else do
          err <- lastError tensorFileNative
          capiV4CompactionAnalysisReportFree tensorFileNative reportPtr
          pure (Left err)

-- | Return detailed V4 ordinary current-state compaction analysis with precise accounting.
analyzeV4CompactionPrecise :: TensorFile -> V4PreciseAccountingOptions -> IO (Result V4CompactionAnalysisPreciseReport)
analyzeV4CompactionPrecise TensorFile{tensorFileNative, tensorFileHandle} options =
  withForeignPtr tensorFileHandle $ \handle ->
    alloca $ \optionsPtr ->
      alloca $ \reportPtr -> do
        poke optionsPtr (v4PreciseAccountingOptionsToC options)
        poke reportPtr emptyCArcadiaTioV4CompactionAnalysisPreciseReport
        status <- capiAnalyzeV4CompactionPrecise tensorFileNative handle optionsPtr reportPtr
        if status == okStatus
          then (peek reportPtr >>= copyV4CompactionAnalysisPreciseReport) `finally` capiV4CompactionAnalysisPreciseReportFree tensorFileNative reportPtr
          else do
            err <- lastError tensorFileNative
            capiV4CompactionAnalysisPreciseReportFree tensorFileNative reportPtr
            pure (Left err)

-- | Compact visible V4 data into a destination while retaining bounded visible history.
compactV4RetainedHistoryTo :: TensorFile -> FilePath -> V4RetainedHistoryCompactionOptions -> IO (Result V4RetainedHistoryCompactionReport)
compactV4RetainedHistoryTo TensorFile{tensorFileNative, tensorFileHandle} dstPath options =
  case validateRetainedHistoryOptions options of
    Left err -> pure (Left err)
    Right () -> withPath dstPath $ \cPath ->
      withForeignPtr tensorFileHandle $ \handle ->
        alloca $ \optionsPtr ->
          alloca $ \reportPtr -> do
            poke optionsPtr (retainedHistoryOptionsToC options)
            poke reportPtr emptyCArcadiaTioV4RetainedHistoryCompactionReport
            status <- capiCompactV4RetainedHistoryTo tensorFileNative handle cPath optionsPtr reportPtr
            if status == okStatus
              then (peek reportPtr >>= copyV4RetainedHistoryCompactionReport) `finally` capiV4RetainedHistoryCompactionReportFree tensorFileNative reportPtr
              else do
                err <- lastError tensorFileNative
                capiV4RetainedHistoryCompactionReportFree tensorFileNative reportPtr
                pure (Left err)

-- | Compact visible V4 data into a retained-history destination with source precise accounting.
compactV4RetainedHistoryToPrecise :: TensorFile -> FilePath -> V4RetainedHistoryCompactionOptions -> V4PreciseAccountingOptions -> IO (Result V4RetainedHistoryCompactionPreciseReport)
compactV4RetainedHistoryToPrecise TensorFile{tensorFileNative, tensorFileHandle} dstPath retentionOptions preciseOptions =
  case validateRetainedHistoryOptions retentionOptions of
    Left err -> pure (Left err)
    Right () -> withPath dstPath $ \cPath ->
      withForeignPtr tensorFileHandle $ \handle ->
        alloca $ \retentionPtr ->
          alloca $ \precisePtr ->
            alloca $ \reportPtr -> do
              poke retentionPtr (retainedHistoryOptionsToC retentionOptions)
              poke precisePtr (v4PreciseAccountingOptionsToC preciseOptions)
              poke reportPtr emptyCArcadiaTioV4RetainedHistoryCompactionPreciseReport
              status <- capiCompactV4RetainedHistoryToPrecise tensorFileNative handle cPath retentionPtr precisePtr reportPtr
              if status == okStatus
                then (peek reportPtr >>= copyV4RetainedHistoryCompactionPreciseReport) `finally` capiV4RetainedHistoryCompactionPreciseReportFree tensorFileNative reportPtr
                else do
                  err <- lastError tensorFileNative
                  capiV4RetainedHistoryCompactionPreciseReportFree tensorFileNative reportPtr
                  pure (Left err)

validateRetainedHistoryOptions :: V4RetainedHistoryCompactionOptions -> Result ()
validateRetainedHistoryOptions V4RetainedHistoryCompactionOptions{v4RetainedHistoryPolicy, v4RetainedHistoryRetainLastN}
  | v4RetainedHistoryRetainLastN == 0 = Left (invalidArgument "retained-history compaction retain_last_n must be positive")
  | otherwise = case v4RetainedHistoryPolicy of
      V4RetainLast -> Right ()
      V4RetainedHistoryPolicyUnknown raw -> Left (invalidArgument ("unknown retained-history compaction policy " <> show raw))

retainedHistoryOptionsToC :: V4RetainedHistoryCompactionOptions -> CArcadiaTioV4RetainedHistoryCompactionOptions
retainedHistoryOptionsToC V4RetainedHistoryCompactionOptions{v4RetainedHistoryPolicy, v4RetainedHistoryRetainLastN} =
  emptyCArcadiaTioV4RetainedHistoryCompactionOptions
    { cV4RetainedHistoryCompactionOptionsPolicy = retainedHistoryPolicyToRaw v4RetainedHistoryPolicy
    , cV4RetainedHistoryCompactionOptionsRetainLastN = v4RetainedHistoryRetainLastN
    }

retainedHistoryPolicyToRaw :: V4RetainedHistoryPolicy -> CInt
retainedHistoryPolicyToRaw = Types.v4RetainedHistoryPolicyToRaw

v4CompactionAnalysisPolicyFromRaw :: CInt -> V4CompactionAnalysisPolicy
v4CompactionAnalysisPolicyFromRaw = Types.v4CompactionAnalysisPolicyFromRaw

copyV4CompactionAnalysisReport :: CArcadiaTioV4CompactionAnalysisReport -> IO (Result V4CompactionAnalysisReport)
copyV4CompactionAnalysisReport raw = do
  reason <- peekOptionalCString (cV4CompactionAnalysisReportReason raw)
  omittedReason <- peekOptionalCString (cV4CompactionAnalysisReportOmittedUnreachableBytesReason raw)
  pure $ Right V4CompactionAnalysisReport
    { v4CompactionAnalysisStatus = v4ReportStatusFromRaw (cV4CompactionAnalysisReportStatus raw)
    , v4CompactionAnalysisReason = reason
    , v4CompactionAnalysisPolicy = v4CompactionAnalysisPolicyFromRaw (cV4CompactionAnalysisReportPolicy raw)
    , v4CompactionAnalysisSourceFileBytes = cV4CompactionAnalysisReportSourceFileBytes raw
    , v4CompactionAnalysisCurrentStateRequiredBytes = cV4CompactionAnalysisReportCurrentStateRequiredBytes raw
    , v4CompactionAnalysisOrdinaryReclaimableBytes = cV4CompactionAnalysisReportOrdinaryReclaimableBytes raw
    , v4CompactionAnalysisUnknownBytes = cV4CompactionAnalysisReportUnknownBytes raw
    , v4CompactionAnalysisOmittedUnreachableBytes = cV4CompactionAnalysisReportOmittedUnreachableBytes raw /= 0
    , v4CompactionAnalysisOmittedUnreachableBytesReason = omittedReason
    }

copyV4CompactionAnalysisPreciseReport :: CArcadiaTioV4CompactionAnalysisPreciseReport -> IO (Result V4CompactionAnalysisPreciseReport)
copyV4CompactionAnalysisPreciseReport raw = do
  reason <- peekOptionalCString (cV4CompactionAnalysisPreciseReportReason raw)
  reasonCode <- peekOptionalCString (cV4CompactionAnalysisPreciseReportReasonCode raw)
  precise <- copyV4PreciseAccountingBytes (cV4CompactionAnalysisPreciseReportPreciseAccounting raw)
  pure $ do
    preciseAccounting <- precise
    Right V4CompactionAnalysisPreciseReport
      { v4CompactionAnalysisPreciseStatus = v4ReportStatusFromRaw (cV4CompactionAnalysisPreciseReportStatus raw)
      , v4CompactionAnalysisPreciseReason = reason
      , v4CompactionAnalysisPrecisePolicy = v4CompactionAnalysisPolicyFromRaw (cV4CompactionAnalysisPreciseReportPolicy raw)
      , v4CompactionAnalysisPreciseSourceFileBytes = cV4CompactionAnalysisPreciseReportSourceFileBytes raw
      , v4CompactionAnalysisPreciseCurrentStateRequiredBytes = cV4CompactionAnalysisPreciseReportCurrentStateRequiredBytes raw
      , v4CompactionAnalysisPreciseOrdinaryReclaimableBytes = cV4CompactionAnalysisPreciseReportOrdinaryReclaimableBytes raw
      , v4CompactionAnalysisPreciseUnknownBytes = cV4CompactionAnalysisPreciseReportUnknownBytes raw
      , v4CompactionAnalysisPreciseAccounting = preciseAccounting
      , v4CompactionAnalysisPreciseReasonCode = reasonCode
      }

copyV4RetainedHistoryCompactionReport :: CArcadiaTioV4RetainedHistoryCompactionReport -> IO (Result V4RetainedHistoryCompactionReport)
copyV4RetainedHistoryCompactionReport raw = do
  reason <- peekOptionalCString (cV4RetainedHistoryCompactionReportReason raw)
  omittedReason <- peekOptionalCString (cV4RetainedHistoryCompactionReportOmittedUnreachableBytesReason raw)
  seqsResult <- copyWord64Array "retained history commit seqs" (cV4RetainedHistoryCompactionReportRetainedCommitSeqs raw) (fromIntegralCSize (cV4RetainedHistoryCompactionReportRetainedCommitSeqsLen raw))
  pure $ do
    seqs <- seqsResult
    Right V4RetainedHistoryCompactionReport
      { v4RetainedHistoryStatus = v4ReportStatusFromRaw (cV4RetainedHistoryCompactionReportStatus raw)
      , v4RetainedHistoryReason = reason
      , v4RetainedHistoryRetainedCommitCount = cV4RetainedHistoryCompactionReportRetainedCommitCount raw
      , v4RetainedHistoryRetainedCommitSeqs = seqs
      , v4RetainedHistoryUnretainedOlderCommitCount = present (cV4RetainedHistoryCompactionReportHasUnretainedOlderCommitCount raw) (cV4RetainedHistoryCompactionReportUnretainedOlderCommitCount raw)
      , v4RetainedHistorySourceFileBytes = cV4RetainedHistoryCompactionReportSourceFileBytes raw
      , v4RetainedHistoryDestinationFileBytes = cV4RetainedHistoryCompactionReportDestinationFileBytes raw
      , v4RetainedHistoryOmittedUnreachableBytes = cV4RetainedHistoryCompactionReportOmittedUnreachableBytes raw /= 0
      , v4RetainedHistoryOmittedUnreachableBytesReason = omittedReason
      }
 where
  present flag value = if flag == 0 then Nothing else Just value

copyV4RetainedHistoryCompactionPreciseReport :: CArcadiaTioV4RetainedHistoryCompactionPreciseReport -> IO (Result V4RetainedHistoryCompactionPreciseReport)
copyV4RetainedHistoryCompactionPreciseReport raw = do
  reason <- peekOptionalCString (cV4RetainedHistoryCompactionPreciseReportReason raw)
  reasonCode <- peekOptionalCString (cV4RetainedHistoryCompactionPreciseReportReasonCode raw)
  seqsResult <- copyWord64Array "retained history precise commit seqs" (cV4RetainedHistoryCompactionPreciseReportRetainedCommitSeqs raw) (fromIntegralCSize (cV4RetainedHistoryCompactionPreciseReportRetainedCommitSeqsLen raw))
  precise <- copyV4PreciseAccountingBytes (cV4RetainedHistoryCompactionPreciseReportPreciseSourceAccounting raw)
  pure $ do
    seqs <- seqsResult
    preciseAccounting <- precise
    Right V4RetainedHistoryCompactionPreciseReport
      { v4RetainedHistoryPreciseStatus = v4ReportStatusFromRaw (cV4RetainedHistoryCompactionPreciseReportStatus raw)
      , v4RetainedHistoryPreciseReason = reason
      , v4RetainedHistoryPreciseRetainedCommitCount = cV4RetainedHistoryCompactionPreciseReportRetainedCommitCount raw
      , v4RetainedHistoryPreciseRetainedCommitSeqs = seqs
      , v4RetainedHistoryPreciseUnretainedOlderCommitCount = present (cV4RetainedHistoryCompactionPreciseReportHasUnretainedOlderCommitCount raw) (cV4RetainedHistoryCompactionPreciseReportUnretainedOlderCommitCount raw)
      , v4RetainedHistoryPreciseSourceFileBytes = cV4RetainedHistoryCompactionPreciseReportSourceFileBytes raw
      , v4RetainedHistoryPreciseDestinationFileBytes = cV4RetainedHistoryCompactionPreciseReportDestinationFileBytes raw
      , v4RetainedHistoryPreciseSourceAccounting = preciseAccounting
      , v4RetainedHistoryPreciseReasonCode = reasonCode
      }
 where
  present flag value = if flag == 0 then Nothing else Just value

copyWord64Array :: String -> Ptr Word64 -> Int -> IO (Result [Word64])
copyWord64Array label ptr len
  | len < 0 = pure (Left (invalidArgument (label <> " length is negative")))
  | len == 0 = pure (Right [])
  | ptr == nullPtr = pure (Left (invalidArgument (label <> " pointer is null")))
  | otherwise = Right <$> peekArray len ptr


-- | Reform visible data into a fresh destination with an explicit target layout.
reformTo :: TensorFile -> FilePath -> ReformOptions -> IO (Result ())
reformTo file@TensorFile{tensorFileNative} dstPath options =
  case validateReformOptions options of
    Left err -> pure (Left err)
    Right () -> withPath dstPath $ \cPath ->
      withReformOptions options $ \optionsPtr ->
        callStatus file $ \handle -> capiReformTo tensorFileNative handle cPath optionsPtr

-- | Reform visible data into a fresh destination and return diagnostic report metadata.
reformToEx :: TensorFile -> FilePath -> ReformOptions -> IO (Result ReformReport)
reformToEx TensorFile{tensorFileNative, tensorFileHandle} dstPath options =
  case validateReformOptions options of
    Left err -> pure (Left err)
    Right () -> withPath dstPath $ \cPath ->
      withReformOptions options $ \optionsPtr ->
        withForeignPtr tensorFileHandle $ \handle ->
          alloca $ \reportPtr -> do
            poke reportPtr emptyCArcadiaTioReformReport
            status <- capiReformToEx tensorFileNative handle cPath optionsPtr reportPtr
            report <- peek reportPtr >>= copyReformReport
            capiReformReportFree tensorFileNative reportPtr
            if status == okStatus
              then pure (Right report)
              else do
                err <- lastError tensorFileNative
                pure (Left err{tioErrorMessage = tioErrorMessage err <> reformReportSuffix report})

validateReformOptions :: ReformOptions -> Result ()
validateReformOptions ReformOptions{reformTargetLayout} = case reformTargetLayout of
  ReformPreserveFamily -> Right ()
  ReformWholeAppendUnit -> Right ()
  ReformRegularChunked shape
    | null shape -> Left (invalidArgument "regular-chunked reform block shape must not be empty")
    | any (== 0) shape -> Left (invalidArgument "regular-chunked reform block shape entries must be positive")
    | otherwise -> Right ()

withReformOptions :: ReformOptions -> (Ptr CArcadiaTioReformOptions -> IO a) -> IO a
withReformOptions options action =
  case reformTargetLayout options of
    ReformRegularChunked shape -> withArray shape $ \shapePtr -> pokeAndRun shapePtr (CSize (fromIntegral (length shape)))
    _ -> pokeAndRun nullPtr 0
 where
  pokeAndRun shapePtr shapeLen = alloca $ \optionsPtr -> do
    poke optionsPtr (reformOptionsToC options shapePtr shapeLen)
    action optionsPtr

reformOptionsToC :: ReformOptions -> Ptr Word32 -> CSize -> CArcadiaTioReformOptions
reformOptionsToC ReformOptions{reformTargetLayout} shapePtr shapeLen =
  emptyCArcadiaTioReformOptions
    { cReformOptionsTargetLayout = reformTargetLayoutToRaw reformTargetLayout
    , cReformOptionsRegularChunkedBlockShape = shapePtr
    , cReformOptionsRegularChunkedBlockShapeLen = shapeLen
    }

reformTargetLayoutToRaw :: ReformTargetLayout -> CInt
reformTargetLayoutToRaw = Types.reformTargetLayoutTagToRaw . Types.reformTargetLayoutTag

copyReformReport :: CArcadiaTioReformReport -> IO ReformReport
copyReformReport raw = do
  reasonCode <- peekOptionalCString (cReformReportReasonCode raw)
  taxonomy <- peekOptionalCString (cReformReportReasonCodeTaxonomy raw)
  reason <- peekOptionalCString (cReformReportReason raw)
  pure ReformReport{reformReasonCode = reasonCode, reformReasonCodeTaxonomy = taxonomy, reformReason = reason}

reformReportSuffix :: ReformReport -> String
reformReportSuffix ReformReport{reformReasonCode, reformReasonCodeTaxonomy, reformReason}
  | reformReasonCode == Nothing && reformReasonCodeTaxonomy == Nothing && reformReason == Nothing = ""
  | otherwise = " (reform report: code=" <> show reformReasonCode <> ", taxonomy=" <> show reformReasonCodeTaxonomy <> ", reason=" <> show reformReason <> ")"

compactionModeToC :: CompactionMode -> CArcadiaTioCompactionMode
compactionModeToC mode = case mode of
  CompactionCopyLive -> CArcadiaTioCompactionMode{cCompactionModeKind = 0, cCompactionModeReblockEntryBlockSize = 0}
  CompactionReblock blockSize -> CArcadiaTioCompactionMode{cCompactionModeKind = 1, cCompactionModeReblockEntryBlockSize = blockSize}

-- The Linux x86_64 C ABI passes ArcadiaTioCompactionMode by value as one
-- 64-bit integer-class register. This package's first slice is Linux .so only,
-- so pack the two 32-bit fields for the by-value compaction entrypoints.
compactionModeToRawWord64 :: CompactionMode -> Word64
compactionModeToRawWord64 mode =
  let CArcadiaTioCompactionMode{cCompactionModeKind, cCompactionModeReblockEntryBlockSize} = compactionModeToC mode
   in fromIntegral cCompactionModeKind .|. (fromIntegral cCompactionModeReblockEntryBlockSize `shiftL` 32)

compactionModeFromC :: CArcadiaTioCompactionMode -> Result CompactionMode
compactionModeFromC CArcadiaTioCompactionMode{cCompactionModeKind, cCompactionModeReblockEntryBlockSize} = case cCompactionModeKind of
  0 -> Right CompactionCopyLive
  1 -> Right (CompactionReblock cCompactionModeReblockEntryBlockSize)
  _ -> Left (invalidArgument ("native compaction mode has unknown kind " <> show cCompactionModeKind))

autoCompactionConfigToC :: AutoCompactionConfig -> CArcadiaTioAutoCompactionConfig
autoCompactionConfigToC AutoCompactionConfig{autoCompactionEnabled, autoCompactionRetainCommits, autoCompactionDeadRatioThreshold, autoCompactionMinDeadBytes, autoCompactionMode, autoCompactionCheckEveryCommits, autoCompactionCooldownCommits} =
  CArcadiaTioAutoCompactionConfig
    { cAutoCompactionEnabled = if autoCompactionEnabled then 1 else 0
    , cAutoCompactionRetainCommits = autoCompactionRetainCommits
    , cAutoCompactionDeadRatioThreshold = autoCompactionDeadRatioThreshold
    , cAutoCompactionMinDeadBytes = autoCompactionMinDeadBytes
    , cAutoCompactionMode = compactionModeToC autoCompactionMode
    , cAutoCompactionCheckEveryCommits = autoCompactionCheckEveryCommits
    , cAutoCompactionCooldownCommits = autoCompactionCooldownCommits
    }

autoCompactionConfigFromC :: CArcadiaTioAutoCompactionConfig -> Result AutoCompactionConfig
autoCompactionConfigFromC CArcadiaTioAutoCompactionConfig{cAutoCompactionEnabled, cAutoCompactionRetainCommits, cAutoCompactionDeadRatioThreshold, cAutoCompactionMinDeadBytes, cAutoCompactionMode, cAutoCompactionCheckEveryCommits, cAutoCompactionCooldownCommits} = do
  mode <- compactionModeFromC cAutoCompactionMode
  Right
    AutoCompactionConfig
      { autoCompactionEnabled = cAutoCompactionEnabled /= 0
      , autoCompactionRetainCommits = cAutoCompactionRetainCommits
      , autoCompactionDeadRatioThreshold = cAutoCompactionDeadRatioThreshold
      , autoCompactionMinDeadBytes = cAutoCompactionMinDeadBytes
      , autoCompactionMode = mode
      , autoCompactionCheckEveryCommits = cAutoCompactionCheckEveryCommits
      , autoCompactionCooldownCommits = cAutoCompactionCooldownCommits
      }

compactionStateFromC :: CArcadiaTioCompactionState -> CompactionState
compactionStateFromC CArcadiaTioCompactionState{cCompactionStateLastCompactedCommitSeq, cCompactionStateLastCompactedAtUnixMs} =
  CompactionState
    { compactionStateLastCompactedCommitSeq = cCompactionStateLastCompactedCommitSeq
    , compactionStateLastCompactedAtUnixMs = cCompactionStateLastCompactedAtUnixMs
    }

-- | Analyze how a sparse-intent append would be handled by the native writer.
analyzeSparseAppend :: forall a. TioElement a => TensorFile -> Tensor a -> SparseRule -> IO (Result SparseAppendAnalysis)
analyzeSparseAppend TensorFile{tensorFileNative, tensorFileHandle} tensor@Tensor{tensorShape, tensorValues} rule =
  case validateTensor tensor *> validateSparseRule payloadDType (length tensorShape) rule of
    Left err -> pure (Left err)
    Right () -> withForeignPtr tensorFileHandle $ \handle ->
      VS.unsafeWith tensorValues $ \valuesPtr ->
        withArray tensorShape $ \shapePtr ->
          withSparseRule rule $ \rulePtr ->
            alloca $ \analysisPtr -> do
              poke analysisPtr emptyCArcadiaTioSparseAppendAnalysis
              status <- case payloadDType of
                F32 -> capiAnalyzeSparseAppendF32V2 tensorFileNative handle (castPtr valuesPtr) shapePtr tensorRank rulePtr analysisPtr
                F64 -> capiAnalyzeSparseAppendF64V2 tensorFileNative handle (castPtr valuesPtr) shapePtr tensorRank rulePtr analysisPtr
                I32 -> capiAnalyzeSparseAppendI32V2 tensorFileNative handle (castPtr valuesPtr) shapePtr tensorRank rulePtr analysisPtr
                I64 -> capiAnalyzeSparseAppendI64V2 tensorFileNative handle (castPtr valuesPtr) shapePtr tensorRank rulePtr analysisPtr
              if status == okStatus
                then (peek analysisPtr >>= copySparseAppendAnalysis) `finally` capiSparseAppendAnalysisFree tensorFileNative analysisPtr
                else do
                  err <- lastError tensorFileNative
                  capiSparseAppendAnalysisFree tensorFileNative analysisPtr
                  pure (Left err)
 where
  payloadDType = elementDType (Proxy :: Proxy a)
  tensorRank = CSize (fromIntegral (length tensorShape))

-- | Analyze an f32 sparse-intent append.
analyzeSparseAppendF32 :: TensorFile -> [Word64] -> VS.Vector Float -> SparseRule -> IO (Result SparseAppendAnalysis)
analyzeSparseAppendF32 file shape values rule = analyzeSparseAppendVector file shape values rule

-- | Analyze an f64 sparse-intent append.
analyzeSparseAppendF64 :: TensorFile -> [Word64] -> VS.Vector Double -> SparseRule -> IO (Result SparseAppendAnalysis)
analyzeSparseAppendF64 file shape values rule = analyzeSparseAppendVector file shape values rule

-- | Analyze an i32 sparse-intent append.
analyzeSparseAppendI32 :: TensorFile -> [Word64] -> VS.Vector Int32 -> SparseRule -> IO (Result SparseAppendAnalysis)
analyzeSparseAppendI32 file shape values rule = analyzeSparseAppendVector file shape values rule

-- | Analyze an i64 sparse-intent append.
analyzeSparseAppendI64 :: TensorFile -> [Word64] -> VS.Vector Int64 -> SparseRule -> IO (Result SparseAppendAnalysis)
analyzeSparseAppendI64 file shape values rule = analyzeSparseAppendVector file shape values rule

analyzeSparseAppendVector :: TioElement a => TensorFile -> [Word64] -> VS.Vector a -> SparseRule -> IO (Result SparseAppendAnalysis)
analyzeSparseAppendVector file shape values rule = case tensorFromVector shape values of
  Left err -> pure (Left err)
  Right tensor -> analyzeSparseAppend file tensor rule

copySparseAppendAnalysis :: CArcadiaTioSparseAppendAnalysis -> IO (Result SparseAppendAnalysis)
copySparseAppendAnalysis raw = do
  reasons <- copySparseReasons (cSparseAnalysisReasons raw) (fromIntegralCSize (cSparseAnalysisReasonsLen raw))
  pure $ do
    outcome <- sparseOutcomeFromRaw (cSparseAnalysisOutcome raw)
    copiedReasons <- reasons
    Right
      SparseAppendAnalysis
        { sparseAppendOutcome = outcome
        , sparseAppendAbsentFraction = cSparseAnalysisAbsentFraction raw
        , sparseAppendAbsentSubtensorCount = cSparseAnalysisAbsentSubtensorCount raw
        , sparseAppendTotalSubtensorCount = cSparseAnalysisTotalSubtensorCount raw
        , sparseAppendReasons = copiedReasons
        }

copySparseReasons :: Ptr CInt -> Int -> IO (Result [SparseAppendReason])
copySparseReasons ptr len
  | len < 0 = pure (Left (invalidArgument "sparse analysis reasons length is negative"))
  | len == 0 = pure (Right [])
  | ptr == nullPtr = pure (Left (invalidArgument "sparse analysis reasons pointer is null"))
  | otherwise = do
      raws <- peekArray len ptr
      pure (mapM sparseReasonFromRaw raws)

sparseOutcomeFromRaw :: CInt -> Result SparseAppendOutcome
sparseOutcomeFromRaw raw = case raw of
  0 -> Right SparseAppendSparseRegularChunked
  1 -> Right SparseAppendDenseFallback
  2 -> Right SparseAppendReject
  3 -> Right SparseAppendSparseChunkTree
  _ -> Left (invalidArgument ("native sparse append analysis has unknown outcome " <> show raw))

sparseReasonFromRaw :: CInt -> Result SparseAppendReason
sparseReasonFromRaw raw = case raw of
  0 -> Right SparseReasonNoAbsentSubtensorsDetected
  1 -> Right SparseReasonSparseAxesMustNotBeEmpty
  2 -> Right SparseReasonSparseAxesMustBeUnique
  3 -> Right SparseReasonSparseAxesOutOfBounds
  4 -> Right SparseReasonSparseAxesMustExcludeAppendAxis
  5 -> Right SparseReasonAppendAxisMustBeZeroForCurrentRootAppend
  6 -> Right SparseReasonPredicateDTypeMismatch
  7 -> Right SparseReasonDenseFallbackPreservesExactValues
  8 -> Right SparseReasonSparseLoweringBelowThreshold
  9 -> Right SparseReasonWholeAppendUnitHasNoSparseProducerPath
  10 -> Right SparseReasonRegularChunkedBlockShapeUnpublished
  11 -> Right SparseReasonRegularChunkedDenseFallbackRequiresStableNonAppendExtents
  12 -> Right SparseReasonRegularChunkedDenseFallbackRequiresDensePublishedLaneSet
  13 -> Right SparseReasonRegularChunkedSparseLoweringRequiresStablePublishedLaneSet
  14 -> Right SparseReasonTensorContainsNullsThatDenseFallbackCannotPreserve
  15 -> Right SparseReasonLogicalAbsenceDoesNotCompileToCurrentSparseModel
  16 -> Right SparseReasonCurrentSparseLoweringNotYetImplementedForDetector
  _ -> Left (invalidArgument ("native sparse append analysis has unknown reason " <> show raw))

copyCArray :: Storable c => String -> Ptr c -> Int -> (c -> IO (Result a)) -> IO (Result [a])
copyCArray label ptr len convert
  | len < 0 = pure (Left (invalidArgument (label <> " length is negative")))
  | len == 0 = pure (Right [])
  | ptr == nullPtr = pure (Left (invalidArgument (label <> " pointer is null")))
  | otherwise = peekArray len ptr >>= mapResultM convert

mapResultM :: (a -> IO (Result b)) -> [a] -> IO (Result [b])
mapResultM _ [] = pure (Right [])
mapResultM f (x : xs) = do
  first <- f x
  case first of
    Left err -> pure (Left err)
    Right y -> do
      rest <- mapResultM f xs
      pure ((y :) <$> rest)

peekOptionalCString :: CString -> IO (Maybe String)
peekOptionalCString ptr
  | ptr == nullPtr = pure Nothing
  | otherwise = Just <$> peekCString ptr

peekRequiredCString :: CString -> IO String
peekRequiredCString ptr
  | ptr == nullPtr = pure ""
  | otherwise = peekCString ptr

-- | Append a dense tensor with universe slot bindings.
appendDenseWithUniverse :: forall a. TioElement a => TensorFile -> Tensor a -> AppendWithUniverseOptions -> IO (Result AppendRange)
appendDenseWithUniverse file@TensorFile{tensorFileNative} tensor@Tensor{tensorShape, tensorValues} options = do
  case validateTensor tensor *> validateAppendUniverseOptions options of
    Left err -> pure (Left err)
    Right () -> withForeignPtr (tensorFileHandle file) $ \handle ->
      VS.unsafeWith tensorValues $ \valuesPtr ->
        withArray tensorShape $ \shapePtr ->
          withAppendUniverseOptions options $ \optionsPtr ->
            alloca $ \startPtr ->
              alloca $ \endPtr -> do
                status <- case elementDType (Proxy :: Proxy a) of
                  F32 -> capiAppendF32WithUniverse tensorFileNative handle (castPtr valuesPtr) shapePtr tensorRank optionsPtr startPtr endPtr
                  F64 -> capiAppendF64WithUniverse tensorFileNative handle (castPtr valuesPtr) shapePtr tensorRank optionsPtr startPtr endPtr
                  I32 -> capiAppendI32WithUniverse tensorFileNative handle (castPtr valuesPtr) shapePtr tensorRank optionsPtr startPtr endPtr
                  I64 -> capiAppendI64WithUniverse tensorFileNative handle (castPtr valuesPtr) shapePtr tensorRank optionsPtr startPtr endPtr
                if status == okStatus
                  then AppendRange <$> peek startPtr <*> peek endPtr >>= pure . Right
                  else Left <$> lastError tensorFileNative
 where
  tensorRank = CSize (fromIntegral (length tensorShape))

appendDenseF32WithUniverse :: TensorFile -> [Word64] -> VS.Vector Float -> AppendWithUniverseOptions -> IO (Result AppendRange)
appendDenseF32WithUniverse file shape values options = appendUniverseVector file shape values options

appendDenseF64WithUniverse :: TensorFile -> [Word64] -> VS.Vector Double -> AppendWithUniverseOptions -> IO (Result AppendRange)
appendDenseF64WithUniverse file shape values options = appendUniverseVector file shape values options

appendDenseI32WithUniverse :: TensorFile -> [Word64] -> VS.Vector Int32 -> AppendWithUniverseOptions -> IO (Result AppendRange)
appendDenseI32WithUniverse file shape values options = appendUniverseVector file shape values options

appendDenseI64WithUniverse :: TensorFile -> [Word64] -> VS.Vector Int64 -> AppendWithUniverseOptions -> IO (Result AppendRange)
appendDenseI64WithUniverse file shape values options = appendUniverseVector file shape values options

appendUniverseVector :: TioElement a => TensorFile -> [Word64] -> VS.Vector a -> AppendWithUniverseOptions -> IO (Result AppendRange)
appendUniverseVector file shape values options = case tensorFromVector shape values of
  Left err -> pure (Left err)
  Right tensor -> appendDenseWithUniverse file tensor options

validateAppendUniverseOptions :: AppendWithUniverseOptions -> Result ()
validateAppendUniverseOptions AppendWithUniverseOptions{appendUniverseSlots, appendUniverseRemapSlots} = do
  mapM_ validateSlot appendUniverseSlots
  mapM_ validateRemapSlot appendUniverseRemapSlots
 where
  validateSlot (SlotUniverseBindingInput axes) = mapM_ validateBinding axes
  validateBinding UniverseBindingInput{universeBindingAxis, universeBindingFamilyUuid, universeBindingVersionUuid} = do
    validateAxisIndex "universe binding" universeBindingAxis
    validateUuid "universe binding family UUID" universeBindingFamilyUuid
    validateUuid "universe binding version UUID" universeBindingVersionUuid
  validateRemapSlot (SlotUniverseRemapInput axes) = mapM_ validateRemap axes
  validateRemap UniverseRemapInput{universeRemapAxis, universeRemapTargetFamilyUuid, universeRemapTargetVersionUuid} = do
    validateAxisIndex "universe remap" universeRemapAxis
    validateUuid "universe remap family UUID" universeRemapTargetFamilyUuid
    validateUuid "universe remap version UUID" universeRemapTargetVersionUuid

withAppendUniverseOptions :: AppendWithUniverseOptions -> (Ptr CArcadiaTioAppendWithUniverseOptions -> IO a) -> IO a
withAppendUniverseOptions AppendWithUniverseOptions{appendUniverseSlots, appendUniverseRemapSlots} action =
  withSlotUniverseBindingInputs appendUniverseSlots $ \slotsPtr slotsLen ->
    withSlotUniverseRemapInputs appendUniverseRemapSlots $ \remapPtr remapLen ->
      alloca $ \optionsPtr -> do
        poke optionsPtr CArcadiaTioAppendWithUniverseOptions
          { cAppendWithUniverseOptionsVersion = 1
          , cAppendWithUniverseOptionsStructSize = 48
          , cAppendWithUniverseOptionsSlots = slotsPtr
          , cAppendWithUniverseOptionsSlotsLen = slotsLen
          , cAppendWithUniverseOptionsRemapSlots = remapPtr
          , cAppendWithUniverseOptionsRemapSlotsLen = remapLen
          }
        action optionsPtr

withSlotUniverseBindingInputs :: [SlotUniverseBindingInput] -> (Ptr CArcadiaTioSlotUniverseBindingInput -> CSize -> IO a) -> IO a
withSlotUniverseBindingInputs slots action = go slots []
 where
  go [] acc = withArray (reverse acc) $ \ptr -> action (if null acc then nullPtr else ptr) (CSize (fromIntegral (length acc)))
  go (SlotUniverseBindingInput axes : rest) acc =
    withArray (map universeBindingToC axes) $ \axesPtr ->
      go rest (CArcadiaTioSlotUniverseBindingInput (if null axes then nullPtr else axesPtr) (CSize (fromIntegral (length axes))) : acc)

universeBindingToC :: UniverseBindingInput -> CArcadiaTioUniverseBindingInput
universeBindingToC UniverseBindingInput{universeBindingAxis, universeBindingFamilyUuid, universeBindingVersionUuid, universeBindingLength} =
  CArcadiaTioUniverseBindingInput (fromIntegral universeBindingAxis) (uuidBytes16 universeBindingFamilyUuid) (uuidBytes16 universeBindingVersionUuid) universeBindingLength

withSlotUniverseRemapInputs :: [SlotUniverseRemapInput] -> (Ptr CArcadiaTioSlotUniverseRemapInput -> CSize -> IO a) -> IO a
withSlotUniverseRemapInputs slots action = go slots []
 where
  go [] acc = withArray (reverse acc) $ \ptr -> action (if null acc then nullPtr else ptr) (CSize (fromIntegral (length acc)))
  go (SlotUniverseRemapInput axes : rest) acc =
    withUniverseRemapInputs axes $ \axesPtr axesLen ->
      go rest (CArcadiaTioSlotUniverseRemapInput axesPtr axesLen : acc)

withUniverseRemapInputs :: [UniverseRemapInput] -> (Ptr CArcadiaTioUniverseRemapInput -> CSize -> IO a) -> IO a
withUniverseRemapInputs remaps action = go remaps []
 where
  go [] acc = withArray (reverse acc) $ \ptr -> action (if null acc then nullPtr else ptr) (CSize (fromIntegral (length acc)))
  go (remap : rest) acc =
    withArray (universeRemapSourceToTarget remap) $ \mapPtr ->
      go rest (universeRemapToC (if null (universeRemapSourceToTarget remap) then nullPtr else mapPtr) remap : acc)

universeRemapToC :: Ptr Word64 -> UniverseRemapInput -> CArcadiaTioUniverseRemapInput
universeRemapToC mapPtr UniverseRemapInput{universeRemapAxis, universeRemapTargetFamilyUuid, universeRemapTargetVersionUuid, universeRemapTargetLength, universeRemapSourceToTarget} =
  CArcadiaTioUniverseRemapInput 1 80 (fromIntegral universeRemapAxis) (uuidBytes16 universeRemapTargetFamilyUuid) (uuidBytes16 universeRemapTargetVersionUuid) universeRemapTargetLength mapPtr (CSize (fromIntegral (length universeRemapSourceToTarget)))

-- | Append a dense tensor with Coordinate v2 append-axis batches. Payload and
-- coordinate buffers are borrowed only for the duration of the C call.
appendDenseWithCoordinatesV2 :: forall a. TioElement a => TensorFile -> Tensor a -> [AppendCoordinateEntryV2] -> IO (Result AppendRange)
appendDenseWithCoordinatesV2 file@TensorFile{tensorFileNative} tensor@Tensor{tensorShape, tensorValues} coordinates = do
  case validateTensor tensor *> validateAppendCoordinateEntries coordinates of
    Left err -> pure (Left err)
    Right () -> withForeignPtr (tensorFileHandle file) $ \handle ->
      VS.unsafeWith tensorValues $ \valuesPtr ->
        withArray tensorShape $ \shapePtr ->
          withAppendCoordinateBatch coordinates $ \coordinateBatchPtr ->
            alloca $ \startPtr ->
              alloca $ \endPtr -> do
                status <- case elementDType (Proxy :: Proxy a) of
                  F32 -> capiAppendF32WithCoordinatesV2 tensorFileNative handle (castPtr valuesPtr) shapePtr tensorRank coordinateBatchPtr startPtr endPtr
                  F64 -> capiAppendF64WithCoordinatesV2 tensorFileNative handle (castPtr valuesPtr) shapePtr tensorRank coordinateBatchPtr startPtr endPtr
                  I32 -> capiAppendI32WithCoordinatesV2 tensorFileNative handle (castPtr valuesPtr) shapePtr tensorRank coordinateBatchPtr startPtr endPtr
                  I64 -> capiAppendI64WithCoordinatesV2 tensorFileNative handle (castPtr valuesPtr) shapePtr tensorRank coordinateBatchPtr startPtr endPtr
                if status == okStatus
                  then AppendRange <$> peek startPtr <*> peek endPtr >>= pure . Right
                  else Left <$> lastError tensorFileNative
 where
  tensorRank = CSize (fromIntegral (length tensorShape))

appendDenseF32WithCoordinatesV2 :: TensorFile -> [Word64] -> VS.Vector Float -> [AppendCoordinateEntryV2] -> IO (Result AppendRange)
appendDenseF32WithCoordinatesV2 file shape values coordinates = appendVectorWithCoordinates file shape values coordinates

appendDenseF64WithCoordinatesV2 :: TensorFile -> [Word64] -> VS.Vector Double -> [AppendCoordinateEntryV2] -> IO (Result AppendRange)
appendDenseF64WithCoordinatesV2 file shape values coordinates = appendVectorWithCoordinates file shape values coordinates

appendDenseI32WithCoordinatesV2 :: TensorFile -> [Word64] -> VS.Vector Int32 -> [AppendCoordinateEntryV2] -> IO (Result AppendRange)
appendDenseI32WithCoordinatesV2 file shape values coordinates = appendVectorWithCoordinates file shape values coordinates

appendDenseI64WithCoordinatesV2 :: TensorFile -> [Word64] -> VS.Vector Int64 -> [AppendCoordinateEntryV2] -> IO (Result AppendRange)
appendDenseI64WithCoordinatesV2 file shape values coordinates = appendVectorWithCoordinates file shape values coordinates

appendVectorWithCoordinates :: TioElement a => TensorFile -> [Word64] -> VS.Vector a -> [AppendCoordinateEntryV2] -> IO (Result AppendRange)
appendVectorWithCoordinates file shape values coordinates = case tensorFromVector shape values of
  Left err -> pure (Left err)
  Right tensor -> appendDenseWithCoordinatesV2 file tensor coordinates

validateAppendCoordinateEntries :: [AppendCoordinateEntryV2] -> Result ()
validateAppendCoordinateEntries coordinates = mapM_ validateEntry coordinates
 where
  validateEntry AppendCoordinateEntryV2{appendCoordinateEntryAxis, appendCoordinateEntryDescriptorId, appendCoordinateEntryName}
    | appendCoordinateEntryAxis < 0 = Left (invalidArgument "append coordinate axis must be non-negative")
    | otherwise = do
        validateRequiredString "append coordinate descriptor id" appendCoordinateEntryDescriptorId
        validateRequiredString "append coordinate name" appendCoordinateEntryName

withAppendCoordinateBatch :: [AppendCoordinateEntryV2] -> (Ptr CArcadiaTioAppendCoordinateBatchV2 -> IO a) -> IO a
withAppendCoordinateBatch coordinates action =
  withAppendCoordinateEntries coordinates $ \entriesPtr entriesLen ->
    alloca $ \batchPtr -> do
      poke batchPtr CArcadiaTioAppendCoordinateBatchV2
        { cAppendCoordinateBatchVersion = 1
        , cAppendCoordinateBatchStructSize = 64
        , cAppendCoordinateBatchEntries = entriesPtr
        , cAppendCoordinateBatchEntriesLen = entriesLen
        }
      action batchPtr

withAppendCoordinateEntries :: [AppendCoordinateEntryV2] -> (Ptr CArcadiaTioAppendCoordinateEntryV2 -> CSize -> IO a) -> IO a
withAppendCoordinateEntries [] action = action nullPtr 0
withAppendCoordinateEntries coordinates action =
  withAppendCoordinateEntriesRaw coordinates $ \raw ->
    withArray raw $ \entriesPtr -> action entriesPtr (CSize (fromIntegral (length raw)))

withAppendCoordinateEntriesRaw :: [AppendCoordinateEntryV2] -> ([CArcadiaTioAppendCoordinateEntryV2] -> IO a) -> IO a
withAppendCoordinateEntriesRaw [] action = action []
withAppendCoordinateEntriesRaw (entry : rest) action =
  withCString (appendCoordinateEntryDescriptorId entry) $ \descriptorPtr ->
    withCString (appendCoordinateEntryName entry) $ \namePtr ->
      withCoordinateValues (appendCoordinateEntryValues entry) $ \dtype valuesPtr valuesLen ->
        withAppendCoordinateEntriesRaw rest $ \restRaw ->
          action (appendCoordinateEntryToC descriptorPtr namePtr dtype valuesPtr valuesLen entry : restRaw)

appendCoordinateEntryToC :: CString -> CString -> CoordinateDType -> Ptr Word8 -> CSize -> AppendCoordinateEntryV2 -> CArcadiaTioAppendCoordinateEntryV2
appendCoordinateEntryToC descriptorPtr namePtr dtype valuesPtr valuesLen AppendCoordinateEntryV2{appendCoordinateEntryAxis, appendCoordinateEntryEncoding} =
  CArcadiaTioAppendCoordinateEntryV2
    { cAppendCoordinateEntryVersion = 1
    , cAppendCoordinateEntryStructSize = 120
    , cAppendCoordinateEntryAxis = CSize (fromIntegral appendCoordinateEntryAxis)
    , cAppendCoordinateEntryDescriptorId = descriptorPtr
    , cAppendCoordinateEntryName = namePtr
    , cAppendCoordinateEntryValueDomain = coordinateValueDomainV2ToRaw CoordinateV2InlineNumeric
    , cAppendCoordinateEntryNumericDType = coordinateDTypeToRaw dtype
    , cAppendCoordinateEntryNumericEncoding = coordinateEncodingToRaw appendCoordinateEntryEncoding
    , cAppendCoordinateEntryCodeDType = 0
    , cAppendCoordinateEntryValues = valuesPtr
    , cAppendCoordinateEntryCount = valuesLen
    , cAppendCoordinateEntryElementSize = CSize (case dtype of CoordinateI32 -> 4; CoordinateI64 -> 8; _ -> 0)
    , cAppendCoordinateEntryFixedTextWidth = 0
    , cAppendCoordinateEntryDictionaryEntries = nullPtr
    , cAppendCoordinateEntryDictionaryEntriesLen = 0
    }

-- | Append a dense tensor. The tensor payload is borrowed only for the duration
-- of the C call.
appendDense :: forall a. TioElement a => TensorFile -> Tensor a -> IO (Result AppendRange)
appendDense file@TensorFile{tensorFileNative} tensor@Tensor{tensorShape, tensorValues} = do
  case validateTensor tensor of
    Left err -> pure (Left err)
    Right () -> withForeignPtr (tensorFileHandle file) $ \handle ->
      VS.unsafeWith tensorValues $ \valuesPtr ->
        withArray tensorShape $ \shapePtr ->
          alloca $ \startPtr ->
            alloca $ \endPtr -> do
              status <- case elementDType (Proxy :: Proxy a) of
                F32 -> capiAppendF32WithRange tensorFileNative handle (castPtr valuesPtr) shapePtr tensorRank startPtr endPtr
                F64 -> capiAppendF64WithRange tensorFileNative handle (castPtr valuesPtr) shapePtr tensorRank startPtr endPtr
                I32 -> capiAppendI32WithRange tensorFileNative handle (castPtr valuesPtr) shapePtr tensorRank startPtr endPtr
                I64 -> capiAppendI64WithRange tensorFileNative handle (castPtr valuesPtr) shapePtr tensorRank startPtr endPtr
              if status == okStatus
                then AppendRange <$> peek startPtr <*> peek endPtr >>= pure . Right
                else Left <$> lastError tensorFileNative
 where
  tensorRank = CSize (fromIntegral (length tensorShape))

-- | Append an f32 dense tensor.
appendDenseF32 :: TensorFile -> [Word64] -> VS.Vector Float -> IO (Result AppendRange)
appendDenseF32 file shape values = appendVector file shape values

-- | Append an f64 dense tensor.
appendDenseF64 :: TensorFile -> [Word64] -> VS.Vector Double -> IO (Result AppendRange)
appendDenseF64 file shape values = appendVector file shape values

-- | Append an i32 dense tensor.
appendDenseI32 :: TensorFile -> [Word64] -> VS.Vector Int32 -> IO (Result AppendRange)
appendDenseI32 file shape values = appendVector file shape values

-- | Append an i64 dense tensor.
appendDenseI64 :: TensorFile -> [Word64] -> VS.Vector Int64 -> IO (Result AppendRange)
appendDenseI64 file shape values = appendVector file shape values

appendVector :: TioElement a => TensorFile -> [Word64] -> VS.Vector a -> IO (Result AppendRange)
appendVector file shape values = case tensorFromVector shape values of
  Left err -> pure (Left err)
  Right tensor -> appendDense file tensor

-- | Append a tensor through the native sparse-intent path and return the
-- assigned append-entry range. The payload and rule are borrowed only for the
-- duration of the C call.
appendSparse :: forall a. TioElement a => TensorFile -> Tensor a -> SparseRule -> IO (Result AppendRange)
appendSparse file@TensorFile{tensorFileNative} tensor@Tensor{tensorShape, tensorValues} rule = do
  case validateTensor tensor *> validateSparseRule payloadDType (length tensorShape) rule of
    Left err -> pure (Left err)
    Right () -> withForeignPtr (tensorFileHandle file) $ \handle ->
      VS.unsafeWith tensorValues $ \valuesPtr ->
        withArray tensorShape $ \shapePtr ->
          withSparseRule rule $ \rulePtr ->
            alloca $ \startPtr ->
              alloca $ \endPtr -> do
                status <- case payloadDType of
                  F32 -> capiAppendSparseF32WithRangeV2 tensorFileNative handle (castPtr valuesPtr) shapePtr tensorRank rulePtr startPtr endPtr
                  F64 -> capiAppendSparseF64WithRangeV2 tensorFileNative handle (castPtr valuesPtr) shapePtr tensorRank rulePtr startPtr endPtr
                  I32 -> capiAppendSparseI32WithRangeV2 tensorFileNative handle (castPtr valuesPtr) shapePtr tensorRank rulePtr startPtr endPtr
                  I64 -> capiAppendSparseI64WithRangeV2 tensorFileNative handle (castPtr valuesPtr) shapePtr tensorRank rulePtr startPtr endPtr
                if status == okStatus
                  then AppendRange <$> peek startPtr <*> peek endPtr >>= pure . Right
                  else Left <$> lastError tensorFileNative
 where
  payloadDType = elementDType (Proxy :: Proxy a)
  tensorRank = CSize (fromIntegral (length tensorShape))

-- | Append f32 data through the sparse-intent path.
appendSparseF32 :: TensorFile -> [Word64] -> VS.Vector Float -> SparseRule -> IO (Result AppendRange)
appendSparseF32 file shape values rule = appendSparseVector file shape values rule

-- | Append f64 data through the sparse-intent path.
appendSparseF64 :: TensorFile -> [Word64] -> VS.Vector Double -> SparseRule -> IO (Result AppendRange)
appendSparseF64 file shape values rule = appendSparseVector file shape values rule

-- | Append i32 data through the sparse-intent path.
appendSparseI32 :: TensorFile -> [Word64] -> VS.Vector Int32 -> SparseRule -> IO (Result AppendRange)
appendSparseI32 file shape values rule = appendSparseVector file shape values rule

-- | Append i64 data through the sparse-intent path.
appendSparseI64 :: TensorFile -> [Word64] -> VS.Vector Int64 -> SparseRule -> IO (Result AppendRange)
appendSparseI64 file shape values rule = appendSparseVector file shape values rule

appendSparseVector :: TioElement a => TensorFile -> [Word64] -> VS.Vector a -> SparseRule -> IO (Result AppendRange)
appendSparseVector file shape values rule = case tensorFromVector shape values of
  Left err -> pure (Left err)
  Right tensor -> appendSparse file tensor rule

validateTensor :: TioElement a => Tensor a -> Result ()
validateTensor Tensor{tensorShape, tensorValues} = do
  expected <- tensorElementCount tensorShape
  let actual = VS.length tensorValues
  if expected == actual
    then Right ()
    else Left (invalidArgument ("tensor payload length " <> show actual <> " does not match shape product " <> show expected))

validateSparseRule :: DType -> Int -> SparseRule -> Result ()
validateSparseRule payloadDType tensorRank SparseRule{sparseDetector, sparseAxes, sparsePredicate, sparseMinAbsentFraction}
  | tensorRank <= 0 = Left (invalidArgument "sparse append shape rank must be non-zero")
  | null sparseAxes = Left (invalidArgument "sparse rule sparse_axes must not be empty")
  | any (< 0) sparseAxes = Left (invalidArgument "sparse axes must be non-negative")
  | any (>= tensorRank) sparseAxes = Left (invalidArgument "sparse axes must be within the tensor rank")
  | 0 `elem` sparseAxes = Left (invalidArgument "sparse axes must exclude append axis 0")
  | hasDuplicates sparseAxes = Left (invalidArgument "sparse axes must be unique")
  | isNaN sparseMinAbsentFraction || isInfinite sparseMinAbsentFraction || sparseMinAbsentFraction < 0 || sparseMinAbsentFraction > 1 =
      Left (invalidArgument "sparse rule min_absent_fraction must be finite and between 0.0 and 1.0")
  | otherwise = validateSparsePredicate payloadDType sparseDetector sparsePredicate

validateSparsePredicate :: DType -> SparseDetector -> SparseValuePredicate -> Result ()
validateSparsePredicate _ SparseNullSubtensor _ = Right ()
validateSparsePredicate payloadDType SparsePredicateSubtensor predicate =
  case (payloadDType, predicate) of
    (F32, SparsePredicateEqualF64 _) -> reject "f32 sparse append cannot use this predicate dtype"
    (F32, SparsePredicateEqualI32 _) -> reject "f32 sparse append cannot use this predicate dtype"
    (F32, SparsePredicateEqualI64 _) -> reject "f32 sparse append cannot use this predicate dtype"
    (F64, SparsePredicateEqualF32 _) -> reject "f64 sparse append cannot use this predicate dtype"
    (F64, SparsePredicateEqualI32 _) -> reject "f64 sparse append cannot use this predicate dtype"
    (F64, SparsePredicateEqualI64 _) -> reject "f64 sparse append cannot use this predicate dtype"
    (I32, SparsePredicateZero) -> Right ()
    (I32, SparsePredicateEqualI32 _) -> Right ()
    (I32, _) -> reject "integer sparse append predicate does not match tensor dtype"
    (I64, SparsePredicateZero) -> Right ()
    (I64, SparsePredicateEqualI64 _) -> Right ()
    (I64, _) -> reject "integer sparse append predicate does not match tensor dtype"
    _ -> Right ()
 where
  reject = Left . invalidArgument

hasDuplicates :: Eq a => [a] -> Bool
hasDuplicates [] = False
hasDuplicates (value : rest) = value `elem` rest || hasDuplicates rest

withSparseRule :: SparseRule -> (Ptr CArcadiaTioSparseRuleV2 -> IO a) -> IO a
withSparseRule SparseRule{sparseDetector, sparseAxes, sparsePredicate, sparseMinAbsentFraction, sparseMinAbsentSubtensors, sparseFallback} action =
  withCSizeArray (map (CSize . fromIntegral) sparseAxes) $ \axesPtr axesLen ->
    alloca $ \rulePtr -> do
      poke
        rulePtr
        CArcadiaTioSparseRuleV2
          { cSparseRuleStructSize = sparseRuleV2StructSize
          , cSparseRuleDetectorKind = sparseDetectorToRaw sparseDetector
          , cSparseRuleAxes = axesPtr
          , cSparseRuleAxesLen = axesLen
          , cSparseRulePredicate = sparsePredicateToC sparsePredicate
          , cSparseRuleMinAbsentFraction = sparseMinAbsentFraction
          , cSparseRuleMinAbsentSubtensors = sparseMinAbsentSubtensors
          , cSparseRuleFallback = sparseFallbackToRaw sparseFallback
          }
      action rulePtr

sparseDetectorToRaw :: SparseDetector -> CInt
sparseDetectorToRaw detector = case detector of
  SparseNullSubtensor -> 0
  SparsePredicateSubtensor -> 1

sparsePredicateToC :: SparseValuePredicate -> CArcadiaTioSparseValuePredicateV2
sparsePredicateToC predicate = case predicate of
  SparsePredicateNaN -> raw 0 0 0
  SparsePredicateZero -> raw 1 0 0
  SparsePredicateEqualF32 value -> raw 2 (realToFrac value) 0
  SparsePredicateEqualF64 value -> raw 3 value 0
  SparsePredicateEqualI32 value -> raw 4 0 (fromIntegral value)
  SparsePredicateEqualI64 value -> raw 5 0 value
 where
  raw kind floatValue integerValue =
    CArcadiaTioSparseValuePredicateV2
      { cSparsePredicateKind = kind
      , cSparsePredicateFloatValue = floatValue
      , cSparsePredicateIntegerValue = integerValue
      }

sparseFallbackToRaw :: SparseFallbackPolicy -> CInt
sparseFallbackToRaw fallback = case fallback of
  SparseFallbackDense -> 0

-- | Read all visible data into a Haskell-owned tensor.
readAll :: TensorFile -> IO (Result SomeTensor)
readAll file@TensorFile{tensorFileNative} = readTensor file (capiReadAll tensorFileNative)

-- | Read all visible data and require a particular Haskell element type.
readAllAs :: forall a. TioElement a => TensorFile -> IO (Result (Tensor a))
readAllAs file = do
  result <- readAll file
  pure $ case result of
    Left err -> Left err
    Right tensor -> fromSomeTensor tensor

-- | Read all visible data as f32.
readAllF32 :: TensorFile -> IO (Result (Tensor Float))
readAllF32 = readAllAs

-- | Read all visible data as f64.
readAllF64 :: TensorFile -> IO (Result (Tensor Double))
readAllF64 = readAllAs

-- | Read all visible data as i32.
readAllI32 :: TensorFile -> IO (Result (Tensor Int32))
readAllI32 = readAllAs

-- | Read all visible data as i64.
readAllI64 :: TensorFile -> IO (Result (Tensor Int64))
readAllI64 = readAllAs

-- | Read all visible data into a dense tensor plus validity mask.
readAllDense :: TensorFile -> Double -> IO (Result SomeDenseRead)
readAllDense TensorFile{tensorFileNative, tensorFileHandle} fillValue =
  withForeignPtr tensorFileHandle $ \handle ->
    alloca $ \tensorPtr ->
      alloca $ \maskPtr -> do
        poke tensorPtr emptyCArcadiaTioTensor
        poke maskPtr emptyCArcadiaTioMask
        status <- capiReadAllDense tensorFileNative handle fillValue tensorPtr maskPtr
        if status == okStatus
          then (copySomeDenseReadFromPtrs tensorPtr maskPtr) `finally` freeDenseOutputs tensorPtr maskPtr
          else do
            err <- lastError tensorFileNative
            freeDenseOutputs tensorPtr maskPtr
            pure (Left err)
 where
  freeDenseOutputs tensorPtr maskPtr = do
    capiTensorFree tensorFileNative tensorPtr
    capiMaskFree tensorFileNative maskPtr

-- | Read all visible data as a typed dense tensor plus validity mask.
readAllDenseAs :: forall a. TioElement a => TensorFile -> Double -> IO (Result (DenseRead a))
readAllDenseAs file fillValue = do
  result <- readAllDense file fillValue
  pure $ case result of
    Left err -> Left err
    Right dense -> fromSomeDenseRead dense

-- | Read all visible data as f32 plus validity mask.
readAllDenseF32 :: TensorFile -> Double -> IO (Result (DenseRead Float))
readAllDenseF32 = readAllDenseAs

-- | Read all visible data as f64 plus validity mask.
readAllDenseF64 :: TensorFile -> Double -> IO (Result (DenseRead Double))
readAllDenseF64 = readAllDenseAs

-- | Read all visible data as i32 plus validity mask.
readAllDenseI32 :: TensorFile -> Double -> IO (Result (DenseRead Int32))
readAllDenseI32 = readAllDenseAs

-- | Read all visible data as i64 plus validity mask.
readAllDenseI64 :: TensorFile -> Double -> IO (Result (DenseRead Int64))
readAllDenseI64 = readAllDenseAs

-- | Read a half-open range on one axis.
readAxisRange :: TensorFile -> Int -> Word32 -> Word32 -> IO (Result SomeTensor)
readAxisRange file@TensorFile{tensorFileNative} axis start end =
  if axis < 0
    then pure (Left (invalidArgument "axis must be non-negative"))
    else readTensor file $ \handle outPtr -> capiReadAxisRange tensorFileNative handle (CSize (fromIntegral axis)) start end outPtr

-- | Read a set of indices on one axis.
readAxisTake :: TensorFile -> Int -> [Word32] -> IO (Result SomeTensor)
readAxisTake file@TensorFile{tensorFileNative} axis indices =
  if axis < 0
    then pure (Left (invalidArgument "axis must be non-negative"))
    else withArray indices $ \indicesPtr ->
      readTensor file $ \handle outPtr -> capiReadAxisTake tensorFileNative handle (CSize (fromIntegral axis)) indicesPtr (CSize (fromIntegral (length indices))) outPtr

-- | Read one index on one axis.
readAxisOne :: TensorFile -> Int -> Word32 -> IO (Result SomeTensor)
readAxisOne file@TensorFile{tensorFileNative} axis index =
  if axis < 0
    then pure (Left (invalidArgument "axis must be non-negative"))
    else readTensor file $ \handle outPtr -> capiReadAxisOne tensorFileNative handle (CSize (fromIntegral axis)) index outPtr

-- | Read a half-open append-entry range.
readEntryRange :: TensorFile -> Word32 -> Word32 -> IO (Result SomeTensor)
readEntryRange file@TensorFile{tensorFileNative} start end =
  readTensor file $ \handle outPtr -> capiReadEntryRange tensorFileNative handle start end outPtr

-- | Read explicit append-entry indices.
takeEntries :: TensorFile -> [Word32] -> IO (Result SomeTensor)
takeEntries file@TensorFile{tensorFileNative} indices =
  withArray indices $ \indicesPtr ->
    readTensor file $ \handle outPtr -> capiTakeEntries tensorFileNative handle indicesPtr (CSize (fromIntegral (length indices))) outPtr

-- | Read one scalar by full-rank indices. The C ABI returns scalar payloads as
-- a dtype tag plus a double-valued carrier.
readScalar :: TensorFile -> [Word32] -> IO (Result ScalarValue)
readScalar TensorFile{tensorFileNative, tensorFileHandle} indices =
  withForeignPtr tensorFileHandle $ \handle ->
    withArray indices $ \indicesPtr ->
      alloca $ \outPtr -> do
        status <- capiReadScalar tensorFileNative handle indicesPtr (CSize (fromIntegral (length indices))) outPtr
        if status == okStatus
          then do
            CArcadiaTioScalar{cScalarDType, cScalarValue} <- peek outPtr
            pure $ case dtypeFromRaw cScalarDType of
              Nothing -> Left (invalidArgument "native scalar has unknown dtype")
              Just scalarType -> Right ScalarValue{scalarDType = scalarType, scalarValue = cScalarValue}
          else Left <$> lastError tensorFileNative

validateRewriteSelectors :: [EntrySelector] -> Result ()
validateRewriteSelectors selectors
  | null selectors = Left (invalidArgument "rewrite slice selectors must not be empty")
  | otherwise = Right ()

validateChunkKeys :: [[Word32]] -> Result ()
validateChunkKeys keys
  | null keys = Left (invalidArgument "clear block keys must not be empty")
  | any null keys = Left (invalidArgument "clear block key coordinates must not be empty")
  | otherwise = Right ()

withChunkKeys :: [[Word32]] -> (Ptr CArcadiaTioChunkKey -> CSize -> IO a) -> IO a
withChunkKeys keys action = go keys []
 where
  go [] acc = withArray (reverse acc) $ \keysPtr -> action keysPtr (CSize (fromIntegral (length keys)))
  go (coords : rest) acc =
    withArray coords $ \coordsPtr ->
      go rest (CArcadiaTioChunkKey coordsPtr (CSize (fromIntegral (length coords))) : acc)

wrapArrowCData :: Ptr CArrowArray -> Ptr CArrowSchema -> IO ArrowCData
wrapArrowCData arrayPtr schemaPtr = do
  arrayFp <- FC.newForeignPtr arrayPtr (releaseArrowArrayPtr arrayPtr >> free arrayPtr)
  schemaFp <- FC.newForeignPtr schemaPtr (releaseArrowSchemaPtr schemaPtr >> free schemaPtr)
  pure ArrowCData{arrowArrayForeignPtr = arrayFp, arrowSchemaForeignPtr = schemaFp}

releaseArrowArrayPtr :: Ptr CArrowArray -> IO ()
releaseArrowArrayPtr ptr = do
  array <- peek ptr
  if cArrowArrayRelease array == nullFunPtr
    then pure ()
    else arrowArrayRelease (cArrowArrayRelease array) ptr

releaseArrowSchemaPtr :: Ptr CArrowSchema -> IO ()
releaseArrowSchemaPtr ptr = do
  schema <- peek ptr
  if cArrowSchemaRelease schema == nullFunPtr
    then pure ()
    else arrowSchemaRelease (cArrowSchemaRelease schema) ptr

readTensorWithReport :: TensorFile -> (Ptr CHandle -> Ptr CArcadiaTioTensor -> Ptr CArcadiaTioReadExecutionReport -> IO CInt) -> IO (Result (SomeTensor, ReadExecutionReport))
readTensorWithReport TensorFile{tensorFileNative, tensorFileHandle} nativeRead =
  withForeignPtr tensorFileHandle $ \handle ->
    alloca $ \tensorPtr ->
      alloca $ \reportPtr -> do
        poke tensorPtr emptyCArcadiaTioTensor
        poke reportPtr emptyCArcadiaTioReadExecutionReport
        status <- nativeRead handle tensorPtr reportPtr
        if status == okStatus
          then do
            tensor <- peek tensorPtr >>= copySomeTensor
            report <- peek reportPtr >>= readExecutionReportFromC
            capiTensorFree tensorFileNative tensorPtr
            capiReadExecutionReportFree tensorFileNative reportPtr
            pure $ (,) <$> tensor <*> report
          else do
            err <- lastError tensorFileNative
            capiTensorFree tensorFileNative tensorPtr
            capiReadExecutionReportFree tensorFileNative reportPtr
            pure (Left err)

readDenseWithReport :: TensorFile -> (Ptr CHandle -> Ptr CArcadiaTioTensor -> Ptr CArcadiaTioMask -> Ptr CArcadiaTioReadExecutionReport -> IO CInt) -> IO (Result (SomeDenseRead, ReadExecutionReport))
readDenseWithReport TensorFile{tensorFileNative, tensorFileHandle} nativeRead =
  withForeignPtr tensorFileHandle $ \handle ->
    alloca $ \tensorPtr ->
      alloca $ \maskPtr ->
        alloca $ \reportPtr -> do
          poke tensorPtr emptyCArcadiaTioTensor
          poke maskPtr emptyCArcadiaTioMask
          poke reportPtr emptyCArcadiaTioReadExecutionReport
          status <- nativeRead handle tensorPtr maskPtr reportPtr
          if status == okStatus
            then do
              dense <- copySomeDenseReadFromPtrs tensorPtr maskPtr
              report <- peek reportPtr >>= readExecutionReportFromC
              capiTensorFree tensorFileNative tensorPtr
              capiMaskFree tensorFileNative maskPtr
              capiReadExecutionReportFree tensorFileNative reportPtr
              pure $ (,) <$> dense <*> report
            else do
              err <- lastError tensorFileNative
              capiTensorFree tensorFileNative tensorPtr
              capiMaskFree tensorFileNative maskPtr
              capiReadExecutionReportFree tensorFileNative reportPtr
              pure (Left err)

readHistoricalTensorWithReport :: TensorFile -> (Ptr CHandle -> Ptr CArcadiaTioTensor -> Ptr CArcadiaTioHistoricalReadExecutionReport -> IO CInt) -> IO (Result (SomeTensor, HistoricalReadExecutionReport))
readHistoricalTensorWithReport TensorFile{tensorFileNative, tensorFileHandle} nativeRead =
  withForeignPtr tensorFileHandle $ \handle ->
    alloca $ \tensorPtr ->
      alloca $ \reportPtr -> do
        poke tensorPtr emptyCArcadiaTioTensor
        poke reportPtr emptyCArcadiaTioHistoricalReadExecutionReport
        status <- nativeRead handle tensorPtr reportPtr
        if status == okStatus
          then do
            tensor <- peek tensorPtr >>= copySomeTensor
            report <- peek reportPtr >>= historicalReadExecutionReportFromC
            capiTensorFree tensorFileNative tensorPtr
            capiHistoricalReadExecutionReportFree tensorFileNative reportPtr
            pure $ (,) <$> tensor <*> report
          else do
            err <- lastError tensorFileNative
            capiTensorFree tensorFileNative tensorPtr
            capiHistoricalReadExecutionReportFree tensorFileNative reportPtr
            pure (Left err)

readHistoricalDenseWithReport :: TensorFile -> (Ptr CHandle -> Ptr CArcadiaTioTensor -> Ptr CArcadiaTioMask -> Ptr CArcadiaTioHistoricalReadExecutionReport -> IO CInt) -> IO (Result (SomeDenseRead, HistoricalReadExecutionReport))
readHistoricalDenseWithReport TensorFile{tensorFileNative, tensorFileHandle} nativeRead =
  withForeignPtr tensorFileHandle $ \handle ->
    alloca $ \tensorPtr ->
      alloca $ \maskPtr ->
        alloca $ \reportPtr -> do
          poke tensorPtr emptyCArcadiaTioTensor
          poke maskPtr emptyCArcadiaTioMask
          poke reportPtr emptyCArcadiaTioHistoricalReadExecutionReport
          status <- nativeRead handle tensorPtr maskPtr reportPtr
          if status == okStatus
            then do
              dense <- copySomeDenseReadFromPtrs tensorPtr maskPtr
              report <- peek reportPtr >>= historicalReadExecutionReportFromC
              capiTensorFree tensorFileNative tensorPtr
              capiMaskFree tensorFileNative maskPtr
              capiHistoricalReadExecutionReportFree tensorFileNative reportPtr
              pure $ (,) <$> dense <*> report
            else do
              err <- lastError tensorFileNative
              capiTensorFree tensorFileNative tensorPtr
              capiMaskFree tensorFileNative maskPtr
              capiHistoricalReadExecutionReportFree tensorFileNative reportPtr
              pure (Left err)

finishAttributedRead :: NativeLibrary -> CInt -> Ptr CArcadiaTioTensor -> Ptr CArcadiaTioReadExecutionReport -> Ptr CArcadiaTioQueryTraceJson -> (CArcadiaTioTensor -> IO (Result a)) -> IO (Result (a, ReadExecutionReport, QueryTraceJson))
finishAttributedRead native status tensorPtr reportPtr traceJsonPtr copyTensor =
  if status == okStatus
    then do
      tensor <- peek tensorPtr >>= copyTensor
      report <- peek reportPtr >>= readExecutionReportFromC
      traceJson <- peek traceJsonPtr >>= queryTraceJsonFromC
      capiTensorFree native tensorPtr
      capiReadExecutionReportFree native reportPtr
      capiQueryTraceJsonFree native traceJsonPtr
      pure $ (,,) <$> tensor <*> report <*> traceJson
    else do
      err <- lastError native
      capiTensorFree native tensorPtr
      capiReadExecutionReportFree native reportPtr
      capiQueryTraceJsonFree native traceJsonPtr
      pure (Left err)

finishAttributedDenseRead :: NativeLibrary -> CInt -> Ptr CArcadiaTioTensor -> Ptr CArcadiaTioMask -> Ptr CArcadiaTioReadExecutionReport -> Ptr CArcadiaTioQueryTraceJson -> IO (Result (SomeDenseRead, ReadExecutionReport, QueryTraceJson))
finishAttributedDenseRead native status tensorPtr maskPtr reportPtr traceJsonPtr =
  if status == okStatus
    then do
      dense <- copySomeDenseReadFromPtrs tensorPtr maskPtr
      report <- peek reportPtr >>= readExecutionReportFromC
      traceJson <- peek traceJsonPtr >>= queryTraceJsonFromC
      capiTensorFree native tensorPtr
      capiMaskFree native maskPtr
      capiReadExecutionReportFree native reportPtr
      capiQueryTraceJsonFree native traceJsonPtr
      pure $ (,,) <$> dense <*> report <*> traceJson
    else do
      err <- lastError native
      capiTensorFree native tensorPtr
      capiMaskFree native maskPtr
      capiReadExecutionReportFree native reportPtr
      capiQueryTraceJsonFree native traceJsonPtr
      pure (Left err)

readExecutionReportFromC :: CArcadiaTioReadExecutionReport -> IO (Result ReadExecutionReport)
readExecutionReportFromC CArcadiaTioReadExecutionReport{cReadReportRequestedMode, cReadReportQueryMaxThreads, cReadReportQueryEffectiveMode, cReadReportQueryEffectiveThreads, cReadReportQueryParallelRuntime, cReadReportQueryParallelFallbackReason, cReadReportQueryParallelReasonCode, cReadReportQueryParallelReasonCodeTaxonomy} = do
  requested <- pure (readExecutionModeFromRaw cReadReportRequestedMode)
  effective <- pure (readExecutionModeFromRaw cReadReportQueryEffectiveMode)
  runtime <- peekOptionalCString cReadReportQueryParallelRuntime
  fallback <- peekOptionalCString cReadReportQueryParallelFallbackReason
  reasonCode <- peekOptionalCString cReadReportQueryParallelReasonCode
  taxonomy <- peekOptionalCString cReadReportQueryParallelReasonCodeTaxonomy
  pure $ do
    req <- requested
    eff <- effective
    Right
      ReadExecutionReport
        { readReportRequestedMode = req
        , readReportQueryMaxThreads = fromIntegralCSize cReadReportQueryMaxThreads
        , readReportQueryEffectiveMode = eff
        , readReportQueryEffectiveThreads = fromIntegralCSize cReadReportQueryEffectiveThreads
        , readReportQueryParallelRuntime = runtime
        , readReportQueryParallelFallbackReason = fallback
        , readReportQueryParallelReasonCode = reasonCode
        , readReportQueryParallelReasonCodeTaxonomy = taxonomy
        }

historicalReadExecutionReportFromC :: CArcadiaTioHistoricalReadExecutionReport -> IO (Result HistoricalReadExecutionReport)
historicalReadExecutionReportFromC CArcadiaTioHistoricalReadExecutionReport{cHistoricalReadReportBase, cHistoricalReadReportQuerySourceKind, cHistoricalReadReportQueryCommitSeq} = do
  base <- readExecutionReportFromC cHistoricalReadReportBase
  pure $ do
    report <- base
    source <- historicalQuerySourceKindFromRaw cHistoricalReadReportQuerySourceKind
    Right HistoricalReadExecutionReport{historicalReadExecutionReport = report, historicalReadQuerySourceKind = source, historicalReadQueryCommitSeq = cHistoricalReadReportQueryCommitSeq}

queryTraceJsonFromC :: CArcadiaTioQueryTraceJson -> IO (Result QueryTraceJson)
queryTraceJsonFromC CArcadiaTioQueryTraceJson{cTraceJsonJson}
  | cTraceJsonJson == nullPtr = pure (Left (invalidArgument "native query trace JSON pointer is null"))
  | otherwise = Right . QueryTraceJson <$> peekCString cTraceJsonJson

readIndexReportFromC :: CArcadiaTioReadIndexReport -> IO (Result ReadIndexReport)
readIndexReportFromC CArcadiaTioReadIndexReport{cReadIndexReportLoweringKind, cReadIndexReportUsedFullTensorFallback} =
  pure $ do
    lowering <- readIndexLoweringFromRaw cReadIndexReportLoweringKind
    Right ReadIndexReport{readIndexLoweringKind = lowering, readIndexUsedFullTensorFallback = cReadIndexReportUsedFullTensorFallback /= 0}

readTensor :: TensorFile -> (Ptr CHandle -> Ptr CArcadiaTioTensor -> IO CInt) -> IO (Result SomeTensor)
readTensor TensorFile{tensorFileNative, tensorFileHandle} nativeRead =
  withForeignPtr tensorFileHandle $ \handle ->
    alloca $ \outPtr -> do
      poke outPtr emptyCArcadiaTioTensor
      status <- nativeRead handle outPtr
      if status == okStatus
        then (peek outPtr >>= copySomeTensor) `finally` capiTensorFree tensorFileNative outPtr
        else do
          err <- lastError tensorFileNative
          capiTensorFree tensorFileNative outPtr
          pure (Left err)

copySomeDenseReadFromPtrs :: Ptr CArcadiaTioTensor -> Ptr CArcadiaTioMask -> IO (Result SomeDenseRead)
copySomeDenseReadFromPtrs tensorPtr maskPtr = do
  rawTensor <- peek tensorPtr
  mask <- peek maskPtr >>= copyMask
  case mask of
    Left err -> pure (Left err)
    Right copiedMask -> do
      tensor <- copySomeTensor rawTensor
      pure $ case tensor of
        Left err -> Left err
        Right (SomeTensorF32 value) -> Right (SomeDenseReadF32 (DenseRead value copiedMask))
        Right (SomeTensorF64 value) -> Right (SomeDenseReadF64 (DenseRead value copiedMask))
        Right (SomeTensorI32 value) -> Right (SomeDenseReadI32 (DenseRead value copiedMask))
        Right (SomeTensorI64 value) -> Right (SomeDenseReadI64 (DenseRead value copiedMask))

copyMask :: CArcadiaTioMask -> IO (Result (VS.Vector Word8))
copyMask CArcadiaTioMask{cMaskData, cMaskLen} = do
  let len = fromIntegralCSize cMaskLen
  if len > 0 && cMaskData == nullPtr
    then pure (Left (invalidArgument "native mask data pointer is null"))
    else Right <$> copyVector len cMaskData

copySomeTensor :: CArcadiaTioTensor -> IO (Result SomeTensor)
copySomeTensor raw@CArcadiaTioTensor{cTensorDType} = case dtypeFromRaw cTensorDType of
  Just F32 -> fmap SomeTensorF32 <$> copyTypedTensor F32 raw
  Just F64 -> fmap SomeTensorF64 <$> copyTypedTensor F64 raw
  Just I32 -> fmap SomeTensorI32 <$> copyTypedTensor I32 raw
  Just I64 -> fmap SomeTensorI64 <$> copyTypedTensor I64 raw
  Nothing -> pure (Left (invalidArgument "native tensor has unknown dtype"))

copyTypedTensor :: Storable a => DType -> CArcadiaTioTensor -> IO (Result (Tensor a))
copyTypedTensor tensorDType CArcadiaTioTensor{cTensorData, cTensorLenBytes, cTensorRank, cTensorShape} = do
  let tensorRank = fromIntegralCSize cTensorRank
      lenBytes = fromIntegral cTensorLenBytes
      scalarBytes = dtypeSizeBytes tensorDType
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
