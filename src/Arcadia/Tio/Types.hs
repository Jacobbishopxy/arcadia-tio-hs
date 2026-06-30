module Arcadia.Tio.Types
  ( DType(..)
  , dtypeName
  , dtypeSizeBytes
  , dtypeToRaw
  , dtypeFromRaw
  , AxisKind(..)
  , axisKindToRaw
  , axisKindFromRaw
  , DimSpec(..)
  , dim
  , HeaderProfile(..)
  , headerProfileFromRaw
  , DimMeta(..)
  , AxisLabel(..)
  , UserKv(..)
  , FileMeta(..)
  , ChunkPlan(..)
  , CreateMetadata(..)
  , emptyCreateMetadata
  , StorageAccessKind(..)
  , OpenPattern(..)
  , FilePopulation(..)
  , MetadataStability(..)
  , CreateInferredOptions(..)
  , defaultCreateInferredOptions
  , StorageProfile(..)
  , CreatePolicyOptions(..)
  , defaultCreatePolicyOptions
  , ScalarValue(..)
  , CompressionMode(..)
  , CompressionCodec(..)
  , CompressionConfig(..)
  , uncompressedCompression
  , zstdCompression
  , SparseDetector(..)
  , SparseValuePredicate(..)
  , SparseFallbackPolicy(..)
  , SparseRule(..)
  , nullSubtensorRule
  , predicateSubtensorRule
  , SparseAppendOutcome(..)
  , SparseAppendReason(..)
  , SparseAppendAnalysis(..)
  , EntrySelector(..)
  , ReadExecutionMode(..)
  , ReadOptions(..)
  , defaultReadOptions
  , ReadShapePolicy(..)
  , TioUuid(..)
  , AxisIdentityMode(..)
  , AxisIdentityInput(..)
  , UniverseBindingInput(..)
  , SlotUniverseBindingInput(..)
  , UniverseRemapInput(..)
  , SlotUniverseRemapInput(..)
  , CreateWithUniverseOptions(..)
  , defaultCreateWithUniverseOptions
  , AppendWithUniverseOptions(..)
  , defaultAppendWithUniverseOptions
  , ExplicitUniverseAxisTarget(..)
  , ExplicitExtentAxisTarget(..)
  , ReadExecutionReport(..)
  , QueryTraceContext(..)
  , QueryTraceJson(..)
  , ReadIndexItem(..)
  , ReadIndexLoweringKind(..)
  , ReadIndexReport(..)
  , HistoricalQuerySourceKind(..)
  , HistoricalReadExecutionReport(..)
  , CommitInfo(..)
  , CompactionMode(..)
  , CompactionStats(..)
  , AutoCompactionConfig(..)
  , CompactionState(..)
  , V4ReportStatus(..)
  , V4CurrentHeadBytes(..)
  , V4AuditBytes(..)
  , V4PayloadReuseBytes(..)
  , V4SupersededBytes(..)
  , V4PreciseAccountingField(..)
  , V4PreciseAccountingOptions(..)
  , defaultV4PreciseAccountingOptions
  , V4OmittedPreciseAccountingField(..)
  , V4PreciseAccountingBytes(..)
  , V4DiagnosticsReport(..)
  , V4DiagnosticsPreciseReport(..)
  , V4CompactionAnalysisPolicy(..)
  , V4CompactionAnalysisReport(..)
  , V4CompactionAnalysisPreciseReport(..)
  , V4RetainedHistoryPolicy(..)
  , V4RetainedHistoryCompactionOptions(..)
  , defaultV4RetainedHistoryCompactionOptions
  , V4RetainedHistoryCompactionReport(..)
  , V4RetainedHistoryCompactionPreciseReport(..)
  , ReformTargetLayout(..)
  , ReformOptions(..)
  , defaultReformOptions
  , ReformReport(..)
  , CoordinateKind(..)
  , coordinateKindToRaw
  , coordinateKindFromRaw
  , CoordinateDType(..)
  , coordinateDTypeToRaw
  , coordinateDTypeFromRaw
  , CoordinateEncoding(..)
  , coordinateEncodingToRaw
  , coordinateEncodingFromRaw
  , CoordinateSortedness(..)
  , coordinateSortednessToRaw
  , coordinateSortednessFromRaw
  , CoordinateMonotonicity(..)
  , coordinateMonotonicityToRaw
  , coordinateMonotonicityFromRaw
  , CoordinateUniqueness(..)
  , coordinateUniquenessToRaw
  , coordinateUniquenessFromRaw
  , CoordinateStorageKind(..)
  , coordinateStorageKindFromRaw
  , CoordinateSourceKind(..)
  , coordinateSourceKindFromRaw
  , CoordinateValidationStatus(..)
  , coordinateValidationStatusFromRaw
  , CoordinateValueDomainV2(..)
  , coordinateValueDomainV2ToRaw
  , coordinateValueDomainV2FromRaw
  , CoordinateAvailabilityV2(..)
  , coordinateAvailabilityV2FromRaw
  , CoordinateStatusCategoryV2(..)
  , coordinateStatusCategoryV2FromRaw
  , CoordinateCodeDTypeV2(..)
  , coordinateCodeDTypeV2FromRaw
  , CoordinateKeyDomainV2(..)
  , coordinateKeyDomainV2ToRaw
  , coordinateKeyDomainV2FromRaw
  , CoordinateLookupResultStatusV2(..)
  , coordinateLookupResultStatusV2FromRaw
  , CoordinateLookupKeyV2(..)
  , CoordinateLookupResultV2(..)
  , CoordinateV2Options(..)
  , defaultCoordinateV2Options
  , AxisCoordinateInputV2(..)
  , CoordinateV2Values(..)
  , AppendCoordinateEntryV2(..)
  , AxisCoordinateMeta(..)
  , CoordinateDictionarySummaryV2(..)
  , CoordinateExternalBindingV2(..)
  , CoordinateIndexSourceBindingV2(..)
  , CoordinateIndexSummaryV2(..)
  , AxisCoordinateMetaV2(..)
  , CoordinateValueSliceV2(..)
  , CoordinateDictionaryEntryV2(..)
  , CoordinateDictionaryV2(..)
  ) where

import Data.Int (Int32, Int64)
import Data.Word (Word8, Word32, Word64)
import Foreign.C.Types (CInt(..))

-- | Dense payload dtypes supported by the first Haskell wrapper slice.
data DType
  = F32
  | F64
  | I32
  | I64
  deriving (Eq, Ord, Show)

-- | Stable human-readable dtype spelling.
dtypeName :: DType -> String
dtypeName dtype = case dtype of
  F32 -> "f32"
  F64 -> "f64"
  I32 -> "i32"
  I64 -> "i64"

-- | Scalar byte width for the dtype.
dtypeSizeBytes :: DType -> Int
dtypeSizeBytes dtype = case dtype of
  F32 -> 4
  F64 -> 8
  I32 -> 4
  I64 -> 8

-- | Raw C ABI dtype value.
dtypeToRaw :: DType -> CInt
dtypeToRaw dtype = case dtype of
  F32 -> 0
  F64 -> 1
  I32 -> 2
  I64 -> 3

-- | Convert a raw C ABI dtype value.
dtypeFromRaw :: CInt -> Maybe DType
dtypeFromRaw (CInt raw) = case (fromIntegral raw :: Int32) of
  0 -> Just F32
  1 -> Just F64
  2 -> Just I32
  3 -> Just I64
  _ -> Nothing

-- | Semantic axis kind used when creating a file.
data AxisKind
  = AxisTime
  | AxisSymbol
  | AxisChannel
  | AxisOther
  deriving (Eq, Ord, Show)

-- | Raw C ABI axis-kind value.
axisKindToRaw :: AxisKind -> CInt
axisKindToRaw kind = case kind of
  AxisTime -> 0
  AxisSymbol -> 1
  AxisChannel -> 2
  AxisOther -> 3

