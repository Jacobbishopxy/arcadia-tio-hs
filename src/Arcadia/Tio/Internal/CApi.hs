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
  , cAxisIdentityInputMode :: CInt
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
  , cReadShapePolicyPolicy :: CInt
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
  , cReadOptionsMode :: CInt
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
  , cShapeReadOptionsMode :: CInt
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
  , cReadReportRequestedMode :: CInt
  , cReadReportQueryMaxThreads :: CSize
  , cReadReportQueryEffectiveMode :: CInt
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
  { cReadIndexItemKind :: CInt
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
  , cReadIndexReportLoweringKind :: CInt
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
  , cHistoricalReadReportQuerySourceKind :: CInt
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
