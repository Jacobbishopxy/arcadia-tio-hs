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
  , CArcadiaTioChunkPlan(..)
  , emptyCArcadiaTioChunkPlan
  , CArcadiaTioCommitInfo(..)
  , CArcadiaTioCommitList(..)
  , emptyCArcadiaTioCommitList
  , CArcadiaTioCompactionMode(..)
  , CArcadiaTioCompactionStats(..)
  , CArcadiaTioAutoCompactionConfig(..)
  , CArcadiaTioCompactionState(..)
  , CArcadiaTioSparseValuePredicateV2(..)
  , CArcadiaTioSparseRuleV2(..)
  , sparseRuleV2StructSize
  , CArcadiaTioSparseAppendAnalysis(..)
  , emptyCArcadiaTioSparseAppendAnalysis
  , CArcadiaTioOcbMetadata(..)
  , emptyCArcadiaTioOcbMetadata
  , capiCreateStreaming
  , capiCreateStreamingEx
  , capiCreateRandomAccess
  , capiCreateRandomAccessEx
  , capiCreateInferred
  , capiCreateInferredEx
  , capiCreateWithPolicy
  , capiCreateWithPolicyEx
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
  , capiAnalyzeCompaction
  , capiCompactTo
  , capiMaybeCompact
  , capiGetAutoCompactionConfig
  , capiSetAutoCompactionConfig
  , capiCompactionState
  , capiMaybeCompactAuto
  , capiAnalyzeSparseAppendF32V2
  , capiAnalyzeSparseAppendF64V2
  , capiAnalyzeSparseAppendI32V2
  , capiAnalyzeSparseAppendI64V2
  , capiAppendSparseF32WithRangeV2
  , capiAppendSparseF64WithRangeV2
  , capiAppendSparseI32WithRangeV2
  , capiAppendSparseI64WithRangeV2
  , capiSparseAppendAnalysisFree
  , capiOcbOpen
  , capiOcbClose
  , capiOcbMetadata
  , capiOcbMetadataFree
  , capiTensorFree
  , capiMaskFree
  , capiFileMetaFree
  , okStatus
  ) where

import Control.Exception (SomeException, displayException, try)
import Data.Int (Int32, Int64)
import Data.Word (Word8, Word32, Word64)
import Foreign.C.String (CString, peekCString)
import Foreign.C.Types (CFloat, CInt(..), CSize(..))
import Foreign.Ptr (FunPtr, Ptr, nullPtr)
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
  , cOcbMetadataColumns :: Ptr ()
  , cOcbMetadataColumnsLen :: CSize
  , cOcbMetadataDictionaries :: Ptr ()
  , cOcbMetadataDictionariesLen :: CSize
  , cOcbMetadataOrderingKeys :: Ptr ()
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