-- | Convert a raw C ABI axis-kind value.
axisKindFromRaw :: CInt -> Maybe AxisKind
axisKindFromRaw (CInt raw) = case (fromIntegral raw :: Int32) of
  0 -> Just AxisTime
  1 -> Just AxisSymbol
  2 -> Just AxisChannel
  3 -> Just AxisOther
  _ -> Nothing

-- | Dimension descriptor for basic create calls.
data DimSpec = DimSpec
  { dimKind :: AxisKind
  , dimLength :: Word32
  }
  deriving (Eq, Show)

-- | Construct a dimension descriptor.
dim :: AxisKind -> Word32 -> DimSpec
dim = DimSpec

-- | Effective storage/header profile reported by loaded metadata.
data HeaderProfile
  = HeaderStreaming
  | HeaderRandomAccess
  deriving (Eq, Ord, Show)

-- | Convert a raw C ABI header profile value.
headerProfileFromRaw :: CInt -> Maybe HeaderProfile
headerProfileFromRaw (CInt raw) = case (fromIntegral raw :: Int32) of
  0 -> Just HeaderStreaming
  1 -> Just HeaderRandomAccess
  _ -> Nothing

-- | Dimension metadata copied from a file.
data DimMeta = DimMeta
  { dimMetaKind :: AxisKind
  , dimMetaLength :: Word32
  , dimMetaName :: Maybe String
  }
  deriving (Eq, Show)

-- | Axis label metadata item copied from a file.
data AxisLabel = AxisLabel
  { axisLabelId :: Word32
  , axisLabelName :: String
  }
  deriving (Eq, Show)

-- | User metadata key/value item copied from a file.
data UserKv = UserKv
  { userKvKey :: String
  , userKvValue :: String
  }
  deriving (Eq, Show)

-- | File metadata snapshot copied into Haskell-owned values.
data FileMeta = FileMeta
  { fileMetaDType :: DType
  , fileMetaDims :: [DimMeta]
  , fileMetaAppendDim :: Int
  , fileMetaSymbols :: [AxisLabel]
  , fileMetaChannels :: [AxisLabel]
  , fileMetaUserKv :: [UserKv]
  , fileMetaEffectiveProfile :: HeaderProfile
  , fileMetaCommitSeq :: Word64
  }
  deriving (Eq, Show)

-- | Native chunk-plan block sizes copied from an open file.
newtype ChunkPlan = ChunkPlan
  { chunkPlanBlockSizes :: [Word32]
  }
  deriving (Eq, Show)

-- | Optional metadata accepted by the first metadata-rich create helpers.
data CreateMetadata = CreateMetadata
  { createDimNames :: [Maybe String]
  , createSymbols :: [String]
  , createChannels :: [String]
  , createUserKv :: [(String, String)]
  }
  deriving (Eq, Show)

-- | Empty create metadata.
emptyCreateMetadata :: CreateMetadata
emptyCreateMetadata =
  CreateMetadata
    { createDimNames = []
    , createSymbols = []
    , createChannels = []
    , createUserKv = []
    }

-- | Storage access hint for inferred create.
data StorageAccessKind
  = StorageAccessSeekableMounted
  | StorageAccessRemoteRangeRead
  | StorageAccessForwardOnly
  deriving (Eq, Ord, Show)

-- | Open/query pattern hint for inferred create.
data OpenPattern
  = OpenPatternMetadataHot
  | OpenPatternDataHot
  | OpenPatternMixed
  deriving (Eq, Ord, Show)

-- | File population hint for inferred create.
data FilePopulation
  = FilePopulationFewLongLived
  | FilePopulationManyShards
  deriving (Eq, Ord, Show)

-- | Metadata stability hint for inferred create.
data MetadataStability
  = MetadataStable
  | MetadataGrowing
  deriving (Eq, Ord, Show)

-- | Options for inferred create.
data CreateInferredOptions = CreateInferredOptions
  { inferredStorageAccess :: StorageAccessKind
  , inferredOpenPattern :: OpenPattern
  , inferredFilePopulation :: FilePopulation
  , inferredMetadataStability :: MetadataStability
  }
  deriving (Eq, Show)

-- | Conservative inferred-create defaults.
defaultCreateInferredOptions :: CreateInferredOptions
defaultCreateInferredOptions =
  CreateInferredOptions
    { inferredStorageAccess = StorageAccessSeekableMounted
    , inferredOpenPattern = OpenPatternMetadataHot
    , inferredFilePopulation = FilePopulationFewLongLived
    , inferredMetadataStability = MetadataStable
    }

-- | Storage profile for policy create.
data StorageProfile
  = StorageBalanced
  | StorageNvme
  | StorageHdd
  deriving (Eq, Ord, Show)

-- | Options for policy create.
data CreatePolicyOptions = CreatePolicyOptions
  { policyChunkAxes :: [Int]
  , policyStorageProfile :: StorageProfile
  , policyTypicalQuerySizes :: [Word32]
  }
  deriving (Eq, Show)

-- | Conservative policy-create defaults.
defaultCreatePolicyOptions :: CreatePolicyOptions
defaultCreatePolicyOptions =
  CreatePolicyOptions
    { policyChunkAxes = []
    , policyStorageProfile = StorageBalanced
    , policyTypicalQuerySizes = []
    }

-- | Scalar value returned by the C ABI scalar read helper.
--
-- The native C ABI scalar representation stores the value as a double, so this
-- type preserves the reported dtype and raw numeric value without pretending to
-- recover an exact integer payload for large integers.
data ScalarValue = ScalarValue
  { scalarDType :: DType
  , scalarValue :: Double
  }
  deriving (Eq, Show)

-- | Write-forward compression mode.
data CompressionMode
  = CompressionForceOff
  | CompressionAuto
  | CompressionForceOn
  deriving (Eq, Ord, Show)

-- | Compression codec selector exposed by the C ABI.
data CompressionCodec
  = CompressionZstd
  | CompressionLz4
  deriving (Eq, Ord, Show)

-- | Write-forward compression configuration for future dense appends.
data CompressionConfig = CompressionConfig
  { compressionMode :: CompressionMode
  , compressionCodec :: CompressionCodec
  , compressionMinPayloadBytes :: Word32
  , compressionZstdLevel :: Int32
  }
  deriving (Eq, Show)

-- | Disable write-forward compression.
uncompressedCompression :: CompressionConfig
uncompressedCompression =
  CompressionConfig
    { compressionMode = CompressionForceOff
    , compressionCodec = CompressionZstd
    , compressionMinPayloadBytes = 0
    , compressionZstdLevel = 0
    }

-- | Force zstd compression at the given level.
zstdCompression :: Int32 -> CompressionConfig
zstdCompression level =
  CompressionConfig
    { compressionMode = CompressionForceOn
    , compressionCodec = CompressionZstd
    , compressionMinPayloadBytes = 0
    , compressionZstdLevel = level
    }

-- | Sparse-intent detector used to classify logically absent subtensors.
data SparseDetector
  = SparseNullSubtensor
  | SparsePredicateSubtensor
  deriving (Eq, Ord, Show)

-- | Sparse-intent predicate used by predicate-subtensor rules.
data SparseValuePredicate
  = SparsePredicateNaN
  | SparsePredicateZero
  | SparsePredicateEqualF32 Float
  | SparsePredicateEqualF64 Double
  | SparsePredicateEqualI32 Int32
  | SparsePredicateEqualI64 Int64
  deriving (Eq, Show)

-- | Fallback policy when native sparse lowering is not selected.
data SparseFallbackPolicy
  = SparseFallbackDense
  deriving (Eq, Ord, Show)

-- | Sparse-intent append rule. Sparse axes are non-append axis indices that
-- define the subtensor boundary considered by native analysis.
data SparseRule = SparseRule
  { sparseDetector :: SparseDetector
  , sparseAxes :: [Int]
  , sparsePredicate :: SparseValuePredicate
  , sparseMinAbsentFraction :: Double
  , sparseMinAbsentSubtensors :: Word64
  , sparseFallback :: SparseFallbackPolicy
  }
  deriving (Eq, Show)

