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
  ) where

import Data.Int (Int32, Int64)
import Data.Word (Word32, Word64)
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
data ReadShapePolicy
  = ReadShapeFileEnvelope
  | ReadShapeCurrentHead
  | ReadShapeUnion
  | ReadShapeIntersection
  | ReadShapeInitialRegistered
  | ReadShapeExplicitExtents [Word64]
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