type LastErrorMessageFn = IO CString
type LastErrorCodeFn = IO CInt
type AbiVersionFn = IO Word32
type CreateStreamingFn = CString -> CInt -> Ptr CInt -> Ptr Word32 -> CSize -> CSize -> IO (Ptr CHandle)
type CreateRandomAccessFn = CString -> CInt -> Ptr CInt -> Ptr Word32 -> CSize -> CSize -> IO (Ptr CHandle)
type CreateExFn = CString -> CInt -> Ptr CInt -> Ptr Word32 -> CSize -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> Ptr CString -> CSize -> IO (Ptr CHandle)
type CreateInferredFn = CString -> CInt -> Ptr CInt -> Ptr Word32 -> CSize -> CSize -> CInt -> CInt -> CInt -> CInt -> IO (Ptr CHandle)
type CreateInferredExFn = CString -> CInt -> Ptr CInt -> Ptr Word32 -> CSize -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> Ptr CString -> CSize -> CInt -> CInt -> CInt -> CInt -> IO (Ptr CHandle)
type CreateWithPolicyFn = CString -> CInt -> Ptr CInt -> Ptr Word32 -> CSize -> CSize -> Ptr CSize -> CSize -> CInt -> Ptr Word32 -> CSize -> IO (Ptr CHandle)
type CreateWithPolicyExFn = CString -> CInt -> Ptr CInt -> Ptr Word32 -> CSize -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> CSize -> Ptr CString -> Ptr CString -> CSize -> Ptr CSize -> CSize -> CInt -> Ptr Word32 -> CSize -> IO (Ptr CHandle)
type OpenFn = CString -> IO (Ptr CHandle)
type CloseFn = Ptr CHandle -> IO ()
type AppendF32WithRangeFn = Ptr CHandle -> Ptr CFloat -> Ptr Word64 -> CSize -> Ptr Word32 -> Ptr Word32 -> IO CInt
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
type AnalyzeCompactionFn = Ptr CHandle -> Ptr CArcadiaTioCompactionStats -> IO CInt
type CompactToFn = Ptr CHandle -> CString -> Word32 -> Word64 -> IO CInt
type MaybeCompactFn = Ptr CHandle -> CString -> Double -> Word64 -> Word32 -> Word64 -> Ptr Word8 -> IO CInt
type GetAutoCompactionConfigFn = Ptr CHandle -> Ptr CArcadiaTioAutoCompactionConfig -> Ptr Word8 -> IO CInt
type SetAutoCompactionConfigFn = Ptr CHandle -> Ptr CArcadiaTioAutoCompactionConfig -> Word8 -> IO CInt
type CompactionStateFn = Ptr CHandle -> Ptr CArcadiaTioCompactionState -> Ptr Word8 -> IO CInt
type MaybeCompactAutoFn = Ptr CHandle -> Ptr Word8 -> IO CInt
type AnalyzeSparseAppendV2Fn a = Ptr CHandle -> Ptr a -> Ptr Word64 -> CSize -> Ptr CArcadiaTioSparseRuleV2 -> Ptr CArcadiaTioSparseAppendAnalysis -> IO CInt
type AppendSparseWithRangeV2Fn a = Ptr CHandle -> Ptr a -> Ptr Word64 -> CSize -> Ptr CArcadiaTioSparseRuleV2 -> Ptr Word32 -> Ptr Word32 -> IO CInt
type SparseAppendAnalysisFreeFn = Ptr CArcadiaTioSparseAppendAnalysis -> IO ()
type OcbOpenFn = CString -> IO (Ptr COcbFile)
type OcbCloseFn = Ptr COcbFile -> IO ()
type OcbMetadataFn = Ptr COcbFile -> Ptr CArcadiaTioOcbMetadata -> IO CInt
type OcbMetadataFreeFn = Ptr CArcadiaTioOcbMetadata -> IO ()
type TensorFreeFn = Ptr CArcadiaTioTensor -> IO ()
type MaskFreeFn = Ptr CArcadiaTioMask -> IO ()
type FileMetaFreeFn = Ptr CArcadiaTioFileMeta -> IO ()