-- | Build a null-subtensor sparse rule for the provided non-append axes.
nullSubtensorRule :: [Int] -> SparseRule
nullSubtensorRule axes =
  SparseRule
    { sparseDetector = SparseNullSubtensor
    , sparseAxes = axes
    , sparsePredicate = SparsePredicateNaN
    , sparseMinAbsentFraction = 0
    , sparseMinAbsentSubtensors = 1
    , sparseFallback = SparseFallbackDense
    }

-- | Build a predicate-subtensor sparse rule for the provided non-append axes.
predicateSubtensorRule :: [Int] -> SparseValuePredicate -> SparseRule
predicateSubtensorRule axes predicate =
  SparseRule
    { sparseDetector = SparsePredicateSubtensor
    , sparseAxes = axes
    , sparsePredicate = predicate
    , sparseMinAbsentFraction = 0
    , sparseMinAbsentSubtensors = 1
    , sparseFallback = SparseFallbackDense
    }

-- | Native sparse-intent analysis outcome.
data SparseAppendOutcome
  = SparseAppendSparseRegularChunked
  | SparseAppendDenseFallback
  | SparseAppendReject
  | SparseAppendSparseChunkTree
  deriving (Eq, Ord, Show)

-- | Structured sparse-intent analysis reason code.
data SparseAppendReason
  = SparseReasonNoAbsentSubtensorsDetected
  | SparseReasonSparseAxesMustNotBeEmpty
  | SparseReasonSparseAxesMustBeUnique
  | SparseReasonSparseAxesOutOfBounds
  | SparseReasonSparseAxesMustExcludeAppendAxis
  | SparseReasonAppendAxisMustBeZeroForCurrentRootAppend
  | SparseReasonPredicateDTypeMismatch
  | SparseReasonDenseFallbackPreservesExactValues
  | SparseReasonSparseLoweringBelowThreshold
  | SparseReasonWholeAppendUnitHasNoSparseProducerPath
  | SparseReasonRegularChunkedBlockShapeUnpublished
  | SparseReasonRegularChunkedDenseFallbackRequiresStableNonAppendExtents
  | SparseReasonRegularChunkedDenseFallbackRequiresDensePublishedLaneSet
  | SparseReasonRegularChunkedSparseLoweringRequiresStablePublishedLaneSet
  | SparseReasonTensorContainsNullsThatDenseFallbackCannotPreserve
  | SparseReasonLogicalAbsenceDoesNotCompileToCurrentSparseModel
  | SparseReasonCurrentSparseLoweringNotYetImplementedForDetector
  deriving (Eq, Ord, Show)

-- | Sparse-intent analysis report copied from native output.
data SparseAppendAnalysis = SparseAppendAnalysis
  { sparseAppendOutcome :: SparseAppendOutcome
  , sparseAppendAbsentFraction :: Double
  , sparseAppendAbsentSubtensorCount :: Word64
  , sparseAppendTotalSubtensorCount :: Word64
  , sparseAppendReasons :: [SparseAppendReason]
  }
  deriving (Eq, Show)

-- | Per-axis entry selector used by selector-bearing C ABI reads.
data EntrySelector
  = SelectAll
  | SelectRange Word32 Word32
  | SelectTake [Word32]
  deriving (Eq, Show)

-- | Native read execution mode requested by option-bearing reads.
data ReadExecutionMode
  = ReadSerial
  | ReadParallelThreads
  deriving (Eq, Ord, Show)

-- | Read execution options shared by current and historical option reads.
data ReadOptions = ReadOptions
  { readOptionMode :: ReadExecutionMode
  , readOptionMaxThreads :: Int
  }
  deriving (Eq, Show)

-- | Default serial read options.
defaultReadOptions :: ReadOptions
defaultReadOptions = ReadOptions{readOptionMode = ReadSerial, readOptionMaxThreads = 0}

-- | Shape policy for option-bearing reads. Explicit extent-axis and explicit
-- universe-axis payloads are intentionally deferred until the Haskell wrapper
-- has typed UUID inputs for them.
newtype TioUuid = TioUuid { tioUuidBytes :: [Word8] }
  deriving (Eq, Ord, Show)

data AxisIdentityMode = AxisIdentityExtentOnly | AxisIdentityUniverseAware deriving (Eq, Ord, Show)

data AxisIdentityInput = AxisIdentityInput
  { axisIdentityAxis :: Int
  , axisIdentityMode :: AxisIdentityMode
  }
  deriving (Eq, Show)

data UniverseBindingInput = UniverseBindingInput
  { universeBindingAxis :: Int
  , universeBindingFamilyUuid :: TioUuid
  , universeBindingVersionUuid :: TioUuid
  , universeBindingLength :: Word64
  }
  deriving (Eq, Show)

newtype SlotUniverseBindingInput = SlotUniverseBindingInput { slotUniverseBindings :: [UniverseBindingInput] }
  deriving (Eq, Show)

data UniverseRemapInput = UniverseRemapInput
  { universeRemapAxis :: Int
  , universeRemapTargetFamilyUuid :: TioUuid
  , universeRemapTargetVersionUuid :: TioUuid
  , universeRemapTargetLength :: Word64
  , universeRemapSourceToTarget :: [Word64]
  }
  deriving (Eq, Show)

newtype SlotUniverseRemapInput = SlotUniverseRemapInput { slotUniverseRemaps :: [UniverseRemapInput] }
  deriving (Eq, Show)

data CreateWithUniverseOptions = CreateWithUniverseOptions
  { createUniverseAxisIdentities :: [AxisIdentityInput]
  }
  deriving (Eq, Show)

defaultCreateWithUniverseOptions :: CreateWithUniverseOptions
defaultCreateWithUniverseOptions = CreateWithUniverseOptions []

data AppendWithUniverseOptions = AppendWithUniverseOptions
  { appendUniverseSlots :: [SlotUniverseBindingInput]
  , appendUniverseRemapSlots :: [SlotUniverseRemapInput]
  }
  deriving (Eq, Show)

defaultAppendWithUniverseOptions :: AppendWithUniverseOptions
defaultAppendWithUniverseOptions = AppendWithUniverseOptions [] []

data ExplicitUniverseAxisTarget = ExplicitUniverseAxisTarget
  { explicitUniverseAxis :: Int
  , explicitUniverseFamilyUuid :: TioUuid
  , explicitUniverseVersionUuid :: TioUuid
  , explicitUniverseLength :: Word64
  }
  deriving (Eq, Show)

data ExplicitExtentAxisTarget = ExplicitExtentAxisTarget
  { explicitExtentAxis :: Int
  , explicitExtentLength :: Word64
  }
  deriving (Eq, Show)

-- | Shape policy for option-bearing reads.
data ReadShapePolicy
  = ReadShapeFileEnvelope
  | ReadShapeCurrentHead
  | ReadShapeUnion
  | ReadShapeIntersection
  | ReadShapeInitialRegistered
  | ReadShapeExplicitExtents [Word64]
  | ReadShapeExplicitUniverse [ExplicitUniverseAxisTarget]
  | ReadShapeExplicitUniverseAndExtents [ExplicitUniverseAxisTarget] [ExplicitExtentAxisTarget]
  deriving (Eq, Show)

-- | Copied native read execution report. String fields are diagnostic only.
data ReadExecutionReport = ReadExecutionReport
  { readReportRequestedMode :: ReadExecutionMode
  , readReportQueryMaxThreads :: Int
  , readReportQueryEffectiveMode :: ReadExecutionMode
  , readReportQueryEffectiveThreads :: Int
  , readReportQueryParallelRuntime :: Maybe String
  , readReportQueryParallelFallbackReason :: Maybe String
  , readReportQueryParallelReasonCode :: Maybe String
  , readReportQueryParallelReasonCodeTaxonomy :: Maybe String
  }
  deriving (Eq, Show)

-- | Query trace attribution context borrowed by attributed read calls.
data QueryTraceContext = QueryTraceContext
  { queryTraceRunId :: String
  , queryTraceRowId :: String
  , queryTraceRepeatIndex :: Word32
  , queryTracePhase :: String
  , queryTraceLanguage :: String
  , queryTraceApiSurface :: String
  , queryTraceOperation :: String
  , queryTraceClock :: String
  }
  deriving (Eq, Show)

