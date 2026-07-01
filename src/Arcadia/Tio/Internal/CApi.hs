{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE NamedFieldPuns #-}

module Arcadia.Tio.Internal.CApi
  ( expectedAbiVersion
  , NativeLibrary
  , nativeLibraryPath
  , loadNativeLibrary
  , loadNativeLibraryFrom
  , resolveNativeLibraryPath
  , abiVersion
  , lastError
  , CHandle
  , COcbFile
  , COcbReadPlan
  , CArcadiaTioCoordinateAvailabilityV2
  , CArcadiaTioCoordinateCodeDTypeV2
  , CArcadiaTioCoordinateDType
  , CArcadiaTioCoordinateEncoding
  , CArcadiaTioCoordinateFixedTextEncodingV2
  , CArcadiaTioCoordinateFixedTextPaddingV2
  , CArcadiaTioCoordinateIndexFallbackV2
  , CArcadiaTioCoordinateIndexKindV2
  , CArcadiaTioCoordinateIndexUseV2
  , CArcadiaTioCoordinateIndexValidationStatusV2
  , CArcadiaTioCoordinateKeyDomainV2
  , CArcadiaTioCoordinateKind
  , CArcadiaTioCoordinateLookupResultStatusV2
  , CArcadiaTioCoordinateMonotonicity
  , CArcadiaTioCoordinateSortedness
  , CArcadiaTioCoordinateSourceKind
  , CArcadiaTioCoordinateSourceKindV2
  , CArcadiaTioCoordinateStatusCategoryV2
  , CArcadiaTioCoordinateStorageKind
  , CArcadiaTioCoordinateUniqueness
  , CArcadiaTioCoordinateValidationStatus
  , CArcadiaTioCoordinateValueDomainV2
  , CArcadiaTioAxisIdentityMode
  , CArcadiaTioHistoricalQuerySourceKind
  , CArcadiaTioReadExecutionMode
  , CArcadiaTioReadIndexItemTag
  , CArcadiaTioReadIndexLoweringKind
  , CArcadiaTioReadShapePolicyTag
  , CArcadiaTioReformTargetLayout
  , CArcadiaTioV4CompactionAnalysisPolicy
  , CArcadiaTioV4PreciseAccountingField
  , CArcadiaTioV4ReportStatus
  , CArcadiaTioV4RetainedHistoryPolicy
  , CArcadiaTioAxisCoordinateInput(..)
  , CArcadiaTioAxisCoordinateMeta(..)
  , CArcadiaTioAxisCoordinateMetaV2(..)
  , CArcadiaTioAxisCoordinateInputV2(..)
  , CArcadiaTioCoordinateFixedTextLayoutV2(..)
  , CArcadiaTioCoordinateDictionarySummaryV2(..)
  , CArcadiaTioCoordinateExternalBindingV2(..)
  , CArcadiaTioCoordinateIndexSourceBindingV2(..)
  , CArcadiaTioCoordinateIndexSummaryV2(..)
  , CArcadiaTioCoordinateDictionaryEntryV2(..)
  , CArcadiaTioCoordinateDictionaryV2(..)
  , CArcadiaTioCoordinateValueSliceV2(..)
  , CArcadiaTioCoordinateLookupKeyV2(..)
  , CArcadiaTioCoordinateLookupResultV2(..)
  , CArcadiaTioAppendCoordinateEntryV2(..)
  , CArcadiaTioAppendCoordinateBatchV2(..)
  , CArcadiaTioCoordinateV2Options(..)
  , emptyCArcadiaTioCoordinateFixedTextLayoutV2
  , emptyCArcadiaTioCoordinateDictionarySummaryV2
  , emptyCArcadiaTioCoordinateV2Options
  , emptyCArcadiaTioCoordinateLookupKeyV2
  , emptyCArcadiaTioCoordinateLookupResultV2
  , CArcadiaTioTensor(..)
  , emptyCArcadiaTioTensor
  , CArcadiaTioMask(..)
  , emptyCArcadiaTioMask
  , CArcadiaTioDimSpec(..)
  , CArcadiaTioAxisLabel(..)
  , CArcadiaTioUserKv(..)
  , CArcadiaTioFileMeta(..)
  , emptyCArcadiaTioFileMeta
  , CArcadiaTioScalar(..)
  , CArcadiaTioCompressionConfig(..)
  , compressionConfigStructSize
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
  , CArcadiaTioChunkKey(..)
  , CArrowArray(..)
  , CArrowSchema(..)
  , emptyCArrowArray
  , emptyCArrowSchema
  , arrowArrayRelease
  , arrowSchemaRelease
  , CArcadiaTioHistoricalReadWithOptionsOptions
  , CArcadiaTioHistoricalReadWithShapePolicyOptions
  , CArcadiaTioHistoricalReadExecutionReport(..)
  , emptyCArcadiaTioReadShapePolicyOptions
  , emptyCArcadiaTioReadExecutionReport
  , emptyCArcadiaTioQueryTraceJson
  , emptyCArcadiaTioReadIndexReport
  , emptyCArcadiaTioHistoricalReadExecutionReport
  , CArcadiaTioChunkPlan(..)
  , emptyCArcadiaTioChunkPlan
  , CArcadiaTioCommitInfo(..)
  , CArcadiaTioCommitList(..)
  , emptyCArcadiaTioCommitList
  , CArcadiaTioCompactionMode(..)
  , CArcadiaTioCompactionStats(..)
  , CArcadiaTioAutoCompactionConfig(..)
  , CArcadiaTioCompactionState(..)
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
  , CArcadiaTioSparseValuePredicateV2(..)
  , CArcadiaTioSparseRuleV2(..)
  , sparseRuleV2StructSize
  , CArcadiaTioSparseAppendAnalysis(..)
  , emptyCArcadiaTioSparseAppendAnalysis
  , CArcadiaTioOcbOpenOptions(..)
  , CArcadiaTioOcbColumnDescriptor(..)
  , CArcadiaTioOcbDictionaryDescriptor(..)
  , CArcadiaTioOcbOrderingKey(..)
  , CArcadiaTioOcbMetadata(..)
  , CArcadiaTioOcbByteSlice(..)
  , CArcadiaTioOcbDictionaryValues(..)
  , CArcadiaTioOcbPrimitiveValues(..)
  , CArcadiaTioOcbValidityBitmap(..)
  , CArcadiaTioOcbWriteOptions(..)
  , CArcadiaTioOcbWriteColumn(..)
  , CArcadiaTioOcbDictionaryEntry(..)
  , CArcadiaTioOcbWriteDictionary(..)
  , CArcadiaTioOcbWriteColumnChunk(..)
  , CArcadiaTioOcbWriteRowGroup(..)
  , CArcadiaTioOcbWriteOrderingKey(..)
  , CArcadiaTioOcbWriteSpec(..)
  , CArcadiaTioOcbCleanupResult(..)
  , CArcadiaTioOcbPredicateValue(..)
  , CArcadiaTioOcbRowGroupPredicate(..)
  , CArcadiaTioOcbReadRequest(..)
  , CArcadiaTioOcbReadReport(..)
  , CArcadiaTioOcbReadAttribution(..)
  , CArcadiaTioOcbColumnArray(..)
  , CArcadiaTioOcbColumnBatch(..)
  , CArcadiaTioOcbReadOutcome(..)
  , CArcadiaTioOcbReadCursorOptions(..)
  , CArcadiaTioOcbReadCursorReport(..)
  , CArcadiaTioOcbColumnFillBuffer(..)
  , CArcadiaTioOcbRowGroupFillRequest(..)
  , CArcadiaTioOcbReadFillReport(..)
  , CArcadiaTioOcbBodyRefSummary(..)
  , CArcadiaTioOcbColumnChunkSummary(..)
  , CArcadiaTioOcbColumnStatsSummary(..)
  , CArcadiaTioOcbRowGroupSummary(..)
  , CArcadiaTioOcbRowGroupSummaries(..)
  , emptyCArcadiaTioOcbOpenOptions
  , emptyCArcadiaTioOcbMetadata
  , emptyCArcadiaTioOcbDictionaryValues
  , emptyCArcadiaTioOcbPrimitiveValues
  , emptyCArcadiaTioOcbValidityBitmap
  , emptyCArcadiaTioOcbWriteOptions
  , emptyCArcadiaTioOcbWriteColumn
  , emptyCArcadiaTioOcbDictionaryEntry
  , emptyCArcadiaTioOcbWriteDictionary
  , emptyCArcadiaTioOcbWriteColumnChunk
  , emptyCArcadiaTioOcbWriteRowGroup
  , emptyCArcadiaTioOcbWriteOrderingKey
  , emptyCArcadiaTioOcbWriteSpec
  , emptyCArcadiaTioOcbCleanupResult
  , emptyCArcadiaTioOcbPredicateValue
  , emptyCArcadiaTioOcbRowGroupPredicate
  , emptyCArcadiaTioOcbReadRequest
  , emptyCArcadiaTioOcbReadReport
  , emptyCArcadiaTioOcbReadAttribution
  , emptyCArcadiaTioOcbReadOutcome
  , emptyCArcadiaTioOcbReadCursorOptions
  , emptyCArcadiaTioOcbReadCursorReport
  , emptyCArcadiaTioOcbColumnFillBuffer
  , emptyCArcadiaTioOcbRowGroupFillRequest
  , emptyCArcadiaTioOcbReadFillReport
  , emptyCArcadiaTioOcbRowGroupSummaries
  , capiCreateStreaming
  , capiCreateStreamingEx
  , capiCreateRandomAccess
  , capiCreateRandomAccessEx
  , capiCreateRandomAccessWithUniverse
  , capiCreateStreamingWithUniverse
  , capiCreateWithPolicyWithUniverse
  , capiCreateInferred
  , capiCreateInferredEx
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
  , capiOpen
  , capiClose
  , capiAppendF32WithRange
  , capiAppendF64WithRange
  , capiAppendI32WithRange
  , capiAppendI64WithRange
  , capiReadAll
  , capiReadAllDense
  , capiReadAxisRange
  , capiReadAxisTake
  , capiReadAxisOne
  , capiReadEntryRange
  , capiTakeEntries
  , capiTensorToContiguous
  , capiTensorReshape
  , capiTensorFlatten
  , capiTensorExpandDims
  , capiTensorSqueeze
  , capiTensorSqueezeAxis
  , capiTensorPermuteAxes
  , capiTensorTranspose
  , capiTensorSliceAxis
  , capiTensorSliceAxisStep
  , capiTensorTakeAxis
  , capiTensorIndexAxis
  , capiTensorAdd
  , capiTensorSub
  , capiTensorMul
  , capiTensorDiv
  , capiTensorAddScalar
  , capiTensorSubScalar
  , capiTensorMulScalar
  , capiTensorDivScalar
  , capiRank
  , capiDType
  , capiAppendAxis
  , capiDimLens
  , capiChunkPlan
  , capiPath
  , capiStringFree
  , capiChunkPlanFree
  , capiLoadMeta
  , capiSetDimName
  , capiSetSymbols
  , capiSetChannels
  , capiSetUserKv
  , capiReadScalar
  , capiSetCompressionConfig
  , capiGetCompressionConfig
  , capiHeadCommit
  , capiListCommits
  , capiCommitListFree
  , capiPop
  , capiPopBatched
  , capiRevertCommit
  , capiReadAtCommit
  , capiReadAtCommitDense
  , capiReadExecutionReportFree
  , capiQueryTraceJsonFree
  , capiHistoricalReadExecutionReportFree
  , capiReadIndexReportFree
  , capiReadIndex
  , capiReadWithOptions
  , capiReadWithOptionsDense
  , capiReadWithShapePolicy
  , capiReadWithShapePolicyDense
  , capiReadWithOptionsAttributed
  , capiReadWithOptionsDenseAttributed
  , capiReadAtCommitWithOptions
  , capiReadAtCommitWithOptionsDense
  , capiReadAtCommitWithShapePolicy
  , capiReadAtCommitWithShapePolicyDense
  , capiGetIndexCheckpointEveryCommits
  , capiSetIndexCheckpointEveryCommits
  , capiRewriteF32
  , capiRewriteF64
  , capiRewriteSliceF32
  , capiRewriteSliceF64
  , capiClearBlocks
  , capiReadValuesArrow
  , capiAnalyzeCompaction
  , capiCompactTo
  , capiMaybeCompact
  , capiGetAutoCompactionConfig
  , capiSetAutoCompactionConfig
  , capiCompactionState
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
  , capiAnalyzeSparseAppendF32V2
  , capiAnalyzeSparseAppendF64V2
  , capiAnalyzeSparseAppendI32V2
  , capiAnalyzeSparseAppendI64V2
  , capiAppendSparseF32WithRangeV2
  , capiAppendSparseF64WithRangeV2
  , capiAppendSparseI32WithRangeV2
  , capiAppendSparseI64WithRangeV2
  , capiSparseAppendAnalysisFree
  , capiOcbLastErrorKind
  , capiOcbLastErrorCause
  , capiOcbOpen
  , capiOcbOpenWithOptions
  , capiOcbReaderClone
  , capiOcbClose
  , capiOcbMetadata
  , capiOcbMetadataFree
  , capiOcbDictionaryValues
  , capiOcbDictionaryValuesFree
  , capiOcbOpenOptionsInit
  , capiOcbPrimitiveValuesInit
  , capiOcbValidityBitmapInit
  , capiOcbWriteOptionsInit
  , capiOcbWriteColumnInit
  , capiOcbDictionaryEntryInit
  , capiOcbWriteDictionaryInit
  , capiOcbWriteColumnChunkInit
  , capiOcbWriteRowGroupInit
  , capiOcbWriteOrderingKeyInit
  , capiOcbWriteSpecInit
  , capiOcbCleanupResultInit
  , capiOcbWriteColumnSetFixedBinaryWidth
  , capiOcbWriteColumnFixedBinaryWidth
  , capiOcbCreate
  , capiOcbCreateWithOptions
  , capiOcbAppend
  , capiOcbAppendWithOptions
  , capiOcbCleanupOrphanTail
  , capiOcbReadRequestInit
  , capiOcbReadReportInit
  , capiOcbPredicateValueInit
  , capiOcbRowGroupPredicateInit
  , capiOcbReadAttributionInit
  , OcbBatchVisitorFn
  , mkOcbBatchVisitorCallback
  , capiOcbReadOutcomeInit
  , capiOcbReadCursorOptionsInit
  , capiOcbReadCursorReportInit
  , capiOcbReadCursorReportFree
  , capiOcbVisitBatches
  , capiOcbColumnFillBufferInit
  , capiOcbColumnFillBufferSetFixedBinaryWidth
  , capiOcbColumnFillBufferFixedBinaryWidth
  , capiOcbRowGroupFillRequestInit
  , capiOcbReadFillReportInit
  , capiOcbReadRowGroupInto
  , capiOcbReadBatches
  , capiOcbReadBatchesWithAttribution
  , capiOcbReadReportFree
  , capiOcbReadAttributionFree
  , capiOcbReadOutcomeFree
  , capiOcbColumnDescriptorFixedBinaryWidth
  , capiOcbColumnArrayFixedBinaryWidth
  , capiOcbPlanRead
  , capiOcbReadPlanReport
  , capiOcbReadPlanProjectedColumnIds
  , capiOcbReadPlanRowGroupIds
  , capiOcbReadBatchesFromPlan
  , capiOcbReadPlanFree
  , capiOcbRowGroupSummariesInit
  , capiOcbRowGroupSummaries
  , capiOcbReadPlanRowGroupSummaries
  , capiOcbRowGroupSummariesFree
  , capiTensorFree
  , capiMaskFree
  , capiFileMetaFree
  , okStatus
  ) where

import Control.Exception (SomeException, displayException, try)
import Data.Int (Int32, Int64)
import Data.Word (Word8, Word16, Word32, Word64)
import Foreign.C.String (CString, peekCString)
import Foreign.C.Types (CFloat, CInt(..), CSize(..))
import Foreign.Ptr (FunPtr, Ptr, nullFunPtr, nullPtr, plusPtr)
import Foreign.Marshal.Array (pokeArray)
import Foreign.Marshal.Utils (fillBytes)
import Foreign.Storable (Storable(..))
import System.Environment (lookupEnv)
import System.FilePath ((</>))
import System.Posix.DynamicLinker (DL, RTLDFlags(..), dlopen, dlsym)

import Arcadia.Tio.Error
  ( TioError(..)
  , libraryLoadError
  , nativeErrorCodeFromInt
  )

-- | C ABI version expected by this wrapper.
expectedAbiVersion :: Word32
expectedAbiVersion = 3

-- | Raw OK status used by the C ABI.
okStatus :: CInt
okStatus = 0

-- | Opaque C TensorFile handle.
data CHandle

-- | Opaque C OCB selected-snapshot handle.
data COcbFile

-- | Opaque C OCB read plan handle.
data COcbReadPlan

-- | Raw enum typedef aliases for exact coordinate C ABI discriminants.
type CArcadiaTioCoordinateAvailabilityV2 = CInt
type CArcadiaTioCoordinateCodeDTypeV2 = CInt
type CArcadiaTioCoordinateDType = CInt
type CArcadiaTioCoordinateEncoding = CInt
type CArcadiaTioCoordinateFixedTextEncodingV2 = CInt
type CArcadiaTioCoordinateFixedTextPaddingV2 = CInt
type CArcadiaTioCoordinateIndexFallbackV2 = CInt
type CArcadiaTioCoordinateIndexKindV2 = CInt
type CArcadiaTioCoordinateIndexUseV2 = CInt
type CArcadiaTioCoordinateIndexValidationStatusV2 = CInt
type CArcadiaTioCoordinateKeyDomainV2 = CInt
type CArcadiaTioCoordinateKind = CInt
type CArcadiaTioCoordinateLookupResultStatusV2 = CInt
type CArcadiaTioCoordinateMonotonicity = CInt
type CArcadiaTioCoordinateSortedness = CInt
type CArcadiaTioCoordinateSourceKind = CInt
type CArcadiaTioCoordinateSourceKindV2 = CInt
type CArcadiaTioCoordinateStatusCategoryV2 = CInt
type CArcadiaTioCoordinateStorageKind = CInt
type CArcadiaTioCoordinateUniqueness = CInt
type CArcadiaTioCoordinateValidationStatus = CInt
type CArcadiaTioCoordinateValueDomainV2 = CInt

-- | Raw enum typedef aliases for exact non-OCB policy/report C ABI discriminants.
type CArcadiaTioAxisIdentityMode = CInt
type CArcadiaTioHistoricalQuerySourceKind = CInt
type CArcadiaTioReadExecutionMode = CInt
type CArcadiaTioReadIndexItemTag = CInt
type CArcadiaTioReadIndexLoweringKind = CInt
type CArcadiaTioReadShapePolicyTag = CInt
type CArcadiaTioReformTargetLayout = CInt
type CArcadiaTioV4CompactionAnalysisPolicy = CInt
type CArcadiaTioV4PreciseAccountingField = CInt
type CArcadiaTioV4ReportStatus = CInt
type CArcadiaTioV4RetainedHistoryPolicy = CInt

-- | Raw Coordinate v1 create input.
data CArcadiaTioAxisCoordinateInput = CArcadiaTioAxisCoordinateInput
  { cAxisCoordinateInputVersion :: Word32
  , cAxisCoordinateInputAxis :: CSize
  , cAxisCoordinateInputName :: CString
  , cAxisCoordinateInputKind :: CInt
  , cAxisCoordinateInputDType :: CInt
  , cAxisCoordinateInputEncoding :: CInt
  , cAxisCoordinateInputValues :: Ptr Word8
  , cAxisCoordinateInputValuesLen :: CSize
  , cAxisCoordinateInputSorted :: CInt
  , cAxisCoordinateInputMonotonicity :: CInt
  , cAxisCoordinateInputUniqueness :: CInt
  , cAxisCoordinateInputStorageKind :: CInt
  , cAxisCoordinateInputExternalSourceKind :: CInt
  , cAxisCoordinateInputExternalUri :: CString
  , cAxisCoordinateInputExternalDType :: CInt
  , cAxisCoordinateInputExternalLength :: Word64
  , cAxisCoordinateInputRequired :: Word8
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioAxisCoordinateInput where
  sizeOf _ = 120
  alignment _ = alignment (undefined :: Ptr ())
  peek ptr = CArcadiaTioAxisCoordinateInput <$> peekByteOff ptr 0 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 36 <*> peekByteOff ptr 40 <*> peekByteOff ptr 48 <*> peekByteOff ptr 56 <*> peekByteOff ptr 64 <*> peekByteOff ptr 68 <*> peekByteOff ptr 72 <*> peekByteOff ptr 76 <*> peekByteOff ptr 80 <*> peekByteOff ptr 88 <*> peekByteOff ptr 96 <*> peekByteOff ptr 104 <*> peekByteOff ptr 112
  poke ptr v = do
    fillBytes ptr 0 (sizeOf v)
    pokeByteOff ptr 0 (cAxisCoordinateInputVersion v)
    pokeByteOff ptr 8 (120 :: CSize)
    pokeByteOff ptr 16 (cAxisCoordinateInputAxis v)
    pokeByteOff ptr 24 (cAxisCoordinateInputName v)
    pokeByteOff ptr 32 (cAxisCoordinateInputKind v)
    pokeByteOff ptr 36 (cAxisCoordinateInputDType v)
    pokeByteOff ptr 40 (cAxisCoordinateInputEncoding v)
    pokeByteOff ptr 48 (cAxisCoordinateInputValues v)
    pokeByteOff ptr 56 (cAxisCoordinateInputValuesLen v)
    pokeByteOff ptr 64 (cAxisCoordinateInputSorted v)
    pokeByteOff ptr 68 (cAxisCoordinateInputMonotonicity v)
    pokeByteOff ptr 72 (cAxisCoordinateInputUniqueness v)
    pokeByteOff ptr 76 (cAxisCoordinateInputStorageKind v)
    pokeByteOff ptr 80 (cAxisCoordinateInputExternalSourceKind v)
    pokeByteOff ptr 88 (cAxisCoordinateInputExternalUri v)
    pokeByteOff ptr 96 (cAxisCoordinateInputExternalDType v)
    pokeByteOff ptr 104 (cAxisCoordinateInputExternalLength v)
    pokeByteOff ptr 112 (cAxisCoordinateInputRequired v)

-- | Raw Coordinate v1 metadata item returned by the C ABI.
data CArcadiaTioAxisCoordinateMeta = CArcadiaTioAxisCoordinateMeta
  { cAxisCoordinateMetaVersion :: Word32
  , cAxisCoordinateMetaAxis :: CSize
  , cAxisCoordinateMetaAxisNameSnapshot :: CString
  , cAxisCoordinateMetaName :: CString
  , cAxisCoordinateMetaKind :: CInt
  , cAxisCoordinateMetaDType :: CInt
  , cAxisCoordinateMetaEncoding :: CInt
  , cAxisCoordinateMetaLength :: Word64
  , cAxisCoordinateMetaSorted :: CInt
  , cAxisCoordinateMetaMonotonicity :: CInt
  , cAxisCoordinateMetaUniqueness :: CInt
  , cAxisCoordinateMetaStorageKind :: CInt
  , cAxisCoordinateMetaExternalSourceKind :: CInt
  , cAxisCoordinateMetaExternalUri :: CString
  , cAxisCoordinateMetaRequired :: Word8
  , cAxisCoordinateMetaValidationStatus :: CInt
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioAxisCoordinateMeta where
  sizeOf _ = 104
  alignment _ = alignment (undefined :: Ptr ())
  peek ptr =
    CArcadiaTioAxisCoordinateMeta
      <$> peekByteOff ptr 0
      <*> peekByteOff ptr 16
      <*> peekByteOff ptr 24
      <*> peekByteOff ptr 32
      <*> peekByteOff ptr 40
      <*> peekByteOff ptr 44
      <*> peekByteOff ptr 48
      <*> peekByteOff ptr 56
      <*> peekByteOff ptr 64
      <*> peekByteOff ptr 68
      <*> peekByteOff ptr 72
      <*> peekByteOff ptr 76
      <*> peekByteOff ptr 80
      <*> peekByteOff ptr 88
      <*> peekByteOff ptr 96
      <*> peekByteOff ptr 100
  poke ptr v = do
    fillBytes ptr 0 (sizeOf v)
    pokeByteOff ptr 0 (cAxisCoordinateMetaVersion v)
    pokeByteOff ptr 16 (cAxisCoordinateMetaAxis v)
    pokeByteOff ptr 24 (cAxisCoordinateMetaAxisNameSnapshot v)
    pokeByteOff ptr 32 (cAxisCoordinateMetaName v)
    pokeByteOff ptr 40 (cAxisCoordinateMetaKind v)
    pokeByteOff ptr 44 (cAxisCoordinateMetaDType v)
    pokeByteOff ptr 48 (cAxisCoordinateMetaEncoding v)
    pokeByteOff ptr 56 (cAxisCoordinateMetaLength v)
    pokeByteOff ptr 64 (cAxisCoordinateMetaSorted v)
    pokeByteOff ptr 68 (cAxisCoordinateMetaMonotonicity v)
    pokeByteOff ptr 72 (cAxisCoordinateMetaUniqueness v)
    pokeByteOff ptr 76 (cAxisCoordinateMetaStorageKind v)
    pokeByteOff ptr 80 (cAxisCoordinateMetaExternalSourceKind v)
    pokeByteOff ptr 88 (cAxisCoordinateMetaExternalUri v)
    pokeByteOff ptr 96 (cAxisCoordinateMetaRequired v)
    pokeByteOff ptr 100 (cAxisCoordinateMetaValidationStatus v)

-- | Raw Coordinate v2 fixed-text layout.
data CArcadiaTioCoordinateFixedTextLayoutV2 = CArcadiaTioCoordinateFixedTextLayoutV2
  { cCoordinateFixedTextVersion :: Word32
  , cCoordinateFixedTextStructSize :: CSize
  , cCoordinateFixedTextWidth :: CSize
  , cCoordinateFixedTextEncoding :: CInt
  , cCoordinateFixedTextPadding :: CInt
  , cCoordinateFixedTextRejectOverWidth :: Word8
  , cCoordinateFixedTextRejectNonAscii :: Word8
  }
  deriving (Eq, Show)

emptyCArcadiaTioCoordinateFixedTextLayoutV2 :: CArcadiaTioCoordinateFixedTextLayoutV2
emptyCArcadiaTioCoordinateFixedTextLayoutV2 = CArcadiaTioCoordinateFixedTextLayoutV2 1 56 0 0 0 0 0

instance Storable CArcadiaTioCoordinateFixedTextLayoutV2 where
  sizeOf _ = 56
  alignment _ = alignment (undefined :: Ptr ())
  peek ptr = CArcadiaTioCoordinateFixedTextLayoutV2 <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 28 <*> peekByteOff ptr 32 <*> peekByteOff ptr 33
  poke ptr v = do
    fillBytes ptr 0 (sizeOf v)
    pokeByteOff ptr 0 (cCoordinateFixedTextVersion v)
    pokeByteOff ptr 8 (cCoordinateFixedTextStructSize v)
    pokeByteOff ptr 16 (cCoordinateFixedTextWidth v)
    pokeByteOff ptr 24 (cCoordinateFixedTextEncoding v)
    pokeByteOff ptr 28 (cCoordinateFixedTextPadding v)
    pokeByteOff ptr 32 (cCoordinateFixedTextRejectOverWidth v)
    pokeByteOff ptr 33 (cCoordinateFixedTextRejectNonAscii v)

data CArcadiaTioCoordinateDictionarySummaryV2 = CArcadiaTioCoordinateDictionarySummaryV2
  { cCoordinateDictionarySummaryVersion :: Word32
  , cCoordinateDictionarySummaryStructSize :: CSize
  , cCoordinateDictionarySummaryDictionaryId :: CString
  , cCoordinateDictionarySummaryRevision :: Word64
  , cCoordinateDictionarySummaryCodeDType :: CInt
  , cCoordinateDictionarySummaryEntryCount :: Word64
  , cCoordinateDictionarySummaryStableIdsUnique :: Word8
  , cCoordinateDictionarySummaryDisplayLabelsUnique :: Word8
  , cCoordinateDictionarySummaryAliasesUnique :: Word8
  , cCoordinateDictionarySummaryCodesStableAcrossRevisions :: Word8
  , cCoordinateDictionarySummaryContentId :: CString
  }
  deriving (Eq, Show)

emptyCArcadiaTioCoordinateDictionarySummaryV2 :: CArcadiaTioCoordinateDictionarySummaryV2
emptyCArcadiaTioCoordinateDictionarySummaryV2 = CArcadiaTioCoordinateDictionarySummaryV2 1 80 nullPtr 0 0 0 0 0 0 0 nullPtr

instance Storable CArcadiaTioCoordinateDictionarySummaryV2 where
  sizeOf _ = 80
  alignment _ = alignment (undefined :: Ptr ())
  peek ptr = CArcadiaTioCoordinateDictionarySummaryV2 <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 40 <*> peekByteOff ptr 48 <*> peekByteOff ptr 49 <*> peekByteOff ptr 50 <*> peekByteOff ptr 51 <*> peekByteOff ptr 56
  poke ptr v = do
    fillBytes ptr 0 (sizeOf v)
    pokeByteOff ptr 0 (cCoordinateDictionarySummaryVersion v)
    pokeByteOff ptr 8 (cCoordinateDictionarySummaryStructSize v)
    pokeByteOff ptr 16 (cCoordinateDictionarySummaryDictionaryId v)
    pokeByteOff ptr 24 (cCoordinateDictionarySummaryRevision v)
    pokeByteOff ptr 32 (cCoordinateDictionarySummaryCodeDType v)
    pokeByteOff ptr 40 (cCoordinateDictionarySummaryEntryCount v)
    pokeByteOff ptr 48 (cCoordinateDictionarySummaryStableIdsUnique v)
    pokeByteOff ptr 49 (cCoordinateDictionarySummaryDisplayLabelsUnique v)
    pokeByteOff ptr 50 (cCoordinateDictionarySummaryAliasesUnique v)
    pokeByteOff ptr 51 (cCoordinateDictionarySummaryCodesStableAcrossRevisions v)
    pokeByteOff ptr 56 (cCoordinateDictionarySummaryContentId v)

data CArcadiaTioCoordinateExternalBindingV2 = CArcadiaTioCoordinateExternalBindingV2
  { cCoordinateExternalBindingVersion :: Word32
  , cCoordinateExternalBindingStructSize :: CSize
  , cCoordinateExternalBindingSourceKind :: CInt
  , cCoordinateExternalBindingLogicalId :: CString
  , cCoordinateExternalBindingPrivacySafeDisplay :: CString
  , cCoordinateExternalBindingContentId :: CString
  , cCoordinateExternalBindingValueDomain :: CInt
  , cCoordinateExternalBindingLength :: Word64
  , cCoordinateExternalBindingAvailability :: CInt
  , cCoordinateExternalBindingStatusCategory :: CInt
  , cCoordinateExternalBindingRequired :: Word8
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioCoordinateExternalBindingV2 where
  sizeOf _ = 96
  alignment _ = alignment (undefined :: Ptr ())
  peek ptr = CArcadiaTioCoordinateExternalBindingV2 <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 40 <*> peekByteOff ptr 48 <*> peekByteOff ptr 56 <*> peekByteOff ptr 64 <*> peekByteOff ptr 68 <*> peekByteOff ptr 72
  poke ptr v = do
    fillBytes ptr 0 (sizeOf v)
    pokeByteOff ptr 0 (cCoordinateExternalBindingVersion v)
    pokeByteOff ptr 8 (cCoordinateExternalBindingStructSize v)
    pokeByteOff ptr 16 (cCoordinateExternalBindingSourceKind v)
    pokeByteOff ptr 24 (cCoordinateExternalBindingLogicalId v)
    pokeByteOff ptr 32 (cCoordinateExternalBindingPrivacySafeDisplay v)
    pokeByteOff ptr 40 (cCoordinateExternalBindingContentId v)
    pokeByteOff ptr 48 (cCoordinateExternalBindingValueDomain v)
    pokeByteOff ptr 56 (cCoordinateExternalBindingLength v)
    pokeByteOff ptr 64 (cCoordinateExternalBindingAvailability v)
    pokeByteOff ptr 68 (cCoordinateExternalBindingStatusCategory v)
    pokeByteOff ptr 72 (cCoordinateExternalBindingRequired v)

data CArcadiaTioCoordinateIndexSourceBindingV2 = CArcadiaTioCoordinateIndexSourceBindingV2
  { cCoordinateIndexSourceVersion :: Word32
  , cCoordinateIndexSourceStructSize :: CSize
  , cCoordinateIndexSourceDescriptorId :: CString
  , cCoordinateIndexSourceDescriptorRevision :: Word64
  , cCoordinateIndexSourceValueDomain :: CInt
  , cCoordinateIndexSourceValueObjectId :: CString
  , cCoordinateIndexSourceDictionaryId :: CString
  , cCoordinateIndexSourceDictionaryRevision :: Word64
  , cCoordinateIndexSourceDictionaryContentId :: CString
  , cCoordinateIndexSourceExternalSourceKind :: CInt
  , cCoordinateIndexSourceExternalLogicalId :: CString
  , cCoordinateIndexSourceExternalContentId :: CString
  , cCoordinateIndexSourceRootId :: CString
  , cCoordinateIndexSourceAxis :: CSize
  , cCoordinateIndexSourceRootExtent :: Word64
  , cCoordinateIndexSourceAppendStart :: Word64
  , cCoordinateIndexSourceAppendCount :: Word64
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioCoordinateIndexSourceBindingV2 where
  sizeOf _ = 168
  alignment _ = alignment (undefined :: Ptr ())
  peek ptr = CArcadiaTioCoordinateIndexSourceBindingV2 <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 40 <*> peekByteOff ptr 48 <*> peekByteOff ptr 56 <*> peekByteOff ptr 64 <*> peekByteOff ptr 72 <*> peekByteOff ptr 80 <*> peekByteOff ptr 88 <*> peekByteOff ptr 96 <*> peekByteOff ptr 104 <*> peekByteOff ptr 112 <*> peekByteOff ptr 120 <*> peekByteOff ptr 128
  poke ptr v = do
    fillBytes ptr 0 (sizeOf v)
    pokeByteOff ptr 0 (cCoordinateIndexSourceVersion v)
    pokeByteOff ptr 8 (cCoordinateIndexSourceStructSize v)
    pokeByteOff ptr 16 (cCoordinateIndexSourceDescriptorId v)
    pokeByteOff ptr 24 (cCoordinateIndexSourceDescriptorRevision v)
    pokeByteOff ptr 32 (cCoordinateIndexSourceValueDomain v)
    pokeByteOff ptr 40 (cCoordinateIndexSourceValueObjectId v)
    pokeByteOff ptr 48 (cCoordinateIndexSourceDictionaryId v)
    pokeByteOff ptr 56 (cCoordinateIndexSourceDictionaryRevision v)
    pokeByteOff ptr 64 (cCoordinateIndexSourceDictionaryContentId v)
    pokeByteOff ptr 72 (cCoordinateIndexSourceExternalSourceKind v)
    pokeByteOff ptr 80 (cCoordinateIndexSourceExternalLogicalId v)
    pokeByteOff ptr 88 (cCoordinateIndexSourceExternalContentId v)
    pokeByteOff ptr 96 (cCoordinateIndexSourceRootId v)
    pokeByteOff ptr 104 (cCoordinateIndexSourceAxis v)
    pokeByteOff ptr 112 (cCoordinateIndexSourceRootExtent v)
    pokeByteOff ptr 120 (cCoordinateIndexSourceAppendStart v)
    pokeByteOff ptr 128 (cCoordinateIndexSourceAppendCount v)

data CArcadiaTioCoordinateIndexSummaryV2 = CArcadiaTioCoordinateIndexSummaryV2
  { cCoordinateIndexSummaryVersion :: Word32
  , cCoordinateIndexSummaryStructSize :: CSize
  , cCoordinateIndexSummaryIndexId :: CString
  , cCoordinateIndexSummaryIndexKind :: CInt
  , cCoordinateIndexSummaryKeyDomain :: CInt
  , cCoordinateIndexSummarySourceBinding :: CArcadiaTioCoordinateIndexSourceBindingV2
  , cCoordinateIndexSummarySorted :: CInt
  , cCoordinateIndexSummaryMonotonicity :: CInt
  , cCoordinateIndexSummaryUniqueness :: CInt
  , cCoordinateIndexSummaryFormatVersion :: Word32
  , cCoordinateIndexSummaryBuildVersion :: Word32
  , cCoordinateIndexSummaryValidationStatus :: CInt
  , cCoordinateIndexSummaryFallback :: CInt
  , cCoordinateIndexSummarySelectedUse :: CInt
  , cCoordinateIndexSummaryRequired :: Word8
  , cCoordinateIndexSummaryReason :: CString
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioCoordinateIndexSummaryV2 where
  sizeOf _ = 264
  alignment _ = alignment (undefined :: Ptr ())
  peek ptr = CArcadiaTioCoordinateIndexSummaryV2 <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 28 <*> peekByteOff ptr 32 <*> peekByteOff ptr 200 <*> peekByteOff ptr 204 <*> peekByteOff ptr 208 <*> peekByteOff ptr 212 <*> peekByteOff ptr 216 <*> peekByteOff ptr 220 <*> peekByteOff ptr 224 <*> peekByteOff ptr 228 <*> peekByteOff ptr 232 <*> peekByteOff ptr 240
  poke ptr v = do
    fillBytes ptr 0 (sizeOf v)
    pokeByteOff ptr 0 (cCoordinateIndexSummaryVersion v)
    pokeByteOff ptr 8 (cCoordinateIndexSummaryStructSize v)
    pokeByteOff ptr 16 (cCoordinateIndexSummaryIndexId v)
    pokeByteOff ptr 24 (cCoordinateIndexSummaryIndexKind v)
    pokeByteOff ptr 28 (cCoordinateIndexSummaryKeyDomain v)
    pokeByteOff ptr 32 (cCoordinateIndexSummarySourceBinding v)
    pokeByteOff ptr 200 (cCoordinateIndexSummarySorted v)
    pokeByteOff ptr 204 (cCoordinateIndexSummaryMonotonicity v)
    pokeByteOff ptr 208 (cCoordinateIndexSummaryUniqueness v)
    pokeByteOff ptr 212 (cCoordinateIndexSummaryFormatVersion v)
    pokeByteOff ptr 216 (cCoordinateIndexSummaryBuildVersion v)
    pokeByteOff ptr 220 (cCoordinateIndexSummaryValidationStatus v)
    pokeByteOff ptr 224 (cCoordinateIndexSummaryFallback v)
    pokeByteOff ptr 228 (cCoordinateIndexSummarySelectedUse v)
    pokeByteOff ptr 232 (cCoordinateIndexSummaryRequired v)
    pokeByteOff ptr 240 (cCoordinateIndexSummaryReason v)

data CArcadiaTioCoordinateDictionaryEntryV2 = CArcadiaTioCoordinateDictionaryEntryV2
  { cCoordinateDictionaryEntryVersion :: Word32
  , cCoordinateDictionaryEntryStructSize :: CSize
  , cCoordinateDictionaryEntryCode :: Word64
  , cCoordinateDictionaryEntryStableId :: CString
  , cCoordinateDictionaryEntryDisplayLabel :: CString
  , cCoordinateDictionaryEntryAliases :: Ptr CString
  , cCoordinateDictionaryEntryAliasesLen :: CSize
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioCoordinateDictionaryEntryV2 where
  sizeOf _ = 72
  alignment _ = alignment (undefined :: Ptr ())
  peek ptr = CArcadiaTioCoordinateDictionaryEntryV2 <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 40 <*> peekByteOff ptr 48
  poke ptr v = do
    fillBytes ptr 0 (sizeOf v)
    pokeByteOff ptr 0 (cCoordinateDictionaryEntryVersion v)
    pokeByteOff ptr 8 (cCoordinateDictionaryEntryStructSize v)
    pokeByteOff ptr 16 (cCoordinateDictionaryEntryCode v)
    pokeByteOff ptr 24 (cCoordinateDictionaryEntryStableId v)
    pokeByteOff ptr 32 (cCoordinateDictionaryEntryDisplayLabel v)
    pokeByteOff ptr 40 (cCoordinateDictionaryEntryAliases v)
    pokeByteOff ptr 48 (cCoordinateDictionaryEntryAliasesLen v)

data CArcadiaTioCoordinateDictionaryV2 = CArcadiaTioCoordinateDictionaryV2
  { cCoordinateDictionaryVersion :: Word32
  , cCoordinateDictionaryStructSize :: CSize
  , cCoordinateDictionarySummary :: CArcadiaTioCoordinateDictionarySummaryV2
  , cCoordinateDictionaryEntries :: Ptr CArcadiaTioCoordinateDictionaryEntryV2
  , cCoordinateDictionaryEntriesLen :: CSize
  , cCoordinateDictionaryStatusCategory :: CInt
  , cCoordinateDictionaryReason :: CString
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioCoordinateDictionaryV2 where
  sizeOf _ = 160
  alignment _ = alignment (undefined :: Ptr ())
  peek ptr = CArcadiaTioCoordinateDictionaryV2 <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 96 <*> peekByteOff ptr 104 <*> peekByteOff ptr 112 <*> peekByteOff ptr 120
  poke ptr v = do
    fillBytes ptr 0 (sizeOf v)
    pokeByteOff ptr 0 (cCoordinateDictionaryVersion v)
    pokeByteOff ptr 8 (cCoordinateDictionaryStructSize v)
    pokeByteOff ptr 16 (cCoordinateDictionarySummary v)
    pokeByteOff ptr 96 (cCoordinateDictionaryEntries v)
    pokeByteOff ptr 104 (cCoordinateDictionaryEntriesLen v)
    pokeByteOff ptr 112 (cCoordinateDictionaryStatusCategory v)
    pokeByteOff ptr 120 (cCoordinateDictionaryReason v)

data CArcadiaTioCoordinateValueSliceV2 = CArcadiaTioCoordinateValueSliceV2
  { cCoordinateValueSliceVersion :: Word32
  , cCoordinateValueSliceStructSize :: CSize
  , cCoordinateValueSliceValueDomain :: CInt
  , cCoordinateValueSliceNumericDType :: CInt
  , cCoordinateValueSliceNumericEncoding :: CInt
  , cCoordinateValueSliceCodeDType :: CInt
  , cCoordinateValueSliceData :: Ptr Word8
  , cCoordinateValueSliceLen :: CSize
  , cCoordinateValueSliceElementSize :: CSize
  , cCoordinateValueSliceFixedTextWidth :: CSize
  , cCoordinateValueSliceAvailability :: CInt
  , cCoordinateValueSliceStatusCategory :: CInt
  , cCoordinateValueSliceReason :: CString
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioCoordinateValueSliceV2 where
  sizeOf _ = 112
  alignment _ = alignment (undefined :: Ptr ())
  peek ptr = CArcadiaTioCoordinateValueSliceV2 <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 20 <*> peekByteOff ptr 24 <*> peekByteOff ptr 28 <*> peekByteOff ptr 32 <*> peekByteOff ptr 40 <*> peekByteOff ptr 48 <*> peekByteOff ptr 56 <*> peekByteOff ptr 64 <*> peekByteOff ptr 68 <*> peekByteOff ptr 72
  poke ptr v = do
    fillBytes ptr 0 (sizeOf v)
    pokeByteOff ptr 0 (cCoordinateValueSliceVersion v)
    pokeByteOff ptr 8 (cCoordinateValueSliceStructSize v)
    pokeByteOff ptr 16 (cCoordinateValueSliceValueDomain v)
    pokeByteOff ptr 20 (cCoordinateValueSliceNumericDType v)
    pokeByteOff ptr 24 (cCoordinateValueSliceNumericEncoding v)
    pokeByteOff ptr 28 (cCoordinateValueSliceCodeDType v)
    pokeByteOff ptr 32 (cCoordinateValueSliceData v)
    pokeByteOff ptr 40 (cCoordinateValueSliceLen v)
    pokeByteOff ptr 48 (cCoordinateValueSliceElementSize v)
    pokeByteOff ptr 56 (cCoordinateValueSliceFixedTextWidth v)
    pokeByteOff ptr 64 (cCoordinateValueSliceAvailability v)
    pokeByteOff ptr 68 (cCoordinateValueSliceStatusCategory v)
    pokeByteOff ptr 72 (cCoordinateValueSliceReason v)


data CArcadiaTioCoordinateLookupKeyV2 = CArcadiaTioCoordinateLookupKeyV2
  { cCoordinateLookupKeyVersion :: Word32
  , cCoordinateLookupKeyStructSize :: CSize
  , cCoordinateLookupKeyDomain :: CInt
  , cCoordinateLookupKeyI32Value :: Int32
  , cCoordinateLookupKeyI64Value :: Int64
  , cCoordinateLookupKeyCodeValue :: Word64
  , cCoordinateLookupKeyBytes :: Ptr Word8
  , cCoordinateLookupKeyBytesLen :: CSize
  , cCoordinateLookupKeyFixedTextWidth :: CSize
  , cCoordinateLookupKeyText :: CString
  }
  deriving (Eq, Show)

emptyCArcadiaTioCoordinateLookupKeyV2 :: CArcadiaTioCoordinateLookupKeyV2
emptyCArcadiaTioCoordinateLookupKeyV2 = CArcadiaTioCoordinateLookupKeyV2 1 104 0 0 0 0 nullPtr 0 0 nullPtr

instance Storable CArcadiaTioCoordinateLookupKeyV2 where
  sizeOf _ = 104
  alignment _ = alignment (undefined :: Ptr ())
  peek ptr = CArcadiaTioCoordinateLookupKeyV2 <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 20 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 40 <*> peekByteOff ptr 48 <*> peekByteOff ptr 56 <*> peekByteOff ptr 64
  poke ptr v = do
    fillBytes ptr 0 (sizeOf v)
    pokeByteOff ptr 0 (cCoordinateLookupKeyVersion v)
    pokeByteOff ptr 8 (cCoordinateLookupKeyStructSize v)
    pokeByteOff ptr 16 (cCoordinateLookupKeyDomain v)
    pokeByteOff ptr 20 (cCoordinateLookupKeyI32Value v)
    pokeByteOff ptr 24 (cCoordinateLookupKeyI64Value v)
    pokeByteOff ptr 32 (cCoordinateLookupKeyCodeValue v)
    pokeByteOff ptr 40 (cCoordinateLookupKeyBytes v)
    pokeByteOff ptr 48 (cCoordinateLookupKeyBytesLen v)
    pokeByteOff ptr 56 (cCoordinateLookupKeyFixedTextWidth v)
    pokeByteOff ptr 64 (cCoordinateLookupKeyText v)

data CArcadiaTioCoordinateLookupResultV2 = CArcadiaTioCoordinateLookupResultV2
  { cCoordinateLookupResultVersion :: Word32
  , cCoordinateLookupResultStructSize :: CSize
  , cCoordinateLookupResultStatus :: CInt
  , cCoordinateLookupResultStatusCategory :: CInt
  , cCoordinateLookupResultUniquePosition :: Word32
  , cCoordinateLookupResultRangeStart :: Word32
  , cCoordinateLookupResultRangeEnd :: Word32
  , cCoordinateLookupResultPositions :: Ptr Word32
  , cCoordinateLookupResultPositionsLen :: CSize
  , cCoordinateLookupResultAvailability :: CInt
  , cCoordinateLookupResultReason :: CString
  }
  deriving (Eq, Show)

emptyCArcadiaTioCoordinateLookupResultV2 :: CArcadiaTioCoordinateLookupResultV2
emptyCArcadiaTioCoordinateLookupResultV2 = CArcadiaTioCoordinateLookupResultV2 1 104 0 0 0 0 0 nullPtr 0 0 nullPtr

instance Storable CArcadiaTioCoordinateLookupResultV2 where
  sizeOf _ = 104
  alignment _ = alignment (undefined :: Ptr ())
  peek ptr = CArcadiaTioCoordinateLookupResultV2 <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 20 <*> peekByteOff ptr 24 <*> peekByteOff ptr 28 <*> peekByteOff ptr 32 <*> peekByteOff ptr 40 <*> peekByteOff ptr 48 <*> peekByteOff ptr 56 <*> peekByteOff ptr 64
  poke ptr v = do
    fillBytes ptr 0 (sizeOf v)
    pokeByteOff ptr 0 (cCoordinateLookupResultVersion v)
    pokeByteOff ptr 8 (cCoordinateLookupResultStructSize v)
    pokeByteOff ptr 16 (cCoordinateLookupResultStatus v)
    pokeByteOff ptr 20 (cCoordinateLookupResultStatusCategory v)
    pokeByteOff ptr 24 (cCoordinateLookupResultUniquePosition v)
    pokeByteOff ptr 28 (cCoordinateLookupResultRangeStart v)
    pokeByteOff ptr 32 (cCoordinateLookupResultRangeEnd v)
    pokeByteOff ptr 40 (cCoordinateLookupResultPositions v)
    pokeByteOff ptr 48 (cCoordinateLookupResultPositionsLen v)
    pokeByteOff ptr 56 (cCoordinateLookupResultAvailability v)
    pokeByteOff ptr 64 (cCoordinateLookupResultReason v)

data CArcadiaTioAppendCoordinateEntryV2 = CArcadiaTioAppendCoordinateEntryV2
  { cAppendCoordinateEntryVersion :: Word32
  , cAppendCoordinateEntryStructSize :: CSize
  , cAppendCoordinateEntryAxis :: CSize
  , cAppendCoordinateEntryDescriptorId :: CString
  , cAppendCoordinateEntryName :: CString
  , cAppendCoordinateEntryValueDomain :: CInt
  , cAppendCoordinateEntryNumericDType :: CInt
  , cAppendCoordinateEntryNumericEncoding :: CInt
  , cAppendCoordinateEntryCodeDType :: CInt
  , cAppendCoordinateEntryValues :: Ptr Word8
  , cAppendCoordinateEntryCount :: CSize
  , cAppendCoordinateEntryElementSize :: CSize
  , cAppendCoordinateEntryFixedTextWidth :: CSize
  , cAppendCoordinateEntryDictionaryEntries :: Ptr CArcadiaTioCoordinateDictionaryEntryV2
  , cAppendCoordinateEntryDictionaryEntriesLen :: CSize
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioAppendCoordinateEntryV2 where
  sizeOf _ = 120
  alignment _ = alignment (undefined :: Ptr ())
  peek ptr = CArcadiaTioAppendCoordinateEntryV2 <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 40 <*> peekByteOff ptr 44 <*> peekByteOff ptr 48 <*> peekByteOff ptr 52 <*> peekByteOff ptr 56 <*> peekByteOff ptr 64 <*> peekByteOff ptr 72 <*> peekByteOff ptr 80 <*> peekByteOff ptr 88 <*> peekByteOff ptr 96
  poke ptr v = do
    fillBytes ptr 0 (sizeOf v)
    pokeByteOff ptr 0 (cAppendCoordinateEntryVersion v)
    pokeByteOff ptr 8 (cAppendCoordinateEntryStructSize v)
    pokeByteOff ptr 16 (cAppendCoordinateEntryAxis v)
    pokeByteOff ptr 24 (cAppendCoordinateEntryDescriptorId v)
    pokeByteOff ptr 32 (cAppendCoordinateEntryName v)
    pokeByteOff ptr 40 (cAppendCoordinateEntryValueDomain v)
    pokeByteOff ptr 44 (cAppendCoordinateEntryNumericDType v)
    pokeByteOff ptr 48 (cAppendCoordinateEntryNumericEncoding v)
    pokeByteOff ptr 52 (cAppendCoordinateEntryCodeDType v)
    pokeByteOff ptr 56 (cAppendCoordinateEntryValues v)
    pokeByteOff ptr 64 (cAppendCoordinateEntryCount v)
    pokeByteOff ptr 72 (cAppendCoordinateEntryElementSize v)
    pokeByteOff ptr 80 (cAppendCoordinateEntryFixedTextWidth v)
    pokeByteOff ptr 88 (cAppendCoordinateEntryDictionaryEntries v)
    pokeByteOff ptr 96 (cAppendCoordinateEntryDictionaryEntriesLen v)

data CArcadiaTioAppendCoordinateBatchV2 = CArcadiaTioAppendCoordinateBatchV2
  { cAppendCoordinateBatchVersion :: Word32
  , cAppendCoordinateBatchStructSize :: CSize
  , cAppendCoordinateBatchEntries :: Ptr CArcadiaTioAppendCoordinateEntryV2
  , cAppendCoordinateBatchEntriesLen :: CSize
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioAppendCoordinateBatchV2 where
  sizeOf _ = 64
  alignment _ = alignment (undefined :: Ptr ())
  peek ptr = CArcadiaTioAppendCoordinateBatchV2 <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24
  poke ptr v = do
    fillBytes ptr 0 (sizeOf v)
    pokeByteOff ptr 0 (cAppendCoordinateBatchVersion v)
    pokeByteOff ptr 8 (cAppendCoordinateBatchStructSize v)
    pokeByteOff ptr 16 (cAppendCoordinateBatchEntries v)
    pokeByteOff ptr 24 (cAppendCoordinateBatchEntriesLen v)

data CArcadiaTioCoordinateV2Options = CArcadiaTioCoordinateV2Options
  { cCoordinateV2OptionsVersion :: Word32
  , cCoordinateV2OptionsStructSize :: CSize
  , cCoordinateV2OptionsAllowAuthoritativeScan :: Word8
  , cCoordinateV2OptionsIncludeDictionaryEntries :: Word8
  , cCoordinateV2OptionsIncludeIndexSummaries :: Word8
  , cCoordinateV2OptionsAllowExternalResolution :: Word8
  }
  deriving (Eq, Show)

emptyCArcadiaTioCoordinateV2Options :: CArcadiaTioCoordinateV2Options
emptyCArcadiaTioCoordinateV2Options = CArcadiaTioCoordinateV2Options 1 56 0 0 0 0

instance Storable CArcadiaTioCoordinateV2Options where
  sizeOf _ = 56
  alignment _ = alignment (undefined :: Ptr ())
  peek ptr = CArcadiaTioCoordinateV2Options <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 17 <*> peekByteOff ptr 18 <*> peekByteOff ptr 19
  poke ptr v = do
    fillBytes ptr 0 (sizeOf v)
    pokeByteOff ptr 0 (cCoordinateV2OptionsVersion v)
    pokeByteOff ptr 8 (cCoordinateV2OptionsStructSize v)
    pokeByteOff ptr 16 (cCoordinateV2OptionsAllowAuthoritativeScan v)
    pokeByteOff ptr 17 (cCoordinateV2OptionsIncludeDictionaryEntries v)
    pokeByteOff ptr 18 (cCoordinateV2OptionsIncludeIndexSummaries v)
    pokeByteOff ptr 19 (cCoordinateV2OptionsAllowExternalResolution v)

data CArcadiaTioAxisCoordinateInputV2 = CArcadiaTioAxisCoordinateInputV2
  { cAxisCoordinateInputV2Version :: Word32
  , cAxisCoordinateInputV2StructSize :: CSize
  , cAxisCoordinateInputV2Axis :: CSize
  , cAxisCoordinateInputV2DescriptorId :: CString
  , cAxisCoordinateInputV2Name :: CString
  , cAxisCoordinateInputV2Kind :: CInt
  , cAxisCoordinateInputV2ValueDomain :: CInt
  , cAxisCoordinateInputV2NumericDType :: CInt
  , cAxisCoordinateInputV2NumericEncoding :: CInt
  , cAxisCoordinateInputV2FixedText :: CArcadiaTioCoordinateFixedTextLayoutV2
  , cAxisCoordinateInputV2CodeDType :: CInt
  , cAxisCoordinateInputV2Values :: Ptr Word8
  , cAxisCoordinateInputV2ValuesLen :: CSize
  , cAxisCoordinateInputV2Dictionary :: Ptr CArcadiaTioCoordinateDictionarySummaryV2
  , cAxisCoordinateInputV2DictionaryEntries :: Ptr CArcadiaTioCoordinateDictionaryEntryV2
  , cAxisCoordinateInputV2DictionaryEntriesLen :: CSize
  , cAxisCoordinateInputV2ExternalBinding :: Ptr CArcadiaTioCoordinateExternalBindingV2
  , cAxisCoordinateInputV2Sorted :: CInt
  , cAxisCoordinateInputV2Monotonicity :: CInt
  , cAxisCoordinateInputV2Uniqueness :: CInt
  , cAxisCoordinateInputV2Required :: Word8
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioAxisCoordinateInputV2 where
  sizeOf _ = 224
  alignment _ = alignment (undefined :: Ptr ())
  peek ptr = CArcadiaTioAxisCoordinateInputV2 <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 40 <*> peekByteOff ptr 44 <*> peekByteOff ptr 48 <*> peekByteOff ptr 52 <*> peekByteOff ptr 56 <*> peekByteOff ptr 112 <*> peekByteOff ptr 120 <*> peekByteOff ptr 128 <*> peekByteOff ptr 136 <*> peekByteOff ptr 144 <*> peekByteOff ptr 152 <*> peekByteOff ptr 160 <*> peekByteOff ptr 168 <*> peekByteOff ptr 172 <*> peekByteOff ptr 176 <*> peekByteOff ptr 180
  poke ptr v = do
    fillBytes ptr 0 (sizeOf v)
    pokeByteOff ptr 0 (cAxisCoordinateInputV2Version v)
    pokeByteOff ptr 8 (cAxisCoordinateInputV2StructSize v)
    pokeByteOff ptr 16 (cAxisCoordinateInputV2Axis v)
    pokeByteOff ptr 24 (cAxisCoordinateInputV2DescriptorId v)
    pokeByteOff ptr 32 (cAxisCoordinateInputV2Name v)
    pokeByteOff ptr 40 (cAxisCoordinateInputV2Kind v)
    pokeByteOff ptr 44 (cAxisCoordinateInputV2ValueDomain v)
    pokeByteOff ptr 48 (cAxisCoordinateInputV2NumericDType v)
    pokeByteOff ptr 52 (cAxisCoordinateInputV2NumericEncoding v)
    pokeByteOff ptr 56 (cAxisCoordinateInputV2FixedText v)
    pokeByteOff ptr 112 (cAxisCoordinateInputV2CodeDType v)
    pokeByteOff ptr 120 (cAxisCoordinateInputV2Values v)
    pokeByteOff ptr 128 (cAxisCoordinateInputV2ValuesLen v)
    pokeByteOff ptr 136 (cAxisCoordinateInputV2Dictionary v)
    pokeByteOff ptr 144 (cAxisCoordinateInputV2DictionaryEntries v)
    pokeByteOff ptr 152 (cAxisCoordinateInputV2DictionaryEntriesLen v)
    pokeByteOff ptr 160 (cAxisCoordinateInputV2ExternalBinding v)
    pokeByteOff ptr 168 (cAxisCoordinateInputV2Sorted v)
    pokeByteOff ptr 172 (cAxisCoordinateInputV2Monotonicity v)
    pokeByteOff ptr 176 (cAxisCoordinateInputV2Uniqueness v)
    pokeByteOff ptr 180 (cAxisCoordinateInputV2Required v)

data CArcadiaTioAxisCoordinateMetaV2 = CArcadiaTioAxisCoordinateMetaV2
  { cAxisCoordinateMetaV2Version :: Word32
  , cAxisCoordinateMetaV2StructSize :: CSize
  , cAxisCoordinateMetaV2Axis :: CSize
  , cAxisCoordinateMetaV2AxisNameSnapshot :: CString
  , cAxisCoordinateMetaV2DescriptorId :: CString
  , cAxisCoordinateMetaV2DescriptorRevision :: Word64
  , cAxisCoordinateMetaV2Name :: CString
  , cAxisCoordinateMetaV2Kind :: CInt
  , cAxisCoordinateMetaV2ValueDomain :: CInt
  , cAxisCoordinateMetaV2NumericDType :: CInt
  , cAxisCoordinateMetaV2NumericEncoding :: CInt
  , cAxisCoordinateMetaV2FixedText :: CArcadiaTioCoordinateFixedTextLayoutV2
  , cAxisCoordinateMetaV2CodeDType :: CInt
  , cAxisCoordinateMetaV2Length :: Word64
  , cAxisCoordinateMetaV2Sorted :: CInt
  , cAxisCoordinateMetaV2Monotonicity :: CInt
  , cAxisCoordinateMetaV2Uniqueness :: CInt
  , cAxisCoordinateMetaV2Required :: Word8
  , cAxisCoordinateMetaV2Availability :: CInt
  , cAxisCoordinateMetaV2StatusCategory :: CInt
  , cAxisCoordinateMetaV2Reason :: CString
  , cAxisCoordinateMetaV2Dictionary :: CArcadiaTioCoordinateDictionarySummaryV2
  , cAxisCoordinateMetaV2ExternalBinding :: CArcadiaTioCoordinateExternalBindingV2
  , cAxisCoordinateMetaV2IndexSummaries :: Ptr CArcadiaTioCoordinateIndexSummaryV2
  , cAxisCoordinateMetaV2IndexSummariesLen :: CSize
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioAxisCoordinateMetaV2 where
  sizeOf _ = 408
  alignment _ = alignment (undefined :: Ptr ())
  peek ptr = CArcadiaTioAxisCoordinateMetaV2 <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 40 <*> peekByteOff ptr 48 <*> peekByteOff ptr 56 <*> peekByteOff ptr 60 <*> peekByteOff ptr 64 <*> peekByteOff ptr 68 <*> peekByteOff ptr 72 <*> peekByteOff ptr 128 <*> peekByteOff ptr 136 <*> peekByteOff ptr 144 <*> peekByteOff ptr 148 <*> peekByteOff ptr 152 <*> peekByteOff ptr 156 <*> peekByteOff ptr 164 <*> peekByteOff ptr 168 <*> peekByteOff ptr 176 <*> peekByteOff ptr 184 <*> peekByteOff ptr 264 <*> peekByteOff ptr 360 <*> peekByteOff ptr 368
  poke ptr v = do
    fillBytes ptr 0 (sizeOf v)
    pokeByteOff ptr 0 (cAxisCoordinateMetaV2Version v)
    pokeByteOff ptr 8 (cAxisCoordinateMetaV2StructSize v)
    pokeByteOff ptr 16 (cAxisCoordinateMetaV2Axis v)
    pokeByteOff ptr 24 (cAxisCoordinateMetaV2AxisNameSnapshot v)
    pokeByteOff ptr 32 (cAxisCoordinateMetaV2DescriptorId v)
    pokeByteOff ptr 40 (cAxisCoordinateMetaV2DescriptorRevision v)
    pokeByteOff ptr 48 (cAxisCoordinateMetaV2Name v)
    pokeByteOff ptr 56 (cAxisCoordinateMetaV2Kind v)
    pokeByteOff ptr 60 (cAxisCoordinateMetaV2ValueDomain v)
    pokeByteOff ptr 64 (cAxisCoordinateMetaV2NumericDType v)
    pokeByteOff ptr 68 (cAxisCoordinateMetaV2NumericEncoding v)
    pokeByteOff ptr 72 (cAxisCoordinateMetaV2FixedText v)
    pokeByteOff ptr 128 (cAxisCoordinateMetaV2CodeDType v)
    pokeByteOff ptr 136 (cAxisCoordinateMetaV2Length v)
    pokeByteOff ptr 144 (cAxisCoordinateMetaV2Sorted v)
    pokeByteOff ptr 148 (cAxisCoordinateMetaV2Monotonicity v)
    pokeByteOff ptr 152 (cAxisCoordinateMetaV2Uniqueness v)
    pokeByteOff ptr 156 (cAxisCoordinateMetaV2Required v)
    pokeByteOff ptr 164 (cAxisCoordinateMetaV2Availability v)
    pokeByteOff ptr 168 (cAxisCoordinateMetaV2StatusCategory v)
    pokeByteOff ptr 176 (cAxisCoordinateMetaV2Reason v)
    pokeByteOff ptr 184 (cAxisCoordinateMetaV2Dictionary v)
    pokeByteOff ptr 264 (cAxisCoordinateMetaV2ExternalBinding v)
    pokeByteOff ptr 360 (cAxisCoordinateMetaV2IndexSummaries v)
    pokeByteOff ptr 368 (cAxisCoordinateMetaV2IndexSummariesLen v)

-- | Minimal raw tensor struct matching the Linux C ABI layout.
--
-- This struct mirrors:
--
-- @
-- typedef struct ArcadiaTioTensor {
--   uint8_t* data;
--   size_t len_bytes;
--   size_t rank;
--   uint64_t* shape;
--   ArcadiaTioDType dtype;
-- } ArcadiaTioTensor;
-- @
--
-- The first Haskell slice is Linux shared-library focused and uses the ordinary
-- x86_64 SysV layout for this struct.
data CArcadiaTioTensor = CArcadiaTioTensor
  { cTensorData :: Ptr Word8
  , cTensorLenBytes :: CSize
  , cTensorRank :: CSize
  , cTensorShape :: Ptr Word64
  , cTensorDType :: CInt
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioTensor where
  sizeOf _ = 40
  alignment _ = alignment (undefined :: Ptr ())
  peek ptr =
    CArcadiaTioTensor
      <$> peekByteOff ptr 0
      <*> peekByteOff ptr 8
      <*> peekByteOff ptr 16
      <*> peekByteOff ptr 24
      <*> peekByteOff ptr 32
  poke ptr CArcadiaTioTensor{cTensorData, cTensorLenBytes, cTensorRank, cTensorShape, cTensorDType} = do
    pokeByteOff ptr 0 cTensorData
    pokeByteOff ptr 8 cTensorLenBytes
    pokeByteOff ptr 16 cTensorRank
    pokeByteOff ptr 24 cTensorShape
    pokeByteOff ptr 32 cTensorDType

-- | Zero/null tensor value for initializing C outputs before calls.
emptyCArcadiaTioTensor :: CArcadiaTioTensor
emptyCArcadiaTioTensor =
  CArcadiaTioTensor
    { cTensorData = nullPtr
    , cTensorLenBytes = 0
    , cTensorRank = 0
    , cTensorShape = nullPtr
    , cTensorDType = 0
    }

-- | Raw validity-mask output matching @ArcadiaTioMask@.
data CArcadiaTioMask = CArcadiaTioMask
  { cMaskData :: Ptr Word8
  , cMaskLen :: CSize
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioMask where
  sizeOf _ = 16
  alignment _ = alignment (undefined :: Ptr ())
  peek ptr = CArcadiaTioMask <$> peekByteOff ptr 0 <*> peekByteOff ptr 8
  poke ptr CArcadiaTioMask{cMaskData, cMaskLen} = do
    pokeByteOff ptr 0 cMaskData
    pokeByteOff ptr 8 cMaskLen

-- | Zero/null mask value for initializing C outputs before calls.
emptyCArcadiaTioMask :: CArcadiaTioMask
emptyCArcadiaTioMask = CArcadiaTioMask{cMaskData = nullPtr, cMaskLen = 0}

-- | Raw file dimension metadata matching @ArcadiaTioDimSpec@.
data CArcadiaTioDimSpec = CArcadiaTioDimSpec
  { cDimKind :: CInt
  , cDimLen :: Word32
  , cDimName :: CString
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioDimSpec where
  sizeOf _ = 16
  alignment _ = alignment (undefined :: Ptr ())
  peek ptr =
    CArcadiaTioDimSpec
      <$> peekByteOff ptr 0
      <*> peekByteOff ptr 4
      <*> peekByteOff ptr 8
  poke ptr CArcadiaTioDimSpec{cDimKind, cDimLen, cDimName} = do
    pokeByteOff ptr 0 cDimKind
    pokeByteOff ptr 4 cDimLen
    pokeByteOff ptr 8 cDimName

-- | Raw axis-label metadata matching @ArcadiaTioAxisLabel@.
data CArcadiaTioAxisLabel = CArcadiaTioAxisLabel
  { cAxisLabelId :: Word32
  , cAxisLabelName :: CString
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioAxisLabel where
  sizeOf _ = 16
  alignment _ = alignment (undefined :: Ptr ())
  peek ptr = CArcadiaTioAxisLabel <$> peekByteOff ptr 0 <*> peekByteOff ptr 8
  poke ptr CArcadiaTioAxisLabel{cAxisLabelId, cAxisLabelName} = do
    pokeByteOff ptr 0 cAxisLabelId
    pokeByteOff ptr 8 cAxisLabelName

-- | Raw user metadata key/value pair matching @ArcadiaTioUserKv@.
data CArcadiaTioUserKv = CArcadiaTioUserKv
  { cUserKvKey :: CString
  , cUserKvValue :: CString
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioUserKv where
  sizeOf _ = 16
  alignment _ = alignment (undefined :: Ptr ())
  peek ptr = CArcadiaTioUserKv <$> peekByteOff ptr 0 <*> peekByteOff ptr 8
  poke ptr CArcadiaTioUserKv{cUserKvKey, cUserKvValue} = do
    pokeByteOff ptr 0 cUserKvKey
    pokeByteOff ptr 8 cUserKvValue

-- | Raw loaded file metadata matching @ArcadiaTioFileMeta@.
data CArcadiaTioFileMeta = CArcadiaTioFileMeta
  { cFileMetaDType :: CInt
  , cFileMetaDims :: Ptr CArcadiaTioDimSpec
  , cFileMetaRank :: CSize
  , cFileMetaAppendDim :: CSize
  , cFileMetaSymbols :: Ptr CArcadiaTioAxisLabel
  , cFileMetaSymbolsLen :: CSize
  , cFileMetaChannels :: Ptr CArcadiaTioAxisLabel
  , cFileMetaChannelsLen :: CSize
  , cFileMetaUserKv :: Ptr CArcadiaTioUserKv
  , cFileMetaUserKvLen :: CSize
  , cFileMetaEffectiveProfile :: CInt
  , cFileMetaCommitSeq :: Word64
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioFileMeta where
  sizeOf _ = 96
  alignment _ = alignment (undefined :: Ptr ())
  peek ptr =
    CArcadiaTioFileMeta
      <$> peekByteOff ptr 0
      <*> peekByteOff ptr 8
      <*> peekByteOff ptr 16
      <*> peekByteOff ptr 24
      <*> peekByteOff ptr 32
      <*> peekByteOff ptr 40
      <*> peekByteOff ptr 48
      <*> peekByteOff ptr 56
      <*> peekByteOff ptr 64
      <*> peekByteOff ptr 72
      <*> peekByteOff ptr 80
      <*> peekByteOff ptr 88
  poke ptr CArcadiaTioFileMeta{cFileMetaDType, cFileMetaDims, cFileMetaRank, cFileMetaAppendDim, cFileMetaSymbols, cFileMetaSymbolsLen, cFileMetaChannels, cFileMetaChannelsLen, cFileMetaUserKv, cFileMetaUserKvLen, cFileMetaEffectiveProfile, cFileMetaCommitSeq} = do
    pokeByteOff ptr 0 cFileMetaDType
    pokeByteOff ptr 8 cFileMetaDims
    pokeByteOff ptr 16 cFileMetaRank
    pokeByteOff ptr 24 cFileMetaAppendDim
    pokeByteOff ptr 32 cFileMetaSymbols
    pokeByteOff ptr 40 cFileMetaSymbolsLen
    pokeByteOff ptr 48 cFileMetaChannels
    pokeByteOff ptr 56 cFileMetaChannelsLen
    pokeByteOff ptr 64 cFileMetaUserKv
    pokeByteOff ptr 72 cFileMetaUserKvLen
    pokeByteOff ptr 80 cFileMetaEffectiveProfile
    pokeByteOff ptr 88 cFileMetaCommitSeq

-- | Zero/null file metadata output value.
emptyCArcadiaTioFileMeta :: CArcadiaTioFileMeta
emptyCArcadiaTioFileMeta =
  CArcadiaTioFileMeta
    { cFileMetaDType = 0
    , cFileMetaDims = nullPtr
    , cFileMetaRank = 0
    , cFileMetaAppendDim = 0
    , cFileMetaSymbols = nullPtr
    , cFileMetaSymbolsLen = 0
    , cFileMetaChannels = nullPtr
    , cFileMetaChannelsLen = 0
    , cFileMetaUserKv = nullPtr
    , cFileMetaUserKvLen = 0
    , cFileMetaEffectiveProfile = 0
    , cFileMetaCommitSeq = 0
    }

-- | Raw scalar output matching @ArcadiaTioScalar@.
data CArcadiaTioScalar = CArcadiaTioScalar
  { cScalarDType :: CInt
  , cScalarValue :: Double
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioScalar where
  sizeOf _ = 16
  alignment _ = alignment (undefined :: Double)
  peek ptr = CArcadiaTioScalar <$> peekByteOff ptr 0 <*> peekByteOff ptr 8
  poke ptr CArcadiaTioScalar{cScalarDType, cScalarValue} = do
    pokeByteOff ptr 0 cScalarDType
    pokeByteOff ptr 8 cScalarValue

-- | Raw compression config matching @ArcadiaTioCompressionConfig@.
data CArcadiaTioCompressionConfig = CArcadiaTioCompressionConfig
  { cCompressionVersion :: Word32
  , cCompressionStructSize :: CSize
  , cCompressionMode :: CInt
  , cCompressionCodec :: CInt
  , cCompressionMinPayloadBytes :: Word32
  , cCompressionZstdLevel :: Int32
  }
  deriving (Eq, Show)

compressionConfigStructSize :: CSize
compressionConfigStructSize = 32

instance Storable CArcadiaTioCompressionConfig where
  sizeOf _ = fromIntegral compressionConfigStructSize
  alignment _ = alignment (undefined :: CSize)
  peek ptr =
    CArcadiaTioCompressionConfig
      <$> peekByteOff ptr 0
      <*> peekByteOff ptr 8
      <*> peekByteOff ptr 16
      <*> peekByteOff ptr 20
      <*> peekByteOff ptr 24
      <*> peekByteOff ptr 28
  poke ptr CArcadiaTioCompressionConfig{cCompressionVersion, cCompressionStructSize, cCompressionMode, cCompressionCodec, cCompressionMinPayloadBytes, cCompressionZstdLevel} = do
    pokeByteOff ptr 0 cCompressionVersion
    pokeByteOff ptr 8 cCompressionStructSize
    pokeByteOff ptr 16 cCompressionMode
    pokeByteOff ptr 20 cCompressionCodec
    pokeByteOff ptr 24 cCompressionMinPayloadBytes
    pokeByteOff ptr 28 cCompressionZstdLevel

-- | Raw commit info matching @ArcadiaTioCommitInfo@.
-- | Raw selector matching @ArcadiaTioEntrySelector@.
data CArcadiaTioEntrySelector = CArcadiaTioEntrySelector
  { cEntrySelectorKind :: CInt
  , cEntrySelectorStart :: Word32
  , cEntrySelectorEnd :: Word32
  , cEntrySelectorIndices :: Ptr Word32
  , cEntrySelectorIndicesLen :: CSize
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioEntrySelector where
  sizeOf _ = 32
  alignment _ = alignment (undefined :: Ptr ())
  peek ptr =
    CArcadiaTioEntrySelector
      <$> peekByteOff ptr 0
      <*> peekByteOff ptr 4
      <*> peekByteOff ptr 8
      <*> peekByteOff ptr 16
      <*> peekByteOff ptr 24
  poke ptr CArcadiaTioEntrySelector{cEntrySelectorKind, cEntrySelectorStart, cEntrySelectorEnd, cEntrySelectorIndices, cEntrySelectorIndicesLen} = do
    pokeByteOff ptr 0 cEntrySelectorKind
    pokeByteOff ptr 4 cEntrySelectorStart
    pokeByteOff ptr 8 cEntrySelectorEnd
    pokeByteOff ptr 16 cEntrySelectorIndices
    pokeByteOff ptr 24 cEntrySelectorIndicesLen

readShapePolicyOptionsStructSize :: CSize
readShapePolicyOptionsStructSize = 72

readOptionsStructSize :: CSize
readOptionsStructSize = 32

readWithShapePolicyOptionsStructSize :: CSize
readWithShapePolicyOptionsStructSize = 104

readExecutionReportStructSize :: CSize
readExecutionReportStructSize = 80

queryTraceContextStructSize :: CSize
queryTraceContextStructSize = 80

queryTraceJsonStructSize :: CSize
queryTraceJsonStructSize = 24

readIndexReportStructSize :: CSize
readIndexReportStructSize = 32

historicalReadExecutionReportStructSize :: CSize
historicalReadExecutionReportStructSize = 96


-- | Raw explicit-universe read target.
data CArcadiaTioExplicitUniverseAxisTarget = CArcadiaTioExplicitUniverseAxisTarget
  { cExplicitUniverseAxisTargetAxis :: Word32
  , cExplicitUniverseAxisTargetFamilyUuid :: [Word8]
  , cExplicitUniverseAxisTargetVersionUuid :: [Word8]
  , cExplicitUniverseAxisTargetLength :: Word64
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioExplicitUniverseAxisTarget where
  sizeOf _ = 48
  alignment _ = alignment (undefined :: Word64)
  peek _ = fail "CArcadiaTioExplicitUniverseAxisTarget.peek is not implemented"
  poke ptr v = do
    fillBytes ptr 0 (sizeOf v)
    pokeByteOff ptr 0 (cExplicitUniverseAxisTargetAxis v)
    pokeArray (ptr `plusPtr` 4) (take 16 (cExplicitUniverseAxisTargetFamilyUuid v <> repeat 0))
    pokeArray (ptr `plusPtr` 20) (take 16 (cExplicitUniverseAxisTargetVersionUuid v <> repeat 0))
    pokeByteOff ptr 40 (cExplicitUniverseAxisTargetLength v)

data CArcadiaTioExplicitExtentAxisTarget = CArcadiaTioExplicitExtentAxisTarget
  { cExplicitExtentAxisTargetAxis :: Word32
  , cExplicitExtentAxisTargetLength :: Word64
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioExplicitExtentAxisTarget where
  sizeOf _ = 16
  alignment _ = alignment (undefined :: Word64)
  peek _ = fail "CArcadiaTioExplicitExtentAxisTarget.peek is not implemented"
  poke ptr v = do
    fillBytes ptr 0 (sizeOf v)
    pokeByteOff ptr 0 (cExplicitExtentAxisTargetAxis v)
    pokeByteOff ptr 8 (cExplicitExtentAxisTargetLength v)

data CArcadiaTioAxisIdentityInput = CArcadiaTioAxisIdentityInput
  { cAxisIdentityInputVersion :: Word32
  , cAxisIdentityInputStructSize :: CSize
  , cAxisIdentityInputAxis :: Word32
  , cAxisIdentityInputMode :: CArcadiaTioAxisIdentityMode
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioAxisIdentityInput where
  sizeOf _ = 24
  alignment _ = alignment (undefined :: Ptr ())
  peek _ = fail "CArcadiaTioAxisIdentityInput.peek is not implemented"
  poke ptr v = do
    fillBytes ptr 0 (sizeOf v)
    pokeByteOff ptr 0 (cAxisIdentityInputVersion v)
    pokeByteOff ptr 8 (cAxisIdentityInputStructSize v)
    pokeByteOff ptr 16 (cAxisIdentityInputAxis v)
    pokeByteOff ptr 20 (cAxisIdentityInputMode v)

data CArcadiaTioUniverseBindingInput = CArcadiaTioUniverseBindingInput
  { cUniverseBindingInputAxis :: Word32
  , cUniverseBindingInputFamilyUuid :: [Word8]
  , cUniverseBindingInputVersionUuid :: [Word8]
  , cUniverseBindingInputLength :: Word64
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioUniverseBindingInput where
  sizeOf _ = 48
  alignment _ = alignment (undefined :: Word64)
  peek _ = fail "CArcadiaTioUniverseBindingInput.peek is not implemented"
  poke ptr v = do
    fillBytes ptr 0 (sizeOf v)
    pokeByteOff ptr 0 (cUniverseBindingInputAxis v)
    pokeArray (ptr `plusPtr` 4) (take 16 (cUniverseBindingInputFamilyUuid v <> repeat 0))
    pokeArray (ptr `plusPtr` 20) (take 16 (cUniverseBindingInputVersionUuid v <> repeat 0))
    pokeByteOff ptr 40 (cUniverseBindingInputLength v)

data CArcadiaTioSlotUniverseBindingInput = CArcadiaTioSlotUniverseBindingInput
  { cSlotUniverseBindingInputAxes :: Ptr CArcadiaTioUniverseBindingInput
  , cSlotUniverseBindingInputAxesLen :: CSize
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioSlotUniverseBindingInput where
  sizeOf _ = 16
  alignment _ = alignment (undefined :: Ptr ())
  peek _ = fail "CArcadiaTioSlotUniverseBindingInput.peek is not implemented"
  poke ptr v = do
    fillBytes ptr 0 (sizeOf v)
    pokeByteOff ptr 0 (cSlotUniverseBindingInputAxes v)
    pokeByteOff ptr 8 (cSlotUniverseBindingInputAxesLen v)

data CArcadiaTioUniverseRemapInput = CArcadiaTioUniverseRemapInput
  { cUniverseRemapInputVersion :: Word32
  , cUniverseRemapInputStructSize :: CSize
  , cUniverseRemapInputAxis :: Word32
  , cUniverseRemapInputTargetFamilyUuid :: [Word8]
  , cUniverseRemapInputTargetVersionUuid :: [Word8]
  , cUniverseRemapInputTargetLength :: Word64
  , cUniverseRemapInputSourceToTarget :: Ptr Word64
  , cUniverseRemapInputSourceToTargetLen :: CSize
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioUniverseRemapInput where
  sizeOf _ = 80
  alignment _ = alignment (undefined :: Ptr ())
  peek _ = fail "CArcadiaTioUniverseRemapInput.peek is not implemented"
  poke ptr v = do
    fillBytes ptr 0 (sizeOf v)
    pokeByteOff ptr 0 (cUniverseRemapInputVersion v)
    pokeByteOff ptr 8 (cUniverseRemapInputStructSize v)
    pokeByteOff ptr 16 (cUniverseRemapInputAxis v)
    pokeArray (ptr `plusPtr` 20) (take 16 (cUniverseRemapInputTargetFamilyUuid v <> repeat 0))
    pokeArray (ptr `plusPtr` 36) (take 16 (cUniverseRemapInputTargetVersionUuid v <> repeat 0))
    pokeByteOff ptr 56 (cUniverseRemapInputTargetLength v)
    pokeByteOff ptr 64 (cUniverseRemapInputSourceToTarget v)
    pokeByteOff ptr 72 (cUniverseRemapInputSourceToTargetLen v)

data CArcadiaTioSlotUniverseRemapInput = CArcadiaTioSlotUniverseRemapInput
  { cSlotUniverseRemapInputAxes :: Ptr CArcadiaTioUniverseRemapInput
  , cSlotUniverseRemapInputAxesLen :: CSize
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioSlotUniverseRemapInput where
  sizeOf _ = 16
  alignment _ = alignment (undefined :: Ptr ())
  peek _ = fail "CArcadiaTioSlotUniverseRemapInput.peek is not implemented"
  poke ptr v = do
    fillBytes ptr 0 (sizeOf v)
    pokeByteOff ptr 0 (cSlotUniverseRemapInputAxes v)
    pokeByteOff ptr 8 (cSlotUniverseRemapInputAxesLen v)

data CArcadiaTioCreateWithUniverseOptions = CArcadiaTioCreateWithUniverseOptions
  { cCreateWithUniverseOptionsVersion :: Word32
  , cCreateWithUniverseOptionsStructSize :: CSize
  , cCreateWithUniverseOptionsAxisIdentities :: Ptr CArcadiaTioAxisIdentityInput
  , cCreateWithUniverseOptionsAxisIdentitiesLen :: CSize
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioCreateWithUniverseOptions where
  sizeOf _ = 32
  alignment _ = alignment (undefined :: Ptr ())
  peek _ = fail "CArcadiaTioCreateWithUniverseOptions.peek is not implemented"
  poke ptr v = do
    fillBytes ptr 0 (sizeOf v)
    pokeByteOff ptr 0 (cCreateWithUniverseOptionsVersion v)
    pokeByteOff ptr 8 (cCreateWithUniverseOptionsStructSize v)
    pokeByteOff ptr 16 (cCreateWithUniverseOptionsAxisIdentities v)
    pokeByteOff ptr 24 (cCreateWithUniverseOptionsAxisIdentitiesLen v)

data CArcadiaTioAppendWithUniverseOptions = CArcadiaTioAppendWithUniverseOptions
  { cAppendWithUniverseOptionsVersion :: Word32
  , cAppendWithUniverseOptionsStructSize :: CSize
  , cAppendWithUniverseOptionsSlots :: Ptr CArcadiaTioSlotUniverseBindingInput
  , cAppendWithUniverseOptionsSlotsLen :: CSize
  , cAppendWithUniverseOptionsRemapSlots :: Ptr CArcadiaTioSlotUniverseRemapInput
  , cAppendWithUniverseOptionsRemapSlotsLen :: CSize
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioAppendWithUniverseOptions where
  sizeOf _ = 48
  alignment _ = alignment (undefined :: Ptr ())
  peek _ = fail "CArcadiaTioAppendWithUniverseOptions.peek is not implemented"
  poke ptr v = do
    fillBytes ptr 0 (sizeOf v)
    pokeByteOff ptr 0 (cAppendWithUniverseOptionsVersion v)
    pokeByteOff ptr 8 (cAppendWithUniverseOptionsStructSize v)
    pokeByteOff ptr 16 (cAppendWithUniverseOptionsSlots v)
    pokeByteOff ptr 24 (cAppendWithUniverseOptionsSlotsLen v)
    pokeByteOff ptr 32 (cAppendWithUniverseOptionsRemapSlots v)
    pokeByteOff ptr 40 (cAppendWithUniverseOptionsRemapSlotsLen v)

-- | Raw read shape-policy options matching @ArcadiaTioReadShapePolicyOptions@.
data CArcadiaTioReadShapePolicyOptions = CArcadiaTioReadShapePolicyOptions
  { cReadShapePolicyVersion :: Word32
  , cReadShapePolicyStructSize :: CSize
  , cReadShapePolicyPolicy :: CArcadiaTioReadShapePolicyTag
  , cReadShapePolicyExplicitExtents :: Ptr Word64
  , cReadShapePolicyExplicitExtentsLen :: CSize
  , cReadShapePolicyExplicitUniverseAxes :: Ptr ()
  , cReadShapePolicyExplicitUniverseAxesLen :: CSize
  , cReadShapePolicyExplicitExtentAxes :: Ptr ()
  , cReadShapePolicyExplicitExtentAxesLen :: CSize
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioReadShapePolicyOptions where
  sizeOf _ = fromIntegral readShapePolicyOptionsStructSize
  alignment _ = alignment (undefined :: CSize)
  peek ptr =
    CArcadiaTioReadShapePolicyOptions
      <$> peekByteOff ptr 0
      <*> peekByteOff ptr 8
      <*> peekByteOff ptr 16
      <*> peekByteOff ptr 24
      <*> peekByteOff ptr 32
      <*> peekByteOff ptr 40
      <*> peekByteOff ptr 48
      <*> peekByteOff ptr 56
      <*> peekByteOff ptr 64
  poke ptr CArcadiaTioReadShapePolicyOptions{cReadShapePolicyVersion, cReadShapePolicyStructSize, cReadShapePolicyPolicy, cReadShapePolicyExplicitExtents, cReadShapePolicyExplicitExtentsLen, cReadShapePolicyExplicitUniverseAxes, cReadShapePolicyExplicitUniverseAxesLen, cReadShapePolicyExplicitExtentAxes, cReadShapePolicyExplicitExtentAxesLen} = do
    pokeByteOff ptr 0 cReadShapePolicyVersion
    pokeByteOff ptr 8 cReadShapePolicyStructSize
    pokeByteOff ptr 16 cReadShapePolicyPolicy
    pokeByteOff ptr 24 cReadShapePolicyExplicitExtents
    pokeByteOff ptr 32 cReadShapePolicyExplicitExtentsLen
    pokeByteOff ptr 40 cReadShapePolicyExplicitUniverseAxes
    pokeByteOff ptr 48 cReadShapePolicyExplicitUniverseAxesLen
    pokeByteOff ptr 56 cReadShapePolicyExplicitExtentAxes
    pokeByteOff ptr 64 cReadShapePolicyExplicitExtentAxesLen

emptyCArcadiaTioReadShapePolicyOptions :: CArcadiaTioReadShapePolicyOptions
emptyCArcadiaTioReadShapePolicyOptions =
  CArcadiaTioReadShapePolicyOptions
    { cReadShapePolicyVersion = 1
    , cReadShapePolicyStructSize = readShapePolicyOptionsStructSize
    , cReadShapePolicyPolicy = 0
    , cReadShapePolicyExplicitExtents = nullPtr
    , cReadShapePolicyExplicitExtentsLen = 0
    , cReadShapePolicyExplicitUniverseAxes = nullPtr
    , cReadShapePolicyExplicitUniverseAxesLen = 0
    , cReadShapePolicyExplicitExtentAxes = nullPtr
    , cReadShapePolicyExplicitExtentAxesLen = 0
    }

-- | Raw read options matching @ArcadiaTioReadWithOptionsOptions@.
data CArcadiaTioReadWithOptionsOptions = CArcadiaTioReadWithOptionsOptions
  { cReadOptionsVersion :: Word32
  , cReadOptionsStructSize :: CSize
  , cReadOptionsMode :: CArcadiaTioReadExecutionMode
  , cReadOptionsMaxThreads :: CSize
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioReadWithOptionsOptions where
  sizeOf _ = fromIntegral readOptionsStructSize
  alignment _ = alignment (undefined :: CSize)
  peek ptr = CArcadiaTioReadWithOptionsOptions <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24
  poke ptr CArcadiaTioReadWithOptionsOptions{cReadOptionsVersion, cReadOptionsStructSize, cReadOptionsMode, cReadOptionsMaxThreads} = do
    pokeByteOff ptr 0 cReadOptionsVersion
    pokeByteOff ptr 8 cReadOptionsStructSize
    pokeByteOff ptr 16 cReadOptionsMode
    pokeByteOff ptr 24 cReadOptionsMaxThreads

-- | Raw shape-policy read options matching @ArcadiaTioReadWithShapePolicyOptions@.
data CArcadiaTioReadWithShapePolicyOptions = CArcadiaTioReadWithShapePolicyOptions
  { cShapeReadOptionsVersion :: Word32
  , cShapeReadOptionsStructSize :: CSize
  , cShapeReadOptionsMode :: CArcadiaTioReadExecutionMode
  , cShapeReadOptionsMaxThreads :: CSize
  , cShapeReadOptionsShapePolicy :: CArcadiaTioReadShapePolicyOptions
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioReadWithShapePolicyOptions where
  sizeOf _ = fromIntegral readWithShapePolicyOptionsStructSize
  alignment _ = alignment (undefined :: CSize)
  peek ptr = CArcadiaTioReadWithShapePolicyOptions <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32
  poke ptr CArcadiaTioReadWithShapePolicyOptions{cShapeReadOptionsVersion, cShapeReadOptionsStructSize, cShapeReadOptionsMode, cShapeReadOptionsMaxThreads, cShapeReadOptionsShapePolicy} = do
    pokeByteOff ptr 0 cShapeReadOptionsVersion
    pokeByteOff ptr 8 cShapeReadOptionsStructSize
    pokeByteOff ptr 16 cShapeReadOptionsMode
    pokeByteOff ptr 24 cShapeReadOptionsMaxThreads
    pokeByteOff ptr 32 cShapeReadOptionsShapePolicy

-- | Raw read-execution report matching @ArcadiaTioReadExecutionReport@.
data CArcadiaTioReadExecutionReport = CArcadiaTioReadExecutionReport
  { cReadReportVersion :: Word32
  , cReadReportStructSize :: CSize
  , cReadReportRequestedMode :: CArcadiaTioReadExecutionMode
  , cReadReportQueryMaxThreads :: CSize
  , cReadReportQueryEffectiveMode :: CArcadiaTioReadExecutionMode
  , cReadReportQueryEffectiveThreads :: CSize
  , cReadReportQueryParallelRuntime :: CString
  , cReadReportQueryParallelFallbackReason :: CString
  , cReadReportQueryParallelReasonCode :: CString
  , cReadReportQueryParallelReasonCodeTaxonomy :: CString
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioReadExecutionReport where
  sizeOf _ = fromIntegral readExecutionReportStructSize
  alignment _ = alignment (undefined :: CSize)
  peek ptr =
    CArcadiaTioReadExecutionReport
      <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24
      <*> peekByteOff ptr 32 <*> peekByteOff ptr 40 <*> peekByteOff ptr 48 <*> peekByteOff ptr 56
      <*> peekByteOff ptr 64 <*> peekByteOff ptr 72
  poke ptr CArcadiaTioReadExecutionReport{cReadReportVersion, cReadReportStructSize, cReadReportRequestedMode, cReadReportQueryMaxThreads, cReadReportQueryEffectiveMode, cReadReportQueryEffectiveThreads, cReadReportQueryParallelRuntime, cReadReportQueryParallelFallbackReason, cReadReportQueryParallelReasonCode, cReadReportQueryParallelReasonCodeTaxonomy} = do
    pokeByteOff ptr 0 cReadReportVersion
    pokeByteOff ptr 8 cReadReportStructSize
    pokeByteOff ptr 16 cReadReportRequestedMode
    pokeByteOff ptr 24 cReadReportQueryMaxThreads
    pokeByteOff ptr 32 cReadReportQueryEffectiveMode
    pokeByteOff ptr 40 cReadReportQueryEffectiveThreads
    pokeByteOff ptr 48 cReadReportQueryParallelRuntime
    pokeByteOff ptr 56 cReadReportQueryParallelFallbackReason
    pokeByteOff ptr 64 cReadReportQueryParallelReasonCode
    pokeByteOff ptr 72 cReadReportQueryParallelReasonCodeTaxonomy

emptyCArcadiaTioReadExecutionReport :: CArcadiaTioReadExecutionReport
emptyCArcadiaTioReadExecutionReport =
  CArcadiaTioReadExecutionReport 1 readExecutionReportStructSize 0 0 0 0 nullPtr nullPtr nullPtr nullPtr

-- | Raw query-trace context matching @ArcadiaTioQueryTraceContext@.
data CArcadiaTioQueryTraceContext = CArcadiaTioQueryTraceContext
  { cTraceContextVersion :: Word32
  , cTraceContextStructSize :: CSize
  , cTraceContextRunId :: CString
  , cTraceContextRowId :: CString
  , cTraceContextRepeatIndex :: Word32
  , cTraceContextPhase :: CString
  , cTraceContextLanguage :: CString
  , cTraceContextApiSurface :: CString
  , cTraceContextOperation :: CString
  , cTraceContextTraceClock :: CString
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioQueryTraceContext where
  sizeOf _ = fromIntegral queryTraceContextStructSize
  alignment _ = alignment (undefined :: CSize)
  peek ptr = CArcadiaTioQueryTraceContext <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 40 <*> peekByteOff ptr 48 <*> peekByteOff ptr 56 <*> peekByteOff ptr 64 <*> peekByteOff ptr 72
  poke ptr CArcadiaTioQueryTraceContext{cTraceContextVersion, cTraceContextStructSize, cTraceContextRunId, cTraceContextRowId, cTraceContextRepeatIndex, cTraceContextPhase, cTraceContextLanguage, cTraceContextApiSurface, cTraceContextOperation, cTraceContextTraceClock} = do
    pokeByteOff ptr 0 cTraceContextVersion
    pokeByteOff ptr 8 cTraceContextStructSize
    pokeByteOff ptr 16 cTraceContextRunId
    pokeByteOff ptr 24 cTraceContextRowId
    pokeByteOff ptr 32 cTraceContextRepeatIndex
    pokeByteOff ptr 40 cTraceContextPhase
    pokeByteOff ptr 48 cTraceContextLanguage
    pokeByteOff ptr 56 cTraceContextApiSurface
    pokeByteOff ptr 64 cTraceContextOperation
    pokeByteOff ptr 72 cTraceContextTraceClock

-- | Raw owned query-trace JSON output matching @ArcadiaTioQueryTraceJson@.
data CArcadiaTioQueryTraceJson = CArcadiaTioQueryTraceJson
  { cTraceJsonVersion :: Word32
  , cTraceJsonStructSize :: CSize
  , cTraceJsonJson :: CString
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioQueryTraceJson where
  sizeOf _ = fromIntegral queryTraceJsonStructSize
  alignment _ = alignment (undefined :: CSize)
  peek ptr = CArcadiaTioQueryTraceJson <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16
  poke ptr CArcadiaTioQueryTraceJson{cTraceJsonVersion, cTraceJsonStructSize, cTraceJsonJson} = do
    pokeByteOff ptr 0 cTraceJsonVersion
    pokeByteOff ptr 8 cTraceJsonStructSize
    pokeByteOff ptr 16 cTraceJsonJson

emptyCArcadiaTioQueryTraceJson :: CArcadiaTioQueryTraceJson
emptyCArcadiaTioQueryTraceJson = CArcadiaTioQueryTraceJson 1 queryTraceJsonStructSize nullPtr

-- | Raw read-index item matching @ArcadiaTioReadIndexItem@.
data CArcadiaTioReadIndexItem = CArcadiaTioReadIndexItem
  { cReadIndexItemKind :: CArcadiaTioReadIndexItemTag
  , cReadIndexItemHasStart :: Word8
  , cReadIndexItemStart :: Int64
  , cReadIndexItemHasEnd :: Word8
  , cReadIndexItemEnd :: Int64
  , cReadIndexItemStep :: Int64
  , cReadIndexItemIndex :: Int64
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioReadIndexItem where
  sizeOf _ = 48
  alignment _ = alignment (undefined :: Int64)
  peek ptr = CArcadiaTioReadIndexItem <$> peekByteOff ptr 0 <*> peekByteOff ptr 4 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 40
  poke ptr CArcadiaTioReadIndexItem{cReadIndexItemKind, cReadIndexItemHasStart, cReadIndexItemStart, cReadIndexItemHasEnd, cReadIndexItemEnd, cReadIndexItemStep, cReadIndexItemIndex} = do
    pokeByteOff ptr 0 cReadIndexItemKind
    pokeByteOff ptr 4 cReadIndexItemHasStart
    pokeByteOff ptr 8 cReadIndexItemStart
    pokeByteOff ptr 16 cReadIndexItemHasEnd
    pokeByteOff ptr 24 cReadIndexItemEnd
    pokeByteOff ptr 32 cReadIndexItemStep
    pokeByteOff ptr 40 cReadIndexItemIndex

-- | Raw read-index report matching @ArcadiaTioReadIndexReport@.
data CArcadiaTioReadIndexReport = CArcadiaTioReadIndexReport
  { cReadIndexReportVersion :: Word32
  , cReadIndexReportStructSize :: CSize
  , cReadIndexReportLoweringKind :: CArcadiaTioReadIndexLoweringKind
  , cReadIndexReportUsedFullTensorFallback :: Word8
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioReadIndexReport where
  sizeOf _ = fromIntegral readIndexReportStructSize
  alignment _ = alignment (undefined :: CSize)
  peek ptr = CArcadiaTioReadIndexReport <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 20
  poke ptr CArcadiaTioReadIndexReport{cReadIndexReportVersion, cReadIndexReportStructSize, cReadIndexReportLoweringKind, cReadIndexReportUsedFullTensorFallback} = do
    pokeByteOff ptr 0 cReadIndexReportVersion
    pokeByteOff ptr 8 cReadIndexReportStructSize
    pokeByteOff ptr 16 cReadIndexReportLoweringKind
    pokeByteOff ptr 20 cReadIndexReportUsedFullTensorFallback

emptyCArcadiaTioReadIndexReport :: CArcadiaTioReadIndexReport
emptyCArcadiaTioReadIndexReport = CArcadiaTioReadIndexReport 1 readIndexReportStructSize 0 0

-- | Raw historical read options matching @ArcadiaTioHistoricalReadWithOptionsOptions@.
type CArcadiaTioHistoricalReadWithOptionsOptions = CArcadiaTioReadWithOptionsOptions

-- | Raw historical shape-policy options matching @ArcadiaTioHistoricalReadWithShapePolicyOptions@.
type CArcadiaTioHistoricalReadWithShapePolicyOptions = CArcadiaTioReadWithShapePolicyOptions

-- | Raw historical read-execution report matching @ArcadiaTioHistoricalReadExecutionReport@.
data CArcadiaTioHistoricalReadExecutionReport = CArcadiaTioHistoricalReadExecutionReport
  { cHistoricalReadReportBase :: CArcadiaTioReadExecutionReport
  , cHistoricalReadReportQuerySourceKind :: CArcadiaTioHistoricalQuerySourceKind
  , cHistoricalReadReportQueryCommitSeq :: Word64
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioHistoricalReadExecutionReport where
  sizeOf _ = fromIntegral historicalReadExecutionReportStructSize
  alignment _ = alignment (undefined :: CSize)
  peek ptr = CArcadiaTioHistoricalReadExecutionReport <$> peekByteOff ptr 0 <*> peekByteOff ptr 80 <*> peekByteOff ptr 88
  poke ptr CArcadiaTioHistoricalReadExecutionReport{cHistoricalReadReportBase, cHistoricalReadReportQuerySourceKind, cHistoricalReadReportQueryCommitSeq} = do
    pokeByteOff ptr 0 cHistoricalReadReportBase
    pokeByteOff ptr 80 cHistoricalReadReportQuerySourceKind
    pokeByteOff ptr 88 cHistoricalReadReportQueryCommitSeq

emptyCArcadiaTioHistoricalReadExecutionReport :: CArcadiaTioHistoricalReadExecutionReport
emptyCArcadiaTioHistoricalReadExecutionReport =
  CArcadiaTioHistoricalReadExecutionReport emptyCArcadiaTioReadExecutionReport{cReadReportStructSize = historicalReadExecutionReportStructSize} 0 0

-- | Raw chunk key matching @ArcadiaTioChunkKey@.
data CArcadiaTioChunkKey = CArcadiaTioChunkKey
  { cChunkKeyCoords :: Ptr Word32
  , cChunkKeyLen :: CSize
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioChunkKey where
  sizeOf _ = 16
  alignment _ = alignment (undefined :: Ptr ())
  peek ptr = CArcadiaTioChunkKey <$> peekByteOff ptr 0 <*> peekByteOff ptr 8
  poke ptr CArcadiaTioChunkKey{cChunkKeyCoords, cChunkKeyLen} = do
    pokeByteOff ptr 0 cChunkKeyCoords
    pokeByteOff ptr 8 cChunkKeyLen

-- | Minimal Arrow C Data Interface array. Release callbacks are invoked through
-- 'arrowArrayRelease'.
data CArrowArray = CArrowArray
  { cArrowArrayLength :: Int64
  , cArrowArrayNullCount :: Int64
  , cArrowArrayOffset :: Int64
  , cArrowArrayNBuffers :: Int64
  , cArrowArrayNChildren :: Int64
  , cArrowArrayBuffers :: Ptr ()
  , cArrowArrayChildren :: Ptr ()
  , cArrowArrayDictionary :: Ptr CArrowArray
  , cArrowArrayRelease :: FunPtr ArrowArrayReleaseFn
  , cArrowArrayPrivateData :: Ptr ()
  }
  deriving (Eq, Show)

instance Storable CArrowArray where
  sizeOf _ = 80
  alignment _ = alignment (undefined :: Int64)
  peek ptr = CArrowArray <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 40 <*> peekByteOff ptr 48 <*> peekByteOff ptr 56 <*> peekByteOff ptr 64 <*> peekByteOff ptr 72
  poke ptr CArrowArray{cArrowArrayLength, cArrowArrayNullCount, cArrowArrayOffset, cArrowArrayNBuffers, cArrowArrayNChildren, cArrowArrayBuffers, cArrowArrayChildren, cArrowArrayDictionary, cArrowArrayRelease, cArrowArrayPrivateData} = do
    pokeByteOff ptr 0 cArrowArrayLength
    pokeByteOff ptr 8 cArrowArrayNullCount
    pokeByteOff ptr 16 cArrowArrayOffset
    pokeByteOff ptr 24 cArrowArrayNBuffers
    pokeByteOff ptr 32 cArrowArrayNChildren
    pokeByteOff ptr 40 cArrowArrayBuffers
    pokeByteOff ptr 48 cArrowArrayChildren
    pokeByteOff ptr 56 cArrowArrayDictionary
    pokeByteOff ptr 64 cArrowArrayRelease
    pokeByteOff ptr 72 cArrowArrayPrivateData

emptyCArrowArray :: CArrowArray
emptyCArrowArray = CArrowArray 0 0 0 0 0 nullPtr nullPtr nullPtr nullFunPtr nullPtr

-- | Minimal Arrow C Data Interface schema.
data CArrowSchema = CArrowSchema
  { cArrowSchemaFormat :: CString
  , cArrowSchemaName :: CString
  , cArrowSchemaMetadata :: CString
  , cArrowSchemaFlags :: Int64
  , cArrowSchemaNChildren :: Int64
  , cArrowSchemaChildren :: Ptr ()
  , cArrowSchemaDictionary :: Ptr CArrowSchema
  , cArrowSchemaRelease :: FunPtr ArrowSchemaReleaseFn
  , cArrowSchemaPrivateData :: Ptr ()
  }
  deriving (Eq, Show)

instance Storable CArrowSchema where
  sizeOf _ = 72
  alignment _ = alignment (undefined :: Ptr ())
  peek ptr = CArrowSchema <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 40 <*> peekByteOff ptr 48 <*> peekByteOff ptr 56 <*> peekByteOff ptr 64
  poke ptr CArrowSchema{cArrowSchemaFormat, cArrowSchemaName, cArrowSchemaMetadata, cArrowSchemaFlags, cArrowSchemaNChildren, cArrowSchemaChildren, cArrowSchemaDictionary, cArrowSchemaRelease, cArrowSchemaPrivateData} = do
    pokeByteOff ptr 0 cArrowSchemaFormat
    pokeByteOff ptr 8 cArrowSchemaName
    pokeByteOff ptr 16 cArrowSchemaMetadata
    pokeByteOff ptr 24 cArrowSchemaFlags
    pokeByteOff ptr 32 cArrowSchemaNChildren
    pokeByteOff ptr 40 cArrowSchemaChildren
    pokeByteOff ptr 48 cArrowSchemaDictionary
    pokeByteOff ptr 56 cArrowSchemaRelease
    pokeByteOff ptr 64 cArrowSchemaPrivateData

emptyCArrowSchema :: CArrowSchema
emptyCArrowSchema = CArrowSchema nullPtr nullPtr nullPtr 0 0 nullPtr nullPtr nullFunPtr nullPtr

-- | Raw chunk plan matching @ArcadiaTioChunkPlan@.
data CArcadiaTioChunkPlan = CArcadiaTioChunkPlan
  { cChunkPlanBlockSizes :: Ptr Word32
  , cChunkPlanLen :: CSize
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioChunkPlan where
  sizeOf _ = 16
  alignment _ = alignment (undefined :: Ptr ())
  peek ptr = CArcadiaTioChunkPlan <$> peekByteOff ptr 0 <*> peekByteOff ptr 8
  poke ptr CArcadiaTioChunkPlan{cChunkPlanBlockSizes, cChunkPlanLen} = do
    pokeByteOff ptr 0 cChunkPlanBlockSizes
    pokeByteOff ptr 8 cChunkPlanLen

emptyCArcadiaTioChunkPlan :: CArcadiaTioChunkPlan
emptyCArcadiaTioChunkPlan = CArcadiaTioChunkPlan{cChunkPlanBlockSizes = nullPtr, cChunkPlanLen = 0}

-- | Raw commit info matching @ArcadiaTioCommitInfo@.
data CArcadiaTioCommitInfo = CArcadiaTioCommitInfo
  { cCommitSeq :: Word64
  , cCommitFooterOffset :: Word64
  , cCommitPrevFooterOffset :: Word64
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioCommitInfo where
  sizeOf _ = 24
  alignment _ = alignment (undefined :: Word64)
  peek ptr =
    CArcadiaTioCommitInfo
      <$> peekByteOff ptr 0
      <*> peekByteOff ptr 8
      <*> peekByteOff ptr 16
  poke ptr CArcadiaTioCommitInfo{cCommitSeq, cCommitFooterOffset, cCommitPrevFooterOffset} = do
    pokeByteOff ptr 0 cCommitSeq
    pokeByteOff ptr 8 cCommitFooterOffset
    pokeByteOff ptr 16 cCommitPrevFooterOffset

-- | Raw commit-list output matching @ArcadiaTioCommitList@.
data CArcadiaTioCommitList = CArcadiaTioCommitList
  { cCommitListItems :: Ptr CArcadiaTioCommitInfo
  , cCommitListLen :: CSize
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioCommitList where
  sizeOf _ = 16
  alignment _ = alignment (undefined :: Ptr ())
  peek ptr = CArcadiaTioCommitList <$> peekByteOff ptr 0 <*> peekByteOff ptr 8
  poke ptr CArcadiaTioCommitList{cCommitListItems, cCommitListLen} = do
    pokeByteOff ptr 0 cCommitListItems
    pokeByteOff ptr 8 cCommitListLen

emptyCArcadiaTioCommitList :: CArcadiaTioCommitList
emptyCArcadiaTioCommitList = CArcadiaTioCommitList{cCommitListItems = nullPtr, cCommitListLen = 0}

-- | Raw compaction mode matching @ArcadiaTioCompactionMode@.
data CArcadiaTioCompactionMode = CArcadiaTioCompactionMode
  { cCompactionModeKind :: CInt
  , cCompactionModeReblockEntryBlockSize :: Word32
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioCompactionMode where
  sizeOf _ = 8
  alignment _ = alignment (undefined :: CInt)
  peek ptr = CArcadiaTioCompactionMode <$> peekByteOff ptr 0 <*> peekByteOff ptr 4
  poke ptr CArcadiaTioCompactionMode{cCompactionModeKind, cCompactionModeReblockEntryBlockSize} = do
    pokeByteOff ptr 0 cCompactionModeKind
    pokeByteOff ptr 4 cCompactionModeReblockEntryBlockSize

-- | Raw shallow compaction stats matching @ArcadiaTioCompactionStats@.
data CArcadiaTioCompactionStats = CArcadiaTioCompactionStats
  { cCompactionLiveBytes :: Word64
  , cCompactionDeadBytes :: Word64
  , cCompactionDeadRatio :: Double
  , cCompactionCommitCount :: Word32
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioCompactionStats where
  sizeOf _ = 32
  alignment _ = alignment (undefined :: Word64)
  peek ptr =
    CArcadiaTioCompactionStats
      <$> peekByteOff ptr 0
      <*> peekByteOff ptr 8
      <*> peekByteOff ptr 16
      <*> peekByteOff ptr 24
  poke ptr CArcadiaTioCompactionStats{cCompactionLiveBytes, cCompactionDeadBytes, cCompactionDeadRatio, cCompactionCommitCount} = do
    pokeByteOff ptr 0 cCompactionLiveBytes
    pokeByteOff ptr 8 cCompactionDeadBytes
    pokeByteOff ptr 16 cCompactionDeadRatio
    pokeByteOff ptr 24 cCompactionCommitCount

-- | Raw auto-compaction config matching @ArcadiaTioAutoCompactionConfig@.
data CArcadiaTioAutoCompactionConfig = CArcadiaTioAutoCompactionConfig
  { cAutoCompactionEnabled :: Word8
  , cAutoCompactionRetainCommits :: Word32
  , cAutoCompactionDeadRatioThreshold :: Double
  , cAutoCompactionMinDeadBytes :: Word64
  , cAutoCompactionMode :: CArcadiaTioCompactionMode
  , cAutoCompactionCheckEveryCommits :: Word32
  , cAutoCompactionCooldownCommits :: Word32
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioAutoCompactionConfig where
  sizeOf _ = 40
  alignment _ = alignment (undefined :: Double)
  peek ptr =
    CArcadiaTioAutoCompactionConfig
      <$> peekByteOff ptr 0
      <*> peekByteOff ptr 4
      <*> peekByteOff ptr 8
      <*> peekByteOff ptr 16
      <*> peekByteOff ptr 24
      <*> peekByteOff ptr 32
      <*> peekByteOff ptr 36
  poke ptr CArcadiaTioAutoCompactionConfig{cAutoCompactionEnabled, cAutoCompactionRetainCommits, cAutoCompactionDeadRatioThreshold, cAutoCompactionMinDeadBytes, cAutoCompactionMode, cAutoCompactionCheckEveryCommits, cAutoCompactionCooldownCommits} = do
    pokeByteOff ptr 0 cAutoCompactionEnabled
    pokeByteOff ptr 4 cAutoCompactionRetainCommits
    pokeByteOff ptr 8 cAutoCompactionDeadRatioThreshold
    pokeByteOff ptr 16 cAutoCompactionMinDeadBytes
    pokeByteOff ptr 24 cAutoCompactionMode
    pokeByteOff ptr 32 cAutoCompactionCheckEveryCommits
    pokeByteOff ptr 36 cAutoCompactionCooldownCommits

-- | Raw compaction state matching @ArcadiaTioCompactionState@.
data CArcadiaTioCompactionState = CArcadiaTioCompactionState
  { cCompactionStateLastCompactedCommitSeq :: Word64
  , cCompactionStateLastCompactedAtUnixMs :: Word64
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioCompactionState where
  sizeOf _ = 16
  alignment _ = alignment (undefined :: Word64)
  peek ptr = CArcadiaTioCompactionState <$> peekByteOff ptr 0 <*> peekByteOff ptr 8
  poke ptr CArcadiaTioCompactionState{cCompactionStateLastCompactedCommitSeq, cCompactionStateLastCompactedAtUnixMs} = do
    pokeByteOff ptr 0 cCompactionStateLastCompactedCommitSeq
    pokeByteOff ptr 8 cCompactionStateLastCompactedAtUnixMs


-- | Raw detailed V4 current-head byte family.
data CArcadiaTioV4CurrentHeadBytes = CArcadiaTioV4CurrentHeadBytes
  { cV4CurrentHeadPayloadBytes :: Word64
  , cV4CurrentHeadIndexBytes :: Word64
  , cV4CurrentHeadEpochBytes :: Word64
  , cV4CurrentHeadAuxBytes :: Word64
  , cV4CurrentHeadCommitBytes :: Word64
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioV4CurrentHeadBytes where
  sizeOf _ = 40
  alignment _ = alignment (undefined :: Word64)
  peek ptr = CArcadiaTioV4CurrentHeadBytes <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32
  poke ptr CArcadiaTioV4CurrentHeadBytes{cV4CurrentHeadPayloadBytes, cV4CurrentHeadIndexBytes, cV4CurrentHeadEpochBytes, cV4CurrentHeadAuxBytes, cV4CurrentHeadCommitBytes} = do
    pokeByteOff ptr 0 cV4CurrentHeadPayloadBytes
    pokeByteOff ptr 8 cV4CurrentHeadIndexBytes
    pokeByteOff ptr 16 cV4CurrentHeadEpochBytes
    pokeByteOff ptr 24 cV4CurrentHeadAuxBytes
    pokeByteOff ptr 32 cV4CurrentHeadCommitBytes

-- | Raw detailed V4 visible-chain audit byte family.
data CArcadiaTioV4AuditBytes = CArcadiaTioV4AuditBytes
  { cV4AuditCommitBytes :: Word64
  , cV4AuditIndexBytes :: Word64
  , cV4AuditEpochBytes :: Word64
  , cV4AuditAuxBytes :: Word64
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioV4AuditBytes where
  sizeOf _ = 32
  alignment _ = alignment (undefined :: Word64)
  peek ptr = CArcadiaTioV4AuditBytes <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24
  poke ptr CArcadiaTioV4AuditBytes{cV4AuditCommitBytes, cV4AuditIndexBytes, cV4AuditEpochBytes, cV4AuditAuxBytes} = do
    pokeByteOff ptr 0 cV4AuditCommitBytes
    pokeByteOff ptr 8 cV4AuditIndexBytes
    pokeByteOff ptr 16 cV4AuditEpochBytes
    pokeByteOff ptr 24 cV4AuditAuxBytes

-- | Raw detailed V4 payload-reuse byte family.
data CArcadiaTioV4PayloadReuseBytes = CArcadiaTioV4PayloadReuseBytes
  { cV4PayloadReuseResurrectedPayloadBytes :: Word64
  , cV4PayloadReuseSharedPayloadBytes :: Word64
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioV4PayloadReuseBytes where
  sizeOf _ = 16
  alignment _ = alignment (undefined :: Word64)
  peek ptr = CArcadiaTioV4PayloadReuseBytes <$> peekByteOff ptr 0 <*> peekByteOff ptr 8
  poke ptr CArcadiaTioV4PayloadReuseBytes{cV4PayloadReuseResurrectedPayloadBytes, cV4PayloadReuseSharedPayloadBytes} = do
    pokeByteOff ptr 0 cV4PayloadReuseResurrectedPayloadBytes
    pokeByteOff ptr 8 cV4PayloadReuseSharedPayloadBytes

-- | Raw detailed V4 superseded byte family.
data CArcadiaTioV4SupersededBytes = CArcadiaTioV4SupersededBytes
  { cV4SupersededPayloadBytes :: Word64
  , cV4SupersededIndexBytes :: Word64
  , cV4SupersededEpochBytes :: Word64
  , cV4SupersededAuxBytes :: Word64
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioV4SupersededBytes where
  sizeOf _ = 32
  alignment _ = alignment (undefined :: Word64)
  peek ptr = CArcadiaTioV4SupersededBytes <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24
  poke ptr CArcadiaTioV4SupersededBytes{cV4SupersededPayloadBytes, cV4SupersededIndexBytes, cV4SupersededEpochBytes, cV4SupersededAuxBytes} = do
    pokeByteOff ptr 0 cV4SupersededPayloadBytes
    pokeByteOff ptr 8 cV4SupersededIndexBytes
    pokeByteOff ptr 16 cV4SupersededEpochBytes
    pokeByteOff ptr 24 cV4SupersededAuxBytes

-- | Raw options for precise V4 accounting reports.
data CArcadiaTioV4PreciseAccountingOptions = CArcadiaTioV4PreciseAccountingOptions
  { cV4PreciseAccountingOptionsVersion :: Word32
  , cV4PreciseAccountingOptionsStructSize :: CSize
  , cV4PreciseAccountingOptionsRequestedFieldsMask :: Word32
  , cV4PreciseAccountingOptionsIncludeOmittedFieldReasons :: Word8
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioV4PreciseAccountingOptions where
  sizeOf _ = 24
  alignment _ = alignment (undefined :: CSize)
  peek ptr = CArcadiaTioV4PreciseAccountingOptions <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 20
  poke ptr CArcadiaTioV4PreciseAccountingOptions{cV4PreciseAccountingOptionsVersion, cV4PreciseAccountingOptionsStructSize, cV4PreciseAccountingOptionsRequestedFieldsMask, cV4PreciseAccountingOptionsIncludeOmittedFieldReasons} = do
    fillBytes ptr 0 (sizeOf (undefined :: CArcadiaTioV4PreciseAccountingOptions))
    pokeByteOff ptr 0 cV4PreciseAccountingOptionsVersion
    pokeByteOff ptr 8 cV4PreciseAccountingOptionsStructSize
    pokeByteOff ptr 16 cV4PreciseAccountingOptionsRequestedFieldsMask
    pokeByteOff ptr 20 cV4PreciseAccountingOptionsIncludeOmittedFieldReasons

emptyCArcadiaTioV4PreciseAccountingOptions :: CArcadiaTioV4PreciseAccountingOptions
emptyCArcadiaTioV4PreciseAccountingOptions = CArcadiaTioV4PreciseAccountingOptions 1 24 0 0

-- | Raw omitted precise-accounting field descriptor.
data CArcadiaTioV4OmittedPreciseAccountingField = CArcadiaTioV4OmittedPreciseAccountingField
  { cV4OmittedPreciseAccountingFieldVersion :: Word32
  , cV4OmittedPreciseAccountingFieldStructSize :: CSize
  , cV4OmittedPreciseAccountingFieldField :: CArcadiaTioV4PreciseAccountingField
  , cV4OmittedPreciseAccountingFieldReason :: CString
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioV4OmittedPreciseAccountingField where
  sizeOf _ = 32
  alignment _ = alignment (undefined :: CSize)
  peek ptr = CArcadiaTioV4OmittedPreciseAccountingField <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24
  poke ptr CArcadiaTioV4OmittedPreciseAccountingField{cV4OmittedPreciseAccountingFieldVersion, cV4OmittedPreciseAccountingFieldStructSize, cV4OmittedPreciseAccountingFieldField, cV4OmittedPreciseAccountingFieldReason} = do
    pokeByteOff ptr 0 cV4OmittedPreciseAccountingFieldVersion
    pokeByteOff ptr 8 cV4OmittedPreciseAccountingFieldStructSize
    pokeByteOff ptr 16 cV4OmittedPreciseAccountingFieldField
    pokeByteOff ptr 24 cV4OmittedPreciseAccountingFieldReason

-- | Raw precise-accounting byte family with report-owned nested arrays.
data CArcadiaTioV4PreciseAccountingBytes = CArcadiaTioV4PreciseAccountingBytes
  { cV4PreciseAccountingBytesVersion :: Word32
  , cV4PreciseAccountingBytesStructSize :: CSize
  , cV4PreciseAccountingHasUnreachableBytes :: Word8
  , cV4PreciseAccountingUnreachableBytes :: Word64
  , cV4PreciseAccountingHasRetainedHistoryRequiredBytes :: Word8
  , cV4PreciseAccountingRetainedHistoryRequiredBytes :: Word64
  , cV4PreciseAccountingHasPoppedSkippedBytes :: Word8
  , cV4PreciseAccountingPoppedSkippedBytes :: Word64
  , cV4PreciseAccountingHasReclaimableBytes :: Word8
  , cV4PreciseAccountingReclaimableBytes :: Word64
  , cV4PreciseAccountingOmittedFields :: Ptr CArcadiaTioV4OmittedPreciseAccountingField
  , cV4PreciseAccountingOmittedFieldsLen :: CSize
  , cV4PreciseAccountingOmittedFieldReasonCodes :: Ptr CString
  , cV4PreciseAccountingOmittedFieldReasonCodesLen :: CSize
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioV4PreciseAccountingBytes where
  sizeOf _ = 112
  alignment _ = alignment (undefined :: CSize)
  peek ptr = CArcadiaTioV4PreciseAccountingBytes <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 40 <*> peekByteOff ptr 48 <*> peekByteOff ptr 56 <*> peekByteOff ptr 64 <*> peekByteOff ptr 72 <*> peekByteOff ptr 80 <*> peekByteOff ptr 88 <*> peekByteOff ptr 96 <*> peekByteOff ptr 104
  poke ptr CArcadiaTioV4PreciseAccountingBytes{cV4PreciseAccountingBytesVersion, cV4PreciseAccountingBytesStructSize, cV4PreciseAccountingHasUnreachableBytes, cV4PreciseAccountingUnreachableBytes, cV4PreciseAccountingHasRetainedHistoryRequiredBytes, cV4PreciseAccountingRetainedHistoryRequiredBytes, cV4PreciseAccountingHasPoppedSkippedBytes, cV4PreciseAccountingPoppedSkippedBytes, cV4PreciseAccountingHasReclaimableBytes, cV4PreciseAccountingReclaimableBytes, cV4PreciseAccountingOmittedFields, cV4PreciseAccountingOmittedFieldsLen, cV4PreciseAccountingOmittedFieldReasonCodes, cV4PreciseAccountingOmittedFieldReasonCodesLen} = do
    pokeByteOff ptr 0 cV4PreciseAccountingBytesVersion
    pokeByteOff ptr 8 cV4PreciseAccountingBytesStructSize
    pokeByteOff ptr 16 cV4PreciseAccountingHasUnreachableBytes
    pokeByteOff ptr 24 cV4PreciseAccountingUnreachableBytes
    pokeByteOff ptr 32 cV4PreciseAccountingHasRetainedHistoryRequiredBytes
    pokeByteOff ptr 40 cV4PreciseAccountingRetainedHistoryRequiredBytes
    pokeByteOff ptr 48 cV4PreciseAccountingHasPoppedSkippedBytes
    pokeByteOff ptr 56 cV4PreciseAccountingPoppedSkippedBytes
    pokeByteOff ptr 64 cV4PreciseAccountingHasReclaimableBytes
    pokeByteOff ptr 72 cV4PreciseAccountingReclaimableBytes
    pokeByteOff ptr 80 cV4PreciseAccountingOmittedFields
    pokeByteOff ptr 88 cV4PreciseAccountingOmittedFieldsLen
    pokeByteOff ptr 96 cV4PreciseAccountingOmittedFieldReasonCodes
    pokeByteOff ptr 104 cV4PreciseAccountingOmittedFieldReasonCodesLen

emptyCArcadiaTioV4PreciseAccountingBytes :: CArcadiaTioV4PreciseAccountingBytes
emptyCArcadiaTioV4PreciseAccountingBytes = CArcadiaTioV4PreciseAccountingBytes 1 112 0 0 0 0 0 0 0 0 nullPtr 0 nullPtr 0

-- | Raw detailed V4 diagnostics report.
data CArcadiaTioV4DiagnosticsReport = CArcadiaTioV4DiagnosticsReport
  { cV4DiagnosticsReportVersion :: Word32
  , cV4DiagnosticsReportStructSize :: CSize
  , cV4DiagnosticsReportStatus :: CArcadiaTioV4ReportStatus
  , cV4DiagnosticsReportReason :: CString
  , cV4DiagnosticsReportCurrentHead :: CArcadiaTioV4CurrentHeadBytes
  , cV4DiagnosticsReportVisibleChainAudit :: CArcadiaTioV4AuditBytes
  , cV4DiagnosticsReportPayloadReuse :: CArcadiaTioV4PayloadReuseBytes
  , cV4DiagnosticsReportSuperseded :: CArcadiaTioV4SupersededBytes
  , cV4DiagnosticsReportUnknownBytes :: Word64
  , cV4DiagnosticsReportOmittedUnreachableBytes :: Word8
  , cV4DiagnosticsReportOmittedUnreachableBytesReason :: CString
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioV4DiagnosticsReport where
  sizeOf _ = 176
  alignment _ = alignment (undefined :: CSize)
  peek ptr = CArcadiaTioV4DiagnosticsReport <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 72 <*> peekByteOff ptr 104 <*> peekByteOff ptr 120 <*> peekByteOff ptr 152 <*> peekByteOff ptr 160 <*> peekByteOff ptr 168
  poke ptr CArcadiaTioV4DiagnosticsReport{cV4DiagnosticsReportVersion, cV4DiagnosticsReportStructSize, cV4DiagnosticsReportStatus, cV4DiagnosticsReportReason, cV4DiagnosticsReportCurrentHead, cV4DiagnosticsReportVisibleChainAudit, cV4DiagnosticsReportPayloadReuse, cV4DiagnosticsReportSuperseded, cV4DiagnosticsReportUnknownBytes, cV4DiagnosticsReportOmittedUnreachableBytes, cV4DiagnosticsReportOmittedUnreachableBytesReason} = do
    fillBytes ptr 0 (sizeOf (undefined :: CArcadiaTioV4DiagnosticsReport))
    pokeByteOff ptr 0 cV4DiagnosticsReportVersion
    pokeByteOff ptr 8 cV4DiagnosticsReportStructSize
    pokeByteOff ptr 16 cV4DiagnosticsReportStatus
    pokeByteOff ptr 24 cV4DiagnosticsReportReason
    pokeByteOff ptr 32 cV4DiagnosticsReportCurrentHead
    pokeByteOff ptr 72 cV4DiagnosticsReportVisibleChainAudit
    pokeByteOff ptr 104 cV4DiagnosticsReportPayloadReuse
    pokeByteOff ptr 120 cV4DiagnosticsReportSuperseded
    pokeByteOff ptr 152 cV4DiagnosticsReportUnknownBytes
    pokeByteOff ptr 160 cV4DiagnosticsReportOmittedUnreachableBytes
    pokeByteOff ptr 168 cV4DiagnosticsReportOmittedUnreachableBytesReason

emptyCArcadiaTioV4DiagnosticsReport :: CArcadiaTioV4DiagnosticsReport
emptyCArcadiaTioV4DiagnosticsReport = CArcadiaTioV4DiagnosticsReport 1 176 0 nullPtr (CArcadiaTioV4CurrentHeadBytes 0 0 0 0 0) (CArcadiaTioV4AuditBytes 0 0 0 0) (CArcadiaTioV4PayloadReuseBytes 0 0) (CArcadiaTioV4SupersededBytes 0 0 0 0) 0 0 nullPtr

-- | Raw detailed V4 diagnostics report with precise accounting.
data CArcadiaTioV4DiagnosticsPreciseReport = CArcadiaTioV4DiagnosticsPreciseReport
  { cV4DiagnosticsPreciseReportVersion :: Word32
  , cV4DiagnosticsPreciseReportStructSize :: CSize
  , cV4DiagnosticsPreciseReportStatus :: CArcadiaTioV4ReportStatus
  , cV4DiagnosticsPreciseReportReason :: CString
  , cV4DiagnosticsPreciseReportCurrentHead :: CArcadiaTioV4CurrentHeadBytes
  , cV4DiagnosticsPreciseReportVisibleChainAudit :: CArcadiaTioV4AuditBytes
  , cV4DiagnosticsPreciseReportPayloadReuse :: CArcadiaTioV4PayloadReuseBytes
  , cV4DiagnosticsPreciseReportSuperseded :: CArcadiaTioV4SupersededBytes
  , cV4DiagnosticsPreciseReportUnknownBytes :: Word64
  , cV4DiagnosticsPreciseReportPreciseAccounting :: CArcadiaTioV4PreciseAccountingBytes
  , cV4DiagnosticsPreciseReportReasonCode :: CString
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioV4DiagnosticsPreciseReport where
  sizeOf _ = 280
  alignment _ = alignment (undefined :: CSize)
  peek ptr = CArcadiaTioV4DiagnosticsPreciseReport <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 72 <*> peekByteOff ptr 104 <*> peekByteOff ptr 120 <*> peekByteOff ptr 152 <*> peekByteOff ptr 160 <*> peekByteOff ptr 272
  poke ptr CArcadiaTioV4DiagnosticsPreciseReport{cV4DiagnosticsPreciseReportVersion, cV4DiagnosticsPreciseReportStructSize, cV4DiagnosticsPreciseReportStatus, cV4DiagnosticsPreciseReportReason, cV4DiagnosticsPreciseReportCurrentHead, cV4DiagnosticsPreciseReportVisibleChainAudit, cV4DiagnosticsPreciseReportPayloadReuse, cV4DiagnosticsPreciseReportSuperseded, cV4DiagnosticsPreciseReportUnknownBytes, cV4DiagnosticsPreciseReportPreciseAccounting, cV4DiagnosticsPreciseReportReasonCode} = do
    fillBytes ptr 0 (sizeOf (undefined :: CArcadiaTioV4DiagnosticsPreciseReport))
    pokeByteOff ptr 0 cV4DiagnosticsPreciseReportVersion
    pokeByteOff ptr 8 cV4DiagnosticsPreciseReportStructSize
    pokeByteOff ptr 16 cV4DiagnosticsPreciseReportStatus
    pokeByteOff ptr 24 cV4DiagnosticsPreciseReportReason
    pokeByteOff ptr 32 cV4DiagnosticsPreciseReportCurrentHead
    pokeByteOff ptr 72 cV4DiagnosticsPreciseReportVisibleChainAudit
    pokeByteOff ptr 104 cV4DiagnosticsPreciseReportPayloadReuse
    pokeByteOff ptr 120 cV4DiagnosticsPreciseReportSuperseded
    pokeByteOff ptr 152 cV4DiagnosticsPreciseReportUnknownBytes
    pokeByteOff ptr 160 cV4DiagnosticsPreciseReportPreciseAccounting
    pokeByteOff ptr 272 cV4DiagnosticsPreciseReportReasonCode

emptyCArcadiaTioV4DiagnosticsPreciseReport :: CArcadiaTioV4DiagnosticsPreciseReport
emptyCArcadiaTioV4DiagnosticsPreciseReport = CArcadiaTioV4DiagnosticsPreciseReport 1 280 0 nullPtr (CArcadiaTioV4CurrentHeadBytes 0 0 0 0 0) (CArcadiaTioV4AuditBytes 0 0 0 0) (CArcadiaTioV4PayloadReuseBytes 0 0) (CArcadiaTioV4SupersededBytes 0 0 0 0) 0 emptyCArcadiaTioV4PreciseAccountingBytes nullPtr


-- | Raw status-aware V4 ordinary current-state compaction analysis report.
data CArcadiaTioV4CompactionAnalysisReport = CArcadiaTioV4CompactionAnalysisReport
  { cV4CompactionAnalysisReportVersion :: Word32
  , cV4CompactionAnalysisReportStructSize :: CSize
  , cV4CompactionAnalysisReportStatus :: CArcadiaTioV4ReportStatus
  , cV4CompactionAnalysisReportReason :: CString
  , cV4CompactionAnalysisReportPolicy :: CArcadiaTioV4CompactionAnalysisPolicy
  , cV4CompactionAnalysisReportSourceFileBytes :: Word64
  , cV4CompactionAnalysisReportCurrentStateRequiredBytes :: Word64
  , cV4CompactionAnalysisReportOrdinaryReclaimableBytes :: Word64
  , cV4CompactionAnalysisReportUnknownBytes :: Word64
  , cV4CompactionAnalysisReportOmittedUnreachableBytes :: Word8
  , cV4CompactionAnalysisReportOmittedUnreachableBytesReason :: CString
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioV4CompactionAnalysisReport where
  sizeOf _ = 88
  alignment _ = alignment (undefined :: CSize)
  peek ptr = CArcadiaTioV4CompactionAnalysisReport <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 40 <*> peekByteOff ptr 48 <*> peekByteOff ptr 56 <*> peekByteOff ptr 64 <*> peekByteOff ptr 72 <*> peekByteOff ptr 80
  poke ptr CArcadiaTioV4CompactionAnalysisReport{cV4CompactionAnalysisReportVersion, cV4CompactionAnalysisReportStructSize, cV4CompactionAnalysisReportStatus, cV4CompactionAnalysisReportReason, cV4CompactionAnalysisReportPolicy, cV4CompactionAnalysisReportSourceFileBytes, cV4CompactionAnalysisReportCurrentStateRequiredBytes, cV4CompactionAnalysisReportOrdinaryReclaimableBytes, cV4CompactionAnalysisReportUnknownBytes, cV4CompactionAnalysisReportOmittedUnreachableBytes, cV4CompactionAnalysisReportOmittedUnreachableBytesReason} = do
    fillBytes ptr 0 (sizeOf (undefined :: CArcadiaTioV4CompactionAnalysisReport))
    pokeByteOff ptr 0 cV4CompactionAnalysisReportVersion
    pokeByteOff ptr 8 cV4CompactionAnalysisReportStructSize
    pokeByteOff ptr 16 cV4CompactionAnalysisReportStatus
    pokeByteOff ptr 24 cV4CompactionAnalysisReportReason
    pokeByteOff ptr 32 cV4CompactionAnalysisReportPolicy
    pokeByteOff ptr 40 cV4CompactionAnalysisReportSourceFileBytes
    pokeByteOff ptr 48 cV4CompactionAnalysisReportCurrentStateRequiredBytes
    pokeByteOff ptr 56 cV4CompactionAnalysisReportOrdinaryReclaimableBytes
    pokeByteOff ptr 64 cV4CompactionAnalysisReportUnknownBytes
    pokeByteOff ptr 72 cV4CompactionAnalysisReportOmittedUnreachableBytes
    pokeByteOff ptr 80 cV4CompactionAnalysisReportOmittedUnreachableBytesReason

emptyCArcadiaTioV4CompactionAnalysisReport :: CArcadiaTioV4CompactionAnalysisReport
emptyCArcadiaTioV4CompactionAnalysisReport = CArcadiaTioV4CompactionAnalysisReport 1 88 0 nullPtr 0 0 0 0 0 0 nullPtr

-- | Raw status-aware V4 ordinary current-state compaction analysis report with precise accounting.
data CArcadiaTioV4CompactionAnalysisPreciseReport = CArcadiaTioV4CompactionAnalysisPreciseReport
  { cV4CompactionAnalysisPreciseReportVersion :: Word32
  , cV4CompactionAnalysisPreciseReportStructSize :: CSize
  , cV4CompactionAnalysisPreciseReportStatus :: CArcadiaTioV4ReportStatus
  , cV4CompactionAnalysisPreciseReportReason :: CString
  , cV4CompactionAnalysisPreciseReportPolicy :: CArcadiaTioV4CompactionAnalysisPolicy
  , cV4CompactionAnalysisPreciseReportSourceFileBytes :: Word64
  , cV4CompactionAnalysisPreciseReportCurrentStateRequiredBytes :: Word64
  , cV4CompactionAnalysisPreciseReportOrdinaryReclaimableBytes :: Word64
  , cV4CompactionAnalysisPreciseReportUnknownBytes :: Word64
  , cV4CompactionAnalysisPreciseReportPreciseAccounting :: CArcadiaTioV4PreciseAccountingBytes
  , cV4CompactionAnalysisPreciseReportReasonCode :: CString
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioV4CompactionAnalysisPreciseReport where
  sizeOf _ = 192
  alignment _ = alignment (undefined :: CSize)
  peek ptr = CArcadiaTioV4CompactionAnalysisPreciseReport <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 40 <*> peekByteOff ptr 48 <*> peekByteOff ptr 56 <*> peekByteOff ptr 64 <*> peekByteOff ptr 72 <*> peekByteOff ptr 184
  poke ptr CArcadiaTioV4CompactionAnalysisPreciseReport{cV4CompactionAnalysisPreciseReportVersion, cV4CompactionAnalysisPreciseReportStructSize, cV4CompactionAnalysisPreciseReportStatus, cV4CompactionAnalysisPreciseReportReason, cV4CompactionAnalysisPreciseReportPolicy, cV4CompactionAnalysisPreciseReportSourceFileBytes, cV4CompactionAnalysisPreciseReportCurrentStateRequiredBytes, cV4CompactionAnalysisPreciseReportOrdinaryReclaimableBytes, cV4CompactionAnalysisPreciseReportUnknownBytes, cV4CompactionAnalysisPreciseReportPreciseAccounting, cV4CompactionAnalysisPreciseReportReasonCode} = do
    fillBytes ptr 0 (sizeOf (undefined :: CArcadiaTioV4CompactionAnalysisPreciseReport))
    pokeByteOff ptr 0 cV4CompactionAnalysisPreciseReportVersion
    pokeByteOff ptr 8 cV4CompactionAnalysisPreciseReportStructSize
    pokeByteOff ptr 16 cV4CompactionAnalysisPreciseReportStatus
    pokeByteOff ptr 24 cV4CompactionAnalysisPreciseReportReason
    pokeByteOff ptr 32 cV4CompactionAnalysisPreciseReportPolicy
    pokeByteOff ptr 40 cV4CompactionAnalysisPreciseReportSourceFileBytes
    pokeByteOff ptr 48 cV4CompactionAnalysisPreciseReportCurrentStateRequiredBytes
    pokeByteOff ptr 56 cV4CompactionAnalysisPreciseReportOrdinaryReclaimableBytes
    pokeByteOff ptr 64 cV4CompactionAnalysisPreciseReportUnknownBytes
    pokeByteOff ptr 72 cV4CompactionAnalysisPreciseReportPreciseAccounting
    pokeByteOff ptr 184 cV4CompactionAnalysisPreciseReportReasonCode

emptyCArcadiaTioV4CompactionAnalysisPreciseReport :: CArcadiaTioV4CompactionAnalysisPreciseReport
emptyCArcadiaTioV4CompactionAnalysisPreciseReport = CArcadiaTioV4CompactionAnalysisPreciseReport 1 192 0 nullPtr 0 0 0 0 0 emptyCArcadiaTioV4PreciseAccountingBytes nullPtr

-- | Raw retained-history compaction options.
data CArcadiaTioV4RetainedHistoryCompactionOptions = CArcadiaTioV4RetainedHistoryCompactionOptions
  { cV4RetainedHistoryCompactionOptionsVersion :: Word32
  , cV4RetainedHistoryCompactionOptionsStructSize :: CSize
  , cV4RetainedHistoryCompactionOptionsPolicy :: CArcadiaTioV4RetainedHistoryPolicy
  , cV4RetainedHistoryCompactionOptionsRetainLastN :: Word32
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioV4RetainedHistoryCompactionOptions where
  sizeOf _ = 24
  alignment _ = alignment (undefined :: CSize)
  peek ptr = CArcadiaTioV4RetainedHistoryCompactionOptions <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 20
  poke ptr CArcadiaTioV4RetainedHistoryCompactionOptions{cV4RetainedHistoryCompactionOptionsVersion, cV4RetainedHistoryCompactionOptionsStructSize, cV4RetainedHistoryCompactionOptionsPolicy, cV4RetainedHistoryCompactionOptionsRetainLastN} = do
    fillBytes ptr 0 (sizeOf (undefined :: CArcadiaTioV4RetainedHistoryCompactionOptions))
    pokeByteOff ptr 0 cV4RetainedHistoryCompactionOptionsVersion
    pokeByteOff ptr 8 cV4RetainedHistoryCompactionOptionsStructSize
    pokeByteOff ptr 16 cV4RetainedHistoryCompactionOptionsPolicy
    pokeByteOff ptr 20 cV4RetainedHistoryCompactionOptionsRetainLastN

emptyCArcadiaTioV4RetainedHistoryCompactionOptions :: CArcadiaTioV4RetainedHistoryCompactionOptions
emptyCArcadiaTioV4RetainedHistoryCompactionOptions = CArcadiaTioV4RetainedHistoryCompactionOptions 1 24 0 0

-- | Raw retained-history compaction report.
data CArcadiaTioV4RetainedHistoryCompactionReport = CArcadiaTioV4RetainedHistoryCompactionReport
  { cV4RetainedHistoryCompactionReportVersion :: Word32
  , cV4RetainedHistoryCompactionReportStructSize :: CSize
  , cV4RetainedHistoryCompactionReportStatus :: CArcadiaTioV4ReportStatus
  , cV4RetainedHistoryCompactionReportReason :: CString
  , cV4RetainedHistoryCompactionReportRetainedCommitCount :: Word32
  , cV4RetainedHistoryCompactionReportRetainedCommitSeqs :: Ptr Word64
  , cV4RetainedHistoryCompactionReportRetainedCommitSeqsLen :: CSize
  , cV4RetainedHistoryCompactionReportHasUnretainedOlderCommitCount :: Word8
  , cV4RetainedHistoryCompactionReportUnretainedOlderCommitCount :: Word64
  , cV4RetainedHistoryCompactionReportSourceFileBytes :: Word64
  , cV4RetainedHistoryCompactionReportDestinationFileBytes :: Word64
  , cV4RetainedHistoryCompactionReportOmittedUnreachableBytes :: Word8
  , cV4RetainedHistoryCompactionReportOmittedUnreachableBytesReason :: CString
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioV4RetainedHistoryCompactionReport where
  sizeOf _ = 104
  alignment _ = alignment (undefined :: CSize)
  peek ptr = CArcadiaTioV4RetainedHistoryCompactionReport <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 40 <*> peekByteOff ptr 48 <*> peekByteOff ptr 56 <*> peekByteOff ptr 64 <*> peekByteOff ptr 72 <*> peekByteOff ptr 80 <*> peekByteOff ptr 88 <*> peekByteOff ptr 96
  poke ptr CArcadiaTioV4RetainedHistoryCompactionReport{cV4RetainedHistoryCompactionReportVersion, cV4RetainedHistoryCompactionReportStructSize, cV4RetainedHistoryCompactionReportStatus, cV4RetainedHistoryCompactionReportReason, cV4RetainedHistoryCompactionReportRetainedCommitCount, cV4RetainedHistoryCompactionReportRetainedCommitSeqs, cV4RetainedHistoryCompactionReportRetainedCommitSeqsLen, cV4RetainedHistoryCompactionReportHasUnretainedOlderCommitCount, cV4RetainedHistoryCompactionReportUnretainedOlderCommitCount, cV4RetainedHistoryCompactionReportSourceFileBytes, cV4RetainedHistoryCompactionReportDestinationFileBytes, cV4RetainedHistoryCompactionReportOmittedUnreachableBytes, cV4RetainedHistoryCompactionReportOmittedUnreachableBytesReason} = do
    fillBytes ptr 0 (sizeOf (undefined :: CArcadiaTioV4RetainedHistoryCompactionReport))
    pokeByteOff ptr 0 cV4RetainedHistoryCompactionReportVersion
    pokeByteOff ptr 8 cV4RetainedHistoryCompactionReportStructSize
    pokeByteOff ptr 16 cV4RetainedHistoryCompactionReportStatus
    pokeByteOff ptr 24 cV4RetainedHistoryCompactionReportReason
    pokeByteOff ptr 32 cV4RetainedHistoryCompactionReportRetainedCommitCount
    pokeByteOff ptr 40 cV4RetainedHistoryCompactionReportRetainedCommitSeqs
    pokeByteOff ptr 48 cV4RetainedHistoryCompactionReportRetainedCommitSeqsLen
    pokeByteOff ptr 56 cV4RetainedHistoryCompactionReportHasUnretainedOlderCommitCount
    pokeByteOff ptr 64 cV4RetainedHistoryCompactionReportUnretainedOlderCommitCount
    pokeByteOff ptr 72 cV4RetainedHistoryCompactionReportSourceFileBytes
    pokeByteOff ptr 80 cV4RetainedHistoryCompactionReportDestinationFileBytes
    pokeByteOff ptr 88 cV4RetainedHistoryCompactionReportOmittedUnreachableBytes
    pokeByteOff ptr 96 cV4RetainedHistoryCompactionReportOmittedUnreachableBytesReason

emptyCArcadiaTioV4RetainedHistoryCompactionReport :: CArcadiaTioV4RetainedHistoryCompactionReport
emptyCArcadiaTioV4RetainedHistoryCompactionReport = CArcadiaTioV4RetainedHistoryCompactionReport 1 104 0 nullPtr 0 nullPtr 0 0 0 0 0 0 nullPtr

-- | Raw retained-history compaction report with source precise accounting.
data CArcadiaTioV4RetainedHistoryCompactionPreciseReport = CArcadiaTioV4RetainedHistoryCompactionPreciseReport
  { cV4RetainedHistoryCompactionPreciseReportVersion :: Word32
  , cV4RetainedHistoryCompactionPreciseReportStructSize :: CSize
  , cV4RetainedHistoryCompactionPreciseReportStatus :: CArcadiaTioV4ReportStatus
  , cV4RetainedHistoryCompactionPreciseReportReason :: CString
  , cV4RetainedHistoryCompactionPreciseReportRetainedCommitCount :: Word32
  , cV4RetainedHistoryCompactionPreciseReportRetainedCommitSeqs :: Ptr Word64
  , cV4RetainedHistoryCompactionPreciseReportRetainedCommitSeqsLen :: CSize
  , cV4RetainedHistoryCompactionPreciseReportHasUnretainedOlderCommitCount :: Word8
  , cV4RetainedHistoryCompactionPreciseReportUnretainedOlderCommitCount :: Word64
  , cV4RetainedHistoryCompactionPreciseReportSourceFileBytes :: Word64
  , cV4RetainedHistoryCompactionPreciseReportDestinationFileBytes :: Word64
  , cV4RetainedHistoryCompactionPreciseReportPreciseSourceAccounting :: CArcadiaTioV4PreciseAccountingBytes
  , cV4RetainedHistoryCompactionPreciseReportReasonCode :: CString
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioV4RetainedHistoryCompactionPreciseReport where
  sizeOf _ = 208
  alignment _ = alignment (undefined :: CSize)
  peek ptr = CArcadiaTioV4RetainedHistoryCompactionPreciseReport <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 40 <*> peekByteOff ptr 48 <*> peekByteOff ptr 56 <*> peekByteOff ptr 64 <*> peekByteOff ptr 72 <*> peekByteOff ptr 80 <*> peekByteOff ptr 88 <*> peekByteOff ptr 200
  poke ptr CArcadiaTioV4RetainedHistoryCompactionPreciseReport{cV4RetainedHistoryCompactionPreciseReportVersion, cV4RetainedHistoryCompactionPreciseReportStructSize, cV4RetainedHistoryCompactionPreciseReportStatus, cV4RetainedHistoryCompactionPreciseReportReason, cV4RetainedHistoryCompactionPreciseReportRetainedCommitCount, cV4RetainedHistoryCompactionPreciseReportRetainedCommitSeqs, cV4RetainedHistoryCompactionPreciseReportRetainedCommitSeqsLen, cV4RetainedHistoryCompactionPreciseReportHasUnretainedOlderCommitCount, cV4RetainedHistoryCompactionPreciseReportUnretainedOlderCommitCount, cV4RetainedHistoryCompactionPreciseReportSourceFileBytes, cV4RetainedHistoryCompactionPreciseReportDestinationFileBytes, cV4RetainedHistoryCompactionPreciseReportPreciseSourceAccounting, cV4RetainedHistoryCompactionPreciseReportReasonCode} = do
    fillBytes ptr 0 (sizeOf (undefined :: CArcadiaTioV4RetainedHistoryCompactionPreciseReport))
    pokeByteOff ptr 0 cV4RetainedHistoryCompactionPreciseReportVersion
    pokeByteOff ptr 8 cV4RetainedHistoryCompactionPreciseReportStructSize
    pokeByteOff ptr 16 cV4RetainedHistoryCompactionPreciseReportStatus
    pokeByteOff ptr 24 cV4RetainedHistoryCompactionPreciseReportReason
    pokeByteOff ptr 32 cV4RetainedHistoryCompactionPreciseReportRetainedCommitCount
    pokeByteOff ptr 40 cV4RetainedHistoryCompactionPreciseReportRetainedCommitSeqs
    pokeByteOff ptr 48 cV4RetainedHistoryCompactionPreciseReportRetainedCommitSeqsLen
    pokeByteOff ptr 56 cV4RetainedHistoryCompactionPreciseReportHasUnretainedOlderCommitCount
    pokeByteOff ptr 64 cV4RetainedHistoryCompactionPreciseReportUnretainedOlderCommitCount
    pokeByteOff ptr 72 cV4RetainedHistoryCompactionPreciseReportSourceFileBytes
    pokeByteOff ptr 80 cV4RetainedHistoryCompactionPreciseReportDestinationFileBytes
    pokeByteOff ptr 88 cV4RetainedHistoryCompactionPreciseReportPreciseSourceAccounting
    pokeByteOff ptr 200 cV4RetainedHistoryCompactionPreciseReportReasonCode

emptyCArcadiaTioV4RetainedHistoryCompactionPreciseReport :: CArcadiaTioV4RetainedHistoryCompactionPreciseReport
emptyCArcadiaTioV4RetainedHistoryCompactionPreciseReport = CArcadiaTioV4RetainedHistoryCompactionPreciseReport 1 208 0 nullPtr 0 nullPtr 0 0 0 0 0 emptyCArcadiaTioV4PreciseAccountingBytes nullPtr


-- | Raw reform options.
data CArcadiaTioReformOptions = CArcadiaTioReformOptions
  { cReformOptionsVersion :: Word32
  , cReformOptionsStructSize :: CSize
  , cReformOptionsTargetLayout :: CArcadiaTioReformTargetLayout
  , cReformOptionsRegularChunkedBlockShape :: Ptr Word32
  , cReformOptionsRegularChunkedBlockShapeLen :: CSize
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioReformOptions where
  sizeOf _ = 40
  alignment _ = alignment (undefined :: CSize)
  peek ptr = CArcadiaTioReformOptions <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32
  poke ptr CArcadiaTioReformOptions{cReformOptionsVersion, cReformOptionsStructSize, cReformOptionsTargetLayout, cReformOptionsRegularChunkedBlockShape, cReformOptionsRegularChunkedBlockShapeLen} = do
    fillBytes ptr 0 (sizeOf (undefined :: CArcadiaTioReformOptions))
    pokeByteOff ptr 0 cReformOptionsVersion
    pokeByteOff ptr 8 cReformOptionsStructSize
    pokeByteOff ptr 16 cReformOptionsTargetLayout
    pokeByteOff ptr 24 cReformOptionsRegularChunkedBlockShape
    pokeByteOff ptr 32 cReformOptionsRegularChunkedBlockShapeLen

emptyCArcadiaTioReformOptions :: CArcadiaTioReformOptions
emptyCArcadiaTioReformOptions = CArcadiaTioReformOptions 1 40 0 nullPtr 0

-- | Raw reform diagnostic report.
data CArcadiaTioReformReport = CArcadiaTioReformReport
  { cReformReportVersion :: Word32
  , cReformReportStructSize :: CSize
  , cReformReportReasonCode :: CString
  , cReformReportReasonCodeTaxonomy :: CString
  , cReformReportReason :: CString
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioReformReport where
  sizeOf _ = 40
  alignment _ = alignment (undefined :: CSize)
  peek ptr = CArcadiaTioReformReport <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32
  poke ptr CArcadiaTioReformReport{cReformReportVersion, cReformReportStructSize, cReformReportReasonCode, cReformReportReasonCodeTaxonomy, cReformReportReason} = do
    fillBytes ptr 0 (sizeOf (undefined :: CArcadiaTioReformReport))
    pokeByteOff ptr 0 cReformReportVersion
    pokeByteOff ptr 8 cReformReportStructSize
    pokeByteOff ptr 16 cReformReportReasonCode
    pokeByteOff ptr 24 cReformReportReasonCodeTaxonomy
    pokeByteOff ptr 32 cReformReportReason

emptyCArcadiaTioReformReport :: CArcadiaTioReformReport
emptyCArcadiaTioReformReport = CArcadiaTioReformReport 1 40 nullPtr nullPtr nullPtr

-- | Raw sparse predicate matching @ArcadiaTioSparseValuePredicateV2@.
data CArcadiaTioSparseValuePredicateV2 = CArcadiaTioSparseValuePredicateV2
  { cSparsePredicateKind :: CInt
  , cSparsePredicateFloatValue :: Double
  , cSparsePredicateIntegerValue :: Int64
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioSparseValuePredicateV2 where
  sizeOf _ = 24
  alignment _ = alignment (undefined :: Double)
  peek ptr =
    CArcadiaTioSparseValuePredicateV2
      <$> peekByteOff ptr 0
      <*> peekByteOff ptr 8
      <*> peekByteOff ptr 16
  poke ptr CArcadiaTioSparseValuePredicateV2{cSparsePredicateKind, cSparsePredicateFloatValue, cSparsePredicateIntegerValue} = do
    pokeByteOff ptr 0 cSparsePredicateKind
    pokeByteOff ptr 8 cSparsePredicateFloatValue
    pokeByteOff ptr 16 cSparsePredicateIntegerValue

-- | Raw sparse-intent rule matching @ArcadiaTioSparseRuleV2@.
data CArcadiaTioSparseRuleV2 = CArcadiaTioSparseRuleV2
  { cSparseRuleStructSize :: Word32
  , cSparseRuleDetectorKind :: CInt
  , cSparseRuleAxes :: Ptr CSize
  , cSparseRuleAxesLen :: CSize
  , cSparseRulePredicate :: CArcadiaTioSparseValuePredicateV2
  , cSparseRuleMinAbsentFraction :: Double
  , cSparseRuleMinAbsentSubtensors :: Word64
  , cSparseRuleFallback :: CInt
  }
  deriving (Eq, Show)

sparseRuleV2StructSize :: Word32
sparseRuleV2StructSize = 72

instance Storable CArcadiaTioSparseRuleV2 where
  sizeOf _ = fromIntegral sparseRuleV2StructSize
  alignment _ = alignment (undefined :: Double)
  peek ptr =
    CArcadiaTioSparseRuleV2
      <$> peekByteOff ptr 0
      <*> peekByteOff ptr 4
      <*> peekByteOff ptr 8
      <*> peekByteOff ptr 16
      <*> peekByteOff ptr 24
      <*> peekByteOff ptr 48
      <*> peekByteOff ptr 56
      <*> peekByteOff ptr 64
  poke ptr CArcadiaTioSparseRuleV2{cSparseRuleStructSize, cSparseRuleDetectorKind, cSparseRuleAxes, cSparseRuleAxesLen, cSparseRulePredicate, cSparseRuleMinAbsentFraction, cSparseRuleMinAbsentSubtensors, cSparseRuleFallback} = do
    pokeByteOff ptr 0 cSparseRuleStructSize
    pokeByteOff ptr 4 cSparseRuleDetectorKind
    pokeByteOff ptr 8 cSparseRuleAxes
    pokeByteOff ptr 16 cSparseRuleAxesLen
    pokeByteOff ptr 24 cSparseRulePredicate
    pokeByteOff ptr 48 cSparseRuleMinAbsentFraction
    pokeByteOff ptr 56 cSparseRuleMinAbsentSubtensors
    pokeByteOff ptr 64 cSparseRuleFallback

-- | Raw sparse append analysis matching @ArcadiaTioSparseAppendAnalysis@.
data CArcadiaTioSparseAppendAnalysis = CArcadiaTioSparseAppendAnalysis
  { cSparseAnalysisOutcome :: CInt
  , cSparseAnalysisAbsentFraction :: Double
  , cSparseAnalysisAbsentSubtensorCount :: Word64
  , cSparseAnalysisTotalSubtensorCount :: Word64
  , cSparseAnalysisReasons :: Ptr CInt
  , cSparseAnalysisReasonsLen :: CSize
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioSparseAppendAnalysis where
  sizeOf _ = 48
  alignment _ = alignment (undefined :: Double)
  peek ptr =
    CArcadiaTioSparseAppendAnalysis
      <$> peekByteOff ptr 0
      <*> peekByteOff ptr 8
      <*> peekByteOff ptr 16
      <*> peekByteOff ptr 24
      <*> peekByteOff ptr 32
      <*> peekByteOff ptr 40
  poke ptr CArcadiaTioSparseAppendAnalysis{cSparseAnalysisOutcome, cSparseAnalysisAbsentFraction, cSparseAnalysisAbsentSubtensorCount, cSparseAnalysisTotalSubtensorCount, cSparseAnalysisReasons, cSparseAnalysisReasonsLen} = do
    pokeByteOff ptr 0 cSparseAnalysisOutcome
    pokeByteOff ptr 8 cSparseAnalysisAbsentFraction
    pokeByteOff ptr 16 cSparseAnalysisAbsentSubtensorCount
    pokeByteOff ptr 24 cSparseAnalysisTotalSubtensorCount
    pokeByteOff ptr 32 cSparseAnalysisReasons
    pokeByteOff ptr 40 cSparseAnalysisReasonsLen

emptyCArcadiaTioSparseAppendAnalysis :: CArcadiaTioSparseAppendAnalysis
emptyCArcadiaTioSparseAppendAnalysis =
  CArcadiaTioSparseAppendAnalysis
    { cSparseAnalysisOutcome = 2
    , cSparseAnalysisAbsentFraction = 0
    , cSparseAnalysisAbsentSubtensorCount = 0
    , cSparseAnalysisTotalSubtensorCount = 0
    , cSparseAnalysisReasons = nullPtr
    , cSparseAnalysisReasonsLen = 0
    }


-- | Raw OCB open options matching @ArcadiaTioOcbOpenOptions@.
data CArcadiaTioOcbOpenOptions = CArcadiaTioOcbOpenOptions
  { cOcbOpenOptionsVersion :: Word32
  , cOcbOpenOptionsStructSize :: CSize
  , cOcbOpenOptionsValidation :: CInt
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbOpenOptions where
  sizeOf _ = 56
  alignment _ = 8
  peek ptr =
    CArcadiaTioOcbOpenOptions
      <$> peekByteOff ptr 0
      <*> peekByteOff ptr 8
      <*> peekByteOff ptr 16
  poke ptr CArcadiaTioOcbOpenOptions{cOcbOpenOptionsVersion, cOcbOpenOptionsStructSize, cOcbOpenOptionsValidation} = do
    fillBytes ptr 0 56
    pokeByteOff ptr 0 cOcbOpenOptionsVersion
    pokeByteOff ptr 8 cOcbOpenOptionsStructSize
    pokeByteOff ptr 16 cOcbOpenOptionsValidation

emptyCArcadiaTioOcbOpenOptions :: CArcadiaTioOcbOpenOptions
emptyCArcadiaTioOcbOpenOptions =
  CArcadiaTioOcbOpenOptions
    { cOcbOpenOptionsVersion = 1
    , cOcbOpenOptionsStructSize = 56
    , cOcbOpenOptionsValidation = 0
    }

-- | Raw OCB column descriptor matching @ArcadiaTioOcbColumnDescriptor@.
data CArcadiaTioOcbColumnDescriptor = CArcadiaTioOcbColumnDescriptor
  { cOcbColumnDescriptorVersion :: Word32
  , cOcbColumnDescriptorStructSize :: CSize
  , cOcbColumnDescriptorId :: Word32
  , cOcbColumnDescriptorName :: CString
  , cOcbColumnDescriptorPhysicalType :: CInt
  , cOcbColumnDescriptorLogicalKind :: CInt
  , cOcbColumnDescriptorHasDictionaryId :: Word8
  , cOcbColumnDescriptorDictionaryId :: Word32
  , cOcbColumnDescriptorScale :: Int32
  , cOcbColumnDescriptorNullable :: Word8
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbColumnDescriptor where
  sizeOf _ = 80
  alignment _ = 8
  peek ptr =
    CArcadiaTioOcbColumnDescriptor
      <$> peekByteOff ptr 0
      <*> peekByteOff ptr 8
      <*> peekByteOff ptr 16
      <*> peekByteOff ptr 24
      <*> peekByteOff ptr 32
      <*> peekByteOff ptr 36
      <*> peekByteOff ptr 40
      <*> peekByteOff ptr 44
      <*> peekByteOff ptr 48
      <*> peekByteOff ptr 52
  poke ptr CArcadiaTioOcbColumnDescriptor{cOcbColumnDescriptorVersion, cOcbColumnDescriptorStructSize, cOcbColumnDescriptorId, cOcbColumnDescriptorName, cOcbColumnDescriptorPhysicalType, cOcbColumnDescriptorLogicalKind, cOcbColumnDescriptorHasDictionaryId, cOcbColumnDescriptorDictionaryId, cOcbColumnDescriptorScale, cOcbColumnDescriptorNullable} = do
    fillBytes ptr 0 80
    pokeByteOff ptr 0 cOcbColumnDescriptorVersion
    pokeByteOff ptr 8 cOcbColumnDescriptorStructSize
    pokeByteOff ptr 16 cOcbColumnDescriptorId
    pokeByteOff ptr 24 cOcbColumnDescriptorName
    pokeByteOff ptr 32 cOcbColumnDescriptorPhysicalType
    pokeByteOff ptr 36 cOcbColumnDescriptorLogicalKind
    pokeByteOff ptr 40 cOcbColumnDescriptorHasDictionaryId
    pokeByteOff ptr 44 cOcbColumnDescriptorDictionaryId
    pokeByteOff ptr 48 cOcbColumnDescriptorScale
    pokeByteOff ptr 52 cOcbColumnDescriptorNullable

-- | Raw OCB dictionary descriptor matching @ArcadiaTioOcbDictionaryDescriptor@.
data CArcadiaTioOcbDictionaryDescriptor = CArcadiaTioOcbDictionaryDescriptor
  { cOcbDictionaryDescriptorVersion :: Word32
  , cOcbDictionaryDescriptorStructSize :: CSize
  , cOcbDictionaryDescriptorDictionaryId :: Word32
  , cOcbDictionaryDescriptorName :: CString
  , cOcbDictionaryDescriptorCodePhysicalType :: CInt
  , cOcbDictionaryDescriptorValueKind :: CInt
  , cOcbDictionaryDescriptorEntryCount :: Word32
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbDictionaryDescriptor where
  sizeOf _ = 72
  alignment _ = 8
  peek ptr =
    CArcadiaTioOcbDictionaryDescriptor
      <$> peekByteOff ptr 0
      <*> peekByteOff ptr 8
      <*> peekByteOff ptr 16
      <*> peekByteOff ptr 24
      <*> peekByteOff ptr 32
      <*> peekByteOff ptr 36
      <*> peekByteOff ptr 40
  poke ptr CArcadiaTioOcbDictionaryDescriptor{cOcbDictionaryDescriptorVersion, cOcbDictionaryDescriptorStructSize, cOcbDictionaryDescriptorDictionaryId, cOcbDictionaryDescriptorName, cOcbDictionaryDescriptorCodePhysicalType, cOcbDictionaryDescriptorValueKind, cOcbDictionaryDescriptorEntryCount} = do
    fillBytes ptr 0 72
    pokeByteOff ptr 0 cOcbDictionaryDescriptorVersion
    pokeByteOff ptr 8 cOcbDictionaryDescriptorStructSize
    pokeByteOff ptr 16 cOcbDictionaryDescriptorDictionaryId
    pokeByteOff ptr 24 cOcbDictionaryDescriptorName
    pokeByteOff ptr 32 cOcbDictionaryDescriptorCodePhysicalType
    pokeByteOff ptr 36 cOcbDictionaryDescriptorValueKind
    pokeByteOff ptr 40 cOcbDictionaryDescriptorEntryCount

-- | Raw OCB ordering key matching @ArcadiaTioOcbOrderingKey@.
data CArcadiaTioOcbOrderingKey = CArcadiaTioOcbOrderingKey
  { cOcbOrderingKeyVersion :: Word32
  , cOcbOrderingKeyStructSize :: CSize
  , cOcbOrderingKeyColumnId :: Word32
  , cOcbOrderingKeyColumnName :: CString
  , cOcbOrderingKeyDirection :: CInt
  , cOcbOrderingKeyNullOrder :: CInt
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbOrderingKey where
  sizeOf _ = 64
  alignment _ = 8
  peek ptr =
    CArcadiaTioOcbOrderingKey
      <$> peekByteOff ptr 0
      <*> peekByteOff ptr 8
      <*> peekByteOff ptr 16
      <*> peekByteOff ptr 24
      <*> peekByteOff ptr 32
      <*> peekByteOff ptr 36
  poke ptr CArcadiaTioOcbOrderingKey{cOcbOrderingKeyVersion, cOcbOrderingKeyStructSize, cOcbOrderingKeyColumnId, cOcbOrderingKeyColumnName, cOcbOrderingKeyDirection, cOcbOrderingKeyNullOrder} = do
    fillBytes ptr 0 64
    pokeByteOff ptr 0 cOcbOrderingKeyVersion
    pokeByteOff ptr 8 cOcbOrderingKeyStructSize
    pokeByteOff ptr 16 cOcbOrderingKeyColumnId
    pokeByteOff ptr 24 cOcbOrderingKeyColumnName
    pokeByteOff ptr 32 cOcbOrderingKeyDirection
    pokeByteOff ptr 36 cOcbOrderingKeyNullOrder

-- | Minimal raw OCB metadata header matching @ArcadiaTioOcbMetadata@.
data CArcadiaTioOcbMetadata = CArcadiaTioOcbMetadata
  { cOcbMetadataVersion :: Word32
  , cOcbMetadataStructSize :: CSize
  , cOcbMetadataFormatName :: CString
  , cOcbMetadataAppendable :: Word8
  , cOcbMetadataRootGeneration :: Word64
  , cOcbMetadataHasPreviousRootGeneration :: Word8
  , cOcbMetadataPreviousRootGeneration :: Word64
  , cOcbMetadataRowCount :: Word64
  , cOcbMetadataRowGroupCount :: Word32
  , cOcbMetadataColumnChunkCount :: Word32
  , cOcbMetadataColumns :: Ptr CArcadiaTioOcbColumnDescriptor
  , cOcbMetadataColumnsLen :: CSize
  , cOcbMetadataDictionaries :: Ptr CArcadiaTioOcbDictionaryDescriptor
  , cOcbMetadataDictionariesLen :: CSize
  , cOcbMetadataOrderingKeys :: Ptr CArcadiaTioOcbOrderingKey
  , cOcbMetadataOrderingKeysLen :: CSize
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbMetadata where
  sizeOf _ = 152
  alignment _ = alignment (undefined :: Word64)
  peek ptr =
    CArcadiaTioOcbMetadata
      <$> peekByteOff ptr 0
      <*> peekByteOff ptr 8
      <*> peekByteOff ptr 16
      <*> peekByteOff ptr 24
      <*> peekByteOff ptr 32
      <*> peekByteOff ptr 40
      <*> peekByteOff ptr 48
      <*> peekByteOff ptr 56
      <*> peekByteOff ptr 64
      <*> peekByteOff ptr 68
      <*> peekByteOff ptr 72
      <*> peekByteOff ptr 80
      <*> peekByteOff ptr 88
      <*> peekByteOff ptr 96
      <*> peekByteOff ptr 104
      <*> peekByteOff ptr 112
  poke ptr CArcadiaTioOcbMetadata{cOcbMetadataVersion, cOcbMetadataStructSize, cOcbMetadataFormatName, cOcbMetadataAppendable, cOcbMetadataRootGeneration, cOcbMetadataHasPreviousRootGeneration, cOcbMetadataPreviousRootGeneration, cOcbMetadataRowCount, cOcbMetadataRowGroupCount, cOcbMetadataColumnChunkCount, cOcbMetadataColumns, cOcbMetadataColumnsLen, cOcbMetadataDictionaries, cOcbMetadataDictionariesLen, cOcbMetadataOrderingKeys, cOcbMetadataOrderingKeysLen} = do
    pokeByteOff ptr 0 cOcbMetadataVersion
    pokeByteOff ptr 8 cOcbMetadataStructSize
    pokeByteOff ptr 16 cOcbMetadataFormatName
    pokeByteOff ptr 24 cOcbMetadataAppendable
    pokeByteOff ptr 32 cOcbMetadataRootGeneration
    pokeByteOff ptr 40 cOcbMetadataHasPreviousRootGeneration
    pokeByteOff ptr 48 cOcbMetadataPreviousRootGeneration
    pokeByteOff ptr 56 cOcbMetadataRowCount
    pokeByteOff ptr 64 cOcbMetadataRowGroupCount
    pokeByteOff ptr 68 cOcbMetadataColumnChunkCount
    pokeByteOff ptr 72 cOcbMetadataColumns
    pokeByteOff ptr 80 cOcbMetadataColumnsLen
    pokeByteOff ptr 88 cOcbMetadataDictionaries
    pokeByteOff ptr 96 cOcbMetadataDictionariesLen
    pokeByteOff ptr 104 cOcbMetadataOrderingKeys
    pokeByteOff ptr 112 cOcbMetadataOrderingKeysLen

emptyCArcadiaTioOcbMetadata :: CArcadiaTioOcbMetadata
emptyCArcadiaTioOcbMetadata =
  CArcadiaTioOcbMetadata
    { cOcbMetadataVersion = 1
    , cOcbMetadataStructSize = 152
    , cOcbMetadataFormatName = nullPtr
    , cOcbMetadataAppendable = 0
    , cOcbMetadataRootGeneration = 0
    , cOcbMetadataHasPreviousRootGeneration = 0
    , cOcbMetadataPreviousRootGeneration = 0
    , cOcbMetadataRowCount = 0
    , cOcbMetadataRowGroupCount = 0
    , cOcbMetadataColumnChunkCount = 0
    , cOcbMetadataColumns = nullPtr
    , cOcbMetadataColumnsLen = 0
    , cOcbMetadataDictionaries = nullPtr
    , cOcbMetadataDictionariesLen = 0
    , cOcbMetadataOrderingKeys = nullPtr
    , cOcbMetadataOrderingKeysLen = 0
    }


-- | Raw OCB byte slice matching @ArcadiaTioOcbByteSlice@.
data CArcadiaTioOcbByteSlice = CArcadiaTioOcbByteSlice
  { cOcbByteSliceData :: Ptr Word8
  , cOcbByteSliceLen :: CSize
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbByteSlice where
  sizeOf _ = 16
  alignment _ = 8
  peek ptr = CArcadiaTioOcbByteSlice <$> peekByteOff ptr 0 <*> peekByteOff ptr 8
  poke ptr CArcadiaTioOcbByteSlice{cOcbByteSliceData, cOcbByteSliceLen} = do
    pokeByteOff ptr 0 cOcbByteSliceData
    pokeByteOff ptr 8 cOcbByteSliceLen

-- | Raw OCB dictionary values matching @ArcadiaTioOcbDictionaryValues@.
data CArcadiaTioOcbDictionaryValues = CArcadiaTioOcbDictionaryValues
  { cOcbDictionaryValuesVersion :: Word32
  , cOcbDictionaryValuesStructSize :: CSize
  , cOcbDictionaryValuesDictionaryId :: Word32
  , cOcbDictionaryValuesName :: CString
  , cOcbDictionaryValuesValueKind :: CInt
  , cOcbDictionaryValuesFixedWidth :: Word32
  , cOcbDictionaryValuesStringValues :: Ptr CString
  , cOcbDictionaryValuesStringValuesLen :: CSize
  , cOcbDictionaryValuesByteValues :: Ptr CArcadiaTioOcbByteSlice
  , cOcbDictionaryValuesByteValuesLen :: CSize
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbDictionaryValues where
  sizeOf _ = 104
  alignment _ = 8
  peek ptr =
    CArcadiaTioOcbDictionaryValues
      <$> peekByteOff ptr 0
      <*> peekByteOff ptr 8
      <*> peekByteOff ptr 16
      <*> peekByteOff ptr 24
      <*> peekByteOff ptr 32
      <*> peekByteOff ptr 36
      <*> peekByteOff ptr 40
      <*> peekByteOff ptr 48
      <*> peekByteOff ptr 56
      <*> peekByteOff ptr 64
  poke ptr CArcadiaTioOcbDictionaryValues{cOcbDictionaryValuesVersion, cOcbDictionaryValuesStructSize, cOcbDictionaryValuesDictionaryId, cOcbDictionaryValuesName, cOcbDictionaryValuesValueKind, cOcbDictionaryValuesFixedWidth, cOcbDictionaryValuesStringValues, cOcbDictionaryValuesStringValuesLen, cOcbDictionaryValuesByteValues, cOcbDictionaryValuesByteValuesLen} = do
    fillBytes ptr 0 104
    pokeByteOff ptr 0 cOcbDictionaryValuesVersion
    pokeByteOff ptr 8 cOcbDictionaryValuesStructSize
    pokeByteOff ptr 16 cOcbDictionaryValuesDictionaryId
    pokeByteOff ptr 24 cOcbDictionaryValuesName
    pokeByteOff ptr 32 cOcbDictionaryValuesValueKind
    pokeByteOff ptr 36 cOcbDictionaryValuesFixedWidth
    pokeByteOff ptr 40 cOcbDictionaryValuesStringValues
    pokeByteOff ptr 48 cOcbDictionaryValuesStringValuesLen
    pokeByteOff ptr 56 cOcbDictionaryValuesByteValues
    pokeByteOff ptr 64 cOcbDictionaryValuesByteValuesLen

emptyCArcadiaTioOcbDictionaryValues :: CArcadiaTioOcbDictionaryValues
emptyCArcadiaTioOcbDictionaryValues =
  CArcadiaTioOcbDictionaryValues
    { cOcbDictionaryValuesVersion = 1
    , cOcbDictionaryValuesStructSize = 104
    , cOcbDictionaryValuesDictionaryId = 0
    , cOcbDictionaryValuesName = nullPtr
    , cOcbDictionaryValuesValueKind = 0
    , cOcbDictionaryValuesFixedWidth = 0
    , cOcbDictionaryValuesStringValues = nullPtr
    , cOcbDictionaryValuesStringValuesLen = 0
    , cOcbDictionaryValuesByteValues = nullPtr
    , cOcbDictionaryValuesByteValuesLen = 0
    }


-- | Raw OCB primitive values matching @ArcadiaTioOcbPrimitiveValues@.
data CArcadiaTioOcbPrimitiveValues = CArcadiaTioOcbPrimitiveValues
  { cOcbPrimitiveValuesVersion :: Word32
  , cOcbPrimitiveValuesStructSize :: CSize
  , cOcbPrimitiveValuesPhysicalType :: CInt
  , cOcbPrimitiveValuesData :: Ptr ()
  , cOcbPrimitiveValuesLen :: CSize
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbPrimitiveValues where
  sizeOf _ = 64
  alignment _ = 8
  peek ptr = CArcadiaTioOcbPrimitiveValues <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32
  poke ptr CArcadiaTioOcbPrimitiveValues{cOcbPrimitiveValuesVersion, cOcbPrimitiveValuesStructSize, cOcbPrimitiveValuesPhysicalType, cOcbPrimitiveValuesData, cOcbPrimitiveValuesLen} = do
    fillBytes ptr 0 64
    pokeByteOff ptr 0 cOcbPrimitiveValuesVersion
    pokeByteOff ptr 8 cOcbPrimitiveValuesStructSize
    pokeByteOff ptr 16 cOcbPrimitiveValuesPhysicalType
    pokeByteOff ptr 24 cOcbPrimitiveValuesData
    pokeByteOff ptr 32 cOcbPrimitiveValuesLen

emptyCArcadiaTioOcbPrimitiveValues :: CArcadiaTioOcbPrimitiveValues
emptyCArcadiaTioOcbPrimitiveValues = CArcadiaTioOcbPrimitiveValues 1 64 0 nullPtr 0

-- | Raw OCB validity bitmap matching @ArcadiaTioOcbValidityBitmap@.
data CArcadiaTioOcbValidityBitmap = CArcadiaTioOcbValidityBitmap
  { cOcbValidityBitmapVersion :: Word32
  , cOcbValidityBitmapStructSize :: CSize
  , cOcbValidityBitmapData :: Ptr Word8
  , cOcbValidityBitmapLen :: CSize
  , cOcbValidityBitmapRowCount :: Word64
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbValidityBitmap where
  sizeOf _ = 64
  alignment _ = 8
  peek ptr = CArcadiaTioOcbValidityBitmap <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32
  poke ptr CArcadiaTioOcbValidityBitmap{cOcbValidityBitmapVersion, cOcbValidityBitmapStructSize, cOcbValidityBitmapData, cOcbValidityBitmapLen, cOcbValidityBitmapRowCount} = do
    fillBytes ptr 0 64
    pokeByteOff ptr 0 cOcbValidityBitmapVersion
    pokeByteOff ptr 8 cOcbValidityBitmapStructSize
    pokeByteOff ptr 16 cOcbValidityBitmapData
    pokeByteOff ptr 24 cOcbValidityBitmapLen
    pokeByteOff ptr 32 cOcbValidityBitmapRowCount

emptyCArcadiaTioOcbValidityBitmap :: CArcadiaTioOcbValidityBitmap
emptyCArcadiaTioOcbValidityBitmap = CArcadiaTioOcbValidityBitmap 1 64 nullPtr 0 0


-- | Raw OCB write options matching @ArcadiaTioOcbWriteOptions@.
data CArcadiaTioOcbWriteOptions = CArcadiaTioOcbWriteOptions
  { cOcbWriteOptionsVersion :: Word32
  , cOcbWriteOptionsStructSize :: CSize
  , cOcbWriteOptionsWriteThreads :: CSize
  , cOcbWriteOptionsChunkCodec :: CInt
  , cOcbWriteOptionsZstdLevel :: Int32
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbWriteOptions where
  sizeOf _ = 64
  alignment _ = 8
  peek ptr = CArcadiaTioOcbWriteOptions <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 28
  poke ptr CArcadiaTioOcbWriteOptions{cOcbWriteOptionsVersion, cOcbWriteOptionsStructSize, cOcbWriteOptionsWriteThreads, cOcbWriteOptionsChunkCodec, cOcbWriteOptionsZstdLevel} = do
    fillBytes ptr 0 64
    pokeByteOff ptr 0 cOcbWriteOptionsVersion
    pokeByteOff ptr 8 cOcbWriteOptionsStructSize
    pokeByteOff ptr 16 cOcbWriteOptionsWriteThreads
    pokeByteOff ptr 24 cOcbWriteOptionsChunkCodec
    pokeByteOff ptr 28 cOcbWriteOptionsZstdLevel

emptyCArcadiaTioOcbWriteOptions :: CArcadiaTioOcbWriteOptions
emptyCArcadiaTioOcbWriteOptions = CArcadiaTioOcbWriteOptions 1 64 1 1 3

-- | Raw OCB write column matching @ArcadiaTioOcbWriteColumn@.
data CArcadiaTioOcbWriteColumn = CArcadiaTioOcbWriteColumn
  { cOcbWriteColumnVersion :: Word32
  , cOcbWriteColumnStructSize :: CSize
  , cOcbWriteColumnName :: CString
  , cOcbWriteColumnPhysicalType :: CInt
  , cOcbWriteColumnLogicalKind :: CInt
  , cOcbWriteColumnHasDictionaryId :: Word8
  , cOcbWriteColumnDictionaryId :: Word32
  , cOcbWriteColumnScale :: Int32
  , cOcbWriteColumnNullable :: Word8
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbWriteColumn where
  sizeOf _ = 72
  alignment _ = 8
  peek ptr = CArcadiaTioOcbWriteColumn <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 28 <*> peekByteOff ptr 32 <*> peekByteOff ptr 36 <*> peekByteOff ptr 40 <*> peekByteOff ptr 44
  poke ptr CArcadiaTioOcbWriteColumn{cOcbWriteColumnVersion, cOcbWriteColumnStructSize, cOcbWriteColumnName, cOcbWriteColumnPhysicalType, cOcbWriteColumnLogicalKind, cOcbWriteColumnHasDictionaryId, cOcbWriteColumnDictionaryId, cOcbWriteColumnScale, cOcbWriteColumnNullable} = do
    fillBytes ptr 0 72
    pokeByteOff ptr 0 cOcbWriteColumnVersion
    pokeByteOff ptr 8 cOcbWriteColumnStructSize
    pokeByteOff ptr 16 cOcbWriteColumnName
    pokeByteOff ptr 24 cOcbWriteColumnPhysicalType
    pokeByteOff ptr 28 cOcbWriteColumnLogicalKind
    pokeByteOff ptr 32 cOcbWriteColumnHasDictionaryId
    pokeByteOff ptr 36 cOcbWriteColumnDictionaryId
    pokeByteOff ptr 40 cOcbWriteColumnScale
    pokeByteOff ptr 44 cOcbWriteColumnNullable

emptyCArcadiaTioOcbWriteColumn :: CArcadiaTioOcbWriteColumn
emptyCArcadiaTioOcbWriteColumn = CArcadiaTioOcbWriteColumn 1 72 nullPtr 0 0 0 0 0 0

-- | Raw OCB dictionary entry matching @ArcadiaTioOcbDictionaryEntry@.
data CArcadiaTioOcbDictionaryEntry = CArcadiaTioOcbDictionaryEntry
  { cOcbDictionaryEntryVersion :: Word32
  , cOcbDictionaryEntryStructSize :: CSize
  , cOcbDictionaryEntryData :: Ptr Word8
  , cOcbDictionaryEntryLen :: CSize
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbDictionaryEntry where
  sizeOf _ = 56
  alignment _ = 8
  peek ptr = CArcadiaTioOcbDictionaryEntry <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24
  poke ptr CArcadiaTioOcbDictionaryEntry{cOcbDictionaryEntryVersion, cOcbDictionaryEntryStructSize, cOcbDictionaryEntryData, cOcbDictionaryEntryLen} = do
    fillBytes ptr 0 56
    pokeByteOff ptr 0 cOcbDictionaryEntryVersion
    pokeByteOff ptr 8 cOcbDictionaryEntryStructSize
    pokeByteOff ptr 16 cOcbDictionaryEntryData
    pokeByteOff ptr 24 cOcbDictionaryEntryLen

emptyCArcadiaTioOcbDictionaryEntry :: CArcadiaTioOcbDictionaryEntry
emptyCArcadiaTioOcbDictionaryEntry = CArcadiaTioOcbDictionaryEntry 1 56 nullPtr 0

-- | Raw OCB write dictionary matching @ArcadiaTioOcbWriteDictionary@.
data CArcadiaTioOcbWriteDictionary = CArcadiaTioOcbWriteDictionary
  { cOcbWriteDictionaryVersion :: Word32
  , cOcbWriteDictionaryStructSize :: CSize
  , cOcbWriteDictionaryId :: Word32
  , cOcbWriteDictionaryName :: CString
  , cOcbWriteDictionaryCodePhysicalType :: CInt
  , cOcbWriteDictionaryValueKind :: CInt
  , cOcbWriteDictionaryFixedWidth :: Word32
  , cOcbWriteDictionaryEntries :: Ptr CArcadiaTioOcbDictionaryEntry
  , cOcbWriteDictionaryEntriesLen :: CSize
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbWriteDictionary where
  sizeOf _ = 88
  alignment _ = 8
  peek ptr = CArcadiaTioOcbWriteDictionary <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 36 <*> peekByteOff ptr 40 <*> peekByteOff ptr 48 <*> peekByteOff ptr 56
  poke ptr CArcadiaTioOcbWriteDictionary{cOcbWriteDictionaryVersion, cOcbWriteDictionaryStructSize, cOcbWriteDictionaryId, cOcbWriteDictionaryName, cOcbWriteDictionaryCodePhysicalType, cOcbWriteDictionaryValueKind, cOcbWriteDictionaryFixedWidth, cOcbWriteDictionaryEntries, cOcbWriteDictionaryEntriesLen} = do
    fillBytes ptr 0 88
    pokeByteOff ptr 0 cOcbWriteDictionaryVersion
    pokeByteOff ptr 8 cOcbWriteDictionaryStructSize
    pokeByteOff ptr 16 cOcbWriteDictionaryId
    pokeByteOff ptr 24 cOcbWriteDictionaryName
    pokeByteOff ptr 32 cOcbWriteDictionaryCodePhysicalType
    pokeByteOff ptr 36 cOcbWriteDictionaryValueKind
    pokeByteOff ptr 40 cOcbWriteDictionaryFixedWidth
    pokeByteOff ptr 48 cOcbWriteDictionaryEntries
    pokeByteOff ptr 56 cOcbWriteDictionaryEntriesLen

emptyCArcadiaTioOcbWriteDictionary :: CArcadiaTioOcbWriteDictionary
emptyCArcadiaTioOcbWriteDictionary = CArcadiaTioOcbWriteDictionary 1 88 0 nullPtr 0 0 0 nullPtr 0

-- | Raw OCB write column chunk matching @ArcadiaTioOcbWriteColumnChunk@.
data CArcadiaTioOcbWriteColumnChunk = CArcadiaTioOcbWriteColumnChunk
  { cOcbWriteColumnChunkVersion :: Word32
  , cOcbWriteColumnChunkStructSize :: CSize
  , cOcbWriteColumnChunkColumnId :: Word32
  , cOcbWriteColumnChunkValues :: CArcadiaTioOcbPrimitiveValues
  , cOcbWriteColumnChunkValidity :: Ptr CArcadiaTioOcbValidityBitmap
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbWriteColumnChunk where
  sizeOf _ = 120
  alignment _ = 8
  peek ptr = CArcadiaTioOcbWriteColumnChunk <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 88
  poke ptr CArcadiaTioOcbWriteColumnChunk{cOcbWriteColumnChunkVersion, cOcbWriteColumnChunkStructSize, cOcbWriteColumnChunkColumnId, cOcbWriteColumnChunkValues, cOcbWriteColumnChunkValidity} = do
    fillBytes ptr 0 120
    pokeByteOff ptr 0 cOcbWriteColumnChunkVersion
    pokeByteOff ptr 8 cOcbWriteColumnChunkStructSize
    pokeByteOff ptr 16 cOcbWriteColumnChunkColumnId
    pokeByteOff ptr 24 cOcbWriteColumnChunkValues
    pokeByteOff ptr 88 cOcbWriteColumnChunkValidity

emptyCArcadiaTioOcbWriteColumnChunk :: CArcadiaTioOcbWriteColumnChunk
emptyCArcadiaTioOcbWriteColumnChunk = CArcadiaTioOcbWriteColumnChunk 1 120 0 emptyCArcadiaTioOcbPrimitiveValues nullPtr

-- | Raw OCB write row group matching @ArcadiaTioOcbWriteRowGroup@.
data CArcadiaTioOcbWriteRowGroup = CArcadiaTioOcbWriteRowGroup
  { cOcbWriteRowGroupVersion :: Word32
  , cOcbWriteRowGroupStructSize :: CSize
  , cOcbWriteRowGroupColumns :: Ptr CArcadiaTioOcbWriteColumnChunk
  , cOcbWriteRowGroupColumnsLen :: CSize
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbWriteRowGroup where
  sizeOf _ = 56
  alignment _ = 8
  peek ptr = CArcadiaTioOcbWriteRowGroup <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24
  poke ptr CArcadiaTioOcbWriteRowGroup{cOcbWriteRowGroupVersion, cOcbWriteRowGroupStructSize, cOcbWriteRowGroupColumns, cOcbWriteRowGroupColumnsLen} = do
    fillBytes ptr 0 56
    pokeByteOff ptr 0 cOcbWriteRowGroupVersion
    pokeByteOff ptr 8 cOcbWriteRowGroupStructSize
    pokeByteOff ptr 16 cOcbWriteRowGroupColumns
    pokeByteOff ptr 24 cOcbWriteRowGroupColumnsLen

emptyCArcadiaTioOcbWriteRowGroup :: CArcadiaTioOcbWriteRowGroup
emptyCArcadiaTioOcbWriteRowGroup = CArcadiaTioOcbWriteRowGroup 1 56 nullPtr 0

-- | Raw OCB write ordering key matching @ArcadiaTioOcbWriteOrderingKey@.
data CArcadiaTioOcbWriteOrderingKey = CArcadiaTioOcbWriteOrderingKey
  { cOcbWriteOrderingKeyVersion :: Word32
  , cOcbWriteOrderingKeyStructSize :: CSize
  , cOcbWriteOrderingKeyColumnId :: Word32
  , cOcbWriteOrderingKeyDirection :: CInt
  , cOcbWriteOrderingKeyNullOrder :: CInt
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbWriteOrderingKey where
  sizeOf _ = 56
  alignment _ = 8
  peek ptr = CArcadiaTioOcbWriteOrderingKey <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 20 <*> peekByteOff ptr 24
  poke ptr CArcadiaTioOcbWriteOrderingKey{cOcbWriteOrderingKeyVersion, cOcbWriteOrderingKeyStructSize, cOcbWriteOrderingKeyColumnId, cOcbWriteOrderingKeyDirection, cOcbWriteOrderingKeyNullOrder} = do
    fillBytes ptr 0 56
    pokeByteOff ptr 0 cOcbWriteOrderingKeyVersion
    pokeByteOff ptr 8 cOcbWriteOrderingKeyStructSize
    pokeByteOff ptr 16 cOcbWriteOrderingKeyColumnId
    pokeByteOff ptr 20 cOcbWriteOrderingKeyDirection
    pokeByteOff ptr 24 cOcbWriteOrderingKeyNullOrder

emptyCArcadiaTioOcbWriteOrderingKey :: CArcadiaTioOcbWriteOrderingKey
emptyCArcadiaTioOcbWriteOrderingKey = CArcadiaTioOcbWriteOrderingKey 1 56 0 0 0

-- | Raw OCB write spec matching @ArcadiaTioOcbWriteSpec@.
data CArcadiaTioOcbWriteSpec = CArcadiaTioOcbWriteSpec
  { cOcbWriteSpecVersion :: Word32
  , cOcbWriteSpecStructSize :: CSize
  , cOcbWriteSpecColumns :: Ptr CArcadiaTioOcbWriteColumn
  , cOcbWriteSpecColumnsLen :: CSize
  , cOcbWriteSpecDictionaries :: Ptr CArcadiaTioOcbWriteDictionary
  , cOcbWriteSpecDictionariesLen :: CSize
  , cOcbWriteSpecRowGroups :: Ptr CArcadiaTioOcbWriteRowGroup
  , cOcbWriteSpecRowGroupsLen :: CSize
  , cOcbWriteSpecOrderingKeys :: Ptr CArcadiaTioOcbWriteOrderingKey
  , cOcbWriteSpecOrderingKeysLen :: CSize
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbWriteSpec where
  sizeOf _ = 112
  alignment _ = 8
  peek ptr = CArcadiaTioOcbWriteSpec <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 40 <*> peekByteOff ptr 48 <*> peekByteOff ptr 56 <*> peekByteOff ptr 64 <*> peekByteOff ptr 72
  poke ptr CArcadiaTioOcbWriteSpec{cOcbWriteSpecVersion, cOcbWriteSpecStructSize, cOcbWriteSpecColumns, cOcbWriteSpecColumnsLen, cOcbWriteSpecDictionaries, cOcbWriteSpecDictionariesLen, cOcbWriteSpecRowGroups, cOcbWriteSpecRowGroupsLen, cOcbWriteSpecOrderingKeys, cOcbWriteSpecOrderingKeysLen} = do
    fillBytes ptr 0 112
    pokeByteOff ptr 0 cOcbWriteSpecVersion
    pokeByteOff ptr 8 cOcbWriteSpecStructSize
    pokeByteOff ptr 16 cOcbWriteSpecColumns
    pokeByteOff ptr 24 cOcbWriteSpecColumnsLen
    pokeByteOff ptr 32 cOcbWriteSpecDictionaries
    pokeByteOff ptr 40 cOcbWriteSpecDictionariesLen
    pokeByteOff ptr 48 cOcbWriteSpecRowGroups
    pokeByteOff ptr 56 cOcbWriteSpecRowGroupsLen
    pokeByteOff ptr 64 cOcbWriteSpecOrderingKeys
    pokeByteOff ptr 72 cOcbWriteSpecOrderingKeysLen

emptyCArcadiaTioOcbWriteSpec :: CArcadiaTioOcbWriteSpec
emptyCArcadiaTioOcbWriteSpec = CArcadiaTioOcbWriteSpec 1 112 nullPtr 0 nullPtr 0 nullPtr 0 nullPtr 0

-- | Raw OCB cleanup result matching @ArcadiaTioOcbCleanupResult@.
data CArcadiaTioOcbCleanupResult = CArcadiaTioOcbCleanupResult
  { cOcbCleanupResultVersion :: Word32
  , cOcbCleanupResultStructSize :: CSize
  , cOcbCleanupResultTruncated :: Word8
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbCleanupResult where
  sizeOf _ = 48
  alignment _ = 8
  peek ptr = CArcadiaTioOcbCleanupResult <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16
  poke ptr CArcadiaTioOcbCleanupResult{cOcbCleanupResultVersion, cOcbCleanupResultStructSize, cOcbCleanupResultTruncated} = do
    fillBytes ptr 0 48
    pokeByteOff ptr 0 cOcbCleanupResultVersion
    pokeByteOff ptr 8 cOcbCleanupResultStructSize
    pokeByteOff ptr 16 cOcbCleanupResultTruncated

emptyCArcadiaTioOcbCleanupResult :: CArcadiaTioOcbCleanupResult
emptyCArcadiaTioOcbCleanupResult = CArcadiaTioOcbCleanupResult 1 48 0

-- | Raw OCB predicate value matching @ArcadiaTioOcbPredicateValue@.
data CArcadiaTioOcbPredicateValue = CArcadiaTioOcbPredicateValue
  { cOcbPredicateValueVersion :: Word32
  , cOcbPredicateValueStructSize :: CSize
  , cOcbPredicateValuePhysicalType :: CInt
  , cOcbPredicateValueI32 :: Int32
  , cOcbPredicateValueI64 :: Int64
  , cOcbPredicateValueF32 :: CFloat
  , cOcbPredicateValueF64 :: Double
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbPredicateValue where
  sizeOf _ = 72
  alignment _ = 8
  peek ptr = CArcadiaTioOcbPredicateValue <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 20 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 40
  poke ptr CArcadiaTioOcbPredicateValue{cOcbPredicateValueVersion, cOcbPredicateValueStructSize, cOcbPredicateValuePhysicalType, cOcbPredicateValueI32, cOcbPredicateValueI64, cOcbPredicateValueF32, cOcbPredicateValueF64} = do
    fillBytes ptr 0 72
    pokeByteOff ptr 0 cOcbPredicateValueVersion
    pokeByteOff ptr 8 cOcbPredicateValueStructSize
    pokeByteOff ptr 16 cOcbPredicateValuePhysicalType
    pokeByteOff ptr 20 cOcbPredicateValueI32
    pokeByteOff ptr 24 cOcbPredicateValueI64
    pokeByteOff ptr 32 cOcbPredicateValueF32
    pokeByteOff ptr 40 cOcbPredicateValueF64

emptyCArcadiaTioOcbPredicateValue :: CArcadiaTioOcbPredicateValue
emptyCArcadiaTioOcbPredicateValue = CArcadiaTioOcbPredicateValue 1 72 0 0 0 0 0

-- | Raw OCB row-group predicate matching @ArcadiaTioOcbRowGroupPredicate@.
data CArcadiaTioOcbRowGroupPredicate = CArcadiaTioOcbRowGroupPredicate
  { cOcbRowGroupPredicateVersion :: Word32
  , cOcbRowGroupPredicateStructSize :: CSize
  , cOcbRowGroupPredicateColumn :: CString
  , cOcbRowGroupPredicateHasLower :: Word8
  , cOcbRowGroupPredicateLower :: CArcadiaTioOcbPredicateValue
  , cOcbRowGroupPredicateHasUpper :: Word8
  , cOcbRowGroupPredicateUpper :: CArcadiaTioOcbPredicateValue
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbRowGroupPredicate where
  sizeOf _ = 208
  alignment _ = 8
  peek ptr = CArcadiaTioOcbRowGroupPredicate <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 104 <*> peekByteOff ptr 112
  poke ptr CArcadiaTioOcbRowGroupPredicate{cOcbRowGroupPredicateVersion, cOcbRowGroupPredicateStructSize, cOcbRowGroupPredicateColumn, cOcbRowGroupPredicateHasLower, cOcbRowGroupPredicateLower, cOcbRowGroupPredicateHasUpper, cOcbRowGroupPredicateUpper} = do
    fillBytes ptr 0 208
    pokeByteOff ptr 0 cOcbRowGroupPredicateVersion
    pokeByteOff ptr 8 cOcbRowGroupPredicateStructSize
    pokeByteOff ptr 16 cOcbRowGroupPredicateColumn
    pokeByteOff ptr 24 cOcbRowGroupPredicateHasLower
    pokeByteOff ptr 32 cOcbRowGroupPredicateLower
    pokeByteOff ptr 104 cOcbRowGroupPredicateHasUpper
    pokeByteOff ptr 112 cOcbRowGroupPredicateUpper

emptyCArcadiaTioOcbRowGroupPredicate :: CArcadiaTioOcbRowGroupPredicate
emptyCArcadiaTioOcbRowGroupPredicate = CArcadiaTioOcbRowGroupPredicate 1 208 nullPtr 0 emptyCArcadiaTioOcbPredicateValue 0 emptyCArcadiaTioOcbPredicateValue

-- | Raw OCB read request matching @ArcadiaTioOcbReadRequest@.
data CArcadiaTioOcbReadRequest = CArcadiaTioOcbReadRequest
  { cOcbReadRequestVersion :: Word32
  , cOcbReadRequestStructSize :: CSize
  , cOcbReadRequestProjectionKind :: CInt
  , cOcbReadRequestColumnNames :: Ptr CString
  , cOcbReadRequestColumnNamesLen :: CSize
  , cOcbReadRequestPredicates :: Ptr CArcadiaTioOcbRowGroupPredicate
  , cOcbReadRequestPredicatesLen :: CSize
  , cOcbReadRequestMaxThreads :: CSize
  , cOcbReadRequestValidateChecksums :: Word8
  , cOcbReadRequestDecodeDictionaries :: Word8
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbReadRequest where
  sizeOf _ = 104
  alignment _ = 8
  peek ptr = CArcadiaTioOcbReadRequest <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 40 <*> peekByteOff ptr 48 <*> peekByteOff ptr 56 <*> peekByteOff ptr 64 <*> peekByteOff ptr 65
  poke ptr CArcadiaTioOcbReadRequest{cOcbReadRequestVersion, cOcbReadRequestStructSize, cOcbReadRequestProjectionKind, cOcbReadRequestColumnNames, cOcbReadRequestColumnNamesLen, cOcbReadRequestPredicates, cOcbReadRequestPredicatesLen, cOcbReadRequestMaxThreads, cOcbReadRequestValidateChecksums, cOcbReadRequestDecodeDictionaries} = do
    fillBytes ptr 0 104
    pokeByteOff ptr 0 cOcbReadRequestVersion
    pokeByteOff ptr 8 cOcbReadRequestStructSize
    pokeByteOff ptr 16 cOcbReadRequestProjectionKind
    pokeByteOff ptr 24 cOcbReadRequestColumnNames
    pokeByteOff ptr 32 cOcbReadRequestColumnNamesLen
    pokeByteOff ptr 40 cOcbReadRequestPredicates
    pokeByteOff ptr 48 cOcbReadRequestPredicatesLen
    pokeByteOff ptr 56 cOcbReadRequestMaxThreads
    pokeByteOff ptr 64 cOcbReadRequestValidateChecksums
    pokeByteOff ptr 65 cOcbReadRequestDecodeDictionaries

emptyCArcadiaTioOcbReadRequest :: CArcadiaTioOcbReadRequest
emptyCArcadiaTioOcbReadRequest = CArcadiaTioOcbReadRequest 1 104 0 nullPtr 0 nullPtr 0 1 1 0

-- | Raw OCB read report matching @ArcadiaTioOcbReadReport@.
data CArcadiaTioOcbReadReport = CArcadiaTioOcbReadReport
  { cOcbReadReportVersion :: Word32
  , cOcbReadReportStructSize :: CSize
  , cOcbReadReportRequestedThreads :: CSize
  , cOcbReadReportEffectiveThreads :: CSize
  , cOcbReadReportSelectedRowGroups :: CSize
  , cOcbReadReportPrunedRowGroups :: CSize
  , cOcbReadReportSelectedColumnChunks :: CSize
  , cOcbReadReportFallbackReason :: CString
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbReadReport where
  sizeOf _ = 96
  alignment _ = 8
  peek ptr = CArcadiaTioOcbReadReport <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 40 <*> peekByteOff ptr 48 <*> peekByteOff ptr 56
  poke ptr CArcadiaTioOcbReadReport{cOcbReadReportVersion, cOcbReadReportStructSize, cOcbReadReportRequestedThreads, cOcbReadReportEffectiveThreads, cOcbReadReportSelectedRowGroups, cOcbReadReportPrunedRowGroups, cOcbReadReportSelectedColumnChunks, cOcbReadReportFallbackReason} = do
    fillBytes ptr 0 96
    pokeByteOff ptr 0 cOcbReadReportVersion
    pokeByteOff ptr 8 cOcbReadReportStructSize
    pokeByteOff ptr 16 cOcbReadReportRequestedThreads
    pokeByteOff ptr 24 cOcbReadReportEffectiveThreads
    pokeByteOff ptr 32 cOcbReadReportSelectedRowGroups
    pokeByteOff ptr 40 cOcbReadReportPrunedRowGroups
    pokeByteOff ptr 48 cOcbReadReportSelectedColumnChunks
    pokeByteOff ptr 56 cOcbReadReportFallbackReason

emptyCArcadiaTioOcbReadReport :: CArcadiaTioOcbReadReport
emptyCArcadiaTioOcbReadReport = CArcadiaTioOcbReadReport 1 96 0 0 0 0 0 nullPtr

-- | Raw OCB read attribution matching @ArcadiaTioOcbReadAttribution@.
data CArcadiaTioOcbReadAttribution = CArcadiaTioOcbReadAttribution
  { cOcbReadAttributionVersion :: Word32
  , cOcbReadAttributionStructSize :: CSize
  , cOcbReadAttributionPlanNs :: Word64
  , cOcbReadAttributionExecuteWallNs :: Word64
  , cOcbReadAttributionRowGroupReadNs :: Word64
  , cOcbReadAttributionReadIoNs :: Word64
  , cOcbReadAttributionChecksumNs :: Word64
  , cOcbReadAttributionDecompressionNs :: Word64
  , cOcbReadAttributionPrimitiveDecodeNs :: Word64
  , cOcbReadAttributionHasNativeToCCopyNs :: Word8
  , cOcbReadAttributionNativeToCCopyNs :: Word64
  , cOcbReadAttributionHasWrapperCopyNs :: Word8
  , cOcbReadAttributionWrapperCopyNs :: Word64
  , cOcbReadAttributionBytesRead :: Word64
  , cOcbReadAttributionCompressedBytes :: Word64
  , cOcbReadAttributionUncompressedBytes :: Word64
  , cOcbReadAttributionRequestedThreads :: CSize
  , cOcbReadAttributionEffectiveThreads :: CSize
  , cOcbReadAttributionSelectedRowGroups :: CSize
  , cOcbReadAttributionPrunedRowGroups :: CSize
  , cOcbReadAttributionSelectedColumnChunks :: CSize
  , cOcbReadAttributionFallbackReason :: CString
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbReadAttribution where
  sizeOf _ = 208
  alignment _ = 8
  peek ptr = CArcadiaTioOcbReadAttribution <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 40 <*> peekByteOff ptr 48 <*> peekByteOff ptr 56 <*> peekByteOff ptr 64 <*> peekByteOff ptr 72 <*> peekByteOff ptr 80 <*> peekByteOff ptr 88 <*> peekByteOff ptr 96 <*> peekByteOff ptr 104 <*> peekByteOff ptr 112 <*> peekByteOff ptr 120 <*> peekByteOff ptr 128 <*> peekByteOff ptr 136 <*> peekByteOff ptr 144 <*> peekByteOff ptr 152 <*> peekByteOff ptr 160 <*> peekByteOff ptr 168
  poke ptr CArcadiaTioOcbReadAttribution{cOcbReadAttributionVersion, cOcbReadAttributionStructSize, cOcbReadAttributionPlanNs, cOcbReadAttributionExecuteWallNs, cOcbReadAttributionRowGroupReadNs, cOcbReadAttributionReadIoNs, cOcbReadAttributionChecksumNs, cOcbReadAttributionDecompressionNs, cOcbReadAttributionPrimitiveDecodeNs, cOcbReadAttributionHasNativeToCCopyNs, cOcbReadAttributionNativeToCCopyNs, cOcbReadAttributionHasWrapperCopyNs, cOcbReadAttributionWrapperCopyNs, cOcbReadAttributionBytesRead, cOcbReadAttributionCompressedBytes, cOcbReadAttributionUncompressedBytes, cOcbReadAttributionRequestedThreads, cOcbReadAttributionEffectiveThreads, cOcbReadAttributionSelectedRowGroups, cOcbReadAttributionPrunedRowGroups, cOcbReadAttributionSelectedColumnChunks, cOcbReadAttributionFallbackReason} = do
    fillBytes ptr 0 208
    pokeByteOff ptr 0 cOcbReadAttributionVersion
    pokeByteOff ptr 8 cOcbReadAttributionStructSize
    pokeByteOff ptr 16 cOcbReadAttributionPlanNs
    pokeByteOff ptr 24 cOcbReadAttributionExecuteWallNs
    pokeByteOff ptr 32 cOcbReadAttributionRowGroupReadNs
    pokeByteOff ptr 40 cOcbReadAttributionReadIoNs
    pokeByteOff ptr 48 cOcbReadAttributionChecksumNs
    pokeByteOff ptr 56 cOcbReadAttributionDecompressionNs
    pokeByteOff ptr 64 cOcbReadAttributionPrimitiveDecodeNs
    pokeByteOff ptr 72 cOcbReadAttributionHasNativeToCCopyNs
    pokeByteOff ptr 80 cOcbReadAttributionNativeToCCopyNs
    pokeByteOff ptr 88 cOcbReadAttributionHasWrapperCopyNs
    pokeByteOff ptr 96 cOcbReadAttributionWrapperCopyNs
    pokeByteOff ptr 104 cOcbReadAttributionBytesRead
    pokeByteOff ptr 112 cOcbReadAttributionCompressedBytes
    pokeByteOff ptr 120 cOcbReadAttributionUncompressedBytes
    pokeByteOff ptr 128 cOcbReadAttributionRequestedThreads
    pokeByteOff ptr 136 cOcbReadAttributionEffectiveThreads
    pokeByteOff ptr 144 cOcbReadAttributionSelectedRowGroups
    pokeByteOff ptr 152 cOcbReadAttributionPrunedRowGroups
    pokeByteOff ptr 160 cOcbReadAttributionSelectedColumnChunks
    pokeByteOff ptr 168 cOcbReadAttributionFallbackReason

emptyCArcadiaTioOcbReadAttribution :: CArcadiaTioOcbReadAttribution
emptyCArcadiaTioOcbReadAttribution = CArcadiaTioOcbReadAttribution 1 208 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 nullPtr

-- | Raw OCB column array matching @ArcadiaTioOcbColumnArray@.
data CArcadiaTioOcbColumnArray = CArcadiaTioOcbColumnArray
  { cOcbColumnArrayVersion :: Word32
  , cOcbColumnArrayStructSize :: CSize
  , cOcbColumnArrayColumnId :: Word32
  , cOcbColumnArrayName :: CString
  , cOcbColumnArrayPhysicalType :: CInt
  , cOcbColumnArrayLogicalKind :: CInt
  , cOcbColumnArrayHasDictionaryId :: Word8
  , cOcbColumnArrayDictionaryId :: Word32
  , cOcbColumnArrayValues :: CArcadiaTioOcbPrimitiveValues
  , cOcbColumnArrayHasValidity :: Word8
  , cOcbColumnArrayValidity :: CArcadiaTioOcbValidityBitmap
  , cOcbColumnArrayReserved0 :: Word64
  , cOcbColumnArrayReserved1 :: Word64
  , cOcbColumnArrayReserved2 :: Word64
  , cOcbColumnArrayReserved3 :: Word64
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbColumnArray where
  sizeOf _ = 216
  alignment _ = 8
  peek ptr = CArcadiaTioOcbColumnArray <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 36 <*> peekByteOff ptr 40 <*> peekByteOff ptr 44 <*> peekByteOff ptr 48 <*> peekByteOff ptr 112 <*> peekByteOff ptr 120 <*> peekByteOff ptr 184 <*> peekByteOff ptr 192 <*> peekByteOff ptr 200 <*> peekByteOff ptr 208
  poke ptr CArcadiaTioOcbColumnArray{cOcbColumnArrayVersion, cOcbColumnArrayStructSize, cOcbColumnArrayColumnId, cOcbColumnArrayName, cOcbColumnArrayPhysicalType, cOcbColumnArrayLogicalKind, cOcbColumnArrayHasDictionaryId, cOcbColumnArrayDictionaryId, cOcbColumnArrayValues, cOcbColumnArrayHasValidity, cOcbColumnArrayValidity, cOcbColumnArrayReserved0, cOcbColumnArrayReserved1, cOcbColumnArrayReserved2, cOcbColumnArrayReserved3} = do
    fillBytes ptr 0 216
    pokeByteOff ptr 0 cOcbColumnArrayVersion
    pokeByteOff ptr 8 cOcbColumnArrayStructSize
    pokeByteOff ptr 16 cOcbColumnArrayColumnId
    pokeByteOff ptr 24 cOcbColumnArrayName
    pokeByteOff ptr 32 cOcbColumnArrayPhysicalType
    pokeByteOff ptr 36 cOcbColumnArrayLogicalKind
    pokeByteOff ptr 40 cOcbColumnArrayHasDictionaryId
    pokeByteOff ptr 44 cOcbColumnArrayDictionaryId
    pokeByteOff ptr 48 cOcbColumnArrayValues
    pokeByteOff ptr 112 cOcbColumnArrayHasValidity
    pokeByteOff ptr 120 cOcbColumnArrayValidity
    pokeByteOff ptr 184 cOcbColumnArrayReserved0
    pokeByteOff ptr 192 cOcbColumnArrayReserved1
    pokeByteOff ptr 200 cOcbColumnArrayReserved2
    pokeByteOff ptr 208 cOcbColumnArrayReserved3

-- | Raw OCB column batch matching @ArcadiaTioOcbColumnBatch@.
data CArcadiaTioOcbColumnBatch = CArcadiaTioOcbColumnBatch
  { cOcbColumnBatchVersion :: Word32
  , cOcbColumnBatchStructSize :: CSize
  , cOcbColumnBatchRowGroupId :: Word32
  , cOcbColumnBatchBaseRow :: Word64
  , cOcbColumnBatchRowCount :: Word64
  , cOcbColumnBatchColumns :: Ptr CArcadiaTioOcbColumnArray
  , cOcbColumnBatchColumnsLen :: CSize
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbColumnBatch where
  sizeOf _ = 88
  alignment _ = 8
  peek ptr = CArcadiaTioOcbColumnBatch <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 40 <*> peekByteOff ptr 48
  poke ptr CArcadiaTioOcbColumnBatch{cOcbColumnBatchVersion, cOcbColumnBatchStructSize, cOcbColumnBatchRowGroupId, cOcbColumnBatchBaseRow, cOcbColumnBatchRowCount, cOcbColumnBatchColumns, cOcbColumnBatchColumnsLen} = do
    fillBytes ptr 0 88
    pokeByteOff ptr 0 cOcbColumnBatchVersion
    pokeByteOff ptr 8 cOcbColumnBatchStructSize
    pokeByteOff ptr 16 cOcbColumnBatchRowGroupId
    pokeByteOff ptr 24 cOcbColumnBatchBaseRow
    pokeByteOff ptr 32 cOcbColumnBatchRowCount
    pokeByteOff ptr 40 cOcbColumnBatchColumns
    pokeByteOff ptr 48 cOcbColumnBatchColumnsLen

-- | Raw OCB read outcome matching @ArcadiaTioOcbReadOutcome@.
data CArcadiaTioOcbReadOutcome = CArcadiaTioOcbReadOutcome
  { cOcbReadOutcomeVersion :: Word32
  , cOcbReadOutcomeStructSize :: CSize
  , cOcbReadOutcomeBatches :: Ptr CArcadiaTioOcbColumnBatch
  , cOcbReadOutcomeBatchesLen :: CSize
  , cOcbReadOutcomeReport :: CArcadiaTioOcbReadReport
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbReadOutcome where
  sizeOf _ = 160
  alignment _ = 8
  peek ptr = CArcadiaTioOcbReadOutcome <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32
  poke ptr CArcadiaTioOcbReadOutcome{cOcbReadOutcomeVersion, cOcbReadOutcomeStructSize, cOcbReadOutcomeBatches, cOcbReadOutcomeBatchesLen, cOcbReadOutcomeReport} = do
    fillBytes ptr 0 160
    pokeByteOff ptr 0 cOcbReadOutcomeVersion
    pokeByteOff ptr 8 cOcbReadOutcomeStructSize
    pokeByteOff ptr 16 cOcbReadOutcomeBatches
    pokeByteOff ptr 24 cOcbReadOutcomeBatchesLen
    pokeByteOff ptr 32 cOcbReadOutcomeReport

emptyCArcadiaTioOcbReadOutcome :: CArcadiaTioOcbReadOutcome
emptyCArcadiaTioOcbReadOutcome = CArcadiaTioOcbReadOutcome 1 160 nullPtr 0 emptyCArcadiaTioOcbReadReport

-- | Raw OCB cursor options matching @ArcadiaTioOcbReadCursorOptions@.
data CArcadiaTioOcbReadCursorOptions = CArcadiaTioOcbReadCursorOptions
  { cOcbReadCursorOptionsVersion :: Word32
  , cOcbReadCursorOptionsStructSize :: CSize
  , cOcbReadCursorOptionsMaxInFlightRowGroups :: CSize
  , cOcbReadCursorOptionsOrdered :: Word8
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbReadCursorOptions where
  sizeOf _ = 96
  alignment _ = 8
  peek ptr = CArcadiaTioOcbReadCursorOptions <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24
  poke ptr CArcadiaTioOcbReadCursorOptions{cOcbReadCursorOptionsVersion, cOcbReadCursorOptionsStructSize, cOcbReadCursorOptionsMaxInFlightRowGroups, cOcbReadCursorOptionsOrdered} = do
    fillBytes ptr 0 96
    pokeByteOff ptr 0 cOcbReadCursorOptionsVersion
    pokeByteOff ptr 8 cOcbReadCursorOptionsStructSize
    pokeByteOff ptr 16 cOcbReadCursorOptionsMaxInFlightRowGroups
    pokeByteOff ptr 24 cOcbReadCursorOptionsOrdered

emptyCArcadiaTioOcbReadCursorOptions :: CArcadiaTioOcbReadCursorOptions
emptyCArcadiaTioOcbReadCursorOptions = CArcadiaTioOcbReadCursorOptions 1 96 0 0

-- | Raw OCB cursor report matching @ArcadiaTioOcbReadCursorReport@.
data CArcadiaTioOcbReadCursorReport = CArcadiaTioOcbReadCursorReport
  { cOcbReadCursorReportVersion :: Word32
  , cOcbReadCursorReportStructSize :: CSize
  , cOcbReadCursorReportBaseReport :: CArcadiaTioOcbReadReport
  , cOcbReadCursorReportBatchesYielded :: CSize
  , cOcbReadCursorReportRowsYielded :: Word64
  , cOcbReadCursorReportCancelled :: Word8
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbReadCursorReport where
  sizeOf _ = 168
  alignment _ = 8
  peek ptr = CArcadiaTioOcbReadCursorReport <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 112 <*> peekByteOff ptr 120 <*> peekByteOff ptr 128
  poke ptr CArcadiaTioOcbReadCursorReport{cOcbReadCursorReportVersion, cOcbReadCursorReportStructSize, cOcbReadCursorReportBaseReport, cOcbReadCursorReportBatchesYielded, cOcbReadCursorReportRowsYielded, cOcbReadCursorReportCancelled} = do
    fillBytes ptr 0 168
    pokeByteOff ptr 0 cOcbReadCursorReportVersion
    pokeByteOff ptr 8 cOcbReadCursorReportStructSize
    pokeByteOff ptr 16 cOcbReadCursorReportBaseReport
    pokeByteOff ptr 112 cOcbReadCursorReportBatchesYielded
    pokeByteOff ptr 120 cOcbReadCursorReportRowsYielded
    pokeByteOff ptr 128 cOcbReadCursorReportCancelled

emptyCArcadiaTioOcbReadCursorReport :: CArcadiaTioOcbReadCursorReport
emptyCArcadiaTioOcbReadCursorReport = CArcadiaTioOcbReadCursorReport 1 168 emptyCArcadiaTioOcbReadReport 0 0 0

-- | Raw OCB caller-owned column fill buffer matching @ArcadiaTioOcbColumnFillBuffer@.
data CArcadiaTioOcbColumnFillBuffer = CArcadiaTioOcbColumnFillBuffer
  { cOcbColumnFillBufferVersion :: Word32
  , cOcbColumnFillBufferStructSize :: CSize
  , cOcbColumnFillBufferColumnName :: CString
  , cOcbColumnFillBufferColumnId :: Word32
  , cOcbColumnFillBufferHasColumnId :: Word8
  , cOcbColumnFillBufferPhysicalType :: CInt
  , cOcbColumnFillBufferValues :: Ptr ()
  , cOcbColumnFillBufferValuesLen :: CSize
  , cOcbColumnFillBufferValidityBytes :: Ptr Word8
  , cOcbColumnFillBufferValidityBytesLen :: CSize
  , cOcbColumnFillBufferAllowNulls :: Word8
  , cOcbColumnFillBufferRowsFilled :: CSize
  , cOcbColumnFillBufferValidityFilled :: Word8
  , cOcbColumnFillBufferReserved0 :: Word64
  , cOcbColumnFillBufferReserved1 :: Word64
  , cOcbColumnFillBufferReserved2 :: Word64
  , cOcbColumnFillBufferReserved3 :: Word64
  , cOcbColumnFillBufferReserved4 :: Word64
  , cOcbColumnFillBufferReserved5 :: Word64
  , cOcbColumnFillBufferReserved6 :: Word64
  , cOcbColumnFillBufferReserved7 :: Word64
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbColumnFillBuffer where
  sizeOf _ = 160
  alignment _ = 8
  peek ptr = CArcadiaTioOcbColumnFillBuffer <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 28 <*> peekByteOff ptr 32 <*> peekByteOff ptr 40 <*> peekByteOff ptr 48 <*> peekByteOff ptr 56 <*> peekByteOff ptr 64 <*> peekByteOff ptr 72 <*> peekByteOff ptr 80 <*> peekByteOff ptr 88 <*> peekByteOff ptr 96 <*> peekByteOff ptr 104 <*> peekByteOff ptr 112 <*> peekByteOff ptr 120 <*> peekByteOff ptr 128 <*> peekByteOff ptr 136 <*> peekByteOff ptr 144 <*> peekByteOff ptr 152
  poke ptr CArcadiaTioOcbColumnFillBuffer{cOcbColumnFillBufferVersion, cOcbColumnFillBufferStructSize, cOcbColumnFillBufferColumnName, cOcbColumnFillBufferColumnId, cOcbColumnFillBufferHasColumnId, cOcbColumnFillBufferPhysicalType, cOcbColumnFillBufferValues, cOcbColumnFillBufferValuesLen, cOcbColumnFillBufferValidityBytes, cOcbColumnFillBufferValidityBytesLen, cOcbColumnFillBufferAllowNulls, cOcbColumnFillBufferRowsFilled, cOcbColumnFillBufferValidityFilled, cOcbColumnFillBufferReserved0, cOcbColumnFillBufferReserved1, cOcbColumnFillBufferReserved2, cOcbColumnFillBufferReserved3, cOcbColumnFillBufferReserved4, cOcbColumnFillBufferReserved5, cOcbColumnFillBufferReserved6, cOcbColumnFillBufferReserved7} = do
    fillBytes ptr 0 160
    pokeByteOff ptr 0 cOcbColumnFillBufferVersion
    pokeByteOff ptr 8 cOcbColumnFillBufferStructSize
    pokeByteOff ptr 16 cOcbColumnFillBufferColumnName
    pokeByteOff ptr 24 cOcbColumnFillBufferColumnId
    pokeByteOff ptr 28 cOcbColumnFillBufferHasColumnId
    pokeByteOff ptr 32 cOcbColumnFillBufferPhysicalType
    pokeByteOff ptr 40 cOcbColumnFillBufferValues
    pokeByteOff ptr 48 cOcbColumnFillBufferValuesLen
    pokeByteOff ptr 56 cOcbColumnFillBufferValidityBytes
    pokeByteOff ptr 64 cOcbColumnFillBufferValidityBytesLen
    pokeByteOff ptr 72 cOcbColumnFillBufferAllowNulls
    pokeByteOff ptr 80 cOcbColumnFillBufferRowsFilled
    pokeByteOff ptr 88 cOcbColumnFillBufferValidityFilled
    pokeByteOff ptr 96 cOcbColumnFillBufferReserved0
    pokeByteOff ptr 104 cOcbColumnFillBufferReserved1
    pokeByteOff ptr 112 cOcbColumnFillBufferReserved2
    pokeByteOff ptr 120 cOcbColumnFillBufferReserved3
    pokeByteOff ptr 128 cOcbColumnFillBufferReserved4
    pokeByteOff ptr 136 cOcbColumnFillBufferReserved5
    pokeByteOff ptr 144 cOcbColumnFillBufferReserved6
    pokeByteOff ptr 152 cOcbColumnFillBufferReserved7

emptyCArcadiaTioOcbColumnFillBuffer :: CArcadiaTioOcbColumnFillBuffer
emptyCArcadiaTioOcbColumnFillBuffer = CArcadiaTioOcbColumnFillBuffer 1 160 nullPtr 0 0 0 nullPtr 0 nullPtr 0 0 0 0 0 0 0 0 0 0 0 0

-- | Raw OCB row-group fill request matching @ArcadiaTioOcbRowGroupFillRequest@.
data CArcadiaTioOcbRowGroupFillRequest = CArcadiaTioOcbRowGroupFillRequest
  { cOcbRowGroupFillRequestVersion :: Word32
  , cOcbRowGroupFillRequestStructSize :: CSize
  , cOcbRowGroupFillRequestRowGroupId :: Word32
  , cOcbRowGroupFillRequestColumns :: Ptr CArcadiaTioOcbColumnFillBuffer
  , cOcbRowGroupFillRequestColumnsLen :: CSize
  , cOcbRowGroupFillRequestValidateChecksums :: Word8
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbRowGroupFillRequest where
  sizeOf _ = 112
  alignment _ = 8
  peek ptr = CArcadiaTioOcbRowGroupFillRequest <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 40
  poke ptr CArcadiaTioOcbRowGroupFillRequest{cOcbRowGroupFillRequestVersion, cOcbRowGroupFillRequestStructSize, cOcbRowGroupFillRequestRowGroupId, cOcbRowGroupFillRequestColumns, cOcbRowGroupFillRequestColumnsLen, cOcbRowGroupFillRequestValidateChecksums} = do
    fillBytes ptr 0 112
    pokeByteOff ptr 0 cOcbRowGroupFillRequestVersion
    pokeByteOff ptr 8 cOcbRowGroupFillRequestStructSize
    pokeByteOff ptr 16 cOcbRowGroupFillRequestRowGroupId
    pokeByteOff ptr 24 cOcbRowGroupFillRequestColumns
    pokeByteOff ptr 32 cOcbRowGroupFillRequestColumnsLen
    pokeByteOff ptr 40 cOcbRowGroupFillRequestValidateChecksums

emptyCArcadiaTioOcbRowGroupFillRequest :: CArcadiaTioOcbRowGroupFillRequest
emptyCArcadiaTioOcbRowGroupFillRequest = CArcadiaTioOcbRowGroupFillRequest 1 112 0 nullPtr 0 1

-- | Raw OCB row-group fill report matching @ArcadiaTioOcbReadFillReport@.
data CArcadiaTioOcbReadFillReport = CArcadiaTioOcbReadFillReport
  { cOcbReadFillReportVersion :: Word32
  , cOcbReadFillReportStructSize :: CSize
  , cOcbReadFillReportRowGroupId :: Word32
  , cOcbReadFillReportBaseRow :: Word64
  , cOcbReadFillReportRowCount :: Word64
  , cOcbReadFillReportColumnsFilled :: CSize
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbReadFillReport where
  sizeOf _ = 112
  alignment _ = 8
  peek ptr = CArcadiaTioOcbReadFillReport <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 40
  poke ptr CArcadiaTioOcbReadFillReport{cOcbReadFillReportVersion, cOcbReadFillReportStructSize, cOcbReadFillReportRowGroupId, cOcbReadFillReportBaseRow, cOcbReadFillReportRowCount, cOcbReadFillReportColumnsFilled} = do
    fillBytes ptr 0 112
    pokeByteOff ptr 0 cOcbReadFillReportVersion
    pokeByteOff ptr 8 cOcbReadFillReportStructSize
    pokeByteOff ptr 16 cOcbReadFillReportRowGroupId
    pokeByteOff ptr 24 cOcbReadFillReportBaseRow
    pokeByteOff ptr 32 cOcbReadFillReportRowCount
    pokeByteOff ptr 40 cOcbReadFillReportColumnsFilled

emptyCArcadiaTioOcbReadFillReport :: CArcadiaTioOcbReadFillReport
emptyCArcadiaTioOcbReadFillReport = CArcadiaTioOcbReadFillReport 1 112 0 0 0 0


-- | Raw OCB body-reference summary matching @ArcadiaTioOcbBodyRefSummary@.
data CArcadiaTioOcbBodyRefSummary = CArcadiaTioOcbBodyRefSummary
  { cOcbBodyRefSummaryVersion :: Word32
  , cOcbBodyRefSummaryStructSize :: CSize
  , cOcbBodyRefSummaryOffset :: Word64
  , cOcbBodyRefSummaryLength :: Word64
  , cOcbBodyRefSummaryKind :: CInt
  , cOcbBodyRefSummaryFlags :: Word16
  , cOcbBodyRefSummaryChecksumKind :: CInt
  , cOcbBodyRefSummaryChecksum :: Word32
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbBodyRefSummary where
  sizeOf _ = 80
  alignment _ = 8
  peek ptr = CArcadiaTioOcbBodyRefSummary <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 36 <*> peekByteOff ptr 40 <*> peekByteOff ptr 44
  poke ptr CArcadiaTioOcbBodyRefSummary{cOcbBodyRefSummaryVersion, cOcbBodyRefSummaryStructSize, cOcbBodyRefSummaryOffset, cOcbBodyRefSummaryLength, cOcbBodyRefSummaryKind, cOcbBodyRefSummaryFlags, cOcbBodyRefSummaryChecksumKind, cOcbBodyRefSummaryChecksum} = do
    fillBytes ptr 0 80
    pokeByteOff ptr 0 cOcbBodyRefSummaryVersion
    pokeByteOff ptr 8 cOcbBodyRefSummaryStructSize
    pokeByteOff ptr 16 cOcbBodyRefSummaryOffset
    pokeByteOff ptr 24 cOcbBodyRefSummaryLength
    pokeByteOff ptr 32 cOcbBodyRefSummaryKind
    pokeByteOff ptr 36 cOcbBodyRefSummaryFlags
    pokeByteOff ptr 40 cOcbBodyRefSummaryChecksumKind
    pokeByteOff ptr 44 cOcbBodyRefSummaryChecksum

-- | Raw OCB column-chunk summary matching @ArcadiaTioOcbColumnChunkSummary@.
data CArcadiaTioOcbColumnChunkSummary = CArcadiaTioOcbColumnChunkSummary
  { cOcbColumnChunkSummaryVersion :: Word32
  , cOcbColumnChunkSummaryStructSize :: CSize
  , cOcbColumnChunkSummaryRowGroupId :: Word32
  , cOcbColumnChunkSummaryColumnId :: Word32
  , cOcbColumnChunkSummaryColumnName :: CString
  , cOcbColumnChunkSummaryPhysicalType :: CInt
  , cOcbColumnChunkSummaryLogicalKind :: CInt
  , cOcbColumnChunkSummaryFixedBinaryWidth :: Word32
  , cOcbColumnChunkSummaryCodec :: CInt
  , cOcbColumnChunkSummaryRowCount :: Word64
  , cOcbColumnChunkSummaryCompressedBytes :: Word64
  , cOcbColumnChunkSummaryUncompressedBytes :: Word64
  , cOcbColumnChunkSummaryValueRef :: CArcadiaTioOcbBodyRefSummary
  , cOcbColumnChunkSummaryHasValidityRef :: Word8
  , cOcbColumnChunkSummaryValidityRef :: CArcadiaTioOcbBodyRefSummary
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbColumnChunkSummary where
  sizeOf _ = 272
  alignment _ = 8
  peek ptr = CArcadiaTioOcbColumnChunkSummary <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 20 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 36 <*> peekByteOff ptr 40 <*> peekByteOff ptr 44 <*> peekByteOff ptr 48 <*> peekByteOff ptr 56 <*> peekByteOff ptr 64 <*> peekByteOff ptr 72 <*> peekByteOff ptr 152 <*> peekByteOff ptr 160
  poke ptr CArcadiaTioOcbColumnChunkSummary{cOcbColumnChunkSummaryVersion, cOcbColumnChunkSummaryStructSize, cOcbColumnChunkSummaryRowGroupId, cOcbColumnChunkSummaryColumnId, cOcbColumnChunkSummaryColumnName, cOcbColumnChunkSummaryPhysicalType, cOcbColumnChunkSummaryLogicalKind, cOcbColumnChunkSummaryFixedBinaryWidth, cOcbColumnChunkSummaryCodec, cOcbColumnChunkSummaryRowCount, cOcbColumnChunkSummaryCompressedBytes, cOcbColumnChunkSummaryUncompressedBytes, cOcbColumnChunkSummaryValueRef, cOcbColumnChunkSummaryHasValidityRef, cOcbColumnChunkSummaryValidityRef} = do
    fillBytes ptr 0 272
    pokeByteOff ptr 0 cOcbColumnChunkSummaryVersion
    pokeByteOff ptr 8 cOcbColumnChunkSummaryStructSize
    pokeByteOff ptr 16 cOcbColumnChunkSummaryRowGroupId
    pokeByteOff ptr 20 cOcbColumnChunkSummaryColumnId
    pokeByteOff ptr 24 cOcbColumnChunkSummaryColumnName
    pokeByteOff ptr 32 cOcbColumnChunkSummaryPhysicalType
    pokeByteOff ptr 36 cOcbColumnChunkSummaryLogicalKind
    pokeByteOff ptr 40 cOcbColumnChunkSummaryFixedBinaryWidth
    pokeByteOff ptr 44 cOcbColumnChunkSummaryCodec
    pokeByteOff ptr 48 cOcbColumnChunkSummaryRowCount
    pokeByteOff ptr 56 cOcbColumnChunkSummaryCompressedBytes
    pokeByteOff ptr 64 cOcbColumnChunkSummaryUncompressedBytes
    pokeByteOff ptr 72 cOcbColumnChunkSummaryValueRef
    pokeByteOff ptr 152 cOcbColumnChunkSummaryHasValidityRef
    pokeByteOff ptr 160 cOcbColumnChunkSummaryValidityRef

-- | Raw OCB column-stats summary matching @ArcadiaTioOcbColumnStatsSummary@.
data CArcadiaTioOcbColumnStatsSummary = CArcadiaTioOcbColumnStatsSummary
  { cOcbColumnStatsSummaryVersion :: Word32
  , cOcbColumnStatsSummaryStructSize :: CSize
  , cOcbColumnStatsSummaryRowGroupId :: Word32
  , cOcbColumnStatsSummaryColumnId :: Word32
  , cOcbColumnStatsSummaryColumnName :: CString
  , cOcbColumnStatsSummaryPhysicalType :: CInt
  , cOcbColumnStatsSummaryNullCount :: Word32
  , cOcbColumnStatsSummaryMin :: CArcadiaTioOcbPredicateValue
  , cOcbColumnStatsSummaryMax :: CArcadiaTioOcbPredicateValue
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbColumnStatsSummary where
  sizeOf _ = 216
  alignment _ = 8
  peek ptr = CArcadiaTioOcbColumnStatsSummary <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 20 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 36 <*> peekByteOff ptr 40 <*> peekByteOff ptr 112
  poke ptr CArcadiaTioOcbColumnStatsSummary{cOcbColumnStatsSummaryVersion, cOcbColumnStatsSummaryStructSize, cOcbColumnStatsSummaryRowGroupId, cOcbColumnStatsSummaryColumnId, cOcbColumnStatsSummaryColumnName, cOcbColumnStatsSummaryPhysicalType, cOcbColumnStatsSummaryNullCount, cOcbColumnStatsSummaryMin, cOcbColumnStatsSummaryMax} = do
    fillBytes ptr 0 216
    pokeByteOff ptr 0 cOcbColumnStatsSummaryVersion
    pokeByteOff ptr 8 cOcbColumnStatsSummaryStructSize
    pokeByteOff ptr 16 cOcbColumnStatsSummaryRowGroupId
    pokeByteOff ptr 20 cOcbColumnStatsSummaryColumnId
    pokeByteOff ptr 24 cOcbColumnStatsSummaryColumnName
    pokeByteOff ptr 32 cOcbColumnStatsSummaryPhysicalType
    pokeByteOff ptr 36 cOcbColumnStatsSummaryNullCount
    pokeByteOff ptr 40 cOcbColumnStatsSummaryMin
    pokeByteOff ptr 112 cOcbColumnStatsSummaryMax

-- | Raw OCB row-group summary matching @ArcadiaTioOcbRowGroupSummary@.
data CArcadiaTioOcbRowGroupSummary = CArcadiaTioOcbRowGroupSummary
  { cOcbRowGroupSummaryVersion :: Word32
  , cOcbRowGroupSummaryStructSize :: CSize
  , cOcbRowGroupSummaryRowGroupId :: Word32
  , cOcbRowGroupSummaryBaseRow :: Word64
  , cOcbRowGroupSummaryRowCount :: Word64
  , cOcbRowGroupSummaryHasFirstKeyTupleRef :: Word8
  , cOcbRowGroupSummaryFirstKeyTupleRef :: CArcadiaTioOcbBodyRefSummary
  , cOcbRowGroupSummaryHasLastKeyTupleRef :: Word8
  , cOcbRowGroupSummaryLastKeyTupleRef :: CArcadiaTioOcbBodyRefSummary
  , cOcbRowGroupSummaryChunks :: Ptr CArcadiaTioOcbColumnChunkSummary
  , cOcbRowGroupSummaryChunksLen :: CSize
  , cOcbRowGroupSummaryStats :: Ptr CArcadiaTioOcbColumnStatsSummary
  , cOcbRowGroupSummaryStatsLen :: CSize
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbRowGroupSummary where
  sizeOf _ = 280
  alignment _ = 8
  peek ptr = CArcadiaTioOcbRowGroupSummary <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24 <*> peekByteOff ptr 32 <*> peekByteOff ptr 40 <*> peekByteOff ptr 48 <*> peekByteOff ptr 128 <*> peekByteOff ptr 136 <*> peekByteOff ptr 216 <*> peekByteOff ptr 224 <*> peekByteOff ptr 232 <*> peekByteOff ptr 240
  poke ptr CArcadiaTioOcbRowGroupSummary{cOcbRowGroupSummaryVersion, cOcbRowGroupSummaryStructSize, cOcbRowGroupSummaryRowGroupId, cOcbRowGroupSummaryBaseRow, cOcbRowGroupSummaryRowCount, cOcbRowGroupSummaryHasFirstKeyTupleRef, cOcbRowGroupSummaryFirstKeyTupleRef, cOcbRowGroupSummaryHasLastKeyTupleRef, cOcbRowGroupSummaryLastKeyTupleRef, cOcbRowGroupSummaryChunks, cOcbRowGroupSummaryChunksLen, cOcbRowGroupSummaryStats, cOcbRowGroupSummaryStatsLen} = do
    fillBytes ptr 0 280
    pokeByteOff ptr 0 cOcbRowGroupSummaryVersion
    pokeByteOff ptr 8 cOcbRowGroupSummaryStructSize
    pokeByteOff ptr 16 cOcbRowGroupSummaryRowGroupId
    pokeByteOff ptr 24 cOcbRowGroupSummaryBaseRow
    pokeByteOff ptr 32 cOcbRowGroupSummaryRowCount
    pokeByteOff ptr 40 cOcbRowGroupSummaryHasFirstKeyTupleRef
    pokeByteOff ptr 48 cOcbRowGroupSummaryFirstKeyTupleRef
    pokeByteOff ptr 128 cOcbRowGroupSummaryHasLastKeyTupleRef
    pokeByteOff ptr 136 cOcbRowGroupSummaryLastKeyTupleRef
    pokeByteOff ptr 216 cOcbRowGroupSummaryChunks
    pokeByteOff ptr 224 cOcbRowGroupSummaryChunksLen
    pokeByteOff ptr 232 cOcbRowGroupSummaryStats
    pokeByteOff ptr 240 cOcbRowGroupSummaryStatsLen

-- | Raw OCB row-group summaries matching @ArcadiaTioOcbRowGroupSummaries@.
data CArcadiaTioOcbRowGroupSummaries = CArcadiaTioOcbRowGroupSummaries
  { cOcbRowGroupSummariesVersion :: Word32
  , cOcbRowGroupSummariesStructSize :: CSize
  , cOcbRowGroupSummariesRowGroups :: Ptr CArcadiaTioOcbRowGroupSummary
  , cOcbRowGroupSummariesRowGroupsLen :: CSize
  }
  deriving (Eq, Show)

instance Storable CArcadiaTioOcbRowGroupSummaries where
  sizeOf _ = 64
  alignment _ = 8
  peek ptr = CArcadiaTioOcbRowGroupSummaries <$> peekByteOff ptr 0 <*> peekByteOff ptr 8 <*> peekByteOff ptr 16 <*> peekByteOff ptr 24
  poke ptr CArcadiaTioOcbRowGroupSummaries{cOcbRowGroupSummariesVersion, cOcbRowGroupSummariesStructSize, cOcbRowGroupSummariesRowGroups, cOcbRowGroupSummariesRowGroupsLen} = do
    fillBytes ptr 0 64
    pokeByteOff ptr 0 cOcbRowGroupSummariesVersion
    pokeByteOff ptr 8 cOcbRowGroupSummariesStructSize
    pokeByteOff ptr 16 cOcbRowGroupSummariesRowGroups
    pokeByteOff ptr 24 cOcbRowGroupSummariesRowGroupsLen

emptyCArcadiaTioOcbRowGroupSummaries :: CArcadiaTioOcbRowGroupSummaries
emptyCArcadiaTioOcbRowGroupSummaries = CArcadiaTioOcbRowGroupSummaries 1 64 nullPtr 0

type LastErrorMessageFn = IO CString
type LastErrorCodeFn = IO CInt
type AbiVersionFn = IO Word32
type CreateStreamingFn = CString -> CInt -> Ptr CInt -> Ptr Word32 -> CSize -> CSize -> IO (Ptr CHandle)
type CreateRandomAccessFn = CString -> CInt -> Ptr CInt -> Ptr Word32 -> CSize -> CSize -> IO (Ptr CHandle)
type CreateExFn = CString -> CInt -> Ptr CInt -> Ptr Word32 -> CSize -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> Ptr CString -> CSize -> IO (Ptr CHandle)
type CreateWithUniverseFn = CString -> CInt -> Ptr CInt -> Ptr Word32 -> CSize -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> Ptr CString -> CSize -> Ptr CArcadiaTioCreateWithUniverseOptions -> IO (Ptr CHandle)
type CreateInferredFn = CString -> CInt -> Ptr CInt -> Ptr Word32 -> CSize -> CSize -> CInt -> CInt -> CInt -> CInt -> IO (Ptr CHandle)
type CreateInferredExFn = CString -> CInt -> Ptr CInt -> Ptr Word32 -> CSize -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> Ptr CString -> CSize -> CInt -> CInt -> CInt -> CInt -> IO (Ptr CHandle)
type CreateWithPolicyFn = CString -> CInt -> Ptr CInt -> Ptr Word32 -> CSize -> CSize -> Ptr CSize -> CSize -> CInt -> Ptr Word32 -> CSize -> IO (Ptr CHandle)
type CreateWithPolicyExFn = CString -> CInt -> Ptr CInt -> Ptr Word32 -> CSize -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> Ptr CString -> CSize -> Ptr CSize -> CSize -> CInt -> Ptr Word32 -> CSize -> IO (Ptr CHandle)
type CreateWithPolicyUniverseFn = CString -> CInt -> Ptr CInt -> Ptr Word32 -> CSize -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> Ptr CString -> CSize -> Ptr CSize -> CSize -> CInt -> Ptr Word32 -> CSize -> Ptr CArcadiaTioCreateWithUniverseOptions -> IO (Ptr CHandle)

type CreateWithPolicyWithCoordinatesFn = CString -> CInt -> Ptr CInt -> Ptr Word32 -> CSize -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> Ptr CString -> CSize -> Ptr CSize -> CSize -> CInt -> Ptr Word32 -> CSize -> Ptr CArcadiaTioAxisCoordinateInput -> CSize -> IO (Ptr CHandle)
type CreateInferredWithCoordinatesFn = CString -> CInt -> Ptr CInt -> Ptr Word32 -> CSize -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> Ptr CString -> CSize -> CInt -> CInt -> CInt -> CInt -> Ptr CArcadiaTioAxisCoordinateInput -> CSize -> IO (Ptr CHandle)
type CreateStreamingWithCoordinatesFn = CString -> CInt -> Ptr CInt -> Ptr Word32 -> CSize -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> Ptr CString -> CSize -> Ptr CArcadiaTioAxisCoordinateInput -> CSize -> IO (Ptr CHandle)
type CreateWithPolicyWithCoordinatesV2Fn = CString -> CInt -> Ptr CInt -> Ptr Word32 -> CSize -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> Ptr CString -> CSize -> Ptr CSize -> CSize -> CInt -> Ptr Word32 -> CSize -> Ptr CArcadiaTioAxisCoordinateInputV2 -> CSize -> Ptr CArcadiaTioCoordinateV2Options -> IO (Ptr CHandle)
type CreateInferredWithCoordinatesV2Fn = CString -> CInt -> Ptr CInt -> Ptr Word32 -> CSize -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> Ptr CString -> CSize -> CInt -> CInt -> CInt -> CInt -> Ptr CArcadiaTioAxisCoordinateInputV2 -> CSize -> Ptr CArcadiaTioCoordinateV2Options -> IO (Ptr CHandle)
type CreateStreamingWithCoordinatesV2Fn = CString -> CInt -> Ptr CInt -> Ptr Word32 -> CSize -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> Ptr CString -> CSize -> Ptr CArcadiaTioAxisCoordinateInputV2 -> CSize -> Ptr CArcadiaTioCoordinateV2Options -> IO (Ptr CHandle)
type CoordinateMetaFn = Ptr CHandle -> Ptr (Ptr CArcadiaTioAxisCoordinateMeta) -> Ptr CSize -> IO CInt
type LoadCoordinateMetaFn = CString -> Ptr (Ptr CArcadiaTioAxisCoordinateMeta) -> Ptr CSize -> IO CInt
type AxisCoordinateMetaFreeFn = Ptr CArcadiaTioAxisCoordinateMeta -> CSize -> IO ()
type CoordinateMetaV2Fn = Ptr CHandle -> Ptr (Ptr CArcadiaTioAxisCoordinateMetaV2) -> Ptr CSize -> IO CInt
type LoadCoordinateMetaV2Fn = CString -> Ptr (Ptr CArcadiaTioAxisCoordinateMetaV2) -> Ptr CSize -> IO CInt
type AxisCoordinateMetaV2FreeFn = Ptr CArcadiaTioAxisCoordinateMetaV2 -> CSize -> IO ()
type ReadAxisCoordinatesFn = Ptr CHandle -> CSize -> Ptr CArcadiaTioTensor -> IO CInt
type CoordinateIndexI32Fn = Ptr CHandle -> CSize -> Int32 -> Ptr Word32 -> IO CInt
type CoordinateIndexI64Fn = Ptr CHandle -> CSize -> Int64 -> Ptr Word32 -> IO CInt
type CoordinateRangeI32Fn = Ptr CHandle -> CSize -> Int32 -> Int32 -> Ptr Word32 -> Ptr Word32 -> IO CInt
type CoordinateRangeI64Fn = Ptr CHandle -> CSize -> Int64 -> Int64 -> Ptr Word32 -> Ptr Word32 -> IO CInt
type ReadAxisCoordinatesV2Fn = Ptr CHandle -> CSize -> Ptr CArcadiaTioCoordinateV2Options -> Ptr CArcadiaTioCoordinateValueSliceV2 -> IO CInt
type CoordinateValueSliceV2FreeFn = Ptr CArcadiaTioCoordinateValueSliceV2 -> IO ()
type CoordinateDictionaryV2Fn = Ptr CHandle -> CSize -> Ptr CArcadiaTioCoordinateV2Options -> Ptr CArcadiaTioCoordinateDictionaryV2 -> IO CInt
type CoordinateDictionaryV2FreeFn = Ptr CArcadiaTioCoordinateDictionaryV2 -> IO ()
type CoordinateLookupV2Fn = Ptr CHandle -> CSize -> Ptr CArcadiaTioCoordinateLookupKeyV2 -> Ptr CArcadiaTioCoordinateV2Options -> Ptr CArcadiaTioCoordinateLookupResultV2 -> IO CInt
type CoordinateLookupRangeV2Fn = Ptr CHandle -> CSize -> Ptr CArcadiaTioCoordinateLookupKeyV2 -> Ptr CArcadiaTioCoordinateLookupKeyV2 -> Ptr CArcadiaTioCoordinateV2Options -> Ptr CArcadiaTioCoordinateLookupResultV2 -> IO CInt
type CoordinateLookupResultV2FreeFn = Ptr CArcadiaTioCoordinateLookupResultV2 -> IO ()
type AppendWithCoordinatesV2Fn a = Ptr CHandle -> Ptr a -> Ptr Word64 -> CSize -> Ptr CArcadiaTioAppendCoordinateBatchV2 -> Ptr Word32 -> Ptr Word32 -> IO CInt
type OpenFn = CString -> IO (Ptr CHandle)
type CloseFn = Ptr CHandle -> IO ()
type AppendF32WithRangeFn = Ptr CHandle -> Ptr CFloat -> Ptr Word64 -> CSize -> Ptr Word32 -> Ptr Word32 -> IO CInt
type AppendWithUniverseFn a = Ptr CHandle -> Ptr a -> Ptr Word64 -> CSize -> Ptr CArcadiaTioAppendWithUniverseOptions -> Ptr Word32 -> Ptr Word32 -> IO CInt
type AppendF64WithRangeFn = Ptr CHandle -> Ptr Double -> Ptr Word64 -> CSize -> Ptr Word32 -> Ptr Word32 -> IO CInt
type AppendI32WithRangeFn = Ptr CHandle -> Ptr Int32 -> Ptr Word64 -> CSize -> Ptr Word32 -> Ptr Word32 -> IO CInt
type AppendI64WithRangeFn = Ptr CHandle -> Ptr Int64 -> Ptr Word64 -> CSize -> Ptr Word32 -> Ptr Word32 -> IO CInt
type ReadAllFn = Ptr CHandle -> Ptr CArcadiaTioTensor -> IO CInt
type ReadAllDenseFn = Ptr CHandle -> Double -> Ptr CArcadiaTioTensor -> Ptr CArcadiaTioMask -> IO CInt
type ReadAxisRangeFn = Ptr CHandle -> CSize -> Word32 -> Word32 -> Ptr CArcadiaTioTensor -> IO CInt
type ReadAxisTakeFn = Ptr CHandle -> CSize -> Ptr Word32 -> CSize -> Ptr CArcadiaTioTensor -> IO CInt
type ReadAxisOneFn = Ptr CHandle -> CSize -> Word32 -> Ptr CArcadiaTioTensor -> IO CInt
type ReadEntryRangeFn = Ptr CHandle -> Word32 -> Word32 -> Ptr CArcadiaTioTensor -> IO CInt
type TakeEntriesFn = Ptr CHandle -> Ptr Word32 -> CSize -> Ptr CArcadiaTioTensor -> IO CInt
type TensorToContiguousFn = Ptr CArcadiaTioTensor -> Ptr CArcadiaTioTensor -> IO CInt
type TensorReshapeFn = Ptr CArcadiaTioTensor -> Ptr Word64 -> CSize -> Ptr CArcadiaTioTensor -> IO CInt
type TensorFlattenFn = Ptr CArcadiaTioTensor -> Ptr CArcadiaTioTensor -> IO CInt
type TensorExpandDimsFn = Ptr CArcadiaTioTensor -> Int64 -> Ptr CArcadiaTioTensor -> IO CInt
type TensorSqueezeFn = Ptr CArcadiaTioTensor -> Ptr CArcadiaTioTensor -> IO CInt
type TensorSqueezeAxisFn = Ptr CArcadiaTioTensor -> Int64 -> Ptr CArcadiaTioTensor -> IO CInt
type TensorPermuteAxesFn = Ptr CArcadiaTioTensor -> Ptr Int64 -> CSize -> Ptr CArcadiaTioTensor -> IO CInt
type TensorTransposeFn = Ptr CArcadiaTioTensor -> Ptr CArcadiaTioTensor -> IO CInt
type TensorSliceAxisFn = Ptr CArcadiaTioTensor -> Int64 -> Word64 -> Word64 -> Ptr CArcadiaTioTensor -> IO CInt
type TensorSliceAxisStepFn = Ptr CArcadiaTioTensor -> Int64 -> Int64 -> Int64 -> Int64 -> Ptr CArcadiaTioTensor -> IO CInt
type TensorTakeAxisFn = Ptr CArcadiaTioTensor -> Int64 -> Ptr Word64 -> CSize -> Ptr CArcadiaTioTensor -> IO CInt
type TensorIndexAxisFn = Ptr CArcadiaTioTensor -> Int64 -> Word64 -> Ptr CArcadiaTioTensor -> IO CInt
type TensorBinaryOpFn = Ptr CArcadiaTioTensor -> Ptr CArcadiaTioTensor -> Ptr CArcadiaTioTensor -> IO CInt
type TensorScalarOpFn = Ptr CArcadiaTioTensor -> Double -> Ptr CArcadiaTioTensor -> IO CInt
type RankFn = Ptr CHandle -> Ptr CSize -> IO CInt
type DTypeFn = Ptr CHandle -> Ptr CInt -> IO CInt
type AppendAxisFn = Ptr CHandle -> Ptr CSize -> IO CInt
type DimLensFn = Ptr CHandle -> Ptr Word32 -> CSize -> IO CInt
type ChunkPlanFn = Ptr CHandle -> Ptr CArcadiaTioChunkPlan -> IO CInt
type PathFn = Ptr CHandle -> Ptr CString -> IO CInt
type StringFreeFn = CString -> IO ()
type ChunkPlanFreeFn = Ptr CArcadiaTioChunkPlan -> IO ()
type LoadMetaFn = CString -> Ptr CArcadiaTioFileMeta -> IO CInt
type SetDimNameFn = Ptr CHandle -> CSize -> CString -> Word8 -> IO CInt
type SetStringsFn = Ptr CHandle -> Ptr CString -> CSize -> IO CInt
type SetUserKvFn = Ptr CHandle -> Ptr CString -> Ptr CString -> CSize -> IO CInt
type ReadScalarFn = Ptr CHandle -> Ptr Word32 -> CSize -> Ptr CArcadiaTioScalar -> IO CInt
type SetCompressionConfigFn = Ptr CHandle -> Ptr CArcadiaTioCompressionConfig -> IO CInt
type GetCompressionConfigFn = Ptr CHandle -> Ptr CArcadiaTioCompressionConfig -> IO CInt
type HeadCommitFn = Ptr CHandle -> Ptr CArcadiaTioCommitInfo -> IO CInt
type ListCommitsFn = Ptr CHandle -> Word32 -> Ptr CArcadiaTioCommitList -> IO CInt
type CommitListFreeFn = Ptr CArcadiaTioCommitList -> IO ()
type PopFn = Ptr CHandle -> IO CInt
type PopBatchedFn = Ptr CHandle -> Word32 -> IO CInt
type RevertCommitFn = Ptr CHandle -> Word64 -> IO CInt
type ReadAtCommitFn = Ptr CHandle -> Word64 -> Ptr CArcadiaTioEntrySelector -> CSize -> Ptr CArcadiaTioTensor -> IO CInt
type ReadAtCommitDenseFn = Ptr CHandle -> Word64 -> Ptr CArcadiaTioEntrySelector -> CSize -> Double -> Ptr CArcadiaTioTensor -> Ptr CArcadiaTioMask -> IO CInt
type ReadExecutionReportFreeFn = Ptr CArcadiaTioReadExecutionReport -> IO ()
type QueryTraceJsonFreeFn = Ptr CArcadiaTioQueryTraceJson -> IO ()
type HistoricalReadExecutionReportFreeFn = Ptr CArcadiaTioHistoricalReadExecutionReport -> IO ()
type ReadIndexReportFreeFn = Ptr CArcadiaTioReadIndexReport -> IO ()
type ReadIndexFn = Ptr CHandle -> Ptr CArcadiaTioReadIndexItem -> CSize -> Ptr CArcadiaTioTensor -> Ptr CArcadiaTioReadIndexReport -> IO CInt
type ReadWithOptionsFn = Ptr CHandle -> Ptr CArcadiaTioEntrySelector -> CSize -> Ptr CArcadiaTioReadWithOptionsOptions -> Ptr CArcadiaTioTensor -> Ptr CArcadiaTioReadExecutionReport -> IO CInt
type ReadWithOptionsDenseFn = Ptr CHandle -> Ptr CArcadiaTioEntrySelector -> CSize -> Ptr CArcadiaTioReadWithOptionsOptions -> Double -> Ptr CArcadiaTioTensor -> Ptr CArcadiaTioMask -> Ptr CArcadiaTioReadExecutionReport -> IO CInt
type ReadWithShapePolicyFn = Ptr CHandle -> Ptr CArcadiaTioEntrySelector -> CSize -> Ptr CArcadiaTioReadWithShapePolicyOptions -> Ptr CArcadiaTioTensor -> Ptr CArcadiaTioReadExecutionReport -> IO CInt
type ReadWithShapePolicyDenseFn = Ptr CHandle -> Ptr CArcadiaTioEntrySelector -> CSize -> Ptr CArcadiaTioReadWithShapePolicyOptions -> Double -> Ptr CArcadiaTioTensor -> Ptr CArcadiaTioMask -> Ptr CArcadiaTioReadExecutionReport -> IO CInt
type ReadWithOptionsAttributedFn = Ptr CHandle -> Ptr CArcadiaTioEntrySelector -> CSize -> Ptr CArcadiaTioReadWithOptionsOptions -> Ptr CArcadiaTioQueryTraceContext -> Ptr CArcadiaTioTensor -> Ptr CArcadiaTioReadExecutionReport -> Ptr CArcadiaTioQueryTraceJson -> IO CInt
type ReadWithOptionsDenseAttributedFn = Ptr CHandle -> Ptr CArcadiaTioEntrySelector -> CSize -> Ptr CArcadiaTioReadWithOptionsOptions -> Ptr CArcadiaTioQueryTraceContext -> Double -> Ptr CArcadiaTioTensor -> Ptr CArcadiaTioMask -> Ptr CArcadiaTioReadExecutionReport -> Ptr CArcadiaTioQueryTraceJson -> IO CInt
type HistoricalReadWithOptionsFn = Ptr CHandle -> Word64 -> Ptr CArcadiaTioEntrySelector -> CSize -> Ptr CArcadiaTioHistoricalReadWithOptionsOptions -> Ptr CArcadiaTioTensor -> Ptr CArcadiaTioHistoricalReadExecutionReport -> IO CInt
type HistoricalReadWithOptionsDenseFn = Ptr CHandle -> Word64 -> Ptr CArcadiaTioEntrySelector -> CSize -> Ptr CArcadiaTioHistoricalReadWithOptionsOptions -> Double -> Ptr CArcadiaTioTensor -> Ptr CArcadiaTioMask -> Ptr CArcadiaTioHistoricalReadExecutionReport -> IO CInt
type HistoricalReadWithShapePolicyFn = Ptr CHandle -> Word64 -> Ptr CArcadiaTioEntrySelector -> CSize -> Ptr CArcadiaTioHistoricalReadWithShapePolicyOptions -> Ptr CArcadiaTioTensor -> Ptr CArcadiaTioHistoricalReadExecutionReport -> IO CInt
type HistoricalReadWithShapePolicyDenseFn = Ptr CHandle -> Word64 -> Ptr CArcadiaTioEntrySelector -> CSize -> Ptr CArcadiaTioHistoricalReadWithShapePolicyOptions -> Double -> Ptr CArcadiaTioTensor -> Ptr CArcadiaTioMask -> Ptr CArcadiaTioHistoricalReadExecutionReport -> IO CInt
type GetIndexCheckpointEveryCommitsFn = Ptr CHandle -> Ptr Word32 -> IO CInt
type SetIndexCheckpointEveryCommitsFn = Ptr CHandle -> Word32 -> IO CInt
type RewriteF32Fn = Ptr CHandle -> Ptr CArcadiaTioEntrySelector -> Ptr CFloat -> Ptr Word64 -> CSize -> IO CInt
type RewriteF64Fn = Ptr CHandle -> Ptr CArcadiaTioEntrySelector -> Ptr Double -> Ptr Word64 -> CSize -> IO CInt
type RewriteSliceF32Fn = Ptr CHandle -> Ptr CArcadiaTioEntrySelector -> CSize -> Ptr CFloat -> Ptr Word64 -> CSize -> IO CInt
type RewriteSliceF64Fn = Ptr CHandle -> Ptr CArcadiaTioEntrySelector -> CSize -> Ptr Double -> Ptr Word64 -> CSize -> IO CInt
type ClearBlocksFn = Ptr CHandle -> Ptr CArcadiaTioChunkKey -> CSize -> IO CInt
type ReadValuesArrowFn = Ptr CHandle -> Ptr CArrowArray -> Ptr CArrowSchema -> IO CInt
type ArrowArrayReleaseFn = Ptr CArrowArray -> IO ()
type ArrowSchemaReleaseFn = Ptr CArrowSchema -> IO ()
type AnalyzeCompactionFn = Ptr CHandle -> Ptr CArcadiaTioCompactionStats -> IO CInt
type CompactToFn = Ptr CHandle -> CString -> Word32 -> Word64 -> IO CInt
type MaybeCompactFn = Ptr CHandle -> CString -> Double -> Word64 -> Word32 -> Word64 -> Ptr Word8 -> IO CInt
type GetAutoCompactionConfigFn = Ptr CHandle -> Ptr CArcadiaTioAutoCompactionConfig -> Ptr Word8 -> IO CInt
type SetAutoCompactionConfigFn = Ptr CHandle -> Ptr CArcadiaTioAutoCompactionConfig -> Word8 -> IO CInt
type CompactionStateFn = Ptr CHandle -> Ptr CArcadiaTioCompactionState -> Ptr Word8 -> IO CInt
type MaybeCompactAutoFn = Ptr CHandle -> Ptr Word8 -> IO CInt
type V4DiagnosticsFn = Ptr CHandle -> Ptr CArcadiaTioV4DiagnosticsReport -> IO CInt
type V4DiagnosticsReportFreeFn = Ptr CArcadiaTioV4DiagnosticsReport -> IO ()
type V4DiagnosticsPreciseFn = Ptr CHandle -> Ptr CArcadiaTioV4PreciseAccountingOptions -> Ptr CArcadiaTioV4DiagnosticsPreciseReport -> IO CInt
type V4DiagnosticsPreciseReportFreeFn = Ptr CArcadiaTioV4DiagnosticsPreciseReport -> IO ()
type AnalyzeV4CompactionFn = Ptr CHandle -> Ptr CArcadiaTioV4CompactionAnalysisReport -> IO CInt
type V4CompactionAnalysisReportFreeFn = Ptr CArcadiaTioV4CompactionAnalysisReport -> IO ()
type AnalyzeV4CompactionPreciseFn = Ptr CHandle -> Ptr CArcadiaTioV4PreciseAccountingOptions -> Ptr CArcadiaTioV4CompactionAnalysisPreciseReport -> IO CInt
type V4CompactionAnalysisPreciseReportFreeFn = Ptr CArcadiaTioV4CompactionAnalysisPreciseReport -> IO ()
type CompactV4RetainedHistoryToFn = Ptr CHandle -> CString -> Ptr CArcadiaTioV4RetainedHistoryCompactionOptions -> Ptr CArcadiaTioV4RetainedHistoryCompactionReport -> IO CInt
type V4RetainedHistoryCompactionReportFreeFn = Ptr CArcadiaTioV4RetainedHistoryCompactionReport -> IO ()
type CompactV4RetainedHistoryToPreciseFn = Ptr CHandle -> CString -> Ptr CArcadiaTioV4RetainedHistoryCompactionOptions -> Ptr CArcadiaTioV4PreciseAccountingOptions -> Ptr CArcadiaTioV4RetainedHistoryCompactionPreciseReport -> IO CInt
type V4RetainedHistoryCompactionPreciseReportFreeFn = Ptr CArcadiaTioV4RetainedHistoryCompactionPreciseReport -> IO ()
type ReformToFn = Ptr CHandle -> CString -> Ptr CArcadiaTioReformOptions -> IO CInt
type ReformToExFn = Ptr CHandle -> CString -> Ptr CArcadiaTioReformOptions -> Ptr CArcadiaTioReformReport -> IO CInt
type ReformReportFreeFn = Ptr CArcadiaTioReformReport -> IO ()
type AnalyzeSparseAppendV2Fn a = Ptr CHandle -> Ptr a -> Ptr Word64 -> CSize -> Ptr CArcadiaTioSparseRuleV2 -> Ptr CArcadiaTioSparseAppendAnalysis -> IO CInt
type AppendSparseWithRangeV2Fn a = Ptr CHandle -> Ptr a -> Ptr Word64 -> CSize -> Ptr CArcadiaTioSparseRuleV2 -> Ptr Word32 -> Ptr Word32 -> IO CInt
type SparseAppendAnalysisFreeFn = Ptr CArcadiaTioSparseAppendAnalysis -> IO ()
type OcbLastErrorKindFn = IO CInt
type OcbLastErrorCauseFn = IO CInt
type OcbOpenFn = CString -> IO (Ptr COcbFile)
type OcbOpenWithOptionsFn = CString -> Ptr CArcadiaTioOcbOpenOptions -> IO (Ptr COcbFile)
type OcbReaderCloneFn = Ptr COcbFile -> Ptr (Ptr COcbFile) -> IO CInt
type OcbCloseFn = Ptr COcbFile -> IO ()
type OcbMetadataFn = Ptr COcbFile -> Ptr CArcadiaTioOcbMetadata -> IO CInt
type OcbMetadataFreeFn = Ptr CArcadiaTioOcbMetadata -> IO ()
type OcbDictionaryValuesFn = Ptr COcbFile -> Word32 -> Ptr CArcadiaTioOcbDictionaryValues -> IO CInt
type OcbDictionaryValuesFreeFn = Ptr CArcadiaTioOcbDictionaryValues -> IO ()
type OcbOpenOptionsInitFn = Ptr CArcadiaTioOcbOpenOptions -> IO ()
type OcbPrimitiveValuesInitFn = Ptr CArcadiaTioOcbPrimitiveValues -> IO ()
type OcbValidityBitmapInitFn = Ptr CArcadiaTioOcbValidityBitmap -> IO ()
type OcbWriteOptionsInitFn = Ptr CArcadiaTioOcbWriteOptions -> IO ()
type OcbWriteColumnInitFn = Ptr CArcadiaTioOcbWriteColumn -> IO ()
type OcbDictionaryEntryInitFn = Ptr CArcadiaTioOcbDictionaryEntry -> IO ()
type OcbWriteDictionaryInitFn = Ptr CArcadiaTioOcbWriteDictionary -> IO ()
type OcbWriteColumnChunkInitFn = Ptr CArcadiaTioOcbWriteColumnChunk -> IO ()
type OcbWriteRowGroupInitFn = Ptr CArcadiaTioOcbWriteRowGroup -> IO ()
type OcbWriteOrderingKeyInitFn = Ptr CArcadiaTioOcbWriteOrderingKey -> IO ()
type OcbWriteSpecInitFn = Ptr CArcadiaTioOcbWriteSpec -> IO ()
type OcbCleanupResultInitFn = Ptr CArcadiaTioOcbCleanupResult -> IO ()
type OcbPredicateValueInitFn = Ptr CArcadiaTioOcbPredicateValue -> IO ()
type OcbRowGroupPredicateInitFn = Ptr CArcadiaTioOcbRowGroupPredicate -> IO ()
type OcbWriteColumnSetFixedBinaryWidthFn = Ptr CArcadiaTioOcbWriteColumn -> Word32 -> IO ()
type OcbWriteColumnFixedBinaryWidthFn = Ptr CArcadiaTioOcbWriteColumn -> IO Word32
type OcbCreateFn = CString -> Ptr CArcadiaTioOcbWriteSpec -> IO CInt
type OcbCreateWithOptionsFn = CString -> Ptr CArcadiaTioOcbWriteSpec -> Ptr CArcadiaTioOcbWriteOptions -> IO CInt
type OcbAppendFn = CString -> Ptr CArcadiaTioOcbWriteSpec -> IO CInt
type OcbAppendWithOptionsFn = CString -> Ptr CArcadiaTioOcbWriteSpec -> Ptr CArcadiaTioOcbWriteOptions -> IO CInt
type OcbCleanupOrphanTailFn = CString -> Ptr CArcadiaTioOcbCleanupResult -> IO CInt
type OcbReadRequestInitFn = Ptr CArcadiaTioOcbReadRequest -> IO ()
type OcbReadReportInitFn = Ptr CArcadiaTioOcbReadReport -> IO ()
type OcbReadAttributionInitFn = Ptr CArcadiaTioOcbReadAttribution -> IO ()
type OcbReadOutcomeInitFn = Ptr CArcadiaTioOcbReadOutcome -> IO ()
type OcbReadCursorOptionsInitFn = Ptr CArcadiaTioOcbReadCursorOptions -> IO ()
type OcbReadCursorReportInitFn = Ptr CArcadiaTioOcbReadCursorReport -> IO ()
type OcbReadCursorReportFreeFn = Ptr CArcadiaTioOcbReadCursorReport -> IO ()
type OcbBatchVisitorFn = Ptr () -> Ptr CArcadiaTioOcbColumnBatch -> Ptr Word8 -> IO CInt
type OcbVisitBatchesFn = Ptr COcbFile -> Ptr CArcadiaTioOcbReadRequest -> Ptr CArcadiaTioOcbReadCursorOptions -> FunPtr OcbBatchVisitorFn -> Ptr () -> Ptr CArcadiaTioOcbReadCursorReport -> IO CInt
type OcbColumnFillBufferInitFn = Ptr CArcadiaTioOcbColumnFillBuffer -> IO ()
type OcbColumnFillBufferSetFixedBinaryWidthFn = Ptr CArcadiaTioOcbColumnFillBuffer -> Word32 -> IO ()
type OcbColumnFillBufferFixedBinaryWidthFn = Ptr CArcadiaTioOcbColumnFillBuffer -> IO Word32
type OcbRowGroupFillRequestInitFn = Ptr CArcadiaTioOcbRowGroupFillRequest -> IO ()
type OcbReadFillReportInitFn = Ptr CArcadiaTioOcbReadFillReport -> IO ()
type OcbReadRowGroupIntoFn = Ptr COcbFile -> Ptr CArcadiaTioOcbRowGroupFillRequest -> Ptr CArcadiaTioOcbReadFillReport -> IO CInt
type OcbReadBatchesFn = Ptr COcbFile -> Ptr CArcadiaTioOcbReadRequest -> Ptr CArcadiaTioOcbReadOutcome -> IO CInt
type OcbReadBatchesWithAttributionFn = Ptr COcbFile -> Ptr CArcadiaTioOcbReadRequest -> Ptr CArcadiaTioOcbReadOutcome -> Ptr CArcadiaTioOcbReadAttribution -> IO CInt
type OcbReadReportFreeFn = Ptr CArcadiaTioOcbReadReport -> IO ()
type OcbReadAttributionFreeFn = Ptr CArcadiaTioOcbReadAttribution -> IO ()
type OcbReadOutcomeFreeFn = Ptr CArcadiaTioOcbReadOutcome -> IO ()
type OcbColumnDescriptorFixedBinaryWidthFn = Ptr CArcadiaTioOcbColumnDescriptor -> IO Word32
type OcbColumnArrayFixedBinaryWidthFn = Ptr CArcadiaTioOcbColumnArray -> IO Word32
type OcbPlanReadFn = Ptr COcbFile -> Ptr CArcadiaTioOcbReadRequest -> Ptr (Ptr COcbReadPlan) -> IO CInt
type OcbReadPlanReportFn = Ptr COcbReadPlan -> Ptr CArcadiaTioOcbReadReport -> IO CInt
type OcbReadPlanIdsFn = Ptr COcbReadPlan -> Ptr Word32 -> CSize -> Ptr CSize -> IO CInt
type OcbReadBatchesFromPlanFn = Ptr COcbFile -> Ptr COcbReadPlan -> Ptr Word32 -> CSize -> Ptr CArcadiaTioOcbReadOutcome -> IO CInt
type OcbReadPlanFreeFn = Ptr COcbReadPlan -> IO ()
type OcbRowGroupSummariesInitFn = Ptr CArcadiaTioOcbRowGroupSummaries -> IO ()
type OcbRowGroupSummariesFn = Ptr COcbFile -> Ptr CArcadiaTioOcbRowGroupSummaries -> IO CInt
type OcbReadPlanRowGroupSummariesFn = Ptr COcbFile -> Ptr COcbReadPlan -> Ptr CArcadiaTioOcbRowGroupSummaries -> IO CInt
type OcbRowGroupSummariesFreeFn = Ptr CArcadiaTioOcbRowGroupSummaries -> IO ()
type TensorFreeFn = Ptr CArcadiaTioTensor -> IO ()
type MaskFreeFn = Ptr CArcadiaTioMask -> IO ()
type FileMetaFreeFn = Ptr CArcadiaTioFileMeta -> IO ()

foreign import ccall safe "dynamic" mkLastErrorMessage :: FunPtr LastErrorMessageFn -> LastErrorMessageFn
foreign import ccall safe "dynamic" mkLastErrorCode :: FunPtr LastErrorCodeFn -> LastErrorCodeFn
foreign import ccall safe "dynamic" mkAbiVersion :: FunPtr AbiVersionFn -> AbiVersionFn
foreign import ccall safe "dynamic" mkCreateStreaming :: FunPtr CreateStreamingFn -> CreateStreamingFn
foreign import ccall safe "dynamic" mkCreateRandomAccess :: FunPtr CreateRandomAccessFn -> CreateRandomAccessFn
foreign import ccall safe "dynamic" mkCreateEx :: FunPtr CreateExFn -> CreateExFn
foreign import ccall safe "dynamic" mkCreateWithUniverse :: FunPtr CreateWithUniverseFn -> CreateWithUniverseFn
foreign import ccall safe "dynamic" mkCreateInferred :: FunPtr CreateInferredFn -> CreateInferredFn
foreign import ccall safe "dynamic" mkCreateInferredEx :: FunPtr CreateInferredExFn -> CreateInferredExFn
foreign import ccall safe "dynamic" mkCreateWithPolicy :: FunPtr CreateWithPolicyFn -> CreateWithPolicyFn
foreign import ccall safe "dynamic" mkCreateWithPolicyEx :: FunPtr CreateWithPolicyExFn -> CreateWithPolicyExFn
foreign import ccall safe "dynamic" mkCreateWithPolicyUniverse :: FunPtr CreateWithPolicyUniverseFn -> CreateWithPolicyUniverseFn

foreign import ccall safe "dynamic" mkCreateWithPolicyWithCoordinates :: FunPtr CreateWithPolicyWithCoordinatesFn -> CreateWithPolicyWithCoordinatesFn
foreign import ccall safe "dynamic" mkCreateInferredWithCoordinates :: FunPtr CreateInferredWithCoordinatesFn -> CreateInferredWithCoordinatesFn
foreign import ccall safe "dynamic" mkCreateStreamingWithCoordinates :: FunPtr CreateStreamingWithCoordinatesFn -> CreateStreamingWithCoordinatesFn
foreign import ccall safe "dynamic" mkCreateWithPolicyWithCoordinatesV2 :: FunPtr CreateWithPolicyWithCoordinatesV2Fn -> CreateWithPolicyWithCoordinatesV2Fn
foreign import ccall safe "dynamic" mkCreateInferredWithCoordinatesV2 :: FunPtr CreateInferredWithCoordinatesV2Fn -> CreateInferredWithCoordinatesV2Fn
foreign import ccall safe "dynamic" mkCreateStreamingWithCoordinatesV2 :: FunPtr CreateStreamingWithCoordinatesV2Fn -> CreateStreamingWithCoordinatesV2Fn
foreign import ccall safe "dynamic" mkCoordinateMeta :: FunPtr CoordinateMetaFn -> CoordinateMetaFn
foreign import ccall safe "dynamic" mkLoadCoordinateMeta :: FunPtr LoadCoordinateMetaFn -> LoadCoordinateMetaFn
foreign import ccall safe "dynamic" mkAxisCoordinateMetaFree :: FunPtr AxisCoordinateMetaFreeFn -> AxisCoordinateMetaFreeFn
foreign import ccall safe "dynamic" mkCoordinateMetaV2 :: FunPtr CoordinateMetaV2Fn -> CoordinateMetaV2Fn
foreign import ccall safe "dynamic" mkLoadCoordinateMetaV2 :: FunPtr LoadCoordinateMetaV2Fn -> LoadCoordinateMetaV2Fn
foreign import ccall safe "dynamic" mkAxisCoordinateMetaV2Free :: FunPtr AxisCoordinateMetaV2FreeFn -> AxisCoordinateMetaV2FreeFn
foreign import ccall safe "dynamic" mkReadAxisCoordinates :: FunPtr ReadAxisCoordinatesFn -> ReadAxisCoordinatesFn
foreign import ccall safe "dynamic" mkCoordinateIndexI32 :: FunPtr CoordinateIndexI32Fn -> CoordinateIndexI32Fn
foreign import ccall safe "dynamic" mkCoordinateIndexI64 :: FunPtr CoordinateIndexI64Fn -> CoordinateIndexI64Fn
foreign import ccall safe "dynamic" mkCoordinateRangeI32 :: FunPtr CoordinateRangeI32Fn -> CoordinateRangeI32Fn
foreign import ccall safe "dynamic" mkCoordinateRangeI64 :: FunPtr CoordinateRangeI64Fn -> CoordinateRangeI64Fn
foreign import ccall safe "dynamic" mkReadAxisCoordinatesV2 :: FunPtr ReadAxisCoordinatesV2Fn -> ReadAxisCoordinatesV2Fn
foreign import ccall safe "dynamic" mkCoordinateValueSliceV2Free :: FunPtr CoordinateValueSliceV2FreeFn -> CoordinateValueSliceV2FreeFn
foreign import ccall safe "dynamic" mkCoordinateDictionaryV2 :: FunPtr CoordinateDictionaryV2Fn -> CoordinateDictionaryV2Fn
foreign import ccall safe "dynamic" mkCoordinateDictionaryV2Free :: FunPtr CoordinateDictionaryV2FreeFn -> CoordinateDictionaryV2FreeFn
foreign import ccall safe "dynamic" mkCoordinateLookupV2 :: FunPtr CoordinateLookupV2Fn -> CoordinateLookupV2Fn
foreign import ccall safe "dynamic" mkCoordinateLookupRangeV2 :: FunPtr CoordinateLookupRangeV2Fn -> CoordinateLookupRangeV2Fn
foreign import ccall safe "dynamic" mkCoordinateLookupResultV2Free :: FunPtr CoordinateLookupResultV2FreeFn -> CoordinateLookupResultV2FreeFn
foreign import ccall safe "dynamic" mkAppendF32WithCoordinatesV2 :: FunPtr (AppendWithCoordinatesV2Fn CFloat) -> AppendWithCoordinatesV2Fn CFloat
foreign import ccall safe "dynamic" mkAppendF64WithCoordinatesV2 :: FunPtr (AppendWithCoordinatesV2Fn Double) -> AppendWithCoordinatesV2Fn Double
foreign import ccall safe "dynamic" mkAppendI32WithCoordinatesV2 :: FunPtr (AppendWithCoordinatesV2Fn Int32) -> AppendWithCoordinatesV2Fn Int32
foreign import ccall safe "dynamic" mkAppendI64WithCoordinatesV2 :: FunPtr (AppendWithCoordinatesV2Fn Int64) -> AppendWithCoordinatesV2Fn Int64
foreign import ccall safe "dynamic" mkOpen :: FunPtr OpenFn -> OpenFn
foreign import ccall safe "dynamic" mkClose :: FunPtr CloseFn -> CloseFn
foreign import ccall safe "dynamic" mkAppendF32WithRange :: FunPtr AppendF32WithRangeFn -> AppendF32WithRangeFn
foreign import ccall safe "dynamic" mkAppendF32WithUniverse :: FunPtr (AppendWithUniverseFn CFloat) -> AppendWithUniverseFn CFloat
foreign import ccall safe "dynamic" mkAppendF64WithUniverse :: FunPtr (AppendWithUniverseFn Double) -> AppendWithUniverseFn Double
foreign import ccall safe "dynamic" mkAppendI32WithUniverse :: FunPtr (AppendWithUniverseFn Int32) -> AppendWithUniverseFn Int32
foreign import ccall safe "dynamic" mkAppendI64WithUniverse :: FunPtr (AppendWithUniverseFn Int64) -> AppendWithUniverseFn Int64
foreign import ccall safe "dynamic" mkAppendF64WithRange :: FunPtr AppendF64WithRangeFn -> AppendF64WithRangeFn
foreign import ccall safe "dynamic" mkAppendI32WithRange :: FunPtr AppendI32WithRangeFn -> AppendI32WithRangeFn
foreign import ccall safe "dynamic" mkAppendI64WithRange :: FunPtr AppendI64WithRangeFn -> AppendI64WithRangeFn
foreign import ccall safe "dynamic" mkReadAll :: FunPtr ReadAllFn -> ReadAllFn
foreign import ccall safe "dynamic" mkReadAllDense :: FunPtr ReadAllDenseFn -> ReadAllDenseFn
foreign import ccall safe "dynamic" mkReadAxisRange :: FunPtr ReadAxisRangeFn -> ReadAxisRangeFn
foreign import ccall safe "dynamic" mkReadAxisTake :: FunPtr ReadAxisTakeFn -> ReadAxisTakeFn
foreign import ccall safe "dynamic" mkReadAxisOne :: FunPtr ReadAxisOneFn -> ReadAxisOneFn
foreign import ccall safe "dynamic" mkReadEntryRange :: FunPtr ReadEntryRangeFn -> ReadEntryRangeFn
foreign import ccall safe "dynamic" mkTakeEntries :: FunPtr TakeEntriesFn -> TakeEntriesFn
foreign import ccall safe "dynamic" mkTensorToContiguous :: FunPtr TensorToContiguousFn -> TensorToContiguousFn
foreign import ccall safe "dynamic" mkTensorReshape :: FunPtr TensorReshapeFn -> TensorReshapeFn
foreign import ccall safe "dynamic" mkTensorFlatten :: FunPtr TensorFlattenFn -> TensorFlattenFn
foreign import ccall safe "dynamic" mkTensorExpandDims :: FunPtr TensorExpandDimsFn -> TensorExpandDimsFn
foreign import ccall safe "dynamic" mkTensorSqueeze :: FunPtr TensorSqueezeFn -> TensorSqueezeFn
foreign import ccall safe "dynamic" mkTensorSqueezeAxis :: FunPtr TensorSqueezeAxisFn -> TensorSqueezeAxisFn
foreign import ccall safe "dynamic" mkTensorPermuteAxes :: FunPtr TensorPermuteAxesFn -> TensorPermuteAxesFn
foreign import ccall safe "dynamic" mkTensorTranspose :: FunPtr TensorTransposeFn -> TensorTransposeFn
foreign import ccall safe "dynamic" mkTensorSliceAxis :: FunPtr TensorSliceAxisFn -> TensorSliceAxisFn
foreign import ccall safe "dynamic" mkTensorSliceAxisStep :: FunPtr TensorSliceAxisStepFn -> TensorSliceAxisStepFn
foreign import ccall safe "dynamic" mkTensorTakeAxis :: FunPtr TensorTakeAxisFn -> TensorTakeAxisFn
foreign import ccall safe "dynamic" mkTensorIndexAxis :: FunPtr TensorIndexAxisFn -> TensorIndexAxisFn
foreign import ccall safe "dynamic" mkTensorBinaryOp :: FunPtr TensorBinaryOpFn -> TensorBinaryOpFn
foreign import ccall safe "dynamic" mkTensorScalarOp :: FunPtr TensorScalarOpFn -> TensorScalarOpFn
foreign import ccall safe "dynamic" mkRank :: FunPtr RankFn -> RankFn
foreign import ccall safe "dynamic" mkDType :: FunPtr DTypeFn -> DTypeFn
foreign import ccall safe "dynamic" mkAppendAxis :: FunPtr AppendAxisFn -> AppendAxisFn
foreign import ccall safe "dynamic" mkDimLens :: FunPtr DimLensFn -> DimLensFn
foreign import ccall safe "dynamic" mkChunkPlan :: FunPtr ChunkPlanFn -> ChunkPlanFn
foreign import ccall safe "dynamic" mkPath :: FunPtr PathFn -> PathFn
foreign import ccall safe "dynamic" mkStringFree :: FunPtr StringFreeFn -> StringFreeFn
foreign import ccall safe "dynamic" mkChunkPlanFree :: FunPtr ChunkPlanFreeFn -> ChunkPlanFreeFn
foreign import ccall safe "dynamic" mkLoadMeta :: FunPtr LoadMetaFn -> LoadMetaFn
foreign import ccall safe "dynamic" mkSetDimName :: FunPtr SetDimNameFn -> SetDimNameFn
foreign import ccall safe "dynamic" mkSetStrings :: FunPtr SetStringsFn -> SetStringsFn
foreign import ccall safe "dynamic" mkSetUserKv :: FunPtr SetUserKvFn -> SetUserKvFn
foreign import ccall safe "dynamic" mkReadScalar :: FunPtr ReadScalarFn -> ReadScalarFn
foreign import ccall safe "dynamic" mkSetCompressionConfig :: FunPtr SetCompressionConfigFn -> SetCompressionConfigFn
foreign import ccall safe "dynamic" mkGetCompressionConfig :: FunPtr GetCompressionConfigFn -> GetCompressionConfigFn
foreign import ccall safe "dynamic" mkHeadCommit :: FunPtr HeadCommitFn -> HeadCommitFn
foreign import ccall safe "dynamic" mkListCommits :: FunPtr ListCommitsFn -> ListCommitsFn
foreign import ccall safe "dynamic" mkCommitListFree :: FunPtr CommitListFreeFn -> CommitListFreeFn
foreign import ccall safe "dynamic" mkPop :: FunPtr PopFn -> PopFn
foreign import ccall safe "dynamic" mkPopBatched :: FunPtr PopBatchedFn -> PopBatchedFn
foreign import ccall safe "dynamic" mkRevertCommit :: FunPtr RevertCommitFn -> RevertCommitFn
foreign import ccall safe "dynamic" mkReadAtCommit :: FunPtr ReadAtCommitFn -> ReadAtCommitFn
foreign import ccall safe "dynamic" mkReadAtCommitDense :: FunPtr ReadAtCommitDenseFn -> ReadAtCommitDenseFn
foreign import ccall safe "dynamic" mkReadExecutionReportFree :: FunPtr ReadExecutionReportFreeFn -> ReadExecutionReportFreeFn
foreign import ccall safe "dynamic" mkQueryTraceJsonFree :: FunPtr QueryTraceJsonFreeFn -> QueryTraceJsonFreeFn
foreign import ccall safe "dynamic" mkHistoricalReadExecutionReportFree :: FunPtr HistoricalReadExecutionReportFreeFn -> HistoricalReadExecutionReportFreeFn
foreign import ccall safe "dynamic" mkReadIndexReportFree :: FunPtr ReadIndexReportFreeFn -> ReadIndexReportFreeFn
foreign import ccall safe "dynamic" mkReadIndex :: FunPtr ReadIndexFn -> ReadIndexFn
foreign import ccall safe "dynamic" mkReadWithOptions :: FunPtr ReadWithOptionsFn -> ReadWithOptionsFn
foreign import ccall safe "dynamic" mkReadWithOptionsDense :: FunPtr ReadWithOptionsDenseFn -> ReadWithOptionsDenseFn
foreign import ccall safe "dynamic" mkReadWithShapePolicy :: FunPtr ReadWithShapePolicyFn -> ReadWithShapePolicyFn
foreign import ccall safe "dynamic" mkReadWithShapePolicyDense :: FunPtr ReadWithShapePolicyDenseFn -> ReadWithShapePolicyDenseFn
foreign import ccall safe "dynamic" mkReadWithOptionsAttributed :: FunPtr ReadWithOptionsAttributedFn -> ReadWithOptionsAttributedFn
foreign import ccall safe "dynamic" mkReadWithOptionsDenseAttributed :: FunPtr ReadWithOptionsDenseAttributedFn -> ReadWithOptionsDenseAttributedFn
foreign import ccall safe "dynamic" mkHistoricalReadWithOptions :: FunPtr HistoricalReadWithOptionsFn -> HistoricalReadWithOptionsFn
foreign import ccall safe "dynamic" mkHistoricalReadWithOptionsDense :: FunPtr HistoricalReadWithOptionsDenseFn -> HistoricalReadWithOptionsDenseFn
foreign import ccall safe "dynamic" mkHistoricalReadWithShapePolicy :: FunPtr HistoricalReadWithShapePolicyFn -> HistoricalReadWithShapePolicyFn
foreign import ccall safe "dynamic" mkHistoricalReadWithShapePolicyDense :: FunPtr HistoricalReadWithShapePolicyDenseFn -> HistoricalReadWithShapePolicyDenseFn
foreign import ccall safe "dynamic" mkGetIndexCheckpointEveryCommits :: FunPtr GetIndexCheckpointEveryCommitsFn -> GetIndexCheckpointEveryCommitsFn
foreign import ccall safe "dynamic" mkSetIndexCheckpointEveryCommits :: FunPtr SetIndexCheckpointEveryCommitsFn -> SetIndexCheckpointEveryCommitsFn
foreign import ccall safe "dynamic" mkRewriteF32 :: FunPtr RewriteF32Fn -> RewriteF32Fn
foreign import ccall safe "dynamic" mkRewriteF64 :: FunPtr RewriteF64Fn -> RewriteF64Fn
foreign import ccall safe "dynamic" mkRewriteSliceF32 :: FunPtr RewriteSliceF32Fn -> RewriteSliceF32Fn
foreign import ccall safe "dynamic" mkRewriteSliceF64 :: FunPtr RewriteSliceF64Fn -> RewriteSliceF64Fn
foreign import ccall safe "dynamic" mkClearBlocks :: FunPtr ClearBlocksFn -> ClearBlocksFn
foreign import ccall safe "dynamic" mkReadValuesArrow :: FunPtr ReadValuesArrowFn -> ReadValuesArrowFn
foreign import ccall safe "dynamic" mkArrowArrayRelease :: FunPtr ArrowArrayReleaseFn -> ArrowArrayReleaseFn
foreign import ccall safe "dynamic" mkArrowSchemaRelease :: FunPtr ArrowSchemaReleaseFn -> ArrowSchemaReleaseFn
foreign import ccall safe "dynamic" mkAnalyzeCompaction :: FunPtr AnalyzeCompactionFn -> AnalyzeCompactionFn
foreign import ccall safe "dynamic" mkCompactTo :: FunPtr CompactToFn -> CompactToFn
foreign import ccall safe "dynamic" mkMaybeCompact :: FunPtr MaybeCompactFn -> MaybeCompactFn
foreign import ccall safe "dynamic" mkGetAutoCompactionConfig :: FunPtr GetAutoCompactionConfigFn -> GetAutoCompactionConfigFn
foreign import ccall safe "dynamic" mkSetAutoCompactionConfig :: FunPtr SetAutoCompactionConfigFn -> SetAutoCompactionConfigFn
foreign import ccall safe "dynamic" mkCompactionState :: FunPtr CompactionStateFn -> CompactionStateFn
foreign import ccall safe "dynamic" mkMaybeCompactAuto :: FunPtr MaybeCompactAutoFn -> MaybeCompactAutoFn
foreign import ccall safe "dynamic" mkV4Diagnostics :: FunPtr V4DiagnosticsFn -> V4DiagnosticsFn
foreign import ccall safe "dynamic" mkV4DiagnosticsReportFree :: FunPtr V4DiagnosticsReportFreeFn -> V4DiagnosticsReportFreeFn
foreign import ccall safe "dynamic" mkV4DiagnosticsPrecise :: FunPtr V4DiagnosticsPreciseFn -> V4DiagnosticsPreciseFn
foreign import ccall safe "dynamic" mkV4DiagnosticsPreciseReportFree :: FunPtr V4DiagnosticsPreciseReportFreeFn -> V4DiagnosticsPreciseReportFreeFn
foreign import ccall safe "dynamic" mkAnalyzeV4Compaction :: FunPtr AnalyzeV4CompactionFn -> AnalyzeV4CompactionFn
foreign import ccall safe "dynamic" mkV4CompactionAnalysisReportFree :: FunPtr V4CompactionAnalysisReportFreeFn -> V4CompactionAnalysisReportFreeFn
foreign import ccall safe "dynamic" mkAnalyzeV4CompactionPrecise :: FunPtr AnalyzeV4CompactionPreciseFn -> AnalyzeV4CompactionPreciseFn
foreign import ccall safe "dynamic" mkV4CompactionAnalysisPreciseReportFree :: FunPtr V4CompactionAnalysisPreciseReportFreeFn -> V4CompactionAnalysisPreciseReportFreeFn
foreign import ccall safe "dynamic" mkCompactV4RetainedHistoryTo :: FunPtr CompactV4RetainedHistoryToFn -> CompactV4RetainedHistoryToFn
foreign import ccall safe "dynamic" mkV4RetainedHistoryCompactionReportFree :: FunPtr V4RetainedHistoryCompactionReportFreeFn -> V4RetainedHistoryCompactionReportFreeFn
foreign import ccall safe "dynamic" mkCompactV4RetainedHistoryToPrecise :: FunPtr CompactV4RetainedHistoryToPreciseFn -> CompactV4RetainedHistoryToPreciseFn
foreign import ccall safe "dynamic" mkV4RetainedHistoryCompactionPreciseReportFree :: FunPtr V4RetainedHistoryCompactionPreciseReportFreeFn -> V4RetainedHistoryCompactionPreciseReportFreeFn
foreign import ccall safe "dynamic" mkReformTo :: FunPtr ReformToFn -> ReformToFn
foreign import ccall safe "dynamic" mkReformToEx :: FunPtr ReformToExFn -> ReformToExFn
foreign import ccall safe "dynamic" mkReformReportFree :: FunPtr ReformReportFreeFn -> ReformReportFreeFn
foreign import ccall safe "dynamic" mkAnalyzeSparseAppendF32V2 :: FunPtr (AnalyzeSparseAppendV2Fn CFloat) -> AnalyzeSparseAppendV2Fn CFloat
foreign import ccall safe "dynamic" mkAnalyzeSparseAppendF64V2 :: FunPtr (AnalyzeSparseAppendV2Fn Double) -> AnalyzeSparseAppendV2Fn Double
foreign import ccall safe "dynamic" mkAnalyzeSparseAppendI32V2 :: FunPtr (AnalyzeSparseAppendV2Fn Int32) -> AnalyzeSparseAppendV2Fn Int32
foreign import ccall safe "dynamic" mkAnalyzeSparseAppendI64V2 :: FunPtr (AnalyzeSparseAppendV2Fn Int64) -> AnalyzeSparseAppendV2Fn Int64
foreign import ccall safe "dynamic" mkAppendSparseF32WithRangeV2 :: FunPtr (AppendSparseWithRangeV2Fn CFloat) -> AppendSparseWithRangeV2Fn CFloat
foreign import ccall safe "dynamic" mkAppendSparseF64WithRangeV2 :: FunPtr (AppendSparseWithRangeV2Fn Double) -> AppendSparseWithRangeV2Fn Double
foreign import ccall safe "dynamic" mkAppendSparseI32WithRangeV2 :: FunPtr (AppendSparseWithRangeV2Fn Int32) -> AppendSparseWithRangeV2Fn Int32
foreign import ccall safe "dynamic" mkAppendSparseI64WithRangeV2 :: FunPtr (AppendSparseWithRangeV2Fn Int64) -> AppendSparseWithRangeV2Fn Int64
foreign import ccall safe "dynamic" mkSparseAppendAnalysisFree :: FunPtr SparseAppendAnalysisFreeFn -> SparseAppendAnalysisFreeFn
foreign import ccall safe "dynamic" mkOcbLastErrorKind :: FunPtr OcbLastErrorKindFn -> OcbLastErrorKindFn
foreign import ccall safe "dynamic" mkOcbLastErrorCause :: FunPtr OcbLastErrorCauseFn -> OcbLastErrorCauseFn
foreign import ccall safe "dynamic" mkOcbOpen :: FunPtr OcbOpenFn -> OcbOpenFn
foreign import ccall safe "dynamic" mkOcbOpenWithOptions :: FunPtr OcbOpenWithOptionsFn -> OcbOpenWithOptionsFn
foreign import ccall safe "dynamic" mkOcbReaderClone :: FunPtr OcbReaderCloneFn -> OcbReaderCloneFn
foreign import ccall safe "dynamic" mkOcbClose :: FunPtr OcbCloseFn -> OcbCloseFn
foreign import ccall safe "dynamic" mkOcbMetadata :: FunPtr OcbMetadataFn -> OcbMetadataFn
foreign import ccall safe "dynamic" mkOcbMetadataFree :: FunPtr OcbMetadataFreeFn -> OcbMetadataFreeFn
foreign import ccall safe "dynamic" mkOcbDictionaryValues :: FunPtr OcbDictionaryValuesFn -> OcbDictionaryValuesFn
foreign import ccall safe "dynamic" mkOcbDictionaryValuesFree :: FunPtr OcbDictionaryValuesFreeFn -> OcbDictionaryValuesFreeFn
foreign import ccall safe "dynamic" mkOcbOpenOptionsInit :: FunPtr OcbOpenOptionsInitFn -> OcbOpenOptionsInitFn
foreign import ccall safe "dynamic" mkOcbPrimitiveValuesInit :: FunPtr OcbPrimitiveValuesInitFn -> OcbPrimitiveValuesInitFn
foreign import ccall safe "dynamic" mkOcbValidityBitmapInit :: FunPtr OcbValidityBitmapInitFn -> OcbValidityBitmapInitFn
foreign import ccall safe "dynamic" mkOcbWriteOptionsInit :: FunPtr OcbWriteOptionsInitFn -> OcbWriteOptionsInitFn
foreign import ccall safe "dynamic" mkOcbWriteColumnInit :: FunPtr OcbWriteColumnInitFn -> OcbWriteColumnInitFn
foreign import ccall safe "dynamic" mkOcbDictionaryEntryInit :: FunPtr OcbDictionaryEntryInitFn -> OcbDictionaryEntryInitFn
foreign import ccall safe "dynamic" mkOcbWriteDictionaryInit :: FunPtr OcbWriteDictionaryInitFn -> OcbWriteDictionaryInitFn
foreign import ccall safe "dynamic" mkOcbWriteColumnChunkInit :: FunPtr OcbWriteColumnChunkInitFn -> OcbWriteColumnChunkInitFn
foreign import ccall safe "dynamic" mkOcbWriteRowGroupInit :: FunPtr OcbWriteRowGroupInitFn -> OcbWriteRowGroupInitFn
foreign import ccall safe "dynamic" mkOcbWriteOrderingKeyInit :: FunPtr OcbWriteOrderingKeyInitFn -> OcbWriteOrderingKeyInitFn
foreign import ccall safe "dynamic" mkOcbWriteSpecInit :: FunPtr OcbWriteSpecInitFn -> OcbWriteSpecInitFn
foreign import ccall safe "dynamic" mkOcbCleanupResultInit :: FunPtr OcbCleanupResultInitFn -> OcbCleanupResultInitFn
foreign import ccall safe "dynamic" mkOcbPredicateValueInit :: FunPtr OcbPredicateValueInitFn -> OcbPredicateValueInitFn
foreign import ccall safe "dynamic" mkOcbRowGroupPredicateInit :: FunPtr OcbRowGroupPredicateInitFn -> OcbRowGroupPredicateInitFn
foreign import ccall safe "dynamic" mkOcbWriteColumnSetFixedBinaryWidth :: FunPtr OcbWriteColumnSetFixedBinaryWidthFn -> OcbWriteColumnSetFixedBinaryWidthFn
foreign import ccall safe "dynamic" mkOcbWriteColumnFixedBinaryWidth :: FunPtr OcbWriteColumnFixedBinaryWidthFn -> OcbWriteColumnFixedBinaryWidthFn
foreign import ccall safe "dynamic" mkOcbCreate :: FunPtr OcbCreateFn -> OcbCreateFn
foreign import ccall safe "dynamic" mkOcbCreateWithOptions :: FunPtr OcbCreateWithOptionsFn -> OcbCreateWithOptionsFn
foreign import ccall safe "dynamic" mkOcbAppend :: FunPtr OcbAppendFn -> OcbAppendFn
foreign import ccall safe "dynamic" mkOcbAppendWithOptions :: FunPtr OcbAppendWithOptionsFn -> OcbAppendWithOptionsFn
foreign import ccall safe "dynamic" mkOcbCleanupOrphanTail :: FunPtr OcbCleanupOrphanTailFn -> OcbCleanupOrphanTailFn
foreign import ccall safe "dynamic" mkOcbReadRequestInit :: FunPtr OcbReadRequestInitFn -> OcbReadRequestInitFn
foreign import ccall safe "dynamic" mkOcbReadReportInit :: FunPtr OcbReadReportInitFn -> OcbReadReportInitFn
foreign import ccall safe "dynamic" mkOcbReadAttributionInit :: FunPtr OcbReadAttributionInitFn -> OcbReadAttributionInitFn
foreign import ccall safe "dynamic" mkOcbReadOutcomeInit :: FunPtr OcbReadOutcomeInitFn -> OcbReadOutcomeInitFn
foreign import ccall safe "dynamic" mkOcbReadCursorOptionsInit :: FunPtr OcbReadCursorOptionsInitFn -> OcbReadCursorOptionsInitFn
foreign import ccall safe "dynamic" mkOcbReadCursorReportInit :: FunPtr OcbReadCursorReportInitFn -> OcbReadCursorReportInitFn
foreign import ccall safe "dynamic" mkOcbReadCursorReportFree :: FunPtr OcbReadCursorReportFreeFn -> OcbReadCursorReportFreeFn
foreign import ccall safe "dynamic" mkOcbVisitBatches :: FunPtr OcbVisitBatchesFn -> OcbVisitBatchesFn
foreign import ccall safe "wrapper" mkOcbBatchVisitorCallback :: OcbBatchVisitorFn -> IO (FunPtr OcbBatchVisitorFn)
foreign import ccall safe "dynamic" mkOcbColumnFillBufferInit :: FunPtr OcbColumnFillBufferInitFn -> OcbColumnFillBufferInitFn
foreign import ccall safe "dynamic" mkOcbColumnFillBufferSetFixedBinaryWidth :: FunPtr OcbColumnFillBufferSetFixedBinaryWidthFn -> OcbColumnFillBufferSetFixedBinaryWidthFn
foreign import ccall safe "dynamic" mkOcbColumnFillBufferFixedBinaryWidth :: FunPtr OcbColumnFillBufferFixedBinaryWidthFn -> OcbColumnFillBufferFixedBinaryWidthFn
foreign import ccall safe "dynamic" mkOcbRowGroupFillRequestInit :: FunPtr OcbRowGroupFillRequestInitFn -> OcbRowGroupFillRequestInitFn
foreign import ccall safe "dynamic" mkOcbReadFillReportInit :: FunPtr OcbReadFillReportInitFn -> OcbReadFillReportInitFn
foreign import ccall safe "dynamic" mkOcbReadRowGroupInto :: FunPtr OcbReadRowGroupIntoFn -> OcbReadRowGroupIntoFn
foreign import ccall safe "dynamic" mkOcbReadBatches :: FunPtr OcbReadBatchesFn -> OcbReadBatchesFn
foreign import ccall safe "dynamic" mkOcbReadBatchesWithAttribution :: FunPtr OcbReadBatchesWithAttributionFn -> OcbReadBatchesWithAttributionFn
foreign import ccall safe "dynamic" mkOcbReadReportFree :: FunPtr OcbReadReportFreeFn -> OcbReadReportFreeFn
foreign import ccall safe "dynamic" mkOcbReadAttributionFree :: FunPtr OcbReadAttributionFreeFn -> OcbReadAttributionFreeFn
foreign import ccall safe "dynamic" mkOcbReadOutcomeFree :: FunPtr OcbReadOutcomeFreeFn -> OcbReadOutcomeFreeFn
foreign import ccall safe "dynamic" mkOcbColumnDescriptorFixedBinaryWidth :: FunPtr OcbColumnDescriptorFixedBinaryWidthFn -> OcbColumnDescriptorFixedBinaryWidthFn
foreign import ccall safe "dynamic" mkOcbColumnArrayFixedBinaryWidth :: FunPtr OcbColumnArrayFixedBinaryWidthFn -> OcbColumnArrayFixedBinaryWidthFn
foreign import ccall safe "dynamic" mkOcbPlanRead :: FunPtr OcbPlanReadFn -> OcbPlanReadFn
foreign import ccall safe "dynamic" mkOcbReadPlanReport :: FunPtr OcbReadPlanReportFn -> OcbReadPlanReportFn
foreign import ccall safe "dynamic" mkOcbReadPlanProjectedColumnIds :: FunPtr OcbReadPlanIdsFn -> OcbReadPlanIdsFn
foreign import ccall safe "dynamic" mkOcbReadPlanRowGroupIds :: FunPtr OcbReadPlanIdsFn -> OcbReadPlanIdsFn
foreign import ccall safe "dynamic" mkOcbReadBatchesFromPlan :: FunPtr OcbReadBatchesFromPlanFn -> OcbReadBatchesFromPlanFn
foreign import ccall safe "dynamic" mkOcbReadPlanFree :: FunPtr OcbReadPlanFreeFn -> OcbReadPlanFreeFn
foreign import ccall safe "dynamic" mkOcbRowGroupSummariesInit :: FunPtr OcbRowGroupSummariesInitFn -> OcbRowGroupSummariesInitFn
foreign import ccall safe "dynamic" mkOcbRowGroupSummaries :: FunPtr OcbRowGroupSummariesFn -> OcbRowGroupSummariesFn
foreign import ccall safe "dynamic" mkOcbReadPlanRowGroupSummaries :: FunPtr OcbReadPlanRowGroupSummariesFn -> OcbReadPlanRowGroupSummariesFn
foreign import ccall safe "dynamic" mkOcbRowGroupSummariesFree :: FunPtr OcbRowGroupSummariesFreeFn -> OcbRowGroupSummariesFreeFn
foreign import ccall safe "dynamic" mkTensorFree :: FunPtr TensorFreeFn -> TensorFreeFn
foreign import ccall safe "dynamic" mkMaskFree :: FunPtr MaskFreeFn -> MaskFreeFn
foreign import ccall safe "dynamic" mkFileMetaFree :: FunPtr FileMetaFreeFn -> FileMetaFreeFn

-- | Dynamically loaded C ABI function table.
data NativeLibrary = NativeLibrary
  { nativeLibraryPath :: FilePath
  , nativeLibraryHandle :: DL
  , nativeLastErrorMessage :: LastErrorMessageFn
  , nativeLastErrorCode :: LastErrorCodeFn
  , nativeAbiVersion :: AbiVersionFn
  , nativeCreateStreaming :: CreateStreamingFn
  , nativeCreateStreamingEx :: CreateExFn
  , nativeCreateRandomAccess :: CreateRandomAccessFn
  , nativeCreateRandomAccessEx :: CreateExFn
  , nativeCreateRandomAccessWithUniverse :: CreateWithUniverseFn
  , nativeCreateStreamingWithUniverse :: CreateWithUniverseFn
  , nativeCreateWithPolicyWithUniverse :: CreateWithPolicyUniverseFn
  , nativeCreateInferred :: CreateInferredFn
  , nativeCreateInferredEx :: CreateInferredExFn
  , nativeCreateWithPolicy :: CreateWithPolicyFn
  , nativeCreateWithPolicyEx :: CreateWithPolicyExFn
  , nativeCreateWithPolicyWithCoordinates :: CreateWithPolicyWithCoordinatesFn
  , nativeCreateInferredWithCoordinates :: CreateInferredWithCoordinatesFn
  , nativeCreateRandomAccessWithCoordinates :: CreateStreamingWithCoordinatesFn
  , nativeCreateStreamingWithCoordinates :: CreateStreamingWithCoordinatesFn
  , nativeCreateWithPolicyWithCoordinatesV2 :: CreateWithPolicyWithCoordinatesV2Fn
  , nativeCreateInferredWithCoordinatesV2 :: CreateInferredWithCoordinatesV2Fn
  , nativeCreateRandomAccessWithCoordinatesV2 :: CreateStreamingWithCoordinatesV2Fn
  , nativeCreateStreamingWithCoordinatesV2 :: CreateStreamingWithCoordinatesV2Fn
  , nativeCoordinateMeta :: CoordinateMetaFn
  , nativeLoadCoordinateMeta :: LoadCoordinateMetaFn
  , nativeAxisCoordinateMetaFree :: AxisCoordinateMetaFreeFn
  , nativeCoordinateMetaV2 :: CoordinateMetaV2Fn
  , nativeLoadCoordinateMetaV2 :: LoadCoordinateMetaV2Fn
  , nativeAxisCoordinateMetaV2Free :: AxisCoordinateMetaV2FreeFn
  , nativeReadAxisCoordinates :: ReadAxisCoordinatesFn
  , nativeCoordinateIndexI32 :: CoordinateIndexI32Fn
  , nativeCoordinateIndexI64 :: CoordinateIndexI64Fn
  , nativeCoordinateRangeI32 :: CoordinateRangeI32Fn
  , nativeCoordinateRangeI64 :: CoordinateRangeI64Fn
  , nativeReadAxisCoordinatesV2 :: ReadAxisCoordinatesV2Fn
  , nativeCoordinateValueSliceV2Free :: CoordinateValueSliceV2FreeFn
  , nativeCoordinateDictionaryV2 :: CoordinateDictionaryV2Fn
  , nativeCoordinateDictionaryV2Free :: CoordinateDictionaryV2FreeFn
  , nativeCoordinateLookupV2 :: CoordinateLookupV2Fn
  , nativeCoordinateLookupRangeV2 :: CoordinateLookupRangeV2Fn
  , nativeCoordinateLookupResultV2Free :: CoordinateLookupResultV2FreeFn
  , nativeAppendF32WithCoordinatesV2 :: AppendWithCoordinatesV2Fn CFloat
  , nativeAppendF64WithCoordinatesV2 :: AppendWithCoordinatesV2Fn Double
  , nativeAppendI32WithCoordinatesV2 :: AppendWithCoordinatesV2Fn Int32
  , nativeAppendI64WithCoordinatesV2 :: AppendWithCoordinatesV2Fn Int64
  , nativeAppendF32WithUniverse :: AppendWithUniverseFn CFloat
  , nativeAppendF64WithUniverse :: AppendWithUniverseFn Double
  , nativeAppendI32WithUniverse :: AppendWithUniverseFn Int32
  , nativeAppendI64WithUniverse :: AppendWithUniverseFn Int64
  , nativeOpen :: OpenFn
  , nativeClose :: CloseFn
  , nativeAppendF32WithRange :: AppendF32WithRangeFn
  , nativeAppendF64WithRange :: AppendF64WithRangeFn
  , nativeAppendI32WithRange :: AppendI32WithRangeFn
  , nativeAppendI64WithRange :: AppendI64WithRangeFn
  , nativeReadAll :: ReadAllFn
  , nativeReadAllDense :: ReadAllDenseFn
  , nativeReadAxisRange :: ReadAxisRangeFn
  , nativeReadAxisTake :: ReadAxisTakeFn
  , nativeReadAxisOne :: ReadAxisOneFn
  , nativeReadEntryRange :: ReadEntryRangeFn
  , nativeTakeEntries :: TakeEntriesFn
  , nativeTensorToContiguous :: TensorToContiguousFn
  , nativeTensorReshape :: TensorReshapeFn
  , nativeTensorFlatten :: TensorFlattenFn
  , nativeTensorExpandDims :: TensorExpandDimsFn
  , nativeTensorSqueeze :: TensorSqueezeFn
  , nativeTensorSqueezeAxis :: TensorSqueezeAxisFn
  , nativeTensorPermuteAxes :: TensorPermuteAxesFn
  , nativeTensorTranspose :: TensorTransposeFn
  , nativeTensorSliceAxis :: TensorSliceAxisFn
  , nativeTensorSliceAxisStep :: TensorSliceAxisStepFn
  , nativeTensorTakeAxis :: TensorTakeAxisFn
  , nativeTensorIndexAxis :: TensorIndexAxisFn
  , nativeTensorAdd :: TensorBinaryOpFn
  , nativeTensorSub :: TensorBinaryOpFn
  , nativeTensorMul :: TensorBinaryOpFn
  , nativeTensorDiv :: TensorBinaryOpFn
  , nativeTensorAddScalar :: TensorScalarOpFn
  , nativeTensorSubScalar :: TensorScalarOpFn
  , nativeTensorMulScalar :: TensorScalarOpFn
  , nativeTensorDivScalar :: TensorScalarOpFn
  , nativeRank :: RankFn
  , nativeDType :: DTypeFn
  , nativeAppendAxis :: AppendAxisFn
  , nativeDimLens :: DimLensFn
  , nativeChunkPlan :: ChunkPlanFn
  , nativePath :: PathFn
  , nativeStringFree :: StringFreeFn
  , nativeChunkPlanFree :: ChunkPlanFreeFn
  , nativeLoadMeta :: LoadMetaFn
  , nativeSetDimName :: SetDimNameFn
  , nativeSetSymbols :: SetStringsFn
  , nativeSetChannels :: SetStringsFn
  , nativeSetUserKv :: SetUserKvFn
  , nativeReadScalar :: ReadScalarFn
  , nativeSetCompressionConfig :: SetCompressionConfigFn
  , nativeGetCompressionConfig :: GetCompressionConfigFn
  , nativeHeadCommit :: HeadCommitFn
  , nativeListCommits :: ListCommitsFn
  , nativeCommitListFree :: CommitListFreeFn
  , nativePop :: PopFn
  , nativePopBatched :: PopBatchedFn
  , nativeRevertCommit :: RevertCommitFn
  , nativeReadAtCommit :: ReadAtCommitFn
  , nativeReadAtCommitDense :: ReadAtCommitDenseFn
  , nativeReadExecutionReportFree :: ReadExecutionReportFreeFn
  , nativeQueryTraceJsonFree :: QueryTraceJsonFreeFn
  , nativeHistoricalReadExecutionReportFree :: HistoricalReadExecutionReportFreeFn
  , nativeReadIndexReportFree :: ReadIndexReportFreeFn
  , nativeReadIndex :: ReadIndexFn
  , nativeReadWithOptions :: ReadWithOptionsFn
  , nativeReadWithOptionsDense :: ReadWithOptionsDenseFn
  , nativeReadWithShapePolicy :: ReadWithShapePolicyFn
  , nativeReadWithShapePolicyDense :: ReadWithShapePolicyDenseFn
  , nativeReadWithOptionsAttributed :: ReadWithOptionsAttributedFn
  , nativeReadWithOptionsDenseAttributed :: ReadWithOptionsDenseAttributedFn
  , nativeHistoricalReadWithOptions :: HistoricalReadWithOptionsFn
  , nativeHistoricalReadWithOptionsDense :: HistoricalReadWithOptionsDenseFn
  , nativeHistoricalReadWithShapePolicy :: HistoricalReadWithShapePolicyFn
  , nativeHistoricalReadWithShapePolicyDense :: HistoricalReadWithShapePolicyDenseFn
  , nativeGetIndexCheckpointEveryCommits :: GetIndexCheckpointEveryCommitsFn
  , nativeSetIndexCheckpointEveryCommits :: SetIndexCheckpointEveryCommitsFn
  , nativeRewriteF32 :: RewriteF32Fn
  , nativeRewriteF64 :: RewriteF64Fn
  , nativeRewriteSliceF32 :: RewriteSliceF32Fn
  , nativeRewriteSliceF64 :: RewriteSliceF64Fn
  , nativeClearBlocks :: ClearBlocksFn
  , nativeReadValuesArrow :: ReadValuesArrowFn
  , nativeAnalyzeCompaction :: AnalyzeCompactionFn
  , nativeCompactTo :: CompactToFn
  , nativeMaybeCompact :: MaybeCompactFn
  , nativeGetAutoCompactionConfig :: GetAutoCompactionConfigFn
  , nativeSetAutoCompactionConfig :: SetAutoCompactionConfigFn
  , nativeCompactionState :: CompactionStateFn
  , nativeMaybeCompactAuto :: MaybeCompactAutoFn
  , nativeV4Diagnostics :: V4DiagnosticsFn
  , nativeV4DiagnosticsReportFree :: V4DiagnosticsReportFreeFn
  , nativeV4DiagnosticsPrecise :: V4DiagnosticsPreciseFn
  , nativeV4DiagnosticsPreciseReportFree :: V4DiagnosticsPreciseReportFreeFn
  , nativeAnalyzeV4Compaction :: AnalyzeV4CompactionFn
  , nativeV4CompactionAnalysisReportFree :: V4CompactionAnalysisReportFreeFn
  , nativeAnalyzeV4CompactionPrecise :: AnalyzeV4CompactionPreciseFn
  , nativeV4CompactionAnalysisPreciseReportFree :: V4CompactionAnalysisPreciseReportFreeFn
  , nativeCompactV4RetainedHistoryTo :: CompactV4RetainedHistoryToFn
  , nativeV4RetainedHistoryCompactionReportFree :: V4RetainedHistoryCompactionReportFreeFn
  , nativeCompactV4RetainedHistoryToPrecise :: CompactV4RetainedHistoryToPreciseFn
  , nativeV4RetainedHistoryCompactionPreciseReportFree :: V4RetainedHistoryCompactionPreciseReportFreeFn
  , nativeReformTo :: ReformToFn
  , nativeReformToEx :: ReformToExFn
  , nativeReformReportFree :: ReformReportFreeFn
  , nativeAnalyzeSparseAppendF32V2 :: AnalyzeSparseAppendV2Fn CFloat
  , nativeAnalyzeSparseAppendF64V2 :: AnalyzeSparseAppendV2Fn Double
  , nativeAnalyzeSparseAppendI32V2 :: AnalyzeSparseAppendV2Fn Int32
  , nativeAnalyzeSparseAppendI64V2 :: AnalyzeSparseAppendV2Fn Int64
  , nativeAppendSparseF32WithRangeV2 :: AppendSparseWithRangeV2Fn CFloat
  , nativeAppendSparseF64WithRangeV2 :: AppendSparseWithRangeV2Fn Double
  , nativeAppendSparseI32WithRangeV2 :: AppendSparseWithRangeV2Fn Int32
  , nativeAppendSparseI64WithRangeV2 :: AppendSparseWithRangeV2Fn Int64
  , nativeSparseAppendAnalysisFree :: SparseAppendAnalysisFreeFn
  , nativeOcbLastErrorKind :: OcbLastErrorKindFn
  , nativeOcbLastErrorCause :: OcbLastErrorCauseFn
  , nativeOcbOpen :: OcbOpenFn
  , nativeOcbOpenWithOptions :: OcbOpenWithOptionsFn
  , nativeOcbReaderClone :: OcbReaderCloneFn
  , nativeOcbClose :: OcbCloseFn
  , nativeOcbMetadata :: OcbMetadataFn
  , nativeOcbMetadataFree :: OcbMetadataFreeFn
  , nativeOcbDictionaryValues :: OcbDictionaryValuesFn
  , nativeOcbDictionaryValuesFree :: OcbDictionaryValuesFreeFn
  , nativeOcbOpenOptionsInit :: OcbOpenOptionsInitFn
  , nativeOcbPrimitiveValuesInit :: OcbPrimitiveValuesInitFn
  , nativeOcbValidityBitmapInit :: OcbValidityBitmapInitFn
  , nativeOcbWriteOptionsInit :: OcbWriteOptionsInitFn
  , nativeOcbWriteColumnInit :: OcbWriteColumnInitFn
  , nativeOcbDictionaryEntryInit :: OcbDictionaryEntryInitFn
  , nativeOcbWriteDictionaryInit :: OcbWriteDictionaryInitFn
  , nativeOcbWriteColumnChunkInit :: OcbWriteColumnChunkInitFn
  , nativeOcbWriteRowGroupInit :: OcbWriteRowGroupInitFn
  , nativeOcbWriteOrderingKeyInit :: OcbWriteOrderingKeyInitFn
  , nativeOcbWriteSpecInit :: OcbWriteSpecInitFn
  , nativeOcbCleanupResultInit :: OcbCleanupResultInitFn
  , nativeOcbPredicateValueInit :: OcbPredicateValueInitFn
  , nativeOcbRowGroupPredicateInit :: OcbRowGroupPredicateInitFn
  , nativeOcbWriteColumnSetFixedBinaryWidth :: OcbWriteColumnSetFixedBinaryWidthFn
  , nativeOcbWriteColumnFixedBinaryWidth :: OcbWriteColumnFixedBinaryWidthFn
  , nativeOcbCreate :: OcbCreateFn
  , nativeOcbCreateWithOptions :: OcbCreateWithOptionsFn
  , nativeOcbAppend :: OcbAppendFn
  , nativeOcbAppendWithOptions :: OcbAppendWithOptionsFn
  , nativeOcbCleanupOrphanTail :: OcbCleanupOrphanTailFn
  , nativeOcbReadRequestInit :: OcbReadRequestInitFn
  , nativeOcbReadReportInit :: OcbReadReportInitFn
  , nativeOcbReadAttributionInit :: OcbReadAttributionInitFn
  , nativeOcbReadOutcomeInit :: OcbReadOutcomeInitFn
  , nativeOcbReadCursorOptionsInit :: OcbReadCursorOptionsInitFn
  , nativeOcbReadCursorReportInit :: OcbReadCursorReportInitFn
  , nativeOcbReadCursorReportFree :: OcbReadCursorReportFreeFn
  , nativeOcbVisitBatches :: OcbVisitBatchesFn
  , nativeOcbColumnFillBufferInit :: OcbColumnFillBufferInitFn
  , nativeOcbColumnFillBufferSetFixedBinaryWidth :: OcbColumnFillBufferSetFixedBinaryWidthFn
  , nativeOcbColumnFillBufferFixedBinaryWidth :: OcbColumnFillBufferFixedBinaryWidthFn
  , nativeOcbRowGroupFillRequestInit :: OcbRowGroupFillRequestInitFn
  , nativeOcbReadFillReportInit :: OcbReadFillReportInitFn
  , nativeOcbReadRowGroupInto :: OcbReadRowGroupIntoFn
  , nativeOcbReadBatches :: OcbReadBatchesFn
  , nativeOcbReadBatchesWithAttribution :: OcbReadBatchesWithAttributionFn
  , nativeOcbReadReportFree :: OcbReadReportFreeFn
  , nativeOcbReadAttributionFree :: OcbReadAttributionFreeFn
  , nativeOcbReadOutcomeFree :: OcbReadOutcomeFreeFn
  , nativeOcbColumnDescriptorFixedBinaryWidth :: OcbColumnDescriptorFixedBinaryWidthFn
  , nativeOcbColumnArrayFixedBinaryWidth :: OcbColumnArrayFixedBinaryWidthFn
  , nativeOcbPlanRead :: OcbPlanReadFn
  , nativeOcbReadPlanReport :: OcbReadPlanReportFn
  , nativeOcbReadPlanProjectedColumnIds :: OcbReadPlanIdsFn
  , nativeOcbReadPlanRowGroupIds :: OcbReadPlanIdsFn
  , nativeOcbReadBatchesFromPlan :: OcbReadBatchesFromPlanFn
  , nativeOcbReadPlanFree :: OcbReadPlanFreeFn
  , nativeOcbRowGroupSummariesInit :: OcbRowGroupSummariesInitFn
  , nativeOcbRowGroupSummaries :: OcbRowGroupSummariesFn
  , nativeOcbReadPlanRowGroupSummaries :: OcbReadPlanRowGroupSummariesFn
  , nativeOcbRowGroupSummariesFree :: OcbRowGroupSummariesFreeFn
  , nativeTensorFree :: TensorFreeFn
  , nativeMaskFree :: MaskFreeFn
  , nativeFileMetaFree :: FileMetaFreeFn
  }

-- | Resolve the native library path from the supported environment variables.
resolveNativeLibraryPath :: IO (Either TioError FilePath)
resolveNativeLibraryPath = do
  exact <- nonEmptyEnv "ARCADIA_TIO_CAPI_LIB"
  case exact of
    Just path -> pure (Right path)
    Nothing -> do
      dir <- nonEmptyEnv "ARCADIA_TIO_CAPI_LIB_DIR"
      case dir of
        Just path -> pure (Right (path </> "libarcadia_tio_capi.so"))
        Nothing ->
          pure
            ( Left
                ( libraryLoadError
                    "set ARCADIA_TIO_CAPI_LIB=/path/to/libarcadia_tio_capi.so or ARCADIA_TIO_CAPI_LIB_DIR=/path/to/lib"
                )
            )

nonEmptyEnv :: String -> IO (Maybe String)
nonEmptyEnv key = do
  value <- lookupEnv key
  pure $ case value of
    Just text | not (null text) -> Just text
    _ -> Nothing

-- | Load the native library from the environment and check the ABI version.
loadNativeLibrary :: IO (Either TioError NativeLibrary)
loadNativeLibrary = do
  resolved <- resolveNativeLibraryPath
  case resolved of
    Left err -> pure (Left err)
    Right path -> loadNativeLibraryFrom path

-- | Load a native library from an explicit shared-object path.
loadNativeLibraryFrom :: FilePath -> IO (Either TioError NativeLibrary)
loadNativeLibraryFrom path = do
  loaded <- try (loadUnchecked path)
  case loaded of
    Left exc -> pure (Left (libraryLoadError ("failed to load Arcadia TIO C ABI library: " <> displayException (exc :: SomeException))))
    Right native -> do
      version <- abiVersion native
      if version == expectedAbiVersion
        then pure (Right native)
        else
          pure
            ( Left
                ( libraryLoadError
                    ( "unsupported Arcadia TIO C ABI version "
                        <> show version
                        <> "; expected "
                        <> show expectedAbiVersion
                    )
                )
            )

loadUnchecked :: FilePath -> IO NativeLibrary
loadUnchecked path = do
  dl <- dlopen path [RTLD_NOW, RTLD_LOCAL]
  nativeLastErrorMessage <- mkLastErrorMessage <$> dlsym dl "arcadia_tio_last_error_message"
  nativeLastErrorCode <- mkLastErrorCode <$> dlsym dl "arcadia_tio_last_error_code"
  nativeAbiVersion <- mkAbiVersion <$> dlsym dl "arcadia_tio_abi_version"
  nativeCreateStreaming <- mkCreateStreaming <$> dlsym dl "arcadia_tio_create_streaming"
  nativeCreateStreamingEx <- mkCreateEx <$> dlsym dl "arcadia_tio_create_streaming_ex"
  nativeCreateRandomAccess <- mkCreateRandomAccess <$> dlsym dl "arcadia_tio_create_random_access"
  nativeCreateRandomAccessEx <- mkCreateEx <$> dlsym dl "arcadia_tio_create_random_access_ex"
  nativeCreateRandomAccessWithUniverse <- mkCreateWithUniverse <$> dlsym dl "arcadia_tio_create_random_access_with_universe"
  nativeCreateStreamingWithUniverse <- mkCreateWithUniverse <$> dlsym dl "arcadia_tio_create_streaming_with_universe"
  nativeCreateInferred <- mkCreateInferred <$> dlsym dl "arcadia_tio_create_inferred"
  nativeCreateInferredEx <- mkCreateInferredEx <$> dlsym dl "arcadia_tio_create_inferred_ex"
  nativeCreateWithPolicy <- mkCreateWithPolicy <$> dlsym dl "arcadia_tio_create_with_policy"
  nativeCreateWithPolicyEx <- mkCreateWithPolicyEx <$> dlsym dl "arcadia_tio_create_with_policy_ex"
  nativeCreateWithPolicyWithUniverse <- mkCreateWithPolicyUniverse <$> dlsym dl "arcadia_tio_create_with_policy_with_universe"
  nativeCreateWithPolicyWithCoordinates <- mkCreateWithPolicyWithCoordinates <$> dlsym dl "arcadia_tio_create_with_policy_with_coordinates"
  nativeCreateInferredWithCoordinates <- mkCreateInferredWithCoordinates <$> dlsym dl "arcadia_tio_create_inferred_with_coordinates"
  nativeCreateRandomAccessWithCoordinates <- mkCreateStreamingWithCoordinates <$> dlsym dl "arcadia_tio_create_random_access_with_coordinates"
  nativeCreateStreamingWithCoordinates <- mkCreateStreamingWithCoordinates <$> dlsym dl "arcadia_tio_create_streaming_with_coordinates"
  nativeCreateWithPolicyWithCoordinatesV2 <- mkCreateWithPolicyWithCoordinatesV2 <$> dlsym dl "arcadia_tio_create_with_policy_with_coordinates_v2"
  nativeCreateInferredWithCoordinatesV2 <- mkCreateInferredWithCoordinatesV2 <$> dlsym dl "arcadia_tio_create_inferred_with_coordinates_v2"
  nativeCreateRandomAccessWithCoordinatesV2 <- mkCreateStreamingWithCoordinatesV2 <$> dlsym dl "arcadia_tio_create_random_access_with_coordinates_v2"
  nativeCreateStreamingWithCoordinatesV2 <- mkCreateStreamingWithCoordinatesV2 <$> dlsym dl "arcadia_tio_create_streaming_with_coordinates_v2"
  nativeCoordinateMeta <- mkCoordinateMeta <$> dlsym dl "arcadia_tio_coordinate_meta"
  nativeLoadCoordinateMeta <- mkLoadCoordinateMeta <$> dlsym dl "arcadia_tio_load_coordinate_meta"
  nativeAxisCoordinateMetaFree <- mkAxisCoordinateMetaFree <$> dlsym dl "arcadia_tio_axis_coordinate_meta_free"
  nativeCoordinateMetaV2 <- mkCoordinateMetaV2 <$> dlsym dl "arcadia_tio_coordinate_meta_v2"
  nativeLoadCoordinateMetaV2 <- mkLoadCoordinateMetaV2 <$> dlsym dl "arcadia_tio_load_coordinate_meta_v2"
  nativeAxisCoordinateMetaV2Free <- mkAxisCoordinateMetaV2Free <$> dlsym dl "arcadia_tio_axis_coordinate_meta_v2_free"
  nativeReadAxisCoordinates <- mkReadAxisCoordinates <$> dlsym dl "arcadia_tio_read_axis_coordinates"
  nativeCoordinateIndexI32 <- mkCoordinateIndexI32 <$> dlsym dl "arcadia_tio_coordinate_index_i32"
  nativeCoordinateIndexI64 <- mkCoordinateIndexI64 <$> dlsym dl "arcadia_tio_coordinate_index_i64"
  nativeCoordinateRangeI32 <- mkCoordinateRangeI32 <$> dlsym dl "arcadia_tio_coordinate_range_i32"
  nativeCoordinateRangeI64 <- mkCoordinateRangeI64 <$> dlsym dl "arcadia_tio_coordinate_range_i64"
  nativeReadAxisCoordinatesV2 <- mkReadAxisCoordinatesV2 <$> dlsym dl "arcadia_tio_read_axis_coordinates_v2"
  nativeCoordinateValueSliceV2Free <- mkCoordinateValueSliceV2Free <$> dlsym dl "arcadia_tio_coordinate_value_slice_v2_free"
  nativeCoordinateDictionaryV2 <- mkCoordinateDictionaryV2 <$> dlsym dl "arcadia_tio_coordinate_dictionary_v2"
  nativeCoordinateDictionaryV2Free <- mkCoordinateDictionaryV2Free <$> dlsym dl "arcadia_tio_coordinate_dictionary_v2_free"
  nativeCoordinateLookupV2 <- mkCoordinateLookupV2 <$> dlsym dl "arcadia_tio_coordinate_lookup_v2"
  nativeCoordinateLookupRangeV2 <- mkCoordinateLookupRangeV2 <$> dlsym dl "arcadia_tio_coordinate_lookup_range_v2"
  nativeCoordinateLookupResultV2Free <- mkCoordinateLookupResultV2Free <$> dlsym dl "arcadia_tio_coordinate_lookup_result_v2_free"
  nativeAppendF32WithCoordinatesV2 <- mkAppendF32WithCoordinatesV2 <$> dlsym dl "arcadia_tio_append_f32_with_coordinates_v2"
  nativeAppendF64WithCoordinatesV2 <- mkAppendF64WithCoordinatesV2 <$> dlsym dl "arcadia_tio_append_f64_with_coordinates_v2"
  nativeAppendI32WithCoordinatesV2 <- mkAppendI32WithCoordinatesV2 <$> dlsym dl "arcadia_tio_append_i32_with_coordinates_v2"
  nativeAppendI64WithCoordinatesV2 <- mkAppendI64WithCoordinatesV2 <$> dlsym dl "arcadia_tio_append_i64_with_coordinates_v2"
  nativeOpen <- mkOpen <$> dlsym dl "arcadia_tio_open"
  nativeClose <- mkClose <$> dlsym dl "arcadia_tio_close"
  nativeAppendF32WithRange <- mkAppendF32WithRange <$> dlsym dl "arcadia_tio_append_f32_with_range"
  nativeAppendF32WithUniverse <- mkAppendF32WithUniverse <$> dlsym dl "arcadia_tio_append_f32_with_universe"
  nativeAppendF64WithUniverse <- mkAppendF64WithUniverse <$> dlsym dl "arcadia_tio_append_f64_with_universe"
  nativeAppendI32WithUniverse <- mkAppendI32WithUniverse <$> dlsym dl "arcadia_tio_append_i32_with_universe"
  nativeAppendI64WithUniverse <- mkAppendI64WithUniverse <$> dlsym dl "arcadia_tio_append_i64_with_universe"
  nativeAppendF64WithRange <- mkAppendF64WithRange <$> dlsym dl "arcadia_tio_append_f64_with_range"
  nativeAppendI32WithRange <- mkAppendI32WithRange <$> dlsym dl "arcadia_tio_append_i32_with_range"
  nativeAppendI64WithRange <- mkAppendI64WithRange <$> dlsym dl "arcadia_tio_append_i64_with_range"
  nativeReadAll <- mkReadAll <$> dlsym dl "arcadia_tio_read_all"
  nativeReadAllDense <- mkReadAllDense <$> dlsym dl "arcadia_tio_read_all_dense"
  nativeReadAxisRange <- mkReadAxisRange <$> dlsym dl "arcadia_tio_read_axis_range"
  nativeReadAxisTake <- mkReadAxisTake <$> dlsym dl "arcadia_tio_read_axis_take"
  nativeReadAxisOne <- mkReadAxisOne <$> dlsym dl "arcadia_tio_read_axis_one"
  nativeReadEntryRange <- mkReadEntryRange <$> dlsym dl "arcadia_tio_read_entry_range"
  nativeTakeEntries <- mkTakeEntries <$> dlsym dl "arcadia_tio_take_entries"
  nativeTensorToContiguous <- mkTensorToContiguous <$> dlsym dl "arcadia_tio_tensor_to_contiguous"
  nativeTensorReshape <- mkTensorReshape <$> dlsym dl "arcadia_tio_tensor_reshape"
  nativeTensorFlatten <- mkTensorFlatten <$> dlsym dl "arcadia_tio_tensor_flatten"
  nativeTensorExpandDims <- mkTensorExpandDims <$> dlsym dl "arcadia_tio_tensor_expand_dims"
  nativeTensorSqueeze <- mkTensorSqueeze <$> dlsym dl "arcadia_tio_tensor_squeeze"
  nativeTensorSqueezeAxis <- mkTensorSqueezeAxis <$> dlsym dl "arcadia_tio_tensor_squeeze_axis"
  nativeTensorPermuteAxes <- mkTensorPermuteAxes <$> dlsym dl "arcadia_tio_tensor_permute_axes"
  nativeTensorTranspose <- mkTensorTranspose <$> dlsym dl "arcadia_tio_tensor_transpose"
  nativeTensorSliceAxis <- mkTensorSliceAxis <$> dlsym dl "arcadia_tio_tensor_slice_axis"
  nativeTensorSliceAxisStep <- mkTensorSliceAxisStep <$> dlsym dl "arcadia_tio_tensor_slice_axis_step"
  nativeTensorTakeAxis <- mkTensorTakeAxis <$> dlsym dl "arcadia_tio_tensor_take_axis"
  nativeTensorIndexAxis <- mkTensorIndexAxis <$> dlsym dl "arcadia_tio_tensor_index_axis"
  nativeTensorAdd <- mkTensorBinaryOp <$> dlsym dl "arcadia_tio_tensor_add"
  nativeTensorSub <- mkTensorBinaryOp <$> dlsym dl "arcadia_tio_tensor_sub"
  nativeTensorMul <- mkTensorBinaryOp <$> dlsym dl "arcadia_tio_tensor_mul"
  nativeTensorDiv <- mkTensorBinaryOp <$> dlsym dl "arcadia_tio_tensor_div"
  nativeTensorAddScalar <- mkTensorScalarOp <$> dlsym dl "arcadia_tio_tensor_add_scalar"
  nativeTensorSubScalar <- mkTensorScalarOp <$> dlsym dl "arcadia_tio_tensor_sub_scalar"
  nativeTensorMulScalar <- mkTensorScalarOp <$> dlsym dl "arcadia_tio_tensor_mul_scalar"
  nativeTensorDivScalar <- mkTensorScalarOp <$> dlsym dl "arcadia_tio_tensor_div_scalar"
  nativeRank <- mkRank <$> dlsym dl "arcadia_tio_rank"
  nativeDType <- mkDType <$> dlsym dl "arcadia_tio_dtype"
  nativeAppendAxis <- mkAppendAxis <$> dlsym dl "arcadia_tio_append_axis"
  nativeDimLens <- mkDimLens <$> dlsym dl "arcadia_tio_dim_lens"
  nativeChunkPlan <- mkChunkPlan <$> dlsym dl "arcadia_tio_chunk_plan"
  nativePath <- mkPath <$> dlsym dl "arcadia_tio_path"
  nativeStringFree <- mkStringFree <$> dlsym dl "arcadia_tio_string_free"
  nativeChunkPlanFree <- mkChunkPlanFree <$> dlsym dl "arcadia_tio_chunk_plan_free"
  nativeLoadMeta <- mkLoadMeta <$> dlsym dl "arcadia_tio_load_meta"
  nativeSetDimName <- mkSetDimName <$> dlsym dl "arcadia_tio_set_dim_name"
  nativeSetSymbols <- mkSetStrings <$> dlsym dl "arcadia_tio_set_symbols"
  nativeSetChannels <- mkSetStrings <$> dlsym dl "arcadia_tio_set_channels"
  nativeSetUserKv <- mkSetUserKv <$> dlsym dl "arcadia_tio_set_user_kv"
  nativeReadScalar <- mkReadScalar <$> dlsym dl "arcadia_tio_read_scalar"
  nativeSetCompressionConfig <- mkSetCompressionConfig <$> dlsym dl "arcadia_tio_set_compression_config"
  nativeGetCompressionConfig <- mkGetCompressionConfig <$> dlsym dl "arcadia_tio_get_compression_config"
  nativeHeadCommit <- mkHeadCommit <$> dlsym dl "arcadia_tio_head_commit"
  nativeListCommits <- mkListCommits <$> dlsym dl "arcadia_tio_list_commits"
  nativeCommitListFree <- mkCommitListFree <$> dlsym dl "arcadia_tio_commit_list_free"
  nativePop <- mkPop <$> dlsym dl "arcadia_tio_pop"
  nativePopBatched <- mkPopBatched <$> dlsym dl "arcadia_tio_pop_batched"
  nativeRevertCommit <- mkRevertCommit <$> dlsym dl "arcadia_tio_revert_commit"
  nativeReadAtCommit <- mkReadAtCommit <$> dlsym dl "arcadia_tio_read_at_commit"
  nativeReadAtCommitDense <- mkReadAtCommitDense <$> dlsym dl "arcadia_tio_read_at_commit_dense"
  nativeReadExecutionReportFree <- mkReadExecutionReportFree <$> dlsym dl "arcadia_tio_read_execution_report_free"
  nativeQueryTraceJsonFree <- mkQueryTraceJsonFree <$> dlsym dl "arcadia_tio_query_trace_json_free"
  nativeHistoricalReadExecutionReportFree <- mkHistoricalReadExecutionReportFree <$> dlsym dl "arcadia_tio_historical_read_execution_report_free"
  nativeReadIndexReportFree <- mkReadIndexReportFree <$> dlsym dl "arcadia_tio_read_index_report_free"
  nativeReadIndex <- mkReadIndex <$> dlsym dl "arcadia_tio_read_index"
  nativeReadWithOptions <- mkReadWithOptions <$> dlsym dl "arcadia_tio_read_with_options"
  nativeReadWithOptionsDense <- mkReadWithOptionsDense <$> dlsym dl "arcadia_tio_read_with_options_dense"
  nativeReadWithShapePolicy <- mkReadWithShapePolicy <$> dlsym dl "arcadia_tio_read_with_shape_policy"
  nativeReadWithShapePolicyDense <- mkReadWithShapePolicyDense <$> dlsym dl "arcadia_tio_read_with_shape_policy_dense"
  nativeReadWithOptionsAttributed <- mkReadWithOptionsAttributed <$> dlsym dl "arcadia_tio_read_with_options_attributed"
  nativeReadWithOptionsDenseAttributed <- mkReadWithOptionsDenseAttributed <$> dlsym dl "arcadia_tio_read_with_options_dense_attributed"
  nativeHistoricalReadWithOptions <- mkHistoricalReadWithOptions <$> dlsym dl "arcadia_tio_read_at_commit_with_options"
  nativeHistoricalReadWithOptionsDense <- mkHistoricalReadWithOptionsDense <$> dlsym dl "arcadia_tio_read_at_commit_with_options_dense"
  nativeHistoricalReadWithShapePolicy <- mkHistoricalReadWithShapePolicy <$> dlsym dl "arcadia_tio_read_at_commit_with_shape_policy"
  nativeHistoricalReadWithShapePolicyDense <- mkHistoricalReadWithShapePolicyDense <$> dlsym dl "arcadia_tio_read_at_commit_with_shape_policy_dense"
  nativeGetIndexCheckpointEveryCommits <- mkGetIndexCheckpointEveryCommits <$> dlsym dl "arcadia_tio_get_index_checkpoint_every_commits"
  nativeSetIndexCheckpointEveryCommits <- mkSetIndexCheckpointEveryCommits <$> dlsym dl "arcadia_tio_set_index_checkpoint_every_commits"
  nativeRewriteF32 <- mkRewriteF32 <$> dlsym dl "arcadia_tio_rewrite_f32"
  nativeRewriteF64 <- mkRewriteF64 <$> dlsym dl "arcadia_tio_rewrite_f64"
  nativeRewriteSliceF32 <- mkRewriteSliceF32 <$> dlsym dl "arcadia_tio_rewrite_slice_f32"
  nativeRewriteSliceF64 <- mkRewriteSliceF64 <$> dlsym dl "arcadia_tio_rewrite_slice_f64"
  nativeClearBlocks <- mkClearBlocks <$> dlsym dl "arcadia_tio_clear_blocks"
  nativeReadValuesArrow <- mkReadValuesArrow <$> dlsym dl "arcadia_tio_read_values_arrow"
  nativeAnalyzeCompaction <- mkAnalyzeCompaction <$> dlsym dl "arcadia_tio_analyze_compaction"
  nativeCompactTo <- mkCompactTo <$> dlsym dl "arcadia_tio_compact_to"
  nativeMaybeCompact <- mkMaybeCompact <$> dlsym dl "arcadia_tio_maybe_compact"
  nativeGetAutoCompactionConfig <- mkGetAutoCompactionConfig <$> dlsym dl "arcadia_tio_get_auto_compaction_config"
  nativeSetAutoCompactionConfig <- mkSetAutoCompactionConfig <$> dlsym dl "arcadia_tio_set_auto_compaction_config"
  nativeCompactionState <- mkCompactionState <$> dlsym dl "arcadia_tio_compaction_state"
  nativeMaybeCompactAuto <- mkMaybeCompactAuto <$> dlsym dl "arcadia_tio_maybe_compact_auto"
  nativeV4Diagnostics <- mkV4Diagnostics <$> dlsym dl "arcadia_tio_v4_diagnostics"
  nativeV4DiagnosticsReportFree <- mkV4DiagnosticsReportFree <$> dlsym dl "arcadia_tio_v4_diagnostics_report_free"
  nativeV4DiagnosticsPrecise <- mkV4DiagnosticsPrecise <$> dlsym dl "arcadia_tio_v4_diagnostics_precise"
  nativeV4DiagnosticsPreciseReportFree <- mkV4DiagnosticsPreciseReportFree <$> dlsym dl "arcadia_tio_v4_diagnostics_precise_report_free"
  nativeAnalyzeV4Compaction <- mkAnalyzeV4Compaction <$> dlsym dl "arcadia_tio_analyze_v4_compaction"
  nativeV4CompactionAnalysisReportFree <- mkV4CompactionAnalysisReportFree <$> dlsym dl "arcadia_tio_v4_compaction_analysis_report_free"
  nativeAnalyzeV4CompactionPrecise <- mkAnalyzeV4CompactionPrecise <$> dlsym dl "arcadia_tio_analyze_v4_compaction_precise"
  nativeV4CompactionAnalysisPreciseReportFree <- mkV4CompactionAnalysisPreciseReportFree <$> dlsym dl "arcadia_tio_v4_compaction_analysis_precise_report_free"
  nativeCompactV4RetainedHistoryTo <- mkCompactV4RetainedHistoryTo <$> dlsym dl "arcadia_tio_compact_v4_retained_history_to"
  nativeV4RetainedHistoryCompactionReportFree <- mkV4RetainedHistoryCompactionReportFree <$> dlsym dl "arcadia_tio_v4_retained_history_compaction_report_free"
  nativeCompactV4RetainedHistoryToPrecise <- mkCompactV4RetainedHistoryToPrecise <$> dlsym dl "arcadia_tio_compact_v4_retained_history_to_precise"
  nativeV4RetainedHistoryCompactionPreciseReportFree <- mkV4RetainedHistoryCompactionPreciseReportFree <$> dlsym dl "arcadia_tio_v4_retained_history_compaction_precise_report_free"
  nativeReformTo <- mkReformTo <$> dlsym dl "arcadia_tio_reform_to"
  nativeReformToEx <- mkReformToEx <$> dlsym dl "arcadia_tio_reform_to_ex"
  nativeReformReportFree <- mkReformReportFree <$> dlsym dl "arcadia_tio_reform_report_free"
  nativeAnalyzeSparseAppendF32V2 <- mkAnalyzeSparseAppendF32V2 <$> dlsym dl "arcadia_tio_analyze_sparse_append_f32_v2"
  nativeAnalyzeSparseAppendF64V2 <- mkAnalyzeSparseAppendF64V2 <$> dlsym dl "arcadia_tio_analyze_sparse_append_f64_v2"
  nativeAnalyzeSparseAppendI32V2 <- mkAnalyzeSparseAppendI32V2 <$> dlsym dl "arcadia_tio_analyze_sparse_append_i32_v2"
  nativeAnalyzeSparseAppendI64V2 <- mkAnalyzeSparseAppendI64V2 <$> dlsym dl "arcadia_tio_analyze_sparse_append_i64_v2"
  nativeAppendSparseF32WithRangeV2 <- mkAppendSparseF32WithRangeV2 <$> dlsym dl "arcadia_tio_append_sparse_f32_with_range_v2"
  nativeAppendSparseF64WithRangeV2 <- mkAppendSparseF64WithRangeV2 <$> dlsym dl "arcadia_tio_append_sparse_f64_with_range_v2"
  nativeAppendSparseI32WithRangeV2 <- mkAppendSparseI32WithRangeV2 <$> dlsym dl "arcadia_tio_append_sparse_i32_with_range_v2"
  nativeAppendSparseI64WithRangeV2 <- mkAppendSparseI64WithRangeV2 <$> dlsym dl "arcadia_tio_append_sparse_i64_with_range_v2"
  nativeSparseAppendAnalysisFree <- mkSparseAppendAnalysisFree <$> dlsym dl "arcadia_tio_sparse_append_analysis_free"
  nativeOcbLastErrorKind <- mkOcbLastErrorKind <$> dlsym dl "arcadia_tio_ocb_last_error_kind"
  nativeOcbLastErrorCause <- mkOcbLastErrorCause <$> dlsym dl "arcadia_tio_ocb_last_error_cause"
  nativeOcbOpen <- mkOcbOpen <$> dlsym dl "arcadia_tio_ocb_open"
  nativeOcbOpenWithOptions <- mkOcbOpenWithOptions <$> dlsym dl "arcadia_tio_ocb_open_with_options"
  nativeOcbReaderClone <- mkOcbReaderClone <$> dlsym dl "arcadia_tio_ocb_reader_clone"
  nativeOcbClose <- mkOcbClose <$> dlsym dl "arcadia_tio_ocb_close"
  nativeOcbMetadata <- mkOcbMetadata <$> dlsym dl "arcadia_tio_ocb_metadata"
  nativeOcbMetadataFree <- mkOcbMetadataFree <$> dlsym dl "arcadia_tio_ocb_metadata_free"
  nativeOcbDictionaryValues <- mkOcbDictionaryValues <$> dlsym dl "arcadia_tio_ocb_dictionary_values"
  nativeOcbDictionaryValuesFree <- mkOcbDictionaryValuesFree <$> dlsym dl "arcadia_tio_ocb_dictionary_values_free"
  nativeOcbOpenOptionsInit <- mkOcbOpenOptionsInit <$> dlsym dl "arcadia_tio_ocb_open_options_init"
  nativeOcbPrimitiveValuesInit <- mkOcbPrimitiveValuesInit <$> dlsym dl "arcadia_tio_ocb_primitive_values_init"
  nativeOcbValidityBitmapInit <- mkOcbValidityBitmapInit <$> dlsym dl "arcadia_tio_ocb_validity_bitmap_init"
  nativeOcbWriteOptionsInit <- mkOcbWriteOptionsInit <$> dlsym dl "arcadia_tio_ocb_write_options_init"
  nativeOcbWriteColumnInit <- mkOcbWriteColumnInit <$> dlsym dl "arcadia_tio_ocb_write_column_init"
  nativeOcbDictionaryEntryInit <- mkOcbDictionaryEntryInit <$> dlsym dl "arcadia_tio_ocb_dictionary_entry_init"
  nativeOcbWriteDictionaryInit <- mkOcbWriteDictionaryInit <$> dlsym dl "arcadia_tio_ocb_write_dictionary_init"
  nativeOcbWriteColumnChunkInit <- mkOcbWriteColumnChunkInit <$> dlsym dl "arcadia_tio_ocb_write_column_chunk_init"
  nativeOcbWriteRowGroupInit <- mkOcbWriteRowGroupInit <$> dlsym dl "arcadia_tio_ocb_write_row_group_init"
  nativeOcbWriteOrderingKeyInit <- mkOcbWriteOrderingKeyInit <$> dlsym dl "arcadia_tio_ocb_write_ordering_key_init"
  nativeOcbWriteSpecInit <- mkOcbWriteSpecInit <$> dlsym dl "arcadia_tio_ocb_write_spec_init"
  nativeOcbCleanupResultInit <- mkOcbCleanupResultInit <$> dlsym dl "arcadia_tio_ocb_cleanup_result_init"
  nativeOcbPredicateValueInit <- mkOcbPredicateValueInit <$> dlsym dl "arcadia_tio_ocb_predicate_value_init"
  nativeOcbRowGroupPredicateInit <- mkOcbRowGroupPredicateInit <$> dlsym dl "arcadia_tio_ocb_row_group_predicate_init"
  nativeOcbWriteColumnSetFixedBinaryWidth <- mkOcbWriteColumnSetFixedBinaryWidth <$> dlsym dl "arcadia_tio_ocb_write_column_set_fixed_binary_width"
  nativeOcbWriteColumnFixedBinaryWidth <- mkOcbWriteColumnFixedBinaryWidth <$> dlsym dl "arcadia_tio_ocb_write_column_fixed_binary_width"
  nativeOcbCreate <- mkOcbCreate <$> dlsym dl "arcadia_tio_ocb_create"
  nativeOcbCreateWithOptions <- mkOcbCreateWithOptions <$> dlsym dl "arcadia_tio_ocb_create_with_options"
  nativeOcbAppend <- mkOcbAppend <$> dlsym dl "arcadia_tio_ocb_append"
  nativeOcbAppendWithOptions <- mkOcbAppendWithOptions <$> dlsym dl "arcadia_tio_ocb_append_with_options"
  nativeOcbCleanupOrphanTail <- mkOcbCleanupOrphanTail <$> dlsym dl "arcadia_tio_ocb_cleanup_orphan_tail"
  nativeOcbReadRequestInit <- mkOcbReadRequestInit <$> dlsym dl "arcadia_tio_ocb_read_request_init"
  nativeOcbReadReportInit <- mkOcbReadReportInit <$> dlsym dl "arcadia_tio_ocb_read_report_init"
  nativeOcbReadAttributionInit <- mkOcbReadAttributionInit <$> dlsym dl "arcadia_tio_ocb_read_attribution_init"
  nativeOcbReadOutcomeInit <- mkOcbReadOutcomeInit <$> dlsym dl "arcadia_tio_ocb_read_outcome_init"
  nativeOcbReadCursorOptionsInit <- mkOcbReadCursorOptionsInit <$> dlsym dl "arcadia_tio_ocb_read_cursor_options_init"
  nativeOcbReadCursorReportInit <- mkOcbReadCursorReportInit <$> dlsym dl "arcadia_tio_ocb_read_cursor_report_init"
  nativeOcbReadCursorReportFree <- mkOcbReadCursorReportFree <$> dlsym dl "arcadia_tio_ocb_read_cursor_report_free"
  nativeOcbVisitBatches <- mkOcbVisitBatches <$> dlsym dl "arcadia_tio_ocb_visit_batches"
  nativeOcbColumnFillBufferInit <- mkOcbColumnFillBufferInit <$> dlsym dl "arcadia_tio_ocb_column_fill_buffer_init"
  nativeOcbColumnFillBufferSetFixedBinaryWidth <- mkOcbColumnFillBufferSetFixedBinaryWidth <$> dlsym dl "arcadia_tio_ocb_column_fill_buffer_set_fixed_binary_width"
  nativeOcbColumnFillBufferFixedBinaryWidth <- mkOcbColumnFillBufferFixedBinaryWidth <$> dlsym dl "arcadia_tio_ocb_column_fill_buffer_fixed_binary_width"
  nativeOcbRowGroupFillRequestInit <- mkOcbRowGroupFillRequestInit <$> dlsym dl "arcadia_tio_ocb_row_group_fill_request_init"
  nativeOcbReadFillReportInit <- mkOcbReadFillReportInit <$> dlsym dl "arcadia_tio_ocb_read_fill_report_init"
  nativeOcbReadRowGroupInto <- mkOcbReadRowGroupInto <$> dlsym dl "arcadia_tio_ocb_read_row_group_into"
  nativeOcbReadBatches <- mkOcbReadBatches <$> dlsym dl "arcadia_tio_ocb_read_batches"
  nativeOcbReadBatchesWithAttribution <- mkOcbReadBatchesWithAttribution <$> dlsym dl "arcadia_tio_ocb_read_batches_with_attribution"
  nativeOcbReadReportFree <- mkOcbReadReportFree <$> dlsym dl "arcadia_tio_ocb_read_report_free"
  nativeOcbReadAttributionFree <- mkOcbReadAttributionFree <$> dlsym dl "arcadia_tio_ocb_read_attribution_free"
  nativeOcbReadOutcomeFree <- mkOcbReadOutcomeFree <$> dlsym dl "arcadia_tio_ocb_read_outcome_free"
  nativeOcbColumnDescriptorFixedBinaryWidth <- mkOcbColumnDescriptorFixedBinaryWidth <$> dlsym dl "arcadia_tio_ocb_column_descriptor_fixed_binary_width"
  nativeOcbColumnArrayFixedBinaryWidth <- mkOcbColumnArrayFixedBinaryWidth <$> dlsym dl "arcadia_tio_ocb_column_array_fixed_binary_width"
  nativeOcbPlanRead <- mkOcbPlanRead <$> dlsym dl "arcadia_tio_ocb_plan_read"
  nativeOcbReadPlanReport <- mkOcbReadPlanReport <$> dlsym dl "arcadia_tio_ocb_read_plan_report"
  nativeOcbReadPlanProjectedColumnIds <- mkOcbReadPlanProjectedColumnIds <$> dlsym dl "arcadia_tio_ocb_read_plan_projected_column_ids"
  nativeOcbReadPlanRowGroupIds <- mkOcbReadPlanRowGroupIds <$> dlsym dl "arcadia_tio_ocb_read_plan_row_group_ids"
  nativeOcbReadBatchesFromPlan <- mkOcbReadBatchesFromPlan <$> dlsym dl "arcadia_tio_ocb_read_batches_from_plan"
  nativeOcbReadPlanFree <- mkOcbReadPlanFree <$> dlsym dl "arcadia_tio_ocb_read_plan_free"
  nativeOcbRowGroupSummariesInit <- mkOcbRowGroupSummariesInit <$> dlsym dl "arcadia_tio_ocb_row_group_summaries_init"
  nativeOcbRowGroupSummaries <- mkOcbRowGroupSummaries <$> dlsym dl "arcadia_tio_ocb_row_group_summaries"
  nativeOcbReadPlanRowGroupSummaries <- mkOcbReadPlanRowGroupSummaries <$> dlsym dl "arcadia_tio_ocb_read_plan_row_group_summaries"
  nativeOcbRowGroupSummariesFree <- mkOcbRowGroupSummariesFree <$> dlsym dl "arcadia_tio_ocb_row_group_summaries_free"
  nativeTensorFree <- mkTensorFree <$> dlsym dl "arcadia_tio_tensor_free"
  nativeMaskFree <- mkMaskFree <$> dlsym dl "arcadia_tio_mask_free"
  nativeFileMetaFree <- mkFileMetaFree <$> dlsym dl "arcadia_tio_file_meta_free"
  pure
    NativeLibrary
      { nativeLibraryPath = path
      , nativeLibraryHandle = dl
      , nativeLastErrorMessage
      , nativeLastErrorCode
      , nativeAbiVersion
      , nativeCreateStreaming
      , nativeCreateStreamingEx
      , nativeCreateRandomAccess
      , nativeCreateRandomAccessEx
      , nativeCreateRandomAccessWithUniverse
      , nativeCreateStreamingWithUniverse
      , nativeCreateWithPolicyWithUniverse
      , nativeCreateInferred
      , nativeCreateInferredEx
      , nativeCreateWithPolicy
      , nativeCreateWithPolicyEx
      , nativeCreateWithPolicyWithCoordinates
      , nativeCreateInferredWithCoordinates
      , nativeCreateRandomAccessWithCoordinates
      , nativeCreateStreamingWithCoordinates
      , nativeCreateWithPolicyWithCoordinatesV2
      , nativeCreateInferredWithCoordinatesV2
      , nativeCreateRandomAccessWithCoordinatesV2
      , nativeCreateStreamingWithCoordinatesV2
      , nativeCoordinateMeta
      , nativeLoadCoordinateMeta
      , nativeAxisCoordinateMetaFree
      , nativeCoordinateMetaV2
      , nativeLoadCoordinateMetaV2
      , nativeAxisCoordinateMetaV2Free
      , nativeReadAxisCoordinates
      , nativeCoordinateIndexI32
      , nativeCoordinateIndexI64
      , nativeCoordinateRangeI32
      , nativeCoordinateRangeI64
      , nativeReadAxisCoordinatesV2
      , nativeCoordinateValueSliceV2Free
      , nativeCoordinateDictionaryV2
      , nativeCoordinateDictionaryV2Free
      , nativeCoordinateLookupV2
      , nativeCoordinateLookupRangeV2
      , nativeCoordinateLookupResultV2Free
      , nativeAppendF32WithCoordinatesV2
      , nativeAppendF64WithCoordinatesV2
      , nativeAppendI32WithCoordinatesV2
      , nativeAppendI64WithCoordinatesV2
      , nativeAppendF32WithUniverse
      , nativeAppendF64WithUniverse
      , nativeAppendI32WithUniverse
      , nativeAppendI64WithUniverse
      , nativeOpen
      , nativeClose
      , nativeAppendF32WithRange
      , nativeAppendF64WithRange
      , nativeAppendI32WithRange
      , nativeAppendI64WithRange
      , nativeReadAll
      , nativeReadAllDense
      , nativeReadAxisRange
      , nativeReadAxisTake
      , nativeReadAxisOne
      , nativeReadEntryRange
      , nativeTakeEntries
      , nativeTensorToContiguous
      , nativeTensorReshape
      , nativeTensorFlatten
      , nativeTensorExpandDims
      , nativeTensorSqueeze
      , nativeTensorSqueezeAxis
      , nativeTensorPermuteAxes
      , nativeTensorTranspose
      , nativeTensorSliceAxis
      , nativeTensorSliceAxisStep
      , nativeTensorTakeAxis
      , nativeTensorIndexAxis
      , nativeTensorAdd
      , nativeTensorSub
      , nativeTensorMul
      , nativeTensorDiv
      , nativeTensorAddScalar
      , nativeTensorSubScalar
      , nativeTensorMulScalar
      , nativeTensorDivScalar
      , nativeRank
      , nativeDType
      , nativeAppendAxis
      , nativeDimLens
      , nativeChunkPlan
      , nativePath
      , nativeStringFree
      , nativeChunkPlanFree
      , nativeLoadMeta
      , nativeSetDimName
      , nativeSetSymbols
      , nativeSetChannels
      , nativeSetUserKv
      , nativeReadScalar
      , nativeSetCompressionConfig
      , nativeGetCompressionConfig
      , nativeHeadCommit
      , nativeListCommits
      , nativeCommitListFree
      , nativePop
      , nativePopBatched
      , nativeRevertCommit
      , nativeReadAtCommit
      , nativeReadAtCommitDense
      , nativeReadExecutionReportFree
      , nativeQueryTraceJsonFree
      , nativeHistoricalReadExecutionReportFree
      , nativeReadIndexReportFree
      , nativeReadIndex
      , nativeReadWithOptions
      , nativeReadWithOptionsDense
      , nativeReadWithShapePolicy
      , nativeReadWithShapePolicyDense
      , nativeReadWithOptionsAttributed
      , nativeReadWithOptionsDenseAttributed
      , nativeHistoricalReadWithOptions
      , nativeHistoricalReadWithOptionsDense
      , nativeHistoricalReadWithShapePolicy
      , nativeHistoricalReadWithShapePolicyDense
      , nativeGetIndexCheckpointEveryCommits
      , nativeSetIndexCheckpointEveryCommits
      , nativeRewriteF32
      , nativeRewriteF64
      , nativeRewriteSliceF32
      , nativeRewriteSliceF64
      , nativeClearBlocks
      , nativeReadValuesArrow
      , nativeAnalyzeCompaction
      , nativeCompactTo
      , nativeMaybeCompact
      , nativeGetAutoCompactionConfig
      , nativeSetAutoCompactionConfig
      , nativeCompactionState
      , nativeMaybeCompactAuto
      , nativeV4Diagnostics
      , nativeV4DiagnosticsReportFree
      , nativeV4DiagnosticsPrecise
      , nativeV4DiagnosticsPreciseReportFree
      , nativeAnalyzeV4Compaction
      , nativeV4CompactionAnalysisReportFree
      , nativeAnalyzeV4CompactionPrecise
      , nativeV4CompactionAnalysisPreciseReportFree
      , nativeCompactV4RetainedHistoryTo
      , nativeV4RetainedHistoryCompactionReportFree
      , nativeCompactV4RetainedHistoryToPrecise
      , nativeV4RetainedHistoryCompactionPreciseReportFree
      , nativeReformTo
      , nativeReformToEx
      , nativeReformReportFree
      , nativeAnalyzeSparseAppendF32V2
      , nativeAnalyzeSparseAppendF64V2
      , nativeAnalyzeSparseAppendI32V2
      , nativeAnalyzeSparseAppendI64V2
      , nativeAppendSparseF32WithRangeV2
      , nativeAppendSparseF64WithRangeV2
      , nativeAppendSparseI32WithRangeV2
      , nativeAppendSparseI64WithRangeV2
      , nativeSparseAppendAnalysisFree
      , nativeOcbLastErrorKind
      , nativeOcbLastErrorCause
      , nativeOcbOpen
      , nativeOcbOpenWithOptions
      , nativeOcbReaderClone
      , nativeOcbClose
      , nativeOcbMetadata
      , nativeOcbMetadataFree
      , nativeOcbDictionaryValues
      , nativeOcbDictionaryValuesFree
      , nativeOcbOpenOptionsInit
      , nativeOcbPrimitiveValuesInit
      , nativeOcbValidityBitmapInit
      , nativeOcbWriteOptionsInit
      , nativeOcbWriteColumnInit
      , nativeOcbDictionaryEntryInit
      , nativeOcbWriteDictionaryInit
      , nativeOcbWriteColumnChunkInit
      , nativeOcbWriteRowGroupInit
      , nativeOcbWriteOrderingKeyInit
      , nativeOcbWriteSpecInit
      , nativeOcbCleanupResultInit
      , nativeOcbPredicateValueInit
      , nativeOcbRowGroupPredicateInit
      , nativeOcbWriteColumnSetFixedBinaryWidth
      , nativeOcbWriteColumnFixedBinaryWidth
      , nativeOcbCreate
      , nativeOcbCreateWithOptions
      , nativeOcbAppend
      , nativeOcbAppendWithOptions
      , nativeOcbCleanupOrphanTail
      , nativeOcbReadRequestInit
      , nativeOcbReadReportInit
      , nativeOcbReadAttributionInit
      , nativeOcbReadOutcomeInit
      , nativeOcbReadCursorOptionsInit
      , nativeOcbReadCursorReportInit
      , nativeOcbReadCursorReportFree
      , nativeOcbVisitBatches
      , nativeOcbColumnFillBufferInit
      , nativeOcbColumnFillBufferSetFixedBinaryWidth
      , nativeOcbColumnFillBufferFixedBinaryWidth
      , nativeOcbRowGroupFillRequestInit
      , nativeOcbReadFillReportInit
      , nativeOcbReadRowGroupInto
      , nativeOcbReadBatches
      , nativeOcbReadBatchesWithAttribution
      , nativeOcbReadReportFree
      , nativeOcbReadAttributionFree
      , nativeOcbReadOutcomeFree
      , nativeOcbColumnDescriptorFixedBinaryWidth
      , nativeOcbColumnArrayFixedBinaryWidth
      , nativeOcbPlanRead
      , nativeOcbReadPlanReport
      , nativeOcbReadPlanProjectedColumnIds
      , nativeOcbReadPlanRowGroupIds
      , nativeOcbReadBatchesFromPlan
      , nativeOcbReadPlanFree
      , nativeOcbRowGroupSummariesInit
      , nativeOcbRowGroupSummaries
      , nativeOcbReadPlanRowGroupSummaries
      , nativeOcbRowGroupSummariesFree
      , nativeTensorFree
      , nativeMaskFree
      , nativeFileMetaFree
      }

-- | Query the loaded native library ABI version.
abiVersion :: NativeLibrary -> IO Word32
abiVersion NativeLibrary{nativeAbiVersion} = nativeAbiVersion

-- | Copy the C ABI thread-local last-error state into Haskell memory.
lastError :: NativeLibrary -> IO TioError
lastError NativeLibrary{nativeLastErrorCode, nativeLastErrorMessage} = do
  CInt rawCode <- nativeLastErrorCode
  messagePtr <- nativeLastErrorMessage
  message <-
    if messagePtr == nullPtr
      then pure "Arcadia TIO C ABI call failed"
      else do
        text <- peekCString messagePtr
        pure $ if null text then "Arcadia TIO C ABI call failed" else text
  pure (TioError (nativeErrorCodeFromInt (fromIntegral rawCode)) message)

capiCreateStreaming :: NativeLibrary -> CreateStreamingFn
capiCreateStreaming NativeLibrary{nativeCreateStreaming} = nativeCreateStreaming

capiCreateStreamingEx :: NativeLibrary -> CreateExFn
capiCreateStreamingEx NativeLibrary{nativeCreateStreamingEx} = nativeCreateStreamingEx

capiCreateRandomAccess :: NativeLibrary -> CreateRandomAccessFn
capiCreateRandomAccess NativeLibrary{nativeCreateRandomAccess} = nativeCreateRandomAccess

capiCreateRandomAccessEx :: NativeLibrary -> CreateExFn
capiCreateRandomAccessEx NativeLibrary{nativeCreateRandomAccessEx} = nativeCreateRandomAccessEx

capiCreateRandomAccessWithUniverse :: NativeLibrary -> CreateWithUniverseFn
capiCreateRandomAccessWithUniverse NativeLibrary{nativeCreateRandomAccessWithUniverse} = nativeCreateRandomAccessWithUniverse

capiCreateStreamingWithUniverse :: NativeLibrary -> CreateWithUniverseFn
capiCreateStreamingWithUniverse NativeLibrary{nativeCreateStreamingWithUniverse} = nativeCreateStreamingWithUniverse

capiCreateInferred :: NativeLibrary -> CreateInferredFn
capiCreateInferred NativeLibrary{nativeCreateInferred} = nativeCreateInferred

capiCreateInferredEx :: NativeLibrary -> CreateInferredExFn
capiCreateInferredEx NativeLibrary{nativeCreateInferredEx} = nativeCreateInferredEx

capiCreateWithPolicy :: NativeLibrary -> CreateWithPolicyFn
capiCreateWithPolicy NativeLibrary{nativeCreateWithPolicy} = nativeCreateWithPolicy

capiCreateWithPolicyEx :: NativeLibrary -> CreateWithPolicyExFn
capiCreateWithPolicyEx NativeLibrary{nativeCreateWithPolicyEx} = nativeCreateWithPolicyEx

capiCreateWithPolicyWithUniverse :: NativeLibrary -> CreateWithPolicyUniverseFn
capiCreateWithPolicyWithUniverse NativeLibrary{nativeCreateWithPolicyWithUniverse} = nativeCreateWithPolicyWithUniverse


capiCreateWithPolicyWithCoordinates :: NativeLibrary -> CreateWithPolicyWithCoordinatesFn
capiCreateWithPolicyWithCoordinates NativeLibrary{nativeCreateWithPolicyWithCoordinates} = nativeCreateWithPolicyWithCoordinates

capiCreateInferredWithCoordinates :: NativeLibrary -> CreateInferredWithCoordinatesFn
capiCreateInferredWithCoordinates NativeLibrary{nativeCreateInferredWithCoordinates} = nativeCreateInferredWithCoordinates

capiCreateRandomAccessWithCoordinates :: NativeLibrary -> CreateStreamingWithCoordinatesFn
capiCreateRandomAccessWithCoordinates NativeLibrary{nativeCreateRandomAccessWithCoordinates} = nativeCreateRandomAccessWithCoordinates

capiCreateStreamingWithCoordinates :: NativeLibrary -> CreateStreamingWithCoordinatesFn
capiCreateStreamingWithCoordinates NativeLibrary{nativeCreateStreamingWithCoordinates} = nativeCreateStreamingWithCoordinates

capiCreateWithPolicyWithCoordinatesV2 :: NativeLibrary -> CreateWithPolicyWithCoordinatesV2Fn
capiCreateWithPolicyWithCoordinatesV2 NativeLibrary{nativeCreateWithPolicyWithCoordinatesV2} = nativeCreateWithPolicyWithCoordinatesV2

capiCreateInferredWithCoordinatesV2 :: NativeLibrary -> CreateInferredWithCoordinatesV2Fn
capiCreateInferredWithCoordinatesV2 NativeLibrary{nativeCreateInferredWithCoordinatesV2} = nativeCreateInferredWithCoordinatesV2

capiCreateRandomAccessWithCoordinatesV2 :: NativeLibrary -> CreateStreamingWithCoordinatesV2Fn
capiCreateRandomAccessWithCoordinatesV2 NativeLibrary{nativeCreateRandomAccessWithCoordinatesV2} = nativeCreateRandomAccessWithCoordinatesV2

capiCreateStreamingWithCoordinatesV2 :: NativeLibrary -> CreateStreamingWithCoordinatesV2Fn
capiCreateStreamingWithCoordinatesV2 NativeLibrary{nativeCreateStreamingWithCoordinatesV2} = nativeCreateStreamingWithCoordinatesV2

capiCoordinateMeta :: NativeLibrary -> CoordinateMetaFn
capiCoordinateMeta NativeLibrary{nativeCoordinateMeta} = nativeCoordinateMeta

capiLoadCoordinateMeta :: NativeLibrary -> LoadCoordinateMetaFn
capiLoadCoordinateMeta NativeLibrary{nativeLoadCoordinateMeta} = nativeLoadCoordinateMeta

capiAxisCoordinateMetaFree :: NativeLibrary -> AxisCoordinateMetaFreeFn
capiAxisCoordinateMetaFree NativeLibrary{nativeAxisCoordinateMetaFree} = nativeAxisCoordinateMetaFree

capiCoordinateMetaV2 :: NativeLibrary -> CoordinateMetaV2Fn
capiCoordinateMetaV2 NativeLibrary{nativeCoordinateMetaV2} = nativeCoordinateMetaV2

capiLoadCoordinateMetaV2 :: NativeLibrary -> LoadCoordinateMetaV2Fn
capiLoadCoordinateMetaV2 NativeLibrary{nativeLoadCoordinateMetaV2} = nativeLoadCoordinateMetaV2

capiAxisCoordinateMetaV2Free :: NativeLibrary -> AxisCoordinateMetaV2FreeFn
capiAxisCoordinateMetaV2Free NativeLibrary{nativeAxisCoordinateMetaV2Free} = nativeAxisCoordinateMetaV2Free

capiReadAxisCoordinates :: NativeLibrary -> ReadAxisCoordinatesFn
capiReadAxisCoordinates NativeLibrary{nativeReadAxisCoordinates} = nativeReadAxisCoordinates

capiCoordinateIndexI32 :: NativeLibrary -> CoordinateIndexI32Fn
capiCoordinateIndexI32 NativeLibrary{nativeCoordinateIndexI32} = nativeCoordinateIndexI32

capiCoordinateIndexI64 :: NativeLibrary -> CoordinateIndexI64Fn
capiCoordinateIndexI64 NativeLibrary{nativeCoordinateIndexI64} = nativeCoordinateIndexI64

capiCoordinateRangeI32 :: NativeLibrary -> CoordinateRangeI32Fn
capiCoordinateRangeI32 NativeLibrary{nativeCoordinateRangeI32} = nativeCoordinateRangeI32

capiCoordinateRangeI64 :: NativeLibrary -> CoordinateRangeI64Fn
capiCoordinateRangeI64 NativeLibrary{nativeCoordinateRangeI64} = nativeCoordinateRangeI64

capiReadAxisCoordinatesV2 :: NativeLibrary -> ReadAxisCoordinatesV2Fn
capiReadAxisCoordinatesV2 NativeLibrary{nativeReadAxisCoordinatesV2} = nativeReadAxisCoordinatesV2

capiCoordinateValueSliceV2Free :: NativeLibrary -> CoordinateValueSliceV2FreeFn
capiCoordinateValueSliceV2Free NativeLibrary{nativeCoordinateValueSliceV2Free} = nativeCoordinateValueSliceV2Free

capiCoordinateDictionaryV2 :: NativeLibrary -> CoordinateDictionaryV2Fn
capiCoordinateDictionaryV2 NativeLibrary{nativeCoordinateDictionaryV2} = nativeCoordinateDictionaryV2

capiCoordinateDictionaryV2Free :: NativeLibrary -> CoordinateDictionaryV2FreeFn
capiCoordinateDictionaryV2Free NativeLibrary{nativeCoordinateDictionaryV2Free} = nativeCoordinateDictionaryV2Free

capiCoordinateLookupV2 :: NativeLibrary -> CoordinateLookupV2Fn
capiCoordinateLookupV2 NativeLibrary{nativeCoordinateLookupV2} = nativeCoordinateLookupV2

capiCoordinateLookupRangeV2 :: NativeLibrary -> CoordinateLookupRangeV2Fn
capiCoordinateLookupRangeV2 NativeLibrary{nativeCoordinateLookupRangeV2} = nativeCoordinateLookupRangeV2

capiCoordinateLookupResultV2Free :: NativeLibrary -> CoordinateLookupResultV2FreeFn
capiCoordinateLookupResultV2Free NativeLibrary{nativeCoordinateLookupResultV2Free} = nativeCoordinateLookupResultV2Free

capiAppendF32WithCoordinatesV2 :: NativeLibrary -> AppendWithCoordinatesV2Fn CFloat
capiAppendF32WithCoordinatesV2 NativeLibrary{nativeAppendF32WithCoordinatesV2} = nativeAppendF32WithCoordinatesV2

capiAppendF64WithCoordinatesV2 :: NativeLibrary -> AppendWithCoordinatesV2Fn Double
capiAppendF64WithCoordinatesV2 NativeLibrary{nativeAppendF64WithCoordinatesV2} = nativeAppendF64WithCoordinatesV2

capiAppendI32WithCoordinatesV2 :: NativeLibrary -> AppendWithCoordinatesV2Fn Int32
capiAppendI32WithCoordinatesV2 NativeLibrary{nativeAppendI32WithCoordinatesV2} = nativeAppendI32WithCoordinatesV2

capiAppendI64WithCoordinatesV2 :: NativeLibrary -> AppendWithCoordinatesV2Fn Int64
capiAppendI64WithCoordinatesV2 NativeLibrary{nativeAppendI64WithCoordinatesV2} = nativeAppendI64WithCoordinatesV2

capiOpen :: NativeLibrary -> OpenFn
capiOpen NativeLibrary{nativeOpen} = nativeOpen

capiClose :: NativeLibrary -> CloseFn
capiClose NativeLibrary{nativeClose} = nativeClose

capiAppendF32WithRange :: NativeLibrary -> AppendF32WithRangeFn
capiAppendF32WithRange NativeLibrary{nativeAppendF32WithRange} = nativeAppendF32WithRange

capiAppendF64WithRange :: NativeLibrary -> AppendF64WithRangeFn
capiAppendF64WithRange NativeLibrary{nativeAppendF64WithRange} = nativeAppendF64WithRange

capiAppendF32WithUniverse :: NativeLibrary -> AppendWithUniverseFn CFloat
capiAppendF32WithUniverse NativeLibrary{nativeAppendF32WithUniverse} = nativeAppendF32WithUniverse

capiAppendF64WithUniverse :: NativeLibrary -> AppendWithUniverseFn Double
capiAppendF64WithUniverse NativeLibrary{nativeAppendF64WithUniverse} = nativeAppendF64WithUniverse

capiAppendI32WithUniverse :: NativeLibrary -> AppendWithUniverseFn Int32
capiAppendI32WithUniverse NativeLibrary{nativeAppendI32WithUniverse} = nativeAppendI32WithUniverse

capiAppendI64WithUniverse :: NativeLibrary -> AppendWithUniverseFn Int64
capiAppendI64WithUniverse NativeLibrary{nativeAppendI64WithUniverse} = nativeAppendI64WithUniverse

capiAppendI32WithRange :: NativeLibrary -> AppendI32WithRangeFn
capiAppendI32WithRange NativeLibrary{nativeAppendI32WithRange} = nativeAppendI32WithRange

capiAppendI64WithRange :: NativeLibrary -> AppendI64WithRangeFn
capiAppendI64WithRange NativeLibrary{nativeAppendI64WithRange} = nativeAppendI64WithRange

capiReadAll :: NativeLibrary -> ReadAllFn
capiReadAll NativeLibrary{nativeReadAll} = nativeReadAll

capiReadAllDense :: NativeLibrary -> ReadAllDenseFn
capiReadAllDense NativeLibrary{nativeReadAllDense} = nativeReadAllDense

capiReadAxisRange :: NativeLibrary -> ReadAxisRangeFn
capiReadAxisRange NativeLibrary{nativeReadAxisRange} = nativeReadAxisRange

capiReadAxisTake :: NativeLibrary -> ReadAxisTakeFn
capiReadAxisTake NativeLibrary{nativeReadAxisTake} = nativeReadAxisTake

capiReadAxisOne :: NativeLibrary -> ReadAxisOneFn
capiReadAxisOne NativeLibrary{nativeReadAxisOne} = nativeReadAxisOne

capiReadEntryRange :: NativeLibrary -> ReadEntryRangeFn
capiReadEntryRange NativeLibrary{nativeReadEntryRange} = nativeReadEntryRange

capiTakeEntries :: NativeLibrary -> TakeEntriesFn
capiTakeEntries NativeLibrary{nativeTakeEntries} = nativeTakeEntries

capiTensorToContiguous :: NativeLibrary -> TensorToContiguousFn
capiTensorToContiguous NativeLibrary{nativeTensorToContiguous} = nativeTensorToContiguous

capiTensorReshape :: NativeLibrary -> TensorReshapeFn
capiTensorReshape NativeLibrary{nativeTensorReshape} = nativeTensorReshape

capiTensorFlatten :: NativeLibrary -> TensorFlattenFn
capiTensorFlatten NativeLibrary{nativeTensorFlatten} = nativeTensorFlatten

capiTensorExpandDims :: NativeLibrary -> TensorExpandDimsFn
capiTensorExpandDims NativeLibrary{nativeTensorExpandDims} = nativeTensorExpandDims

capiTensorSqueeze :: NativeLibrary -> TensorSqueezeFn
capiTensorSqueeze NativeLibrary{nativeTensorSqueeze} = nativeTensorSqueeze

capiTensorSqueezeAxis :: NativeLibrary -> TensorSqueezeAxisFn
capiTensorSqueezeAxis NativeLibrary{nativeTensorSqueezeAxis} = nativeTensorSqueezeAxis

capiTensorPermuteAxes :: NativeLibrary -> TensorPermuteAxesFn
capiTensorPermuteAxes NativeLibrary{nativeTensorPermuteAxes} = nativeTensorPermuteAxes

capiTensorTranspose :: NativeLibrary -> TensorTransposeFn
capiTensorTranspose NativeLibrary{nativeTensorTranspose} = nativeTensorTranspose

capiTensorSliceAxis :: NativeLibrary -> TensorSliceAxisFn
capiTensorSliceAxis NativeLibrary{nativeTensorSliceAxis} = nativeTensorSliceAxis

capiTensorSliceAxisStep :: NativeLibrary -> TensorSliceAxisStepFn
capiTensorSliceAxisStep NativeLibrary{nativeTensorSliceAxisStep} = nativeTensorSliceAxisStep

capiTensorTakeAxis :: NativeLibrary -> TensorTakeAxisFn
capiTensorTakeAxis NativeLibrary{nativeTensorTakeAxis} = nativeTensorTakeAxis

capiTensorIndexAxis :: NativeLibrary -> TensorIndexAxisFn
capiTensorIndexAxis NativeLibrary{nativeTensorIndexAxis} = nativeTensorIndexAxis

capiTensorAdd :: NativeLibrary -> TensorBinaryOpFn
capiTensorAdd NativeLibrary{nativeTensorAdd} = nativeTensorAdd

capiTensorSub :: NativeLibrary -> TensorBinaryOpFn
capiTensorSub NativeLibrary{nativeTensorSub} = nativeTensorSub

capiTensorMul :: NativeLibrary -> TensorBinaryOpFn
capiTensorMul NativeLibrary{nativeTensorMul} = nativeTensorMul

capiTensorDiv :: NativeLibrary -> TensorBinaryOpFn
capiTensorDiv NativeLibrary{nativeTensorDiv} = nativeTensorDiv

capiTensorAddScalar :: NativeLibrary -> TensorScalarOpFn
capiTensorAddScalar NativeLibrary{nativeTensorAddScalar} = nativeTensorAddScalar

capiTensorSubScalar :: NativeLibrary -> TensorScalarOpFn
capiTensorSubScalar NativeLibrary{nativeTensorSubScalar} = nativeTensorSubScalar

capiTensorMulScalar :: NativeLibrary -> TensorScalarOpFn
capiTensorMulScalar NativeLibrary{nativeTensorMulScalar} = nativeTensorMulScalar

capiTensorDivScalar :: NativeLibrary -> TensorScalarOpFn
capiTensorDivScalar NativeLibrary{nativeTensorDivScalar} = nativeTensorDivScalar

capiRank :: NativeLibrary -> RankFn
capiRank NativeLibrary{nativeRank} = nativeRank

capiDType :: NativeLibrary -> DTypeFn
capiDType NativeLibrary{nativeDType} = nativeDType

capiAppendAxis :: NativeLibrary -> AppendAxisFn
capiAppendAxis NativeLibrary{nativeAppendAxis} = nativeAppendAxis

capiDimLens :: NativeLibrary -> DimLensFn
capiDimLens NativeLibrary{nativeDimLens} = nativeDimLens

capiChunkPlan :: NativeLibrary -> ChunkPlanFn
capiChunkPlan NativeLibrary{nativeChunkPlan} = nativeChunkPlan

capiPath :: NativeLibrary -> PathFn
capiPath NativeLibrary{nativePath} = nativePath

capiStringFree :: NativeLibrary -> StringFreeFn
capiStringFree NativeLibrary{nativeStringFree} = nativeStringFree

capiChunkPlanFree :: NativeLibrary -> ChunkPlanFreeFn
capiChunkPlanFree NativeLibrary{nativeChunkPlanFree} = nativeChunkPlanFree

capiLoadMeta :: NativeLibrary -> LoadMetaFn
capiLoadMeta NativeLibrary{nativeLoadMeta} = nativeLoadMeta

capiSetDimName :: NativeLibrary -> SetDimNameFn
capiSetDimName NativeLibrary{nativeSetDimName} = nativeSetDimName

capiSetSymbols :: NativeLibrary -> SetStringsFn
capiSetSymbols NativeLibrary{nativeSetSymbols} = nativeSetSymbols

capiSetChannels :: NativeLibrary -> SetStringsFn
capiSetChannels NativeLibrary{nativeSetChannels} = nativeSetChannels

capiSetUserKv :: NativeLibrary -> SetUserKvFn
capiSetUserKv NativeLibrary{nativeSetUserKv} = nativeSetUserKv

capiReadScalar :: NativeLibrary -> ReadScalarFn
capiReadScalar NativeLibrary{nativeReadScalar} = nativeReadScalar

capiSetCompressionConfig :: NativeLibrary -> SetCompressionConfigFn
capiSetCompressionConfig NativeLibrary{nativeSetCompressionConfig} = nativeSetCompressionConfig

capiGetCompressionConfig :: NativeLibrary -> GetCompressionConfigFn
capiGetCompressionConfig NativeLibrary{nativeGetCompressionConfig} = nativeGetCompressionConfig

capiHeadCommit :: NativeLibrary -> HeadCommitFn
capiHeadCommit NativeLibrary{nativeHeadCommit} = nativeHeadCommit

capiListCommits :: NativeLibrary -> ListCommitsFn
capiListCommits NativeLibrary{nativeListCommits} = nativeListCommits

capiCommitListFree :: NativeLibrary -> CommitListFreeFn
capiCommitListFree NativeLibrary{nativeCommitListFree} = nativeCommitListFree

capiPop :: NativeLibrary -> PopFn
capiPop NativeLibrary{nativePop} = nativePop

capiPopBatched :: NativeLibrary -> PopBatchedFn
capiPopBatched NativeLibrary{nativePopBatched} = nativePopBatched

capiRevertCommit :: NativeLibrary -> RevertCommitFn
capiRevertCommit NativeLibrary{nativeRevertCommit} = nativeRevertCommit

capiReadAtCommit :: NativeLibrary -> ReadAtCommitFn
capiReadAtCommit NativeLibrary{nativeReadAtCommit} = nativeReadAtCommit

capiReadAtCommitDense :: NativeLibrary -> ReadAtCommitDenseFn
capiReadAtCommitDense NativeLibrary{nativeReadAtCommitDense} = nativeReadAtCommitDense

capiReadExecutionReportFree :: NativeLibrary -> ReadExecutionReportFreeFn
capiReadExecutionReportFree NativeLibrary{nativeReadExecutionReportFree} = nativeReadExecutionReportFree

capiQueryTraceJsonFree :: NativeLibrary -> QueryTraceJsonFreeFn
capiQueryTraceJsonFree NativeLibrary{nativeQueryTraceJsonFree} = nativeQueryTraceJsonFree

capiHistoricalReadExecutionReportFree :: NativeLibrary -> HistoricalReadExecutionReportFreeFn
capiHistoricalReadExecutionReportFree NativeLibrary{nativeHistoricalReadExecutionReportFree} = nativeHistoricalReadExecutionReportFree

capiReadIndexReportFree :: NativeLibrary -> ReadIndexReportFreeFn
capiReadIndexReportFree NativeLibrary{nativeReadIndexReportFree} = nativeReadIndexReportFree

capiReadIndex :: NativeLibrary -> ReadIndexFn
capiReadIndex NativeLibrary{nativeReadIndex} = nativeReadIndex

capiReadWithOptions :: NativeLibrary -> ReadWithOptionsFn
capiReadWithOptions NativeLibrary{nativeReadWithOptions} = nativeReadWithOptions

capiReadWithOptionsDense :: NativeLibrary -> ReadWithOptionsDenseFn
capiReadWithOptionsDense NativeLibrary{nativeReadWithOptionsDense} = nativeReadWithOptionsDense

capiReadWithShapePolicy :: NativeLibrary -> ReadWithShapePolicyFn
capiReadWithShapePolicy NativeLibrary{nativeReadWithShapePolicy} = nativeReadWithShapePolicy

capiReadWithShapePolicyDense :: NativeLibrary -> ReadWithShapePolicyDenseFn
capiReadWithShapePolicyDense NativeLibrary{nativeReadWithShapePolicyDense} = nativeReadWithShapePolicyDense

capiReadWithOptionsAttributed :: NativeLibrary -> ReadWithOptionsAttributedFn
capiReadWithOptionsAttributed NativeLibrary{nativeReadWithOptionsAttributed} = nativeReadWithOptionsAttributed

capiReadWithOptionsDenseAttributed :: NativeLibrary -> ReadWithOptionsDenseAttributedFn
capiReadWithOptionsDenseAttributed NativeLibrary{nativeReadWithOptionsDenseAttributed} = nativeReadWithOptionsDenseAttributed

capiReadAtCommitWithOptions :: NativeLibrary -> HistoricalReadWithOptionsFn
capiReadAtCommitWithOptions NativeLibrary{nativeHistoricalReadWithOptions} = nativeHistoricalReadWithOptions

capiReadAtCommitWithOptionsDense :: NativeLibrary -> HistoricalReadWithOptionsDenseFn
capiReadAtCommitWithOptionsDense NativeLibrary{nativeHistoricalReadWithOptionsDense} = nativeHistoricalReadWithOptionsDense

capiReadAtCommitWithShapePolicy :: NativeLibrary -> HistoricalReadWithShapePolicyFn
capiReadAtCommitWithShapePolicy NativeLibrary{nativeHistoricalReadWithShapePolicy} = nativeHistoricalReadWithShapePolicy

capiReadAtCommitWithShapePolicyDense :: NativeLibrary -> HistoricalReadWithShapePolicyDenseFn
capiReadAtCommitWithShapePolicyDense NativeLibrary{nativeHistoricalReadWithShapePolicyDense} = nativeHistoricalReadWithShapePolicyDense

capiGetIndexCheckpointEveryCommits :: NativeLibrary -> GetIndexCheckpointEveryCommitsFn
capiGetIndexCheckpointEveryCommits NativeLibrary{nativeGetIndexCheckpointEveryCommits} = nativeGetIndexCheckpointEveryCommits

capiSetIndexCheckpointEveryCommits :: NativeLibrary -> SetIndexCheckpointEveryCommitsFn
capiSetIndexCheckpointEveryCommits NativeLibrary{nativeSetIndexCheckpointEveryCommits} = nativeSetIndexCheckpointEveryCommits

capiRewriteF32 :: NativeLibrary -> RewriteF32Fn
capiRewriteF32 NativeLibrary{nativeRewriteF32} = nativeRewriteF32

capiRewriteF64 :: NativeLibrary -> RewriteF64Fn
capiRewriteF64 NativeLibrary{nativeRewriteF64} = nativeRewriteF64

capiRewriteSliceF32 :: NativeLibrary -> RewriteSliceF32Fn
capiRewriteSliceF32 NativeLibrary{nativeRewriteSliceF32} = nativeRewriteSliceF32

capiRewriteSliceF64 :: NativeLibrary -> RewriteSliceF64Fn
capiRewriteSliceF64 NativeLibrary{nativeRewriteSliceF64} = nativeRewriteSliceF64

capiClearBlocks :: NativeLibrary -> ClearBlocksFn
capiClearBlocks NativeLibrary{nativeClearBlocks} = nativeClearBlocks

capiReadValuesArrow :: NativeLibrary -> ReadValuesArrowFn
capiReadValuesArrow NativeLibrary{nativeReadValuesArrow} = nativeReadValuesArrow

arrowArrayRelease :: FunPtr ArrowArrayReleaseFn -> ArrowArrayReleaseFn
arrowArrayRelease = mkArrowArrayRelease

arrowSchemaRelease :: FunPtr ArrowSchemaReleaseFn -> ArrowSchemaReleaseFn
arrowSchemaRelease = mkArrowSchemaRelease

capiAnalyzeCompaction :: NativeLibrary -> AnalyzeCompactionFn
capiAnalyzeCompaction NativeLibrary{nativeAnalyzeCompaction} = nativeAnalyzeCompaction

capiCompactTo :: NativeLibrary -> CompactToFn
capiCompactTo NativeLibrary{nativeCompactTo} = nativeCompactTo

capiMaybeCompact :: NativeLibrary -> MaybeCompactFn
capiMaybeCompact NativeLibrary{nativeMaybeCompact} = nativeMaybeCompact

capiGetAutoCompactionConfig :: NativeLibrary -> GetAutoCompactionConfigFn
capiGetAutoCompactionConfig NativeLibrary{nativeGetAutoCompactionConfig} = nativeGetAutoCompactionConfig

capiSetAutoCompactionConfig :: NativeLibrary -> SetAutoCompactionConfigFn
capiSetAutoCompactionConfig NativeLibrary{nativeSetAutoCompactionConfig} = nativeSetAutoCompactionConfig

capiCompactionState :: NativeLibrary -> CompactionStateFn
capiCompactionState NativeLibrary{nativeCompactionState} = nativeCompactionState

capiMaybeCompactAuto :: NativeLibrary -> MaybeCompactAutoFn
capiMaybeCompactAuto NativeLibrary{nativeMaybeCompactAuto} = nativeMaybeCompactAuto

capiV4Diagnostics :: NativeLibrary -> V4DiagnosticsFn
capiV4Diagnostics NativeLibrary{nativeV4Diagnostics} = nativeV4Diagnostics

capiV4DiagnosticsReportFree :: NativeLibrary -> V4DiagnosticsReportFreeFn
capiV4DiagnosticsReportFree NativeLibrary{nativeV4DiagnosticsReportFree} = nativeV4DiagnosticsReportFree

capiV4DiagnosticsPrecise :: NativeLibrary -> V4DiagnosticsPreciseFn
capiV4DiagnosticsPrecise NativeLibrary{nativeV4DiagnosticsPrecise} = nativeV4DiagnosticsPrecise

capiV4DiagnosticsPreciseReportFree :: NativeLibrary -> V4DiagnosticsPreciseReportFreeFn
capiV4DiagnosticsPreciseReportFree NativeLibrary{nativeV4DiagnosticsPreciseReportFree} = nativeV4DiagnosticsPreciseReportFree


capiAnalyzeV4Compaction :: NativeLibrary -> AnalyzeV4CompactionFn
capiAnalyzeV4Compaction NativeLibrary{nativeAnalyzeV4Compaction} = nativeAnalyzeV4Compaction

capiV4CompactionAnalysisReportFree :: NativeLibrary -> V4CompactionAnalysisReportFreeFn
capiV4CompactionAnalysisReportFree NativeLibrary{nativeV4CompactionAnalysisReportFree} = nativeV4CompactionAnalysisReportFree

capiAnalyzeV4CompactionPrecise :: NativeLibrary -> AnalyzeV4CompactionPreciseFn
capiAnalyzeV4CompactionPrecise NativeLibrary{nativeAnalyzeV4CompactionPrecise} = nativeAnalyzeV4CompactionPrecise

capiV4CompactionAnalysisPreciseReportFree :: NativeLibrary -> V4CompactionAnalysisPreciseReportFreeFn
capiV4CompactionAnalysisPreciseReportFree NativeLibrary{nativeV4CompactionAnalysisPreciseReportFree} = nativeV4CompactionAnalysisPreciseReportFree

capiCompactV4RetainedHistoryTo :: NativeLibrary -> CompactV4RetainedHistoryToFn
capiCompactV4RetainedHistoryTo NativeLibrary{nativeCompactV4RetainedHistoryTo} = nativeCompactV4RetainedHistoryTo

capiV4RetainedHistoryCompactionReportFree :: NativeLibrary -> V4RetainedHistoryCompactionReportFreeFn
capiV4RetainedHistoryCompactionReportFree NativeLibrary{nativeV4RetainedHistoryCompactionReportFree} = nativeV4RetainedHistoryCompactionReportFree

capiCompactV4RetainedHistoryToPrecise :: NativeLibrary -> CompactV4RetainedHistoryToPreciseFn
capiCompactV4RetainedHistoryToPrecise NativeLibrary{nativeCompactV4RetainedHistoryToPrecise} = nativeCompactV4RetainedHistoryToPrecise

capiV4RetainedHistoryCompactionPreciseReportFree :: NativeLibrary -> V4RetainedHistoryCompactionPreciseReportFreeFn
capiV4RetainedHistoryCompactionPreciseReportFree NativeLibrary{nativeV4RetainedHistoryCompactionPreciseReportFree} = nativeV4RetainedHistoryCompactionPreciseReportFree


capiReformTo :: NativeLibrary -> ReformToFn
capiReformTo NativeLibrary{nativeReformTo} = nativeReformTo

capiReformToEx :: NativeLibrary -> ReformToExFn
capiReformToEx NativeLibrary{nativeReformToEx} = nativeReformToEx

capiReformReportFree :: NativeLibrary -> ReformReportFreeFn
capiReformReportFree NativeLibrary{nativeReformReportFree} = nativeReformReportFree

capiAnalyzeSparseAppendF32V2 :: NativeLibrary -> AnalyzeSparseAppendV2Fn CFloat
capiAnalyzeSparseAppendF32V2 NativeLibrary{nativeAnalyzeSparseAppendF32V2} = nativeAnalyzeSparseAppendF32V2

capiAnalyzeSparseAppendF64V2 :: NativeLibrary -> AnalyzeSparseAppendV2Fn Double
capiAnalyzeSparseAppendF64V2 NativeLibrary{nativeAnalyzeSparseAppendF64V2} = nativeAnalyzeSparseAppendF64V2

capiAnalyzeSparseAppendI32V2 :: NativeLibrary -> AnalyzeSparseAppendV2Fn Int32
capiAnalyzeSparseAppendI32V2 NativeLibrary{nativeAnalyzeSparseAppendI32V2} = nativeAnalyzeSparseAppendI32V2

capiAnalyzeSparseAppendI64V2 :: NativeLibrary -> AnalyzeSparseAppendV2Fn Int64
capiAnalyzeSparseAppendI64V2 NativeLibrary{nativeAnalyzeSparseAppendI64V2} = nativeAnalyzeSparseAppendI64V2

capiAppendSparseF32WithRangeV2 :: NativeLibrary -> AppendSparseWithRangeV2Fn CFloat
capiAppendSparseF32WithRangeV2 NativeLibrary{nativeAppendSparseF32WithRangeV2} = nativeAppendSparseF32WithRangeV2

capiAppendSparseF64WithRangeV2 :: NativeLibrary -> AppendSparseWithRangeV2Fn Double
capiAppendSparseF64WithRangeV2 NativeLibrary{nativeAppendSparseF64WithRangeV2} = nativeAppendSparseF64WithRangeV2

capiAppendSparseI32WithRangeV2 :: NativeLibrary -> AppendSparseWithRangeV2Fn Int32
capiAppendSparseI32WithRangeV2 NativeLibrary{nativeAppendSparseI32WithRangeV2} = nativeAppendSparseI32WithRangeV2

capiAppendSparseI64WithRangeV2 :: NativeLibrary -> AppendSparseWithRangeV2Fn Int64
capiAppendSparseI64WithRangeV2 NativeLibrary{nativeAppendSparseI64WithRangeV2} = nativeAppendSparseI64WithRangeV2

capiSparseAppendAnalysisFree :: NativeLibrary -> SparseAppendAnalysisFreeFn
capiSparseAppendAnalysisFree NativeLibrary{nativeSparseAppendAnalysisFree} = nativeSparseAppendAnalysisFree

capiOcbLastErrorKind :: NativeLibrary -> OcbLastErrorKindFn
capiOcbLastErrorKind NativeLibrary{nativeOcbLastErrorKind} = nativeOcbLastErrorKind

capiOcbLastErrorCause :: NativeLibrary -> OcbLastErrorCauseFn
capiOcbLastErrorCause NativeLibrary{nativeOcbLastErrorCause} = nativeOcbLastErrorCause

capiOcbOpen :: NativeLibrary -> OcbOpenFn
capiOcbOpen NativeLibrary{nativeOcbOpen} = nativeOcbOpen

capiOcbOpenWithOptions :: NativeLibrary -> OcbOpenWithOptionsFn
capiOcbOpenWithOptions NativeLibrary{nativeOcbOpenWithOptions} = nativeOcbOpenWithOptions

capiOcbReaderClone :: NativeLibrary -> OcbReaderCloneFn
capiOcbReaderClone NativeLibrary{nativeOcbReaderClone} = nativeOcbReaderClone

capiOcbClose :: NativeLibrary -> OcbCloseFn
capiOcbClose NativeLibrary{nativeOcbClose} = nativeOcbClose

capiOcbMetadata :: NativeLibrary -> OcbMetadataFn
capiOcbMetadata NativeLibrary{nativeOcbMetadata} = nativeOcbMetadata

capiOcbMetadataFree :: NativeLibrary -> OcbMetadataFreeFn
capiOcbMetadataFree NativeLibrary{nativeOcbMetadataFree} = nativeOcbMetadataFree

capiOcbDictionaryValues :: NativeLibrary -> OcbDictionaryValuesFn
capiOcbDictionaryValues NativeLibrary{nativeOcbDictionaryValues} = nativeOcbDictionaryValues

capiOcbDictionaryValuesFree :: NativeLibrary -> OcbDictionaryValuesFreeFn
capiOcbDictionaryValuesFree NativeLibrary{nativeOcbDictionaryValuesFree} = nativeOcbDictionaryValuesFree

capiOcbOpenOptionsInit :: NativeLibrary -> OcbOpenOptionsInitFn
capiOcbOpenOptionsInit NativeLibrary{nativeOcbOpenOptionsInit} = nativeOcbOpenOptionsInit

capiOcbPrimitiveValuesInit :: NativeLibrary -> OcbPrimitiveValuesInitFn
capiOcbPrimitiveValuesInit NativeLibrary{nativeOcbPrimitiveValuesInit} = nativeOcbPrimitiveValuesInit

capiOcbValidityBitmapInit :: NativeLibrary -> OcbValidityBitmapInitFn
capiOcbValidityBitmapInit NativeLibrary{nativeOcbValidityBitmapInit} = nativeOcbValidityBitmapInit

capiOcbWriteOptionsInit :: NativeLibrary -> OcbWriteOptionsInitFn
capiOcbWriteOptionsInit NativeLibrary{nativeOcbWriteOptionsInit} = nativeOcbWriteOptionsInit

capiOcbWriteColumnInit :: NativeLibrary -> OcbWriteColumnInitFn
capiOcbWriteColumnInit NativeLibrary{nativeOcbWriteColumnInit} = nativeOcbWriteColumnInit

capiOcbDictionaryEntryInit :: NativeLibrary -> OcbDictionaryEntryInitFn
capiOcbDictionaryEntryInit NativeLibrary{nativeOcbDictionaryEntryInit} = nativeOcbDictionaryEntryInit

capiOcbWriteDictionaryInit :: NativeLibrary -> OcbWriteDictionaryInitFn
capiOcbWriteDictionaryInit NativeLibrary{nativeOcbWriteDictionaryInit} = nativeOcbWriteDictionaryInit

capiOcbWriteColumnChunkInit :: NativeLibrary -> OcbWriteColumnChunkInitFn
capiOcbWriteColumnChunkInit NativeLibrary{nativeOcbWriteColumnChunkInit} = nativeOcbWriteColumnChunkInit

capiOcbWriteRowGroupInit :: NativeLibrary -> OcbWriteRowGroupInitFn
capiOcbWriteRowGroupInit NativeLibrary{nativeOcbWriteRowGroupInit} = nativeOcbWriteRowGroupInit

capiOcbWriteOrderingKeyInit :: NativeLibrary -> OcbWriteOrderingKeyInitFn
capiOcbWriteOrderingKeyInit NativeLibrary{nativeOcbWriteOrderingKeyInit} = nativeOcbWriteOrderingKeyInit

capiOcbWriteSpecInit :: NativeLibrary -> OcbWriteSpecInitFn
capiOcbWriteSpecInit NativeLibrary{nativeOcbWriteSpecInit} = nativeOcbWriteSpecInit

capiOcbCleanupResultInit :: NativeLibrary -> OcbCleanupResultInitFn
capiOcbCleanupResultInit NativeLibrary{nativeOcbCleanupResultInit} = nativeOcbCleanupResultInit

capiOcbPredicateValueInit :: NativeLibrary -> OcbPredicateValueInitFn
capiOcbPredicateValueInit NativeLibrary{nativeOcbPredicateValueInit} = nativeOcbPredicateValueInit

capiOcbRowGroupPredicateInit :: NativeLibrary -> OcbRowGroupPredicateInitFn
capiOcbRowGroupPredicateInit NativeLibrary{nativeOcbRowGroupPredicateInit} = nativeOcbRowGroupPredicateInit

capiOcbWriteColumnSetFixedBinaryWidth :: NativeLibrary -> OcbWriteColumnSetFixedBinaryWidthFn
capiOcbWriteColumnSetFixedBinaryWidth NativeLibrary{nativeOcbWriteColumnSetFixedBinaryWidth} = nativeOcbWriteColumnSetFixedBinaryWidth

capiOcbWriteColumnFixedBinaryWidth :: NativeLibrary -> OcbWriteColumnFixedBinaryWidthFn
capiOcbWriteColumnFixedBinaryWidth NativeLibrary{nativeOcbWriteColumnFixedBinaryWidth} = nativeOcbWriteColumnFixedBinaryWidth

capiOcbCreate :: NativeLibrary -> OcbCreateFn
capiOcbCreate NativeLibrary{nativeOcbCreate} = nativeOcbCreate

capiOcbCreateWithOptions :: NativeLibrary -> OcbCreateWithOptionsFn
capiOcbCreateWithOptions NativeLibrary{nativeOcbCreateWithOptions} = nativeOcbCreateWithOptions

capiOcbAppend :: NativeLibrary -> OcbAppendFn
capiOcbAppend NativeLibrary{nativeOcbAppend} = nativeOcbAppend

capiOcbAppendWithOptions :: NativeLibrary -> OcbAppendWithOptionsFn
capiOcbAppendWithOptions NativeLibrary{nativeOcbAppendWithOptions} = nativeOcbAppendWithOptions

capiOcbCleanupOrphanTail :: NativeLibrary -> OcbCleanupOrphanTailFn
capiOcbCleanupOrphanTail NativeLibrary{nativeOcbCleanupOrphanTail} = nativeOcbCleanupOrphanTail

capiOcbReadRequestInit :: NativeLibrary -> OcbReadRequestInitFn
capiOcbReadRequestInit NativeLibrary{nativeOcbReadRequestInit} = nativeOcbReadRequestInit

capiOcbReadReportInit :: NativeLibrary -> OcbReadReportInitFn
capiOcbReadReportInit NativeLibrary{nativeOcbReadReportInit} = nativeOcbReadReportInit

capiOcbReadAttributionInit :: NativeLibrary -> OcbReadAttributionInitFn
capiOcbReadAttributionInit NativeLibrary{nativeOcbReadAttributionInit} = nativeOcbReadAttributionInit

capiOcbReadOutcomeInit :: NativeLibrary -> OcbReadOutcomeInitFn
capiOcbReadOutcomeInit NativeLibrary{nativeOcbReadOutcomeInit} = nativeOcbReadOutcomeInit

capiOcbReadCursorOptionsInit :: NativeLibrary -> OcbReadCursorOptionsInitFn
capiOcbReadCursorOptionsInit NativeLibrary{nativeOcbReadCursorOptionsInit} = nativeOcbReadCursorOptionsInit

capiOcbReadCursorReportInit :: NativeLibrary -> OcbReadCursorReportInitFn
capiOcbReadCursorReportInit NativeLibrary{nativeOcbReadCursorReportInit} = nativeOcbReadCursorReportInit

capiOcbReadCursorReportFree :: NativeLibrary -> OcbReadCursorReportFreeFn
capiOcbReadCursorReportFree NativeLibrary{nativeOcbReadCursorReportFree} = nativeOcbReadCursorReportFree

capiOcbVisitBatches :: NativeLibrary -> OcbVisitBatchesFn
capiOcbVisitBatches NativeLibrary{nativeOcbVisitBatches} = nativeOcbVisitBatches

capiOcbColumnFillBufferInit :: NativeLibrary -> OcbColumnFillBufferInitFn
capiOcbColumnFillBufferInit NativeLibrary{nativeOcbColumnFillBufferInit} = nativeOcbColumnFillBufferInit

capiOcbColumnFillBufferSetFixedBinaryWidth :: NativeLibrary -> OcbColumnFillBufferSetFixedBinaryWidthFn
capiOcbColumnFillBufferSetFixedBinaryWidth NativeLibrary{nativeOcbColumnFillBufferSetFixedBinaryWidth} = nativeOcbColumnFillBufferSetFixedBinaryWidth

capiOcbColumnFillBufferFixedBinaryWidth :: NativeLibrary -> OcbColumnFillBufferFixedBinaryWidthFn
capiOcbColumnFillBufferFixedBinaryWidth NativeLibrary{nativeOcbColumnFillBufferFixedBinaryWidth} = nativeOcbColumnFillBufferFixedBinaryWidth

capiOcbRowGroupFillRequestInit :: NativeLibrary -> OcbRowGroupFillRequestInitFn
capiOcbRowGroupFillRequestInit NativeLibrary{nativeOcbRowGroupFillRequestInit} = nativeOcbRowGroupFillRequestInit

capiOcbReadFillReportInit :: NativeLibrary -> OcbReadFillReportInitFn
capiOcbReadFillReportInit NativeLibrary{nativeOcbReadFillReportInit} = nativeOcbReadFillReportInit

capiOcbReadRowGroupInto :: NativeLibrary -> OcbReadRowGroupIntoFn
capiOcbReadRowGroupInto NativeLibrary{nativeOcbReadRowGroupInto} = nativeOcbReadRowGroupInto

capiOcbReadBatches :: NativeLibrary -> OcbReadBatchesFn
capiOcbReadBatches NativeLibrary{nativeOcbReadBatches} = nativeOcbReadBatches

capiOcbReadBatchesWithAttribution :: NativeLibrary -> OcbReadBatchesWithAttributionFn
capiOcbReadBatchesWithAttribution NativeLibrary{nativeOcbReadBatchesWithAttribution} = nativeOcbReadBatchesWithAttribution

capiOcbReadReportFree :: NativeLibrary -> OcbReadReportFreeFn
capiOcbReadReportFree NativeLibrary{nativeOcbReadReportFree} = nativeOcbReadReportFree

capiOcbReadAttributionFree :: NativeLibrary -> OcbReadAttributionFreeFn
capiOcbReadAttributionFree NativeLibrary{nativeOcbReadAttributionFree} = nativeOcbReadAttributionFree

capiOcbReadOutcomeFree :: NativeLibrary -> OcbReadOutcomeFreeFn
capiOcbReadOutcomeFree NativeLibrary{nativeOcbReadOutcomeFree} = nativeOcbReadOutcomeFree

capiOcbColumnDescriptorFixedBinaryWidth :: NativeLibrary -> OcbColumnDescriptorFixedBinaryWidthFn
capiOcbColumnDescriptorFixedBinaryWidth NativeLibrary{nativeOcbColumnDescriptorFixedBinaryWidth} = nativeOcbColumnDescriptorFixedBinaryWidth

capiOcbColumnArrayFixedBinaryWidth :: NativeLibrary -> OcbColumnArrayFixedBinaryWidthFn
capiOcbColumnArrayFixedBinaryWidth NativeLibrary{nativeOcbColumnArrayFixedBinaryWidth} = nativeOcbColumnArrayFixedBinaryWidth

capiOcbPlanRead :: NativeLibrary -> OcbPlanReadFn
capiOcbPlanRead NativeLibrary{nativeOcbPlanRead} = nativeOcbPlanRead

capiOcbReadPlanReport :: NativeLibrary -> OcbReadPlanReportFn
capiOcbReadPlanReport NativeLibrary{nativeOcbReadPlanReport} = nativeOcbReadPlanReport

capiOcbReadPlanProjectedColumnIds :: NativeLibrary -> OcbReadPlanIdsFn
capiOcbReadPlanProjectedColumnIds NativeLibrary{nativeOcbReadPlanProjectedColumnIds} = nativeOcbReadPlanProjectedColumnIds

capiOcbReadPlanRowGroupIds :: NativeLibrary -> OcbReadPlanIdsFn
capiOcbReadPlanRowGroupIds NativeLibrary{nativeOcbReadPlanRowGroupIds} = nativeOcbReadPlanRowGroupIds

capiOcbReadBatchesFromPlan :: NativeLibrary -> OcbReadBatchesFromPlanFn
capiOcbReadBatchesFromPlan NativeLibrary{nativeOcbReadBatchesFromPlan} = nativeOcbReadBatchesFromPlan

capiOcbReadPlanFree :: NativeLibrary -> OcbReadPlanFreeFn
capiOcbReadPlanFree NativeLibrary{nativeOcbReadPlanFree} = nativeOcbReadPlanFree

capiOcbRowGroupSummariesInit :: NativeLibrary -> OcbRowGroupSummariesInitFn
capiOcbRowGroupSummariesInit NativeLibrary{nativeOcbRowGroupSummariesInit} = nativeOcbRowGroupSummariesInit

capiOcbRowGroupSummaries :: NativeLibrary -> OcbRowGroupSummariesFn
capiOcbRowGroupSummaries NativeLibrary{nativeOcbRowGroupSummaries} = nativeOcbRowGroupSummaries

capiOcbReadPlanRowGroupSummaries :: NativeLibrary -> OcbReadPlanRowGroupSummariesFn
capiOcbReadPlanRowGroupSummaries NativeLibrary{nativeOcbReadPlanRowGroupSummaries} = nativeOcbReadPlanRowGroupSummaries

capiOcbRowGroupSummariesFree :: NativeLibrary -> OcbRowGroupSummariesFreeFn
capiOcbRowGroupSummariesFree NativeLibrary{nativeOcbRowGroupSummariesFree} = nativeOcbRowGroupSummariesFree

capiTensorFree :: NativeLibrary -> TensorFreeFn
capiTensorFree NativeLibrary{nativeTensorFree} = nativeTensorFree

capiMaskFree :: NativeLibrary -> MaskFreeFn
capiMaskFree NativeLibrary{nativeMaskFree} = nativeMaskFree

capiFileMetaFree :: NativeLibrary -> FileMetaFreeFn
capiFileMetaFree NativeLibrary{nativeFileMetaFree} = nativeFileMetaFree

_keepNativeLibraryHandleAlive :: NativeLibrary -> DL
_keepNativeLibraryHandleAlive = nativeLibraryHandle