foreign import ccall safe "dynamic" mkLastErrorMessage :: FunPtr LastErrorMessageFn -> LastErrorMessageFn
foreign import ccall safe "dynamic" mkLastErrorCode :: FunPtr LastErrorCodeFn -> LastErrorCodeFn
foreign import ccall safe "dynamic" mkAbiVersion :: FunPtr AbiVersionFn -> AbiVersionFn
foreign import ccall safe "dynamic" mkCreateStreaming :: FunPtr CreateStreamingFn -> CreateStreamingFn
foreign import ccall safe "dynamic" mkCreateRandomAccess :: FunPtr CreateRandomAccessFn -> CreateRandomAccessFn
foreign import ccall safe "dynamic" mkCreateEx :: FunPtr CreateExFn -> CreateExFn
foreign import ccall safe "dynamic" mkCreateInferred :: FunPtr CreateInferredFn -> CreateInferredFn
foreign import ccall safe "dynamic" mkCreateInferredEx :: FunPtr CreateInferredExFn -> CreateInferredExFn
foreign import ccall safe "dynamic" mkCreateWithPolicy :: FunPtr CreateWithPolicyFn -> CreateWithPolicyFn
foreign import ccall safe "dynamic" mkCreateWithPolicyEx :: FunPtr CreateWithPolicyExFn -> CreateWithPolicyExFn
foreign import ccall safe "dynamic" mkOpen :: FunPtr OpenFn -> OpenFn
foreign import ccall safe "dynamic" mkClose :: FunPtr CloseFn -> CloseFn
foreign import ccall safe "dynamic" mkAppendF32WithRange :: FunPtr AppendF32WithRangeFn -> AppendF32WithRangeFn
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
foreign import ccall safe "dynamic" mkAnalyzeCompaction :: FunPtr AnalyzeCompactionFn -> AnalyzeCompactionFn
foreign import ccall safe "dynamic" mkCompactTo :: FunPtr CompactToFn -> CompactToFn
foreign import ccall safe "dynamic" mkMaybeCompact :: FunPtr MaybeCompactFn -> MaybeCompactFn
foreign import ccall safe "dynamic" mkGetAutoCompactionConfig :: FunPtr GetAutoCompactionConfigFn -> GetAutoCompactionConfigFn
foreign import ccall safe "dynamic" mkSetAutoCompactionConfig :: FunPtr SetAutoCompactionConfigFn -> SetAutoCompactionConfigFn
foreign import ccall safe "dynamic" mkCompactionState :: FunPtr CompactionStateFn -> CompactionStateFn
foreign import ccall safe "dynamic" mkMaybeCompactAuto :: FunPtr MaybeCompactAutoFn -> MaybeCompactAutoFn
foreign import ccall safe "dynamic" mkAnalyzeSparseAppendF32V2 :: FunPtr (AnalyzeSparseAppendV2Fn CFloat) -> AnalyzeSparseAppendV2Fn CFloat
foreign import ccall safe "dynamic" mkAnalyzeSparseAppendF64V2 :: FunPtr (AnalyzeSparseAppendV2Fn Double) -> AnalyzeSparseAppendV2Fn Double
foreign import ccall safe "dynamic" mkAnalyzeSparseAppendI32V2 :: FunPtr (AnalyzeSparseAppendV2Fn Int32) -> AnalyzeSparseAppendV2Fn Int32
foreign import ccall safe "dynamic" mkAnalyzeSparseAppendI64V2 :: FunPtr (AnalyzeSparseAppendV2Fn Int64) -> AnalyzeSparseAppendV2Fn Int64
foreign import ccall safe "dynamic" mkAppendSparseF32WithRangeV2 :: FunPtr (AppendSparseWithRangeV2Fn CFloat) -> AppendSparseWithRangeV2Fn CFloat
foreign import ccall safe "dynamic" mkAppendSparseF64WithRangeV2 :: FunPtr (AppendSparseWithRangeV2Fn Double) -> AppendSparseWithRangeV2Fn Double
foreign import ccall safe "dynamic" mkAppendSparseI32WithRangeV2 :: FunPtr (AppendSparseWithRangeV2Fn Int32) -> AppendSparseWithRangeV2Fn Int32
foreign import ccall safe "dynamic" mkAppendSparseI64WithRangeV2 :: FunPtr (AppendSparseWithRangeV2Fn Int64) -> AppendSparseWithRangeV2Fn Int64
foreign import ccall safe "dynamic" mkSparseAppendAnalysisFree :: FunPtr SparseAppendAnalysisFreeFn -> SparseAppendAnalysisFreeFn
foreign import ccall safe "dynamic" mkOcbOpen :: FunPtr OcbOpenFn -> OcbOpenFn
foreign import ccall safe "dynamic" mkOcbClose :: FunPtr OcbCloseFn -> OcbCloseFn
foreign import ccall safe "dynamic" mkOcbMetadata :: FunPtr OcbMetadataFn -> OcbMetadataFn
foreign import ccall safe "dynamic" mkOcbMetadataFree :: FunPtr OcbMetadataFreeFn -> OcbMetadataFreeFn
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
  , nativeCreateInferred :: CreateInferredFn
  , nativeCreateInferredEx :: CreateInferredExFn
  , nativeCreateWithPolicy :: CreateWithPolicyFn
  , nativeCreateWithPolicyEx :: CreateWithPolicyExFn
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
  , nativeAnalyzeCompaction :: AnalyzeCompactionFn
  , nativeCompactTo :: CompactToFn
  , nativeMaybeCompact :: MaybeCompactFn
  , nativeGetAutoCompactionConfig :: GetAutoCompactionConfigFn
  , nativeSetAutoCompactionConfig :: SetAutoCompactionConfigFn
  , nativeCompactionState :: CompactionStateFn
  , nativeMaybeCompactAuto :: MaybeCompactAutoFn
  , nativeAnalyzeSparseAppendF32V2 :: AnalyzeSparseAppendV2Fn CFloat
  , nativeAnalyzeSparseAppendF64V2 :: AnalyzeSparseAppendV2Fn Double
  , nativeAnalyzeSparseAppendI32V2 :: AnalyzeSparseAppendV2Fn Int32
  , nativeAnalyzeSparseAppendI64V2 :: AnalyzeSparseAppendV2Fn Int64
  , nativeAppendSparseF32WithRangeV2 :: AppendSparseWithRangeV2Fn CFloat
  , nativeAppendSparseF64WithRangeV2 :: AppendSparseWithRangeV2Fn Double
  , nativeAppendSparseI32WithRangeV2 :: AppendSparseWithRangeV2Fn Int32
  , nativeAppendSparseI64WithRangeV2 :: AppendSparseWithRangeV2Fn Int64
  , nativeSparseAppendAnalysisFree :: SparseAppendAnalysisFreeFn
  , nativeOcbOpen :: OcbOpenFn
  , nativeOcbClose :: OcbCloseFn
  , nativeOcbMetadata :: OcbMetadataFn
  , nativeOcbMetadataFree :: OcbMetadataFreeFn
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
  nativeCreateInferred <- mkCreateInferred <$> dlsym dl "arcadia_tio_create_inferred"
  nativeCreateInferredEx <- mkCreateInferredEx <$> dlsym dl "arcadia_tio_create_inferred_ex"
  nativeCreateWithPolicy <- mkCreateWithPolicy <$> dlsym dl "arcadia_tio_create_with_policy"
  nativeCreateWithPolicyEx <- mkCreateWithPolicyEx <$> dlsym dl "arcadia_tio_create_with_policy_ex"
  nativeOpen <- mkOpen <$> dlsym dl "arcadia_tio_open"
  nativeClose <- mkClose <$> dlsym dl "arcadia_tio_close"
  nativeAppendF32WithRange <- mkAppendF32WithRange <$> dlsym dl "arcadia_tio_append_f32_with_range"
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
  nativeAnalyzeCompaction <- mkAnalyzeCompaction <$> dlsym dl "arcadia_tio_analyze_compaction"
  nativeCompactTo <- mkCompactTo <$> dlsym dl "arcadia_tio_compact_to"
  nativeMaybeCompact <- mkMaybeCompact <$> dlsym dl "arcadia_tio_maybe_compact"
  nativeGetAutoCompactionConfig <- mkGetAutoCompactionConfig <$> dlsym dl "arcadia_tio_get_auto_compaction_config"
  nativeSetAutoCompactionConfig <- mkSetAutoCompactionConfig <$> dlsym dl "arcadia_tio_set_auto_compaction_config"
  nativeCompactionState <- mkCompactionState <$> dlsym dl "arcadia_tio_compaction_state"
  nativeMaybeCompactAuto <- mkMaybeCompactAuto <$> dlsym dl "arcadia_tio_maybe_compact_auto"
  nativeAnalyzeSparseAppendF32V2 <- mkAnalyzeSparseAppendF32V2 <$> dlsym dl "arcadia_tio_analyze_sparse_append_f32_v2"
  nativeAnalyzeSparseAppendF64V2 <- mkAnalyzeSparseAppendF64V2 <$> dlsym dl "arcadia_tio_analyze_sparse_append_f64_v2"
  nativeAnalyzeSparseAppendI32V2 <- mkAnalyzeSparseAppendI32V2 <$> dlsym dl "arcadia_tio_analyze_sparse_append_i32_v2"
  nativeAnalyzeSparseAppendI64V2 <- mkAnalyzeSparseAppendI64V2 <$> dlsym dl "arcadia_tio_analyze_sparse_append_i64_v2"
  nativeAppendSparseF32WithRangeV2 <- mkAppendSparseF32WithRangeV2 <$> dlsym dl "arcadia_tio_append_sparse_f32_with_range_v2"
  nativeAppendSparseF64WithRangeV2 <- mkAppendSparseF64WithRangeV2 <$> dlsym dl "arcadia_tio_append_sparse_f64_with_range_v2"
  nativeAppendSparseI32WithRangeV2 <- mkAppendSparseI32WithRangeV2 <$> dlsym dl "arcadia_tio_append_sparse_i32_with_range_v2"
  nativeAppendSparseI64WithRangeV2 <- mkAppendSparseI64WithRangeV2 <$> dlsym dl "arcadia_tio_append_sparse_i64_with_range_v2"
  nativeSparseAppendAnalysisFree <- mkSparseAppendAnalysisFree <$> dlsym dl "arcadia_tio_sparse_append_analysis_free"
  nativeOcbOpen <- mkOcbOpen <$> dlsym dl "arcadia_tio_ocb_open"
  nativeOcbClose <- mkOcbClose <$> dlsym dl "arcadia_tio_ocb_close"
  nativeOcbMetadata <- mkOcbMetadata <$> dlsym dl "arcadia_tio_ocb_metadata"
  nativeOcbMetadataFree <- mkOcbMetadataFree <$> dlsym dl "arcadia_tio_ocb_metadata_free"
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
      , nativeCreateInferred
      , nativeCreateInferredEx
      , nativeCreateWithPolicy
      , nativeCreateWithPolicyEx
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
      , nativeAnalyzeCompaction
      , nativeCompactTo
      , nativeMaybeCompact
      , nativeGetAutoCompactionConfig
      , nativeSetAutoCompactionConfig
      , nativeCompactionState
      , nativeMaybeCompactAuto
      , nativeAnalyzeSparseAppendF32V2
      , nativeAnalyzeSparseAppendF64V2
      , nativeAnalyzeSparseAppendI32V2
      , nativeAnalyzeSparseAppendI64V2
      , nativeAppendSparseF32WithRangeV2
      , nativeAppendSparseF64WithRangeV2
      , nativeAppendSparseI32WithRangeV2
      , nativeAppendSparseI64WithRangeV2
      , nativeSparseAppendAnalysisFree
      , nativeOcbOpen
      , nativeOcbClose
      , nativeOcbMetadata
      , nativeOcbMetadataFree
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