-- | Owned JSON copied from the native query trace result.
newtype QueryTraceJson = QueryTraceJson { queryTraceJson :: String }
  deriving (Eq, Show)

-- | Python-style index item for @read_index@ lowering.
data ReadIndexItem
  = ReadIndexAll
  | ReadIndexSlice (Maybe Int64) (Maybe Int64) Int64
  | ReadIndexIndex Int64
  | ReadIndexNewAxis
  | ReadIndexEllipsis
  deriving (Eq, Show)

-- | Native read-index lowering selected by the runtime.
data ReadIndexLoweringKind
  = ReadIndexLoweringUnknown
  | ReadIndexLoweringSelectorRead
  | ReadIndexLoweringSelectorReadWithShapePostprocess
  deriving (Eq, Ord, Show)

-- | Copied native read-index report.
data ReadIndexReport = ReadIndexReport
  { readIndexLoweringKind :: ReadIndexLoweringKind
  , readIndexUsedFullTensorFallback :: Bool
  }
  deriving (Eq, Show)

-- | Native historical read source kind.
data HistoricalQuerySourceKind
  = HistoricalQueryRetainedVisibleCommit
  deriving (Eq, Ord, Show)

-- | Copied native historical read execution report.
data HistoricalReadExecutionReport = HistoricalReadExecutionReport
  { historicalReadExecutionReport :: ReadExecutionReport
  , historicalReadQuerySourceKind :: HistoricalQuerySourceKind
  , historicalReadQueryCommitSeq :: Word64
  }
  deriving (Eq, Show)

-- | Commit metadata copied from the C ABI visible-commit list.
data CommitInfo = CommitInfo
  { commitSeq :: Word64
  , commitFooterOffset :: Word64
  , commitPrevFooterOffset :: Word64
  }
  deriving (Eq, Show)

-- | Native compaction mode selector.
data CompactionMode
  = CompactionCopyLive
  | CompactionReblock Word32
  deriving (Eq, Show)

-- | Shallow compaction analysis stats copied from the C ABI.
data CompactionStats = CompactionStats
  { compactionLiveBytes :: Word64
  , compactionDeadBytes :: Word64
  , compactionDeadRatio :: Double
  , compactionCommitCount :: Word32
  }
  deriving (Eq, Show)

-- | Auto-compaction metadata configuration copied from or supplied to the C ABI.
data AutoCompactionConfig = AutoCompactionConfig
  { autoCompactionEnabled :: Bool
  , autoCompactionRetainCommits :: Word32
  , autoCompactionDeadRatioThreshold :: Double
  , autoCompactionMinDeadBytes :: Word64
  , autoCompactionMode :: CompactionMode
  , autoCompactionCheckEveryCommits :: Word32
  , autoCompactionCooldownCommits :: Word32
  }
  deriving (Eq, Show)

-- | Native auto-compaction state metadata, when present.
data CompactionState = CompactionState
  { compactionStateLastCompactedCommitSeq :: Word64
  , compactionStateLastCompactedAtUnixMs :: Word64
  }
  deriving (Eq, Show)


-- | In-band status for detailed V4 diagnostics/accounting report families.
data V4ReportStatus
  = V4ReportComplete
  | V4ReportUnsupported
  | V4ReportUnknown
  | V4ReportStatusUnknown Int32
  deriving (Eq, Ord, Show)

-- | Detailed bytes owned by the current visible V4 head.
data V4CurrentHeadBytes = V4CurrentHeadBytes
  { v4CurrentHeadPayloadBytes :: Word64
  , v4CurrentHeadIndexBytes :: Word64
  , v4CurrentHeadEpochBytes :: Word64
  , v4CurrentHeadAuxBytes :: Word64
  , v4CurrentHeadCommitBytes :: Word64
  }
  deriving (Eq, Show)

-- | Detailed bytes required by visible-chain audit data.
data V4AuditBytes = V4AuditBytes
  { v4AuditCommitBytes :: Word64
  , v4AuditIndexBytes :: Word64
  , v4AuditEpochBytes :: Word64
  , v4AuditAuxBytes :: Word64
  }
  deriving (Eq, Show)

-- | Payload bytes reused across visible/superseded state.
data V4PayloadReuseBytes = V4PayloadReuseBytes
  { v4PayloadReuseResurrectedPayloadBytes :: Word64
  , v4PayloadReuseSharedPayloadBytes :: Word64
  }
  deriving (Eq, Show)

-- | Detailed bytes superseded by the current visible V4 head.
data V4SupersededBytes = V4SupersededBytes
  { v4SupersededPayloadBytes :: Word64
  , v4SupersededIndexBytes :: Word64
  , v4SupersededEpochBytes :: Word64
  , v4SupersededAuxBytes :: Word64
  }
  deriving (Eq, Show)

-- | Precise V4 accounting fields that can be requested explicitly.
data V4PreciseAccountingField
  = V4PreciseUnreachableBytes
  | V4PreciseRetainedHistoryRequiredBytes
  | V4PrecisePoppedSkippedBytes
  | V4PreciseReclaimableBytes
  | V4PreciseAccountingFieldUnknown Int32
  deriving (Eq, Ord, Show)

-- | Options for precise V4 diagnostics/accounting reports.
data V4PreciseAccountingOptions = V4PreciseAccountingOptions
  { v4PreciseRequestedFields :: [V4PreciseAccountingField]
    -- ^ Empty requests every precise field relevant to the report family.
  , v4PreciseIncludeOmittedFieldReasons :: Bool
  }
  deriving (Eq, Show)

defaultV4PreciseAccountingOptions :: V4PreciseAccountingOptions
defaultV4PreciseAccountingOptions = V4PreciseAccountingOptions [] False

-- | Omitted precise-accounting field copied from native-owned arrays.
data V4OmittedPreciseAccountingField = V4OmittedPreciseAccountingField
  { v4OmittedPreciseField :: V4PreciseAccountingField
  , v4OmittedPreciseReason :: Maybe String
  , v4OmittedPreciseReasonCode :: Maybe String
  }
  deriving (Eq, Show)

-- | Precise byte counts with per-field validity and omission details.
data V4PreciseAccountingBytes = V4PreciseAccountingBytes
  { v4PreciseUnreachableBytes :: Maybe Word64
  , v4PreciseRetainedHistoryRequiredBytes :: Maybe Word64
  , v4PrecisePoppedSkippedBytes :: Maybe Word64
  , v4PreciseReclaimableBytes :: Maybe Word64
  , v4PreciseOmittedFields :: [V4OmittedPreciseAccountingField]
  }
  deriving (Eq, Show)

-- | Detailed V4 diagnostics report copied into Haskell-owned values.
data V4DiagnosticsReport = V4DiagnosticsReport
  { v4DiagnosticsStatus :: V4ReportStatus
  , v4DiagnosticsReason :: Maybe String
  , v4DiagnosticsCurrentHead :: V4CurrentHeadBytes
  , v4DiagnosticsVisibleChainAudit :: V4AuditBytes
  , v4DiagnosticsPayloadReuse :: V4PayloadReuseBytes
  , v4DiagnosticsSuperseded :: V4SupersededBytes
  , v4DiagnosticsUnknownBytes :: Word64
  , v4DiagnosticsOmittedUnreachableBytes :: Bool
  , v4DiagnosticsOmittedUnreachableBytesReason :: Maybe String
  }
  deriving (Eq, Show)

-- | Detailed V4 diagnostics report with explicit precise-accounting validity.
data V4DiagnosticsPreciseReport = V4DiagnosticsPreciseReport
  { v4DiagnosticsPreciseStatus :: V4ReportStatus
  , v4DiagnosticsPreciseReason :: Maybe String
  , v4DiagnosticsPreciseCurrentHead :: V4CurrentHeadBytes
  , v4DiagnosticsPreciseVisibleChainAudit :: V4AuditBytes
  , v4DiagnosticsPrecisePayloadReuse :: V4PayloadReuseBytes
  , v4DiagnosticsPreciseSuperseded :: V4SupersededBytes
  , v4DiagnosticsPreciseUnknownBytes :: Word64
  , v4DiagnosticsPreciseAccounting :: V4PreciseAccountingBytes
  , v4DiagnosticsPreciseReasonCode :: Maybe String
  }
  deriving (Eq, Show)


-- | Native detailed V4 compaction analysis policy.
data V4CompactionAnalysisPolicy
  = V4CompactionPolicyCompactToCurrentState
  | V4CompactionAnalysisPolicyUnknown Int32
  deriving (Eq, Ord, Show)

-- | Detailed ordinary current-state compaction analysis report.
data V4CompactionAnalysisReport = V4CompactionAnalysisReport
  { v4CompactionAnalysisStatus :: V4ReportStatus
  , v4CompactionAnalysisReason :: Maybe String
  , v4CompactionAnalysisPolicy :: V4CompactionAnalysisPolicy
  , v4CompactionAnalysisSourceFileBytes :: Word64
  , v4CompactionAnalysisCurrentStateRequiredBytes :: Word64
  , v4CompactionAnalysisOrdinaryReclaimableBytes :: Word64
  , v4CompactionAnalysisUnknownBytes :: Word64
  , v4CompactionAnalysisOmittedUnreachableBytes :: Bool
  , v4CompactionAnalysisOmittedUnreachableBytesReason :: Maybe String
  }
  deriving (Eq, Show)

-- | Detailed ordinary current-state compaction analysis with precise accounting.
data V4CompactionAnalysisPreciseReport = V4CompactionAnalysisPreciseReport
  { v4CompactionAnalysisPreciseStatus :: V4ReportStatus
  , v4CompactionAnalysisPreciseReason :: Maybe String
  , v4CompactionAnalysisPrecisePolicy :: V4CompactionAnalysisPolicy
  , v4CompactionAnalysisPreciseSourceFileBytes :: Word64
  , v4CompactionAnalysisPreciseCurrentStateRequiredBytes :: Word64
  , v4CompactionAnalysisPreciseOrdinaryReclaimableBytes :: Word64
  , v4CompactionAnalysisPreciseUnknownBytes :: Word64
  , v4CompactionAnalysisPreciseAccounting :: V4PreciseAccountingBytes
  , v4CompactionAnalysisPreciseReasonCode :: Maybe String
  }
  deriving (Eq, Show)

-- | Retained-history compaction policy.
data V4RetainedHistoryPolicy
  = V4RetainLast
  | V4RetainedHistoryPolicyUnknown Int32
  deriving (Eq, Ord, Show)

-- | Options for retained-history V4 compaction.
data V4RetainedHistoryCompactionOptions = V4RetainedHistoryCompactionOptions
  { v4RetainedHistoryPolicy :: V4RetainedHistoryPolicy
  , v4RetainedHistoryRetainLastN :: Word32
  }
  deriving (Eq, Show)

defaultV4RetainedHistoryCompactionOptions :: V4RetainedHistoryCompactionOptions
defaultV4RetainedHistoryCompactionOptions = V4RetainedHistoryCompactionOptions V4RetainLast 1

-- | Retained-history compaction report copied into Haskell-owned values.
data V4RetainedHistoryCompactionReport = V4RetainedHistoryCompactionReport
  { v4RetainedHistoryStatus :: V4ReportStatus
  , v4RetainedHistoryReason :: Maybe String
  , v4RetainedHistoryRetainedCommitCount :: Word32
  , v4RetainedHistoryRetainedCommitSeqs :: [Word64]
  , v4RetainedHistoryUnretainedOlderCommitCount :: Maybe Word64
  , v4RetainedHistorySourceFileBytes :: Word64
  , v4RetainedHistoryDestinationFileBytes :: Word64
  , v4RetainedHistoryOmittedUnreachableBytes :: Bool
  , v4RetainedHistoryOmittedUnreachableBytesReason :: Maybe String
  }
  deriving (Eq, Show)

-- | Retained-history compaction report with source precise accounting.
data V4RetainedHistoryCompactionPreciseReport = V4RetainedHistoryCompactionPreciseReport
  { v4RetainedHistoryPreciseStatus :: V4ReportStatus
  , v4RetainedHistoryPreciseReason :: Maybe String
  , v4RetainedHistoryPreciseRetainedCommitCount :: Word32
  , v4RetainedHistoryPreciseRetainedCommitSeqs :: [Word64]
  , v4RetainedHistoryPreciseUnretainedOlderCommitCount :: Maybe Word64
  , v4RetainedHistoryPreciseSourceFileBytes :: Word64
  , v4RetainedHistoryPreciseDestinationFileBytes :: Word64
  , v4RetainedHistoryPreciseSourceAccounting :: V4PreciseAccountingBytes
  , v4RetainedHistoryPreciseReasonCode :: Maybe String
  }
  deriving (Eq, Show)


-- | Target layout policy for reforming visible data into a fresh destination.
data ReformTargetLayout
  = ReformPreserveFamily
  | ReformWholeAppendUnit
  | ReformRegularChunked [Word32]
  deriving (Eq, Show)

-- | Reform options copied to the C ABI.
data ReformOptions = ReformOptions
  { reformTargetLayout :: ReformTargetLayout
  }
  deriving (Eq, Show)

defaultReformOptions :: ReformOptions
defaultReformOptions = ReformOptions ReformPreserveFamily

-- | Stable reform diagnostic metadata copied before native report cleanup.
data ReformReport = ReformReport
  { reformReasonCode :: Maybe String
  , reformReasonCodeTaxonomy :: Maybe String
  , reformReason :: Maybe String
  }
  deriving (Eq, Show)

-- | Coordinate descriptor kind used by v1/v2 coordinate metadata.
data CoordinateKind
  = CoordinatePosition
  | CoordinateLabelId
  | CoordinateDate
  | CoordinateTimestamp
  | CoordinateDomainValue
  | CoordinateKindUnknown Int32
  deriving (Eq, Ord, Show)

coordinateKindToRaw :: CoordinateKind -> CInt
coordinateKindToRaw kind = CInt $ case kind of
  CoordinatePosition -> 0
  CoordinateLabelId -> 1
  CoordinateDate -> 2
  CoordinateTimestamp -> 3
  CoordinateDomainValue -> 4
  CoordinateKindUnknown raw -> raw

coordinateKindFromRaw :: CInt -> CoordinateKind
coordinateKindFromRaw (CInt raw) = case raw of
  0 -> CoordinatePosition
  1 -> CoordinateLabelId
  2 -> CoordinateDate
  3 -> CoordinateTimestamp
  4 -> CoordinateDomainValue
  _ -> CoordinateKindUnknown raw

-- | Coordinate numeric dtype.
data CoordinateDType = CoordinateI32 | CoordinateI64 | CoordinateDTypeUnknown Int32 deriving (Eq, Ord, Show)

coordinateDTypeToRaw :: CoordinateDType -> CInt
coordinateDTypeToRaw dtype = CInt $ case dtype of
  CoordinateI32 -> 0
  CoordinateI64 -> 1
  CoordinateDTypeUnknown raw -> raw

coordinateDTypeFromRaw :: CInt -> CoordinateDType
coordinateDTypeFromRaw (CInt raw) = case raw of
  0 -> CoordinateI32
  1 -> CoordinateI64
  _ -> CoordinateDTypeUnknown raw

-- | Coordinate encoding.
data CoordinateEncoding
  = CoordinateEncodingPlain
  | CoordinateEncodingDateDays
  | CoordinateEncodingDateYYYYMMDD
  | CoordinateEncodingEpochSeconds
  | CoordinateEncodingEpochMilliseconds
  | CoordinateEncodingEpochMicroseconds
  | CoordinateEncodingEpochNanoseconds
  | CoordinateEncodingUnknown Int32
  deriving (Eq, Ord, Show)