capiCreateInferred :: NativeLibrary -> CreateInferredFn
capiCreateInferred NativeLibrary{nativeCreateInferred} = nativeCreateInferred

capiCreateInferredEx :: NativeLibrary -> CreateInferredExFn
capiCreateInferredEx NativeLibrary{nativeCreateInferredEx} = nativeCreateInferredEx

capiCreateWithPolicy :: NativeLibrary -> CreateWithPolicyFn
capiCreateWithPolicy NativeLibrary{nativeCreateWithPolicy} = nativeCreateWithPolicy

capiCreateWithPolicyEx :: NativeLibrary -> CreateWithPolicyExFn
capiCreateWithPolicyEx NativeLibrary{nativeCreateWithPolicyEx} = nativeCreateWithPolicyEx

capiOpen :: NativeLibrary -> OpenFn
capiOpen NativeLibrary{nativeOpen} = nativeOpen

capiClose :: NativeLibrary -> CloseFn
capiClose NativeLibrary{nativeClose} = nativeClose

capiAppendF32WithRange :: NativeLibrary -> AppendF32WithRangeFn
capiAppendF32WithRange NativeLibrary{nativeAppendF32WithRange} = nativeAppendF32WithRange

capiAppendF64WithRange :: NativeLibrary -> AppendF64WithRangeFn
capiAppendF64WithRange NativeLibrary{nativeAppendF64WithRange} = nativeAppendF64WithRange

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