coordinateEncodingToRaw :: CoordinateEncoding -> CInt
coordinateEncodingToRaw enc = CInt $ case enc of
  CoordinateEncodingPlain -> 0
  CoordinateEncodingDateDays -> 1
  CoordinateEncodingDateYYYYMMDD -> 2
  CoordinateEncodingEpochSeconds -> 3
  CoordinateEncodingEpochMilliseconds -> 4
  CoordinateEncodingEpochMicroseconds -> 5
  CoordinateEncodingEpochNanoseconds -> 6
  CoordinateEncodingUnknown raw -> raw

coordinateEncodingFromRaw :: CInt -> CoordinateEncoding
coordinateEncodingFromRaw (CInt raw) = case raw of
  0 -> CoordinateEncodingPlain
  1 -> CoordinateEncodingDateDays
  2 -> CoordinateEncodingDateYYYYMMDD
  3 -> CoordinateEncodingEpochSeconds
  4 -> CoordinateEncodingEpochMilliseconds
  5 -> CoordinateEncodingEpochMicroseconds
  6 -> CoordinateEncodingEpochNanoseconds
  _ -> CoordinateEncodingUnknown raw

data CoordinateSortedness = CoordinateSortedUnknown | CoordinateSortedAscending | CoordinateSortedDescending | CoordinateUnsorted | CoordinateSortednessUnknown Int32 deriving (Eq, Ord, Show)
coordinateSortednessToRaw :: CoordinateSortedness -> CInt
coordinateSortednessToRaw v = CInt $ case v of CoordinateSortedUnknown -> 0; CoordinateSortedAscending -> 1; CoordinateSortedDescending -> 2; CoordinateUnsorted -> 3; CoordinateSortednessUnknown raw -> raw
coordinateSortednessFromRaw :: CInt -> CoordinateSortedness
coordinateSortednessFromRaw (CInt raw) = case raw of 0 -> CoordinateSortedUnknown; 1 -> CoordinateSortedAscending; 2 -> CoordinateSortedDescending; 3 -> CoordinateUnsorted; _ -> CoordinateSortednessUnknown raw

data CoordinateMonotonicity = CoordinateMonotonicityUnknownStatus | CoordinateStrictlyIncreasing | CoordinateNonDecreasing | CoordinateStrictlyDecreasing | CoordinateNonIncreasing | CoordinateNotMonotonic | CoordinateMonotonicityUnknown Int32 deriving (Eq, Ord, Show)
coordinateMonotonicityToRaw :: CoordinateMonotonicity -> CInt
coordinateMonotonicityToRaw v = CInt $ case v of CoordinateMonotonicityUnknownStatus -> 0; CoordinateNonDecreasing -> 1; CoordinateStrictlyIncreasing -> 2; CoordinateNonIncreasing -> 3; CoordinateStrictlyDecreasing -> 4; CoordinateNotMonotonic -> 5; CoordinateMonotonicityUnknown raw -> raw
coordinateMonotonicityFromRaw :: CInt -> CoordinateMonotonicity
coordinateMonotonicityFromRaw (CInt raw) = case raw of 0 -> CoordinateMonotonicityUnknownStatus; 1 -> CoordinateNonDecreasing; 2 -> CoordinateStrictlyIncreasing; 3 -> CoordinateNonIncreasing; 4 -> CoordinateStrictlyDecreasing; 5 -> CoordinateNotMonotonic; _ -> CoordinateMonotonicityUnknown raw

data CoordinateUniqueness = CoordinateUniquenessUnknownStatus | CoordinateUnique | CoordinateHasDuplicates | CoordinateUniquenessUnknown Int32 deriving (Eq, Ord, Show)
coordinateUniquenessToRaw :: CoordinateUniqueness -> CInt
coordinateUniquenessToRaw v = CInt $ case v of CoordinateUniquenessUnknownStatus -> 0; CoordinateUnique -> 1; CoordinateHasDuplicates -> 2; CoordinateUniquenessUnknown raw -> raw
coordinateUniquenessFromRaw :: CInt -> CoordinateUniqueness
coordinateUniquenessFromRaw (CInt raw) = case raw of 0 -> CoordinateUniquenessUnknownStatus; 1 -> CoordinateUnique; 2 -> CoordinateHasDuplicates; _ -> CoordinateUniquenessUnknown raw

data CoordinateStorageKind = CoordinateStorageInline | CoordinateStorageExternal | CoordinateStorageKindUnknown Int32 deriving (Eq, Ord, Show)
coordinateStorageKindFromRaw :: CInt -> CoordinateStorageKind
coordinateStorageKindFromRaw (CInt raw) = case raw of 0 -> CoordinateStorageInline; 1 -> CoordinateStorageExternal; _ -> CoordinateStorageKindUnknown raw

data CoordinateSourceKind = CoordinateSourceSameFileObject | CoordinateSourceRelativePath | CoordinateSourceAbsolutePath | CoordinateSourceUri | CoordinateSourceApplicationRegistry | CoordinateSourceKindUnknown Int32 deriving (Eq, Ord, Show)
coordinateSourceKindFromRaw :: CInt -> CoordinateSourceKind
coordinateSourceKindFromRaw (CInt raw) = case raw of 0 -> CoordinateSourceSameFileObject; 1 -> CoordinateSourceRelativePath; 2 -> CoordinateSourceAbsolutePath; 3 -> CoordinateSourceUri; 4 -> CoordinateSourceApplicationRegistry; _ -> CoordinateSourceKindUnknown raw

data CoordinateValidationStatus = CoordinateValidated | CoordinateUnvalidated | CoordinateValidationStatusUnknown Int32 deriving (Eq, Ord, Show)
coordinateValidationStatusFromRaw :: CInt -> CoordinateValidationStatus
coordinateValidationStatusFromRaw (CInt raw) = case raw of 0 -> CoordinateValidated; 1 -> CoordinateUnvalidated; _ -> CoordinateValidationStatusUnknown raw

data CoordinateValueDomainV2 = CoordinateV2InlineNumeric | CoordinateV2FixedText | CoordinateV2DictionaryCode | CoordinateV2AppendSequence | CoordinateV2ExternalReference | CoordinateValueDomainV2Unknown Int32 deriving (Eq, Ord, Show)
coordinateValueDomainV2ToRaw :: CoordinateValueDomainV2 -> CInt
coordinateValueDomainV2ToRaw v = CInt $ case v of CoordinateV2InlineNumeric -> 0; CoordinateV2FixedText -> 1; CoordinateV2DictionaryCode -> 2; CoordinateV2AppendSequence -> 3; CoordinateV2ExternalReference -> 4; CoordinateValueDomainV2Unknown raw -> raw
coordinateValueDomainV2FromRaw :: CInt -> CoordinateValueDomainV2
coordinateValueDomainV2FromRaw (CInt raw) = case raw of 0 -> CoordinateV2InlineNumeric; 1 -> CoordinateV2FixedText; 2 -> CoordinateV2DictionaryCode; 3 -> CoordinateV2AppendSequence; 4 -> CoordinateV2ExternalReference; _ -> CoordinateValueDomainV2Unknown raw

data CoordinateAvailabilityV2 = CoordinateAvailableV2 | CoordinateAbsentV2 | CoordinateUnknownV2 | CoordinateInvalidV2 | CoordinateUnavailableV2 | CoordinateUnsupportedV2 | CoordinateAvailabilityV2Unknown Int32 deriving (Eq, Ord, Show)
coordinateAvailabilityV2FromRaw :: CInt -> CoordinateAvailabilityV2
coordinateAvailabilityV2FromRaw (CInt raw) = case raw of 0 -> CoordinateAvailableV2; 1 -> CoordinateAbsentV2; 2 -> CoordinateUnknownV2; 3 -> CoordinateInvalidV2; 4 -> CoordinateUnavailableV2; 5 -> CoordinateUnsupportedV2; _ -> CoordinateAvailabilityV2Unknown raw

data CoordinateStatusCategoryV2 = CoordinateStatusOkV2 | CoordinateStatusInvalidArgumentV2 | CoordinateStatusUnsupportedDomainV2 | CoordinateStatusUnknownRequiredVersionV2 | CoordinateStatusRequiredUnavailableV2 | CoordinateStatusStaleExternalBindingV2 | CoordinateStatusDuplicateUniqueLookupV2 | CoordinateStatusLookupDomainMismatchV2 | CoordinateStatusInvalidIndexV2 | CoordinateStatusStaleIndexV2 | CoordinateStatusUnsupportedIndexV2 | CoordinateStatusCategoryV2Unknown Int32 deriving (Eq, Ord, Show)
coordinateStatusCategoryV2FromRaw :: CInt -> CoordinateStatusCategoryV2
coordinateStatusCategoryV2FromRaw (CInt raw) = case raw of 0 -> CoordinateStatusOkV2; 1 -> CoordinateStatusInvalidArgumentV2; 2 -> CoordinateStatusUnsupportedDomainV2; 3 -> CoordinateStatusUnknownRequiredVersionV2; 4 -> CoordinateStatusRequiredUnavailableV2; 5 -> CoordinateStatusStaleExternalBindingV2; 6 -> CoordinateStatusDuplicateUniqueLookupV2; 7 -> CoordinateStatusLookupDomainMismatchV2; 8 -> CoordinateStatusInvalidIndexV2; 9 -> CoordinateStatusStaleIndexV2; 10 -> CoordinateStatusUnsupportedIndexV2; _ -> CoordinateStatusCategoryV2Unknown raw

data CoordinateCodeDTypeV2 = CoordinateCodeU8 | CoordinateCodeU16 | CoordinateCodeU32 | CoordinateCodeU64 | CoordinateCodeDTypeV2Unknown Int32 deriving (Eq, Ord, Show)
coordinateCodeDTypeV2FromRaw :: CInt -> CoordinateCodeDTypeV2
coordinateCodeDTypeV2FromRaw (CInt raw) = case raw of 0 -> CoordinateCodeU8; 1 -> CoordinateCodeU16; 2 -> CoordinateCodeU32; 3 -> CoordinateCodeU64; _ -> CoordinateCodeDTypeV2Unknown raw

-- | Coordinate lookup key domain values from the C ABI.
data CoordinateKeyDomainV2
  = CoordinateKeyI32
  | CoordinateKeyI64
  | CoordinateKeyFixedText
  | CoordinateKeyDictionaryCode
  | CoordinateKeyStableId
  | CoordinateKeyDisplayLabel
  | CoordinateKeyAlias
  | CoordinateKeyRawTime
  | CoordinateKeyDomainV2Unknown Int32
  deriving (Eq, Ord, Show)

coordinateKeyDomainV2ToRaw :: CoordinateKeyDomainV2 -> CInt
coordinateKeyDomainV2ToRaw domain = CInt $ case domain of
  CoordinateKeyI32 -> 0
  CoordinateKeyI64 -> 1
  CoordinateKeyFixedText -> 2
  CoordinateKeyDictionaryCode -> 3
  CoordinateKeyStableId -> 4
  CoordinateKeyDisplayLabel -> 5
  CoordinateKeyAlias -> 6
  CoordinateKeyRawTime -> 7
  CoordinateKeyDomainV2Unknown raw -> raw

coordinateKeyDomainV2FromRaw :: CInt -> CoordinateKeyDomainV2
coordinateKeyDomainV2FromRaw (CInt raw) = case raw of
  0 -> CoordinateKeyI32
  1 -> CoordinateKeyI64
  2 -> CoordinateKeyFixedText
  3 -> CoordinateKeyDictionaryCode
  4 -> CoordinateKeyStableId
  5 -> CoordinateKeyDisplayLabel
  6 -> CoordinateKeyAlias
  7 -> CoordinateKeyRawTime
  _ -> CoordinateKeyDomainV2Unknown raw

-- | Native Coordinate v2 lookup result status.
data CoordinateLookupResultStatusV2
  = CoordinateLookupUniqueV2
  | CoordinateLookupRangeV2
  | CoordinateLookupManyV2
  | CoordinateLookupMissingV2
  | CoordinateLookupUnavailableV2
  | CoordinateLookupDuplicateV2
  | CoordinateLookupUnsupportedV2
  | CoordinateLookupErrorV2
  | CoordinateLookupResultStatusV2Unknown Int32
  deriving (Eq, Ord, Show)

coordinateLookupResultStatusV2FromRaw :: CInt -> CoordinateLookupResultStatusV2
coordinateLookupResultStatusV2FromRaw (CInt raw) = case raw of
  0 -> CoordinateLookupUniqueV2
  1 -> CoordinateLookupRangeV2
  2 -> CoordinateLookupManyV2
  3 -> CoordinateLookupMissingV2
  4 -> CoordinateLookupUnavailableV2
  5 -> CoordinateLookupDuplicateV2
  6 -> CoordinateLookupUnsupportedV2
  7 -> CoordinateLookupErrorV2
  _ -> CoordinateLookupResultStatusV2Unknown raw

-- | Typed Coordinate v2 lookup key.
data CoordinateLookupKeyV2
  = CoordinateLookupKeyI32 Int32
  | CoordinateLookupKeyI64 Int64
  | CoordinateLookupKeyDictionaryCode Word64
  | CoordinateLookupKeyText CoordinateKeyDomainV2 String
  | CoordinateLookupKeyBytes CoordinateKeyDomainV2 [Word8] Int
  deriving (Eq, Show)

-- | Coordinate v2 lookup result copied from native-owned storage.
data CoordinateLookupResultV2 = CoordinateLookupResultV2
  { coordinateLookupStatus :: CoordinateLookupResultStatusV2
  , coordinateLookupStatusCategory :: CoordinateStatusCategoryV2
  , coordinateLookupUniquePosition :: Maybe Word32
  , coordinateLookupRange :: Maybe (Word32, Word32)
  , coordinateLookupPositions :: [Word32]
  , coordinateLookupAvailability :: CoordinateAvailabilityV2
  , coordinateLookupReason :: Maybe String
  }
  deriving (Eq, Show)

data CoordinateV2Options = CoordinateV2Options
  { coordinateAllowAuthoritativeScan :: Bool
  , coordinateIncludeDictionaryEntries :: Bool
  , coordinateIncludeIndexSummaries :: Bool
  , coordinateAllowExternalResolution :: Bool
  }
  deriving (Eq, Show)

defaultCoordinateV2Options :: CoordinateV2Options
defaultCoordinateV2Options = CoordinateV2Options False False False False

data CoordinateV2Values = CoordinateV2I32 [Int32] | CoordinateV2I64 [Int64] | CoordinateV2AppendSequenceValues CoordinateDType deriving (Eq, Show)

data AxisCoordinateInputV2 = AxisCoordinateInputV2
  { axisCoordinateInputV2Axis :: Int
  , axisCoordinateInputV2DescriptorId :: String
  , axisCoordinateInputV2Name :: String
  , axisCoordinateInputV2Kind :: CoordinateKind
  , axisCoordinateInputV2Values :: CoordinateV2Values
  , axisCoordinateInputV2Encoding :: CoordinateEncoding
  , axisCoordinateInputV2Sorted :: CoordinateSortedness
  , axisCoordinateInputV2Monotonicity :: CoordinateMonotonicity
  , axisCoordinateInputV2Uniqueness :: CoordinateUniqueness
  , axisCoordinateInputV2Required :: Bool
  }
  deriving (Eq, Show)

-- | Coordinate v2 values supplied for the append axis during a dense append.
data AppendCoordinateEntryV2 = AppendCoordinateEntryV2
  { appendCoordinateEntryAxis :: Int
  , appendCoordinateEntryDescriptorId :: String
  , appendCoordinateEntryName :: String
  , appendCoordinateEntryValues :: CoordinateV2Values
  , appendCoordinateEntryEncoding :: CoordinateEncoding
  }
  deriving (Eq, Show)