capiOcbOpen :: NativeLibrary -> OcbOpenFn
capiOcbOpen NativeLibrary{nativeOcbOpen} = nativeOcbOpen

capiOcbClose :: NativeLibrary -> OcbCloseFn
capiOcbClose NativeLibrary{nativeOcbClose} = nativeOcbClose

capiOcbMetadata :: NativeLibrary -> OcbMetadataFn
capiOcbMetadata NativeLibrary{nativeOcbMetadata} = nativeOcbMetadata

capiOcbMetadataFree :: NativeLibrary -> OcbMetadataFreeFn
capiOcbMetadataFree NativeLibrary{nativeOcbMetadataFree} = nativeOcbMetadataFree

capiTensorFree :: NativeLibrary -> TensorFreeFn
capiTensorFree NativeLibrary{nativeTensorFree} = nativeTensorFree

capiMaskFree :: NativeLibrary -> MaskFreeFn
capiMaskFree NativeLibrary{nativeMaskFree} = nativeMaskFree

capiFileMetaFree :: NativeLibrary -> FileMetaFreeFn
capiFileMetaFree NativeLibrary{nativeFileMetaFree} = nativeFileMetaFree

_keepNativeLibraryHandleAlive :: NativeLibrary -> DL
_keepNativeLibraryHandleAlive = nativeLibraryHandle