data AxisCoordinateMeta = AxisCoordinateMeta
  { axisCoordinateMetaAxis :: Int
  , axisCoordinateMetaAxisNameSnapshot :: Maybe String
  , axisCoordinateMetaName :: Maybe String
  , axisCoordinateMetaKind :: CoordinateKind
  , axisCoordinateMetaDType :: CoordinateDType
  , axisCoordinateMetaEncoding :: CoordinateEncoding
  , axisCoordinateMetaLength :: Word64
  , axisCoordinateMetaSorted :: CoordinateSortedness
  , axisCoordinateMetaMonotonicity :: CoordinateMonotonicity
  , axisCoordinateMetaUniqueness :: CoordinateUniqueness
  , axisCoordinateMetaStorageKind :: CoordinateStorageKind
  , axisCoordinateMetaExternalSourceKind :: CoordinateSourceKind
  , axisCoordinateMetaExternalUri :: Maybe String
  , axisCoordinateMetaRequired :: Bool
  , axisCoordinateMetaValidationStatus :: CoordinateValidationStatus
  }
  deriving (Eq, Show)

data CoordinateDictionarySummaryV2 = CoordinateDictionarySummaryV2
  { coordinateDictionarySummaryId :: Maybe String
  , coordinateDictionarySummaryRevision :: Word64
  , coordinateDictionarySummaryCodeDType :: CoordinateCodeDTypeV2
  , coordinateDictionarySummaryEntryCount :: Word64
  , coordinateDictionarySummaryStableIdsUnique :: Bool
  , coordinateDictionarySummaryDisplayLabelsUnique :: Bool
  , coordinateDictionarySummaryAliasesUnique :: Bool
  , coordinateDictionarySummaryCodesStableAcrossRevisions :: Bool
  , coordinateDictionarySummaryContentId :: Maybe String
  }
  deriving (Eq, Show)

data CoordinateExternalBindingV2 = CoordinateExternalBindingV2
  { coordinateExternalBindingSourceKind :: CoordinateSourceKind
  , coordinateExternalBindingLogicalId :: Maybe String
  , coordinateExternalBindingPrivacySafeDisplay :: Maybe String
  , coordinateExternalBindingContentId :: Maybe String
  , coordinateExternalBindingValueDomain :: CoordinateValueDomainV2
  , coordinateExternalBindingLength :: Word64
  , coordinateExternalBindingAvailability :: CoordinateAvailabilityV2
  , coordinateExternalBindingStatusCategory :: CoordinateStatusCategoryV2
  , coordinateExternalBindingRequired :: Bool
  }
  deriving (Eq, Show)

data CoordinateIndexSourceBindingV2 = CoordinateIndexSourceBindingV2
  { coordinateIndexSourceDescriptorId :: Maybe String
  , coordinateIndexSourceDescriptorRevision :: Word64
  , coordinateIndexSourceValueDomain :: CoordinateValueDomainV2
  , coordinateIndexSourceValueObjectId :: Maybe String
  , coordinateIndexSourceDictionaryId :: Maybe String
  , coordinateIndexSourceDictionaryRevision :: Word64
  , coordinateIndexSourceDictionaryContentId :: Maybe String
  , coordinateIndexSourceExternalSourceKind :: CoordinateSourceKind
  , coordinateIndexSourceExternalLogicalId :: Maybe String
  , coordinateIndexSourceExternalContentId :: Maybe String
  , coordinateIndexSourceRootId :: Maybe String
  , coordinateIndexSourceAxis :: Int
  , coordinateIndexSourceRootExtent :: Word64
  , coordinateIndexSourceAppendStart :: Word64
  , coordinateIndexSourceAppendCount :: Word64
  }
  deriving (Eq, Show)

data CoordinateIndexSummaryV2 = CoordinateIndexSummaryV2
  { coordinateIndexSummaryIndexId :: Maybe String
  , coordinateIndexSummaryIndexKindRaw :: Int32
  , coordinateIndexSummaryKeyDomainRaw :: Int32
  , coordinateIndexSummarySourceBinding :: CoordinateIndexSourceBindingV2
  , coordinateIndexSummarySorted :: CoordinateSortedness
  , coordinateIndexSummaryMonotonicity :: CoordinateMonotonicity
  , coordinateIndexSummaryUniqueness :: CoordinateUniqueness
  , coordinateIndexSummaryFormatVersion :: Word32
  , coordinateIndexSummaryBuildVersion :: Word32
  , coordinateIndexSummaryValidationStatusRaw :: Int32
  , coordinateIndexSummaryFallbackRaw :: Int32
  , coordinateIndexSummarySelectedUseRaw :: Int32
  , coordinateIndexSummaryRequired :: Bool
  , coordinateIndexSummaryReason :: Maybe String
  }
  deriving (Eq, Show)

data AxisCoordinateMetaV2 = AxisCoordinateMetaV2
  { axisCoordinateMetaV2Axis :: Int
  , axisCoordinateMetaV2AxisNameSnapshot :: Maybe String
  , axisCoordinateMetaV2DescriptorId :: Maybe String
  , axisCoordinateMetaV2DescriptorRevision :: Word64
  , axisCoordinateMetaV2Name :: Maybe String
  , axisCoordinateMetaV2Kind :: CoordinateKind
  , axisCoordinateMetaV2ValueDomain :: CoordinateValueDomainV2
  , axisCoordinateMetaV2NumericDType :: CoordinateDType
  , axisCoordinateMetaV2NumericEncoding :: CoordinateEncoding
  , axisCoordinateMetaV2CodeDType :: CoordinateCodeDTypeV2
  , axisCoordinateMetaV2Length :: Word64
  , axisCoordinateMetaV2Sorted :: CoordinateSortedness
  , axisCoordinateMetaV2Monotonicity :: CoordinateMonotonicity
  , axisCoordinateMetaV2Uniqueness :: CoordinateUniqueness
  , axisCoordinateMetaV2Required :: Bool
  , axisCoordinateMetaV2Availability :: CoordinateAvailabilityV2
  , axisCoordinateMetaV2StatusCategory :: CoordinateStatusCategoryV2
  , axisCoordinateMetaV2Reason :: Maybe String
  , axisCoordinateMetaV2Dictionary :: CoordinateDictionarySummaryV2
  , axisCoordinateMetaV2ExternalBinding :: CoordinateExternalBindingV2
  , axisCoordinateMetaV2IndexSummaries :: [CoordinateIndexSummaryV2]
  }
  deriving (Eq, Show)

data CoordinateValueSliceV2 = CoordinateValueSliceV2
  { coordinateValueSliceDomain :: CoordinateValueDomainV2
  , coordinateValueSliceNumericDType :: CoordinateDType
  , coordinateValueSliceNumericEncoding :: CoordinateEncoding
  , coordinateValueSliceCodeDType :: CoordinateCodeDTypeV2
  , coordinateValueSliceBytes :: [Word8]
  , coordinateValueSliceLen :: Int
  , coordinateValueSliceElementSize :: Int
  , coordinateValueSliceFixedTextWidth :: Int
  , coordinateValueSliceAvailability :: CoordinateAvailabilityV2
  , coordinateValueSliceStatusCategory :: CoordinateStatusCategoryV2
  , coordinateValueSliceReason :: Maybe String
  }
  deriving (Eq, Show)

data CoordinateDictionaryEntryV2 = CoordinateDictionaryEntryV2
  { coordinateDictionaryEntryCode :: Word64
  , coordinateDictionaryEntryStableId :: Maybe String
  , coordinateDictionaryEntryDisplayLabel :: Maybe String
  , coordinateDictionaryEntryAliases :: [String]
  }
  deriving (Eq, Show)

data CoordinateDictionaryV2 = CoordinateDictionaryV2
  { coordinateDictionarySummary :: CoordinateDictionarySummaryV2
  , coordinateDictionaryEntries :: [CoordinateDictionaryEntryV2]
  , coordinateDictionaryStatusCategory :: CoordinateStatusCategoryV2
  , coordinateDictionaryReason :: Maybe String
  }
  deriving (Eq, Show)
