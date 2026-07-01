module Main (main) where

import Control.Exception (finally)
import Control.Monad (unless)
import Data.Int (Int32, Int64)
import Data.Bits ((.|.), shiftL)
import Data.IORef (modifyIORef', newIORef, readIORef)
import Data.Word (Word8, Word64)
import qualified Data.Vector.Storable as VS
import Foreign.Marshal.Alloc (alloca)
import Foreign.Marshal.Array (withArray)
import Foreign.Ptr (nullPtr)
import Foreign.Storable (peek, poke, sizeOf)
import System.Directory (createDirectoryIfMissing, doesFileExist, getCurrentDirectory, removeFile)
import System.Environment (lookupEnv)
import System.Exit (exitFailure, exitSuccess)
import System.FilePath ((</>), takeDirectory)
import System.IO (IOMode(..), hPutStr, withBinaryFile)

import Arcadia.Tio
import qualified Arcadia.Tio.Internal.CApi as C
import qualified Arcadia.Tio.Ocb as Ocb

main :: IO ()
main = do
  testOcbWriteValidationPure
  testOcbEnumConversionsPure
  testCoordinateEnumConversionsPure
  testNonOcbEnumPolicyConversionsPure
  configured <- nativeLibraryConfigured
  unless configured $ do
    putStrLn "SKIP: ARCADIA_TIO_CAPI_LIB or ARCADIA_TIO_CAPI_LIB_DIR is not set"
    exitSuccess

  native <- unwrap "loadNativeLibrary" =<< loadNativeLibrary
  createDirectoryIfMissing True ".test-output"

  testTensorStructuralOps native
  testStreamingF64MetadataSelectorsDense native
  testReadOptionsReportsIndex native
  testMutationAndArrow native
  testStreamingF32 native
  testStreamingI32 native
  testStreamingI64 native
  testRandomAccessF64 native
  testSparseAppend native
  testCompactionHelpers native
  testReformHelpers native
  testDetailedDiagnostics native
  testInferredAndPolicyCreate native
  testMetadataRichCreateSettersAndScalar native
  testCoordinateMetadataValueReads native
  testCoordinateCreateValidationAndVariants native
  testAppendAxisCoordinateBatches native
  testUniverseAuthoringAndReads native
  testOcbReadBatchesAndAttribution native
  testOcbCreateAppendSmoke native
  testOcbRowGroupFill native
  testOcbVisitBatches native

  putStrLn "PASS: dense .tio lifecycle/read parity smoke through libarcadia_tio_capi.so"


testCoordinateEnumConversionsPure :: IO ()
testCoordinateEnumConversionsPure = do
  assertEqual "coordinate dtype i64 raw" CoordinateI64 (coordinateDTypeFromRaw 1)
  assertEqual "coordinate dtype unknown preserved" 99 (coordinateDTypeToRaw (coordinateDTypeFromRaw 99))
  assertEqual "coordinate kind domain raw" 4 (coordinateKindToRaw CoordinateDomainValue)
  assertEqual "coordinate encoding epoch ns raw" 6 (coordinateEncodingToRaw CoordinateEncodingEpochNanoseconds)
  assertEqual "coordinate sortedness unknown preserved" 42 (coordinateSortednessToRaw (coordinateSortednessFromRaw 42))
  assertEqual "coordinate monotonicity non-increasing raw" 3 (coordinateMonotonicityToRaw CoordinateNonIncreasing)
  assertEqual "coordinate uniqueness duplicate raw" 2 (coordinateUniquenessToRaw CoordinateHasDuplicates)
  assertEqual "coordinate storage external raw" 1 (coordinateStorageKindToRaw CoordinateStorageExternal)
  assertEqual "coordinate source v1 unknown preserved" 4 (coordinateSourceKindToRaw (coordinateSourceKindFromRaw 4))
  assertEqual "coordinate validation unvalidated raw" 1 (coordinateValidationStatusToRaw CoordinateUnvalidated)
  assertEqual "coordinate value domain append raw" 3 (coordinateValueDomainV2ToRaw CoordinateV2AppendSequence)
  assertEqual "coordinate availability unsupported raw" 5 (coordinateAvailabilityV2ToRaw CoordinateUnsupportedV2)
  assertEqual "coordinate status unsupported index raw" 10 (coordinateStatusCategoryV2ToRaw CoordinateStatusUnsupportedIndexV2)
  assertEqual "coordinate code dtype u64 raw" 3 (coordinateCodeDTypeV2ToRaw CoordinateCodeU64)
  assertEqual "coordinate fixed text encoding ascii raw" 0 (coordinateFixedTextEncodingV2ToRaw CoordinateFixedTextAsciiV2)
  assertEqual "coordinate fixed text padding right-space raw" 0 (coordinateFixedTextPaddingV2ToRaw CoordinateFixedTextRightSpaceV2)
  assertEqual "coordinate source v2 application registry raw" 4 (coordinateSourceKindV2ToRaw CoordinateSourceV2ApplicationRegistry)
  assertEqual "coordinate index kind dictionary raw" 2 (coordinateIndexKindV2ToRaw CoordinateIndexDictionaryKeyV2)
  assertEqual "coordinate index status unsupported raw" 4 (coordinateIndexValidationStatusV2ToRaw CoordinateIndexUnsupportedV2)
  assertEqual "coordinate index fallback reject raw" 2 (coordinateIndexFallbackV2ToRaw CoordinateIndexFallbackRejectIndexDependentOperationV2)
  assertEqual "coordinate index use unavailable raw" 3 (coordinateIndexUseV2ToRaw CoordinateIndexUseUnavailableV2)
  assertEqual "coordinate key domain raw-time raw" 7 (coordinateKeyDomainV2ToRaw CoordinateKeyRawTime)
  assertEqual "coordinate lookup error raw" 7 (coordinateLookupResultStatusV2ToRaw CoordinateLookupErrorV2)
  assertEqual "coordinate index use future raw preserved" 123 (coordinateIndexUseV2ToRaw (coordinateIndexUseV2FromRaw 123))

testOcbEnumConversionsPure :: IO ()
testOcbEnumConversionsPure = do
  assertEqual "OCB open validation full payload raw" 1 (Ocb.ocbOpenValidationToRaw Ocb.OcbOpenValidationFullPayload)
  assertEqual "OCB open validation unknown preserved" 42 (Ocb.ocbOpenValidationToRaw (Ocb.ocbOpenValidationFromRaw 42))
  assertEqual "OCB error IO raw" 5 (Ocb.ocbErrorKindToRaw Ocb.OcbErrorKindIo)
  assertEqual "OCB error unknown preserved" 43 (Ocb.ocbErrorKindToRaw (Ocb.ocbErrorKindFromRaw 43))
  assertEqual "OCB failure corrupt raw" 3 (Ocb.ocbFailureCauseToRaw Ocb.OcbFailureCauseCorruptFile)
  assertEqual "OCB failure unknown preserved" 44 (Ocb.ocbFailureCauseToRaw (Ocb.ocbFailureCauseFromRaw 44))
  assertEqual "OCB physical fixed-binary raw" 4 (Ocb.ocbPhysicalTypeToRaw Ocb.OcbPhysicalFixedBinary)
  assertEqual "OCB physical unknown preserved" 45 (Ocb.ocbPhysicalTypeToRaw (Ocb.ocbPhysicalTypeFromRaw 45))
  assertEqual "OCB logical opaque key raw" 5 (Ocb.ocbLogicalKindToRaw Ocb.OcbLogicalOpaqueKey)
  assertEqual "OCB logical unknown preserved" 46 (Ocb.ocbLogicalKindToRaw (Ocb.ocbLogicalKindFromRaw 46))
  assertEqual "OCB dictionary enum labels raw" 3 (Ocb.ocbDictionaryValueKindToRaw Ocb.OcbDictionaryEnumLabels)
  assertEqual "OCB dictionary unknown preserved" 47 (Ocb.ocbDictionaryValueKindToRaw (Ocb.ocbDictionaryValueKindFromRaw 47))
  assertEqual "OCB ordering descending raw" 1 (Ocb.ocbOrderingDirectionToRaw Ocb.OcbOrderingDescending)
  assertEqual "OCB ordering unknown preserved" 48 (Ocb.ocbOrderingDirectionToRaw (Ocb.ocbOrderingDirectionFromRaw 48))
  assertEqual "OCB null order no-null raw" 2 (Ocb.ocbNullOrderToRaw Ocb.OcbNoNulls)
  assertEqual "OCB null order unknown preserved" 49 (Ocb.ocbNullOrderToRaw (Ocb.ocbNullOrderFromRaw 49))
  assertEqual "OCB projection names raw" 1 (Ocb.ocbProjectionKindToRaw Ocb.OcbProjectionKindNames)
  assertEqual "OCB projection unknown preserved" 50 (Ocb.ocbProjectionKindToRaw (Ocb.ocbProjectionKindFromRaw 50))
  assertEqual "OCB body row-group delta raw" 12 (Ocb.ocbBodyKindToRaw Ocb.OcbBodyRowGroupIndexDelta)
  assertEqual "OCB body unknown preserved" 51 (Ocb.ocbBodyKindToRaw (Ocb.ocbBodyKindFromRaw 51))
  assertEqual "OCB checksum crc32c raw" 1 (Ocb.ocbChecksumKindToRaw Ocb.OcbChecksumCrc32c)
  assertEqual "OCB checksum unknown preserved" 52 (Ocb.ocbChecksumKindToRaw (Ocb.ocbChecksumKindFromRaw 52))
  assertEqual "OCB chunk summary zstd raw" 1 (Ocb.ocbChunkSummaryCodecToRaw Ocb.OcbChunkSummaryCodecZstd)
  assertEqual "OCB chunk summary unknown preserved" 53 (Ocb.ocbChunkSummaryCodecToRaw (Ocb.ocbChunkSummaryCodecFromRaw 53))
  assertEqual "OCB write chunk none raw" 0 (Ocb.ocbWriteChunkCodecToRaw Ocb.OcbWriteChunkCodecNone)
  assertEqual "OCB write chunk unknown preserved" 54 (Ocb.ocbWriteChunkCodecToRaw (Ocb.ocbWriteChunkCodecFromRaw 54))

testNonOcbEnumPolicyConversionsPure :: IO ()
testNonOcbEnumPolicyConversionsPure = do
  assertEqual "axis identity universe-aware raw" 1 (axisIdentityModeToRaw AxisIdentityUniverseAware)
  assertEqual "axis identity unknown raw" Nothing (axisIdentityModeFromRaw 7)
  assertEqual "read execution parallel raw" 1 (readExecutionModeToRaw ReadParallelThreads)
  assertEqual "read execution serial from raw" (Just ReadSerial) (readExecutionModeFromRaw 0)
  assertEqual "read shape explicit universe/extents raw" 7 (readShapePolicyTagToRaw (readShapePolicyTag (ReadShapeExplicitUniverseAndExtents [] [])))
  assertEqual "read shape invalid raw" Nothing (readShapePolicyTagFromRaw 99)
  assertEqual "read-index slice raw" 1 (readIndexItemTagToRaw (readIndexItemTag (ReadIndexSlice (Just 1) Nothing 1)))
  assertEqual "read-index lowering postprocess raw" 2 (readIndexLoweringKindToRaw ReadIndexLoweringSelectorReadWithShapePostprocess)
  assertEqual "historical retained commit raw" 0 (historicalQuerySourceKindToRaw HistoricalQueryRetainedVisibleCommit)
  assertEqual "reform regular tag raw" 2 (reformTargetLayoutTagToRaw (reformTargetLayoutTag (ReformRegularChunked [1, 1])))
  assertEqual "v4 status unknown preserved" 42 (v4ReportStatusToRaw (v4ReportStatusFromRaw 42))
  assertEqual "v4 precise reclaimable raw" 3 (v4PreciseAccountingFieldToRaw V4PreciseReclaimableBytes)
  assertEqual "v4 compaction policy unknown preserved" 5 (v4CompactionAnalysisPolicyToRaw (v4CompactionAnalysisPolicyFromRaw 5))
  assertEqual "v4 retained history policy raw" 0 (v4RetainedHistoryPolicyToRaw V4RetainLast)


testTensorStructuralOps :: NativeLibrary -> IO ()
testTensorStructuralOps native = do
  let base = Tensor [2, 3] (VS.fromList [1.0, 2.0, 3.0, 4.0, 5.0, 6.0] :: VS.Vector Double)

  contiguous <- unwrap "tensorToContiguous" =<< tensorToContiguous native base
  assertTensor "tensorToContiguous" [2, 3] [1.0, 2.0, 3.0, 4.0, 5.0, 6.0] contiguous

  reshaped <- unwrap "tensorReshape" =<< tensorReshape native [3, 2] base
  assertTensor "tensorReshape" [3, 2] [1.0, 2.0, 3.0, 4.0, 5.0, 6.0] reshaped

  flattened <- unwrap "tensorFlatten" =<< tensorFlatten native base
  assertTensor "tensorFlatten" [6] [1.0, 2.0, 3.0, 4.0, 5.0, 6.0] flattened

  expanded <- unwrap "tensorExpandDims" =<< tensorExpandDims native 1 base
  assertTensor "tensorExpandDims" [2, 1, 3] [1.0, 2.0, 3.0, 4.0, 5.0, 6.0] expanded

  squeezed <- unwrap "tensorSqueeze" =<< tensorSqueeze native (Tensor [1, 2, 1, 3] (tensorValues base))
  assertTensor "tensorSqueeze" [2, 3] [1.0, 2.0, 3.0, 4.0, 5.0, 6.0] squeezed

  squeezedAxis <- unwrap "tensorSqueezeAxis" =<< tensorSqueezeAxis native 1 expanded
  assertTensor "tensorSqueezeAxis" [2, 3] [1.0, 2.0, 3.0, 4.0, 5.0, 6.0] squeezedAxis

  permuted <- unwrap "tensorPermuteAxes" =<< tensorPermuteAxes native [1, 0] base
  assertTensor "tensorPermuteAxes" [3, 2] [1.0, 4.0, 2.0, 5.0, 3.0, 6.0] permuted

  transposed <- unwrap "tensorTranspose" =<< tensorTranspose native base
  assertTensor "tensorTranspose" [3, 2] [1.0, 4.0, 2.0, 5.0, 3.0, 6.0] transposed

  sliced <- unwrap "tensorSliceAxis" =<< tensorSliceAxis native 1 1 3 base
  assertTensor "tensorSliceAxis" [2, 2] [2.0, 3.0, 5.0, 6.0] sliced

  stepped <- unwrap "tensorSliceAxisStep" =<< tensorSliceAxisStep native 1 0 3 2 base
  assertTensor "tensorSliceAxisStep" [2, 2] [1.0, 3.0, 4.0, 6.0] stepped

  taken <- unwrap "tensorTakeAxis" =<< tensorTakeAxis native 1 [2, 0] base
  assertTensor "tensorTakeAxis" [2, 2] [3.0, 1.0, 6.0, 4.0] taken

  indexed <- unwrap "tensorIndexAxis" =<< tensorIndexAxis native 1 2 base
  assertTensor "tensorIndexAxis" [2, 1] [3.0, 6.0] indexed

  added <- unwrap "tensorAdd" =<< tensorAdd native base (Tensor [1, 3] (VS.fromList [10.0, 20.0, 30.0]))
  assertTensor "tensorAdd" [2, 3] [11.0, 22.0, 33.0, 14.0, 25.0, 36.0] added

  multiplied <- unwrap "tensorMulScalar" =<< tensorMulScalar native 2.0 base
  assertTensor "tensorMulScalar" [2, 3] [2.0, 4.0, 6.0, 8.0, 10.0, 12.0] multiplied

testOcbWriteValidationPure :: IO ()
testOcbWriteValidationPure = do
  assertInvalid "OCB write empty schema" (Ocb.validateWriteSpec validWriteSpec{Ocb.ocbWriteColumns = []})
  assertInvalid "OCB write empty row groups" (Ocb.validateWriteSpec validWriteSpec{Ocb.ocbWriteRowGroups = []})
  assertInvalid "OCB write empty column name" (Ocb.validateWriteSpec validWriteSpec{Ocb.ocbWriteColumns = [baseColumn{Ocb.ocbWriteColumnName = ""}]})
  assertInvalid "OCB write NUL column" (Ocb.validateWriteSpec validWriteSpec{Ocb.ocbWriteColumns = [baseColumn{Ocb.ocbWriteColumnName = "bad\0name"}]})
  assertInvalid "OCB write duplicate column names" (Ocb.validateWriteSpec validWriteSpec{Ocb.ocbWriteColumns = [baseColumn, baseColumn]})
  assertInvalid "OCB write missing dictionary" (Ocb.validateWriteSpec validWriteSpec{Ocb.ocbWriteColumns = [baseColumn{Ocb.ocbWriteColumnDictionaryId = Just 7}]})
  assertInvalid "OCB write empty chunks" (Ocb.validateWriteSpec validWriteSpec{Ocb.ocbWriteRowGroups = [Ocb.OcbWriteRowGroup []]})
  assertInvalid "OCB write zero primitive rows" (Ocb.validateWriteSpec validWriteSpec{Ocb.ocbWriteRowGroups = [Ocb.OcbWriteRowGroup [baseChunk{Ocb.ocbWriteChunkValues = Ocb.OcbValuesI32 []}]]})
  assertInvalid "OCB write zero fixed rows" (Ocb.validateWriteSpec fixedSpec{Ocb.ocbWriteRowGroups = [Ocb.OcbWriteRowGroup [fixedChunk{Ocb.ocbWriteChunkValues = Ocb.OcbValuesFixedBinary 2 []}]]})
  assertInvalid "OCB write duplicate chunks" (Ocb.validateWriteSpec validWriteSpec{Ocb.ocbWriteRowGroups = [Ocb.OcbWriteRowGroup [baseChunk, baseChunk]]})
  assertInvalid "OCB write validity on non-null" (Ocb.validateWriteSpec validWriteSpec{Ocb.ocbWriteRowGroups = [Ocb.OcbWriteRowGroup [baseChunk{Ocb.ocbWriteChunkValidity = Just (Ocb.OcbValidityBitmap [0x1] 1)}]]})
  assertInvalid "OCB write validity exact length" (Ocb.validateWriteSpec nullableSpec{Ocb.ocbWriteRowGroups = [Ocb.OcbWriteRowGroup [baseChunk{Ocb.ocbWriteChunkValidity = Just (Ocb.OcbValidityBitmap [0xff, 0x00] 3)}]]})
  assertInvalid "OCB write fixed width mismatch" (Ocb.validateWriteSpec fixedSpec{Ocb.ocbWriteRowGroups = [Ocb.OcbWriteRowGroup [fixedChunk{Ocb.ocbWriteChunkValues = Ocb.OcbValuesFixedBinary 3 [1,2,3,4]}]]})
  assertInvalid "OCB write fixed ordering key" (Ocb.validateWriteSpec fixedSpec{Ocb.ocbWriteOrderingKeys = [Ocb.OcbWriteOrderingKey 0 Ocb.OcbOrderingAscending Ocb.OcbNoNulls]})
  assertInvalid "OCB write duplicate ordering key" (Ocb.validateWriteSpec validWriteSpec{Ocb.ocbWriteOrderingKeys = [baseOrdering, baseOrdering]})
  assertInvalid "OCB write unknown physical" (Ocb.validateWriteSpec validWriteSpec{Ocb.ocbWriteColumns = [baseColumn{Ocb.ocbWriteColumnPhysicalType = Ocb.OcbPhysicalUnknown 99}]})
  assertInvalid "OCB write unknown logical" (Ocb.validateWriteSpec validWriteSpec{Ocb.ocbWriteColumns = [baseColumn{Ocb.ocbWriteColumnLogicalKind = Ocb.OcbLogicalUnknown 99}]})
  assertInvalid "OCB write unknown values" (Ocb.validateWriteSpec validWriteSpec{Ocb.ocbWriteRowGroups = [Ocb.OcbWriteRowGroup [baseChunk{Ocb.ocbWriteChunkValues = Ocb.OcbValuesUnknown (Ocb.OcbPhysicalUnknown 99) 3}]]})
  assertInvalid "OCB write unknown ordering direction" (Ocb.validateWriteSpec validWriteSpec{Ocb.ocbWriteOrderingKeys = [baseOrdering{Ocb.ocbWriteOrderingDirection = Ocb.OcbOrderingDirectionUnknown 99}]})
  assertInvalid "OCB write unknown null order" (Ocb.validateWriteSpec validWriteSpec{Ocb.ocbWriteOrderingKeys = [baseOrdering{Ocb.ocbWriteOrderingNullOrder = Ocb.OcbNullOrderUnknown 99}]})
  assertInvalid "OCB write empty dictionary name" (Ocb.validateWriteSpec validWriteSpec{Ocb.ocbWriteDictionaries = [fixedDictionary{Ocb.ocbWriteDictionaryName = ""}]})
  assertInvalid "OCB write fixed dictionary entry width" (Ocb.validateWriteSpec validWriteSpec{Ocb.ocbWriteDictionaries = [fixedDictionary{Ocb.ocbWriteDictionaryEntries = [Ocb.OcbDictionaryEntryBytes [1]]}]})
  assertInvalid "OCB write utf8 dictionary shape" (Ocb.validateWriteSpec validWriteSpec{Ocb.ocbWriteDictionaries = [utf8Dictionary{Ocb.ocbWriteDictionaryEntries = [Ocb.OcbDictionaryEntryBytes [1,2]]}]})
  assertInvalid "OCB write unknown dictionary code" (Ocb.validateWriteSpec validWriteSpec{Ocb.ocbWriteDictionaries = [utf8Dictionary{Ocb.ocbWriteDictionaryCodePhysicalType = Ocb.OcbPhysicalUnknown 99}]})
  assertInvalid "OCB write unknown dictionary value kind" (Ocb.validateWriteSpec validWriteSpec{Ocb.ocbWriteDictionaries = [utf8Dictionary{Ocb.ocbWriteDictionaryValueKind = Ocb.OcbDictionaryValueUnknown 99}]})
  assertInvalid "OCB write threads range" (Ocb.validateWriteOptions Ocb.defaultOcbWriteOptions{Ocb.ocbWriteThreads = 0})
  assertInvalid "OCB write zstd range" (Ocb.validateWriteOptions Ocb.defaultOcbWriteOptions{Ocb.ocbWriteZstdLevel = 23})
  assertInvalid "OCB write unknown codec" (Ocb.validateWriteOptions Ocb.defaultOcbWriteOptions{Ocb.ocbWriteChunkCodec = Ocb.OcbWriteChunkCodecUnknown 99})
  assertEqual "OCB write valid spec" Nothing (Ocb.validateWriteSpec validWriteSpec)
  assertEqual "OCB write valid options" Nothing (Ocb.validateWriteOptions Ocb.defaultOcbWriteOptions)
 where
  baseColumn =
    Ocb.OcbWriteColumn
      { Ocb.ocbWriteColumnName = "value"
      , Ocb.ocbWriteColumnPhysicalType = Ocb.OcbPhysicalI32
      , Ocb.ocbWriteColumnLogicalKind = Ocb.OcbLogicalPlain
      , Ocb.ocbWriteColumnDictionaryId = Nothing
      , Ocb.ocbWriteColumnScale = 0
      , Ocb.ocbWriteColumnNullable = False
      , Ocb.ocbWriteColumnFixedBinaryWidth = Nothing
      }
  baseChunk = Ocb.OcbWriteColumnChunk 0 (Ocb.OcbValuesI32 [1, 2, 3]) Nothing
  baseOrdering = Ocb.OcbWriteOrderingKey 0 Ocb.OcbOrderingAscending Ocb.OcbNoNulls
  validWriteSpec = Ocb.OcbWriteSpec [baseColumn] [] [Ocb.OcbWriteRowGroup [baseChunk]] [baseOrdering]
  nullableSpec = validWriteSpec{Ocb.ocbWriteColumns = [baseColumn{Ocb.ocbWriteColumnNullable = True}]}
  fixedColumn = baseColumn{Ocb.ocbWriteColumnPhysicalType = Ocb.OcbPhysicalFixedBinary, Ocb.ocbWriteColumnFixedBinaryWidth = Just 2}
  fixedChunk = Ocb.OcbWriteColumnChunk 0 (Ocb.OcbValuesFixedBinary 2 [1,2,3,4]) Nothing
  fixedSpec = validWriteSpec{Ocb.ocbWriteColumns = [fixedColumn], Ocb.ocbWriteRowGroups = [Ocb.OcbWriteRowGroup [fixedChunk]], Ocb.ocbWriteOrderingKeys = []}
  fixedDictionary = Ocb.OcbWriteDictionary 1 "fixed" Ocb.OcbPhysicalI32 Ocb.OcbDictionaryFixedBytes 2 [Ocb.OcbDictionaryEntryBytes [1,2]]
  utf8Dictionary = Ocb.OcbWriteDictionary 2 "labels" Ocb.OcbPhysicalI32 Ocb.OcbDictionaryUtf8 0 [Ocb.OcbDictionaryEntryUtf8 "a"]

testStreamingF64MetadataSelectorsDense :: NativeLibrary -> IO ()
testStreamingF64MetadataSelectorsDense native = do
  let path = ".test-output" </> "streaming-f64.tio"
  cleanup path

  file <- unwrap "createStreaming f64" =<< createStreaming native path F64 [dim AxisTime 0, dim AxisChannel 3] 0
  appended <- unwrap "appendDenseF64" =<< appendDenseF64 file [2, 3] (VS.fromList [1.0, 2.0, 3.0, 4.0, 5.0, 6.0])
  assertEqual "f64 append range" (AppendRange 0 2) appended
  assertEqualResult "rank" 2 =<< rank file
  assertEqualResult "dtype" F64 =<< dtype file
  assertEqualResult "appendAxis" 0 =<< appendAxis file
  assertEqualResult "dimLens" [2, 3] =<< dimLens file
  openedPath <- unwrap "filePath" =<< filePath file
  assertEqual "file path non-empty" True (not (null openedPath))
  plan <- unwrap "chunkPlan" =<< chunkPlan file
  assertEqual "chunk plan non-empty" True (not (null (chunkPlanBlockSizes plan)))

  dense <- unwrap "readAllDenseF64" =<< readAllDenseF64 file (-1.0)
  assertEqual "dense shape" [2, 3] (tensorShape (denseReadTensor dense))
  assertEqual "dense values" (VS.fromList [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]) (tensorValues (denseReadTensor dense))
  assertEqual "dense validity" (VS.fromList [1, 1, 1, 1, 1, 1]) (denseReadValidity dense)

  headInfo <- unwrap "headCommit" =<< headCommit file
  commits <- unwrap "listCommits" =<< listCommits file 8
  assertEqual "listCommits first" (Just (commitSeq headInfo)) (commitSeq <$> safeHead commits)
  historical <- unwrapSomeF64 "readAtCommit" =<< readAtCommit file (commitSeq headInfo)
  assertTensor "read at commit" [2, 3] [1.0, 2.0, 3.0, 4.0, 5.0, 6.0] historical
  historicalDense <- unwrapSomeDenseF64 "readAtCommitDense" =<< readAtCommitDense file (commitSeq headInfo) (-1.0)
  assertEqual "historical dense shape" [2, 3] (tensorShape (denseReadTensor historicalDense))
  assertEqual "historical dense validity" (VS.fromList [1, 1, 1, 1, 1, 1]) (denseReadValidity historicalDense)
  historicalSelected <- unwrapSomeF64 "readAtCommitSelected" =<< readAtCommitSelected file (commitSeq headInfo) [SelectRange 1 2, SelectAll]
  assertTensor "read at commit selected" [1, 3] [4.0, 5.0, 6.0] historicalSelected
  historicalDenseSelected <- unwrapSomeDenseF64 "readAtCommitDenseSelected" =<< readAtCommitDenseSelected file (commitSeq headInfo) [SelectTake [1, 0], SelectRange 1 3] (-1.0)
  assertEqual "historical dense selected shape" [2, 2] (tensorShape (denseReadTensor historicalDenseSelected))
  assertEqual "historical dense selected values" (VS.fromList [5.0, 6.0, 2.0, 3.0]) (tensorValues (denseReadTensor historicalDenseSelected))
  assertEqual "historical dense selected validity" (VS.fromList [1, 1, 1, 1]) (denseReadValidity historicalDenseSelected)
  stats <- unwrap "analyzeCompaction" =<< analyzeCompaction file
  assertEqual "compaction commit count" True (compactionCommitCount stats >= 1)

  range <- unwrapSomeF64 "readEntryRange" =<< readEntryRange file 1 2
  assertTensor "entry range" [1, 3] [4.0, 5.0, 6.0] range

  axisRange <- unwrapSomeF64 "readAxisRange" =<< readAxisRange file 1 1 3
  assertTensor "axis range" [2, 2] [2.0, 3.0, 5.0, 6.0] axisRange

  axisOne <- unwrapSomeF64 "readAxisOne" =<< readAxisOne file 1 2
  assertTensor "axis one" [2, 1] [3.0, 6.0] axisOne

  axisTake <- unwrapSomeF64 "readAxisTake" =<< readAxisTake file 1 [2, 0]
  assertTensor "axis take" [2, 2] [3.0, 1.0, 6.0, 4.0] axisTake

  entries <- unwrapSomeF64 "takeEntries" =<< takeEntries file [1, 0]
  assertTensor "take entries" [2, 3] [4.0, 5.0, 6.0, 1.0, 2.0, 3.0] entries

  close file

  meta <- unwrap "loadMeta" =<< loadMeta native path
  assertEqual "meta dtype" F64 (fileMetaDType meta)
  assertEqual "meta append dim" 0 (fileMetaAppendDim meta)
  assertEqual "meta dim lens" [0, 3] (map dimMetaLength (fileMetaDims meta))
  assertEqual "meta profile" HeaderStreaming (fileMetaEffectiveProfile meta)

  cleanup path

testReadOptionsReportsIndex :: NativeLibrary -> IO ()
testReadOptionsReportsIndex native = do
  let path = ".test-output" </> "read-options-index.tio"
  cleanup path
  file <- unwrap "createStreaming read options" =<< createStreaming native path F64 [dim AxisTime 0, dim AxisChannel 3] 0
  _ <- unwrap "appendDenseF64 read options" =<< appendDenseF64 file [2, 3] (VS.fromList [1.0, 2.0, 3.0, 4.0, 5.0, 6.0])

  (selected, serialReport) <- unwrap "readWithOptions" =<< readWithOptions file [SelectAll, SelectRange 1 3] defaultReadOptions
  selectedF64 <- expectSomeF64 "readWithOptions tensor" selected
  assertTensor "readWithOptions selected" [2, 2] [2.0, 3.0, 5.0, 6.0] selectedF64
  assertEqual "readWithOptions requested mode" ReadSerial (readReportRequestedMode serialReport)

  let parallelOptions = ReadOptions{readOptionMode = ReadParallelThreads, readOptionMaxThreads = 2}
  (denseSelected, parallelReport) <- unwrap "readWithOptionsDense" =<< readWithOptionsDense file [SelectTake [1, 0], SelectAll] parallelOptions (-1.0)
  denseF64 <- expectSomeDenseF64 "readWithOptionsDense tensor" denseSelected
  assertEqual "readWithOptionsDense shape" [2, 3] (tensorShape (denseReadTensor denseF64))
  assertEqual "readWithOptionsDense values" (VS.fromList [4.0, 5.0, 6.0, 1.0, 2.0, 3.0]) (tensorValues (denseReadTensor denseF64))
  assertEqual "readWithOptionsDense validity" (VS.fromList [1, 1, 1, 1, 1, 1]) (denseReadValidity denseF64)
  assertEqual "readWithOptionsDense requested mode" ReadParallelThreads (readReportRequestedMode parallelReport)

  (shapePolicyTensor, _) <- unwrap "readWithShapePolicy" =<< readWithShapePolicy file [SelectRange 0 1, SelectAll] defaultReadOptions ReadShapeCurrentHead
  shapePolicyF64 <- expectSomeF64 "readWithShapePolicy tensor" shapePolicyTensor
  assertTensor "readWithShapePolicy selected" [1, 3] [1.0, 2.0, 3.0] shapePolicyF64

  headInfo <- unwrap "headCommit read options" =<< headCommit file
  (historicalTensor, historicalReport) <- unwrap "readAtCommitWithOptions" =<< readAtCommitWithOptions file (commitSeq headInfo) [SelectRange 1 2, SelectAll] defaultReadOptions
  historicalF64 <- expectSomeF64 "readAtCommitWithOptions tensor" historicalTensor
  assertTensor "readAtCommitWithOptions selected" [1, 3] [4.0, 5.0, 6.0] historicalF64
  assertEqual "historical commit seq" (commitSeq headInfo) (historicalReadQueryCommitSeq historicalReport)

  (historicalDense, _) <- unwrap "readAtCommitWithShapePolicyDense" =<< readAtCommitWithShapePolicyDense file (commitSeq headInfo) [SelectAll, SelectRange 0 2] defaultReadOptions ReadShapeCurrentHead (-1.0)
  historicalDenseF64 <- expectSomeDenseF64 "readAtCommitWithShapePolicyDense tensor" historicalDense
  assertEqual "historical shape policy dense shape" [2, 2] (tensorShape (denseReadTensor historicalDenseF64))
  assertEqual "historical shape policy dense values" (VS.fromList [1.0, 2.0, 4.0, 5.0]) (tensorValues (denseReadTensor historicalDenseF64))

  let traceContext =
        QueryTraceContext
          { queryTraceRunId = "tp467-read-options"
          , queryTraceRowId = "row-1"
          , queryTraceRepeatIndex = 0
          , queryTracePhase = "test"
          , queryTraceLanguage = "haskell"
          , queryTraceApiSurface = "arcadia-tio-hs"
          , queryTraceOperation = "readWithOptionsAttributed"
          , queryTraceClock = "monotonic"
          }
  (tracedTensor, _, traceJson) <- unwrap "readWithOptionsAttributed" =<< readWithOptionsAttributed file [SelectAll, SelectAll] defaultReadOptions traceContext
  tracedF64 <- expectSomeF64 "readWithOptionsAttributed tensor" tracedTensor
  assertTensor "readWithOptionsAttributed tensor" [2, 3] [1.0, 2.0, 3.0, 4.0, 5.0, 6.0] tracedF64
  assertEqual "query trace JSON non-empty" True (not (null (queryTraceJson traceJson)))

  (indexedTensor, indexReport) <- unwrap "readIndex" =<< readIndex file [ReadIndexSlice (Just 1) (Just 2) 1, ReadIndexAll]
  indexedF64 <- expectSomeF64 "readIndex tensor" indexedTensor
  assertTensor "readIndex selected" [1, 3] [4.0, 5.0, 6.0] indexedF64
  assertEqual "readIndex lowering known" True (readIndexLoweringKind indexReport /= ReadIndexLoweringUnknown)

  setCheckpoint <- setIndexCheckpointEveryCommits file 3
  case setCheckpoint of
    Left err -> assertEqual "setIndexCheckpointEveryCommits native status" ErrorUnimplemented (tioErrorCode err)
    Right () -> do
      checkpointEvery <- unwrap "getIndexCheckpointEveryCommits" =<< getIndexCheckpointEveryCommits file
      assertEqual "index checkpoint every" 3 checkpointEvery

  close file
  cleanup path

testMutationAndArrow :: NativeLibrary -> IO ()
testMutationAndArrow native = do
  let path = ".test-output" </> "mutation-arrow.tio"
  cleanup path
  file <- unwrap "createRandomAccess mutation" =<< createRandomAccess native path F64 [dim AxisTime 0, dim AxisChannel 2] 0
  _ <- unwrap "appendDenseF64 mutation" =<< appendDenseF64 file [2, 2] (VS.fromList [1.0, 2.0, 3.0, 4.0])

  replacement <- unwrap "rewrite tensor" (tensorFromVector [1, 2] (VS.fromList [9.0, 10.0]))
  rewriteResult <- rewriteF64 file (SelectRange 0 1) replacement
  case rewriteResult of
    Left _err -> pure ()
    Right () -> do
      rewritten <- unwrap "read after rewriteF64" =<< readAllF64 file
      assertTensor "rewriteF64 effect" [2, 2] [9.0, 10.0, 3.0, 4.0] rewritten

  sliceReplacement <- unwrap "rewrite slice tensor" (tensorFromVector [1, 2] (VS.fromList [11.0, 12.0]))
  sliceResult <- rewriteSliceF64 file [SelectRange 1 2, SelectAll] sliceReplacement
  case sliceResult of
    Left _err -> pure ()
    Right () -> do
      rewritten <- unwrap "read after rewriteSliceF64" =<< readAllF64 file
      assertEqual "rewriteSliceF64 shape" [2, 2] (tensorShape rewritten)

  clearResult <- clearBlocks file [[0, 0]]
  case clearResult of
    Left _err -> pure ()
    Right () -> pure ()

  arrowResult <- readValuesArrow file
  case arrowResult of
    Left err -> assertEqual "readValuesArrow native status" ErrorUnimplemented (tioErrorCode err)
    Right arrow -> do
      len <- arrowArrayLength arrow
      assertEqual "arrow length non-negative" True (len >= 0)
      fmt <- arrowSchemaFormat arrow
      assertEqual "arrow schema format present" True (maybe False (not . null) fmt)
      releaseArrowCData arrow
      releaseArrowCData arrow

  close file
  cleanup path

testStreamingF32 :: NativeLibrary -> IO ()
testStreamingF32 native = do
  let path = ".test-output" </> "streaming-f32.tio"
  cleanup path
  file <- unwrap "createStreaming f32" =<< createStreaming native path F32 [dim AxisTime 0, dim AxisChannel 2] 0
  _ <- unwrap "appendDenseF32" =<< appendDenseF32 file [2, 2] (VS.fromList [1.25, 2.5, 3.75, 4.5])
  tensor <- unwrap "readAllF32" =<< readAllF32 file
  assertEqual "f32 shape" [2, 2] (tensorShape tensor)
  assertEqual "f32 values" (VS.fromList [1.25, 2.5, 3.75, 4.5]) (tensorValues tensor)
  close file
  cleanup path

testStreamingI32 :: NativeLibrary -> IO ()
testStreamingI32 native = do
  let path = ".test-output" </> "streaming-i32.tio"
  cleanup path
  file <- unwrap "createStreaming i32" =<< createStreaming native path I32 [dim AxisTime 0, dim AxisChannel 2] 0
  _ <- unwrap "appendDenseI32" =<< appendDenseI32 file [2, 2] (VS.fromList ([1, 2, 3, 4] :: [Int32]))
  tensor <- unwrap "readAllI32" =<< readAllI32 file
  assertEqual "i32 shape" [2, 2] (tensorShape tensor)
  assertEqual "i32 values" (VS.fromList ([1, 2, 3, 4] :: [Int32])) (tensorValues tensor)
  close file
  cleanup path

testStreamingI64 :: NativeLibrary -> IO ()
testStreamingI64 native = do
  let path = ".test-output" </> "streaming-i64.tio"
  cleanup path
  file <- unwrap "createStreaming i64" =<< createStreaming native path I64 [dim AxisTime 0, dim AxisChannel 2] 0
  _ <- unwrap "appendDenseI64" =<< appendDenseI64 file [2, 2] (VS.fromList ([10, 20, 30, 40] :: [Int64]))
  tensor <- unwrap "readAllI64" =<< readAllI64 file
  assertEqual "i64 shape" [2, 2] (tensorShape tensor)
  assertEqual "i64 values" (VS.fromList ([10, 20, 30, 40] :: [Int64])) (tensorValues tensor)
  close file
  cleanup path

testRandomAccessF64 :: NativeLibrary -> IO ()
testRandomAccessF64 native = do
  let path = ".test-output" </> "random-access-f64.tio"
  cleanup path
  file <- unwrap "createRandomAccess f64" =<< createRandomAccess native path F64 [dim AxisTime 0, dim AxisChannel 2] 0
  unwrap "setCompressionConfig" =<< setCompressionConfig file uncompressedCompression
  compression <- unwrap "getCompressionConfig" =<< getCompressionConfig file
  assertEqual "compression config" uncompressedCompression compression
  _ <- unwrap "appendDenseF64 random access" =<< appendDenseF64 file [1, 2] (VS.fromList [7.0, 8.0])
  tensor <- unwrap "readAllF64 random access" =<< readAllF64 file
  assertTensor "random access f64" [1, 2] [7.0, 8.0] tensor
  close file
  cleanup path

testSparseAppend :: NativeLibrary -> IO ()
testSparseAppend native = do
  let f32Path = ".test-output" </> "sparse-f32.tio"
      f64Path = ".test-output" </> "sparse-f64.tio"
      i32Path = ".test-output" </> "sparse-i32.tio"
      i64Path = ".test-output" </> "sparse-i64.tio"
      sparseRule = predicateSubtensorRule [1] SparsePredicateZero
  cleanup f32Path
  f32File <- unwrap "createRandomAccess sparse f32" =<< createRandomAccess native f32Path F32 [dim AxisTime 0, dim AxisSymbol 4, dim AxisChannel 2] 0
  f32Analysis <- unwrap "analyzeSparseAppendF32" =<< analyzeSparseAppendF32 f32File [1, 4, 2] (VS.fromList [21.0, 22.0, 0.0, 0.0, 25.0, 26.0, 27.0, 28.0]) sparseRule
  assertEqual "f32 sparse outcome" SparseAppendSparseChunkTree (sparseAppendOutcome f32Analysis)
  assertEqual "f32 sparse absent" 1 (sparseAppendAbsentSubtensorCount f32Analysis)
  f32Range <- unwrap "appendSparseF32 range-superset" =<< appendSparseF32 f32File [1, 4, 2] (VS.fromList [21.0, 22.0, 0.0, 0.0, 25.0, 26.0, 27.0, 28.0]) sparseRule
  assertEqual "f32 sparse append range" (AppendRange 0 1) f32Range
  f32Dense <- unwrap "readAllDenseF32 sparse" =<< readAllDenseF32 f32File (-1.0)
  assertEqual "f32 sparse dense shape" [1, 4, 2] (tensorShape (denseReadTensor f32Dense))
  assertEqual "f32 sparse dense values" (VS.fromList [21.0, 22.0, -1.0, -1.0, 25.0, 26.0, 27.0, 28.0]) (tensorValues (denseReadTensor f32Dense))
  assertEqual "f32 sparse validity" (VS.fromList [1, 1, 0, 0, 1, 1, 1, 1]) (denseReadValidity f32Dense)
  close f32File
  cleanup f32Path

  cleanup f64Path
  f64File <- unwrap "createRandomAccess sparse f64" =<< createRandomAccess native f64Path F64 [dim AxisTime 0, dim AxisSymbol 4] 0
  let f64Values = VS.fromList [10.5, 0.0, 12.5, 0.0]
  f64Analysis <- unwrap "analyzeSparseAppendF64" =<< analyzeSparseAppendF64 f64File [1, 4] f64Values sparseRule
  assertEqual "f64 sparse outcome" SparseAppendSparseChunkTree (sparseAppendOutcome f64Analysis)
  assertEqual "f64 sparse absent" 2 (sparseAppendAbsentSubtensorCount f64Analysis)
  f64Range <- unwrap "appendSparseF64 range-superset" =<< appendSparseF64 f64File [1, 4] f64Values sparseRule
  assertEqual "f64 sparse append range" (AppendRange 0 1) f64Range
  f64Dense <- unwrap "readAllDenseF64 sparse" =<< readAllDenseF64 f64File (-1.0)
  assertEqual "f64 sparse dense shape" [1, 4] (tensorShape (denseReadTensor f64Dense))
  assertEqual "f64 sparse dense values" (VS.fromList [10.5, -1.0, 12.5, -1.0]) (tensorValues (denseReadTensor f64Dense))
  assertEqual "f64 sparse validity" (VS.fromList [1, 0, 1, 0]) (denseReadValidity f64Dense)
  close f64File
  cleanup f64Path

  cleanup i32Path
  i32File <- unwrap "createRandomAccess sparse i32" =<< createRandomAccess native i32Path I32 [dim AxisTime 0, dim AxisSymbol 4] 0
  let exactI32Rule = predicateSubtensorRule [1] (SparsePredicateEqualI32 (-7))
      exactI32Values = VS.fromList ([21, -7, 23, -7] :: [Int32])
  i32Analysis <- unwrap "analyzeSparseAppendI32 exact" =<< analyzeSparseAppendI32 i32File [1, 4] exactI32Values exactI32Rule
  assertEqual "i32 exact sparse outcome" SparseAppendSparseChunkTree (sparseAppendOutcome i32Analysis)
  assertEqual "i32 exact sparse absent" 2 (sparseAppendAbsentSubtensorCount i32Analysis)
  i32Range <- unwrap "appendSparseI32 exact range-superset" =<< appendSparseI32 i32File [1, 4] exactI32Values exactI32Rule
  assertEqual "i32 exact sparse append range" (AppendRange 0 1) i32Range
  i32Dense <- unwrap "readAllDenseI32 sparse" =<< readAllDenseI32 i32File 0.0
  assertEqual "i32 sparse dense shape" [1, 4] (tensorShape (denseReadTensor i32Dense))
  assertEqual "i32 sparse dense values" (VS.fromList ([21, 0, 23, 0] :: [Int32])) (tensorValues (denseReadTensor i32Dense))
  assertEqual "i32 sparse validity" (VS.fromList [1, 0, 1, 0]) (denseReadValidity i32Dense)
  close i32File
  cleanup i32Path

  cleanup i64Path
  i64File <- unwrap "createRandomAccess sparse i64" =<< createRandomAccess native i64Path I64 [dim AxisTime 0, dim AxisSymbol 4] 0
  let exactI64Rule = predicateSubtensorRule [1] (SparsePredicateEqualI64 (-7000000000))
      exactI64Values = VS.fromList ([21000000000, -7000000000, 23000000000, -7000000000] :: [Int64])
  i64Analysis <- unwrap "analyzeSparseAppendI64 exact" =<< analyzeSparseAppendI64 i64File [1, 4] exactI64Values exactI64Rule
  assertEqual "i64 exact sparse outcome" SparseAppendSparseChunkTree (sparseAppendOutcome i64Analysis)
  assertEqual "i64 exact sparse absent" 2 (sparseAppendAbsentSubtensorCount i64Analysis)
  i64Range <- unwrap "appendSparseI64 exact range-superset" =<< appendSparseI64 i64File [1, 4] exactI64Values exactI64Rule
  assertEqual "i64 exact sparse append range" (AppendRange 0 1) i64Range
  i64Dense <- unwrap "readAllDenseI64 sparse" =<< readAllDenseI64 i64File 0.0
  assertEqual "i64 sparse dense shape" [1, 4] (tensorShape (denseReadTensor i64Dense))
  assertEqual "i64 sparse dense values" (VS.fromList ([21000000000, 0, 23000000000, 0] :: [Int64])) (tensorValues (denseReadTensor i64Dense))
  assertEqual "i64 sparse validity" (VS.fromList [1, 0, 1, 0]) (denseReadValidity i64Dense)
  close i64File
  cleanup i64Path

testCompactionHelpers :: NativeLibrary -> IO ()
testCompactionHelpers native = do
  let path = ".test-output" </> "compaction-source.tio"
      compactPath = ".test-output" </> "compaction-compact.tio"
      maybeSkipPath = ".test-output" </> "compaction-skip.tio"
      maybeRunPath = ".test-output" </> "compaction-run.tio"
      retainedPath = ".test-output" </> "compaction-retained.tio"
      retainedPrecisePath = ".test-output" </> "compaction-retained-precise.tio"
  mapM_ cleanup [path, compactPath, maybeSkipPath, maybeRunPath, retainedPath, retainedPrecisePath]
  file <- unwrap "createStreaming compaction" =<< createStreaming native path F64 [dim AxisTime 0, dim AxisChannel 2] 0
  _ <- unwrap "append compaction first" =<< appendDenseF64 file [1, 2] (VS.fromList [1.0, 2.0])
  _ <- unwrap "append compaction second" =<< appendDenseF64 file [1, 2] (VS.fromList [3.0, 4.0])
  autoCfg <- unwrap "getAutoCompactionConfig" =<< getAutoCompactionConfig file
  assertEqual "default auto compaction config" Nothing autoCfg
  stateBefore <- unwrap "compactionState" =<< compactionState file
  assertEqual "default compaction state" Nothing stateBefore
  let autoConfig =
        AutoCompactionConfig
          { autoCompactionEnabled = True
          , autoCompactionRetainCommits = 1
          , autoCompactionDeadRatioThreshold = 0.4
          , autoCompactionMinDeadBytes = 0
          , autoCompactionMode = CompactionCopyLive
          , autoCompactionCheckEveryCommits = 1
          , autoCompactionCooldownCommits = 0
          }
  setAutoResult <- setAutoCompactionConfig file (Just autoConfig)
  assertErrorCode "setAutoCompactionConfig native status" ErrorUnimplemented setAutoResult

  analysis <- unwrap "analyzeV4Compaction" =<< analyzeV4Compaction file
  assertEqual "v4 compaction analysis status" True (isKnownV4Status (v4CompactionAnalysisStatus analysis))
  preciseAnalysis <- unwrap "analyzeV4CompactionPrecise" =<< analyzeV4CompactionPrecise file defaultV4PreciseAccountingOptions{v4PreciseIncludeOmittedFieldReasons = True}
  assertEqual "v4 precise compaction status" True (isKnownV4Status (v4CompactionAnalysisPreciseStatus preciseAnalysis))

  let retainOne = defaultV4RetainedHistoryCompactionOptions{v4RetainedHistoryRetainLastN = 1}
  invalidRetain <- compactV4RetainedHistoryTo file retainedPath defaultV4RetainedHistoryCompactionOptions{v4RetainedHistoryRetainLastN = 0}
  assertErrorCode "retained history validation" ErrorInvalidArgument invalidRetain
  retainedReport <- unwrap "compactV4RetainedHistoryTo" =<< compactV4RetainedHistoryTo file retainedPath retainOne
  assertEqual "retained compaction status" True (isKnownV4Status (v4RetainedHistoryStatus retainedReport))
  retainedFile <- unwrap "open retained compacted" =<< open native retainedPath
  retainedTensor <- unwrap "read retained compacted" =<< readAllF64 retainedFile
  assertTensor "retained compacted visible data" [2, 2] [1.0, 2.0, 3.0, 4.0] retainedTensor
  close retainedFile
  retainedPreciseReport <- unwrap "compactV4RetainedHistoryToPrecise" =<< compactV4RetainedHistoryToPrecise file retainedPrecisePath retainOne defaultV4PreciseAccountingOptions{v4PreciseIncludeOmittedFieldReasons = True}
  assertEqual "retained precise compaction status" True (isKnownV4Status (v4RetainedHistoryPreciseStatus retainedPreciseReport))
  retainedPreciseFile <- unwrap "open retained precise compacted" =<< open native retainedPrecisePath
  retainedPreciseTensor <- unwrap "read retained precise compacted" =<< readAllF64 retainedPreciseFile
  assertTensor "retained precise compacted visible data" [2, 2] [1.0, 2.0, 3.0, 4.0] retainedPreciseTensor
  close retainedPreciseFile

  unwrap "compactTo" =<< compactTo file compactPath 1 CompactionCopyLive
  compacted <- unwrap "open compacted" =<< open native compactPath
  compactedTensor <- unwrap "read compacted" =<< readAllF64 compacted
  assertTensor "compacted visible data" [2, 2] [1.0, 2.0, 3.0, 4.0] compactedTensor
  close compacted
  skipped <- unwrap "maybeCompact skip" =<< maybeCompact file maybeSkipPath 1.1 (2 ^ (62 :: Int)) 1 CompactionCopyLive
  assertEqual "maybeCompact skip" False skipped
  ran <- unwrap "maybeCompact run" =<< maybeCompact file maybeRunPath 0.0 0 1 CompactionCopyLive
  assertEqual "maybeCompact run" True ran
  maybeCompacted <- unwrap "open maybe compacted" =<< open native maybeRunPath
  maybeTensor <- unwrap "read maybe compacted" =<< readAllF64 maybeCompacted
  assertTensor "maybe compacted visible data" [2, 2] [1.0, 2.0, 3.0, 4.0] maybeTensor
  close maybeCompacted
  close file
  mapM_ cleanup [path, compactPath, maybeSkipPath, maybeRunPath, retainedPath, retainedPrecisePath]

testReformHelpers :: NativeLibrary -> IO ()
testReformHelpers native = do
  let path = ".test-output" </> "reform-source.tio"
      reformPath = ".test-output" </> "reform-preserve.tio"
      reformExPath = ".test-output" </> "reform-regular.tio"
  mapM_ cleanup [path, reformPath, reformExPath]
  file <- unwrap "createStreaming reform" =<< createStreaming native path F64 [dim AxisTime 0, dim AxisChannel 2] 0
  _ <- unwrap "appendDenseF64 reform" =<< appendDenseF64 file [2, 2] (VS.fromList [1.0, 2.0, 3.0, 4.0])

  invalidEmpty <- reformTo file reformPath defaultReformOptions{reformTargetLayout = ReformRegularChunked []}
  assertErrorCode "regular chunked empty validation" ErrorInvalidArgument invalidEmpty
  invalidZero <- reformTo file reformPath defaultReformOptions{reformTargetLayout = ReformRegularChunked [1, 0]}
  assertErrorCode "regular chunked zero validation" ErrorInvalidArgument invalidZero

  unwrap "reformTo regular" =<< reformTo file reformPath defaultReformOptions{reformTargetLayout = ReformRegularChunked [1, 1]}
  reformed <- unwrap "open reform regular" =<< open native reformPath
  reformedTensor <- unwrap "read reform regular" =<< readAllF64 reformed
  assertTensor "reform regular visible data" [2, 2] [1.0, 2.0, 3.0, 4.0] reformedTensor
  close reformed

  report <- unwrap "reformToEx regular" =<< reformToEx file reformExPath defaultReformOptions{reformTargetLayout = ReformRegularChunked [1, 1]}
  assertEqual "reform report reason code copied" True (reformReasonCode report == Nothing || not (null (maybe "" id (reformReasonCode report))))
  reformedEx <- unwrap "open reform regular" =<< open native reformExPath
  reformedExTensor <- unwrap "read reform regular" =<< readAllF64 reformedEx
  assertTensor "reform regular visible data" [2, 2] [1.0, 2.0, 3.0, 4.0] reformedExTensor
  close reformedEx

  close file
  mapM_ cleanup [path, reformPath, reformExPath]

testDetailedDiagnostics :: NativeLibrary -> IO ()
testDetailedDiagnostics native = do
  let path = ".test-output" </> "v4-diagnostics.tio"
  cleanup path
  file <- unwrap "createStreaming diagnostics" =<< createStreaming native path F64 [dim AxisTime 0, dim AxisChannel 2] 0
  _ <- unwrap "appendDenseF64 diagnostics" =<< appendDenseF64 file [2, 2] (VS.fromList [1.0, 2.0, 3.0, 4.0])

  report <- unwrap "v4Diagnostics" =<< v4Diagnostics file
  assertEqual "diagnostics status is native report status" True (isKnownV4Status (v4DiagnosticsStatus report))
  assertEqual "diagnostics current head payload non-negative" True (v4CurrentHeadPayloadBytes (v4DiagnosticsCurrentHead report) >= 0)
  assertEqual "diagnostics omitted reason consistent" True (v4DiagnosticsOmittedUnreachableBytes report || v4DiagnosticsOmittedUnreachableBytesReason report == Nothing)

  precise <- unwrap "v4DiagnosticsPrecise" =<< v4DiagnosticsPrecise file defaultV4PreciseAccountingOptions{v4PreciseIncludeOmittedFieldReasons = True}
  assertEqual "precise diagnostics status is native report status" True (isKnownV4Status (v4DiagnosticsPreciseStatus precise))
  assertEqual "precise diagnostics copied current-head bytes" (v4DiagnosticsCurrentHead report) (v4DiagnosticsPreciseCurrentHead precise)
  assertEqual "precise omitted fields copied safely" True (all omittedFieldHasStableShape (v4PreciseOmittedFields (v4DiagnosticsPreciseAccounting precise)))

  close file
  cleanup path

isKnownV4Status :: V4ReportStatus -> Bool
isKnownV4Status status = case status of
  V4ReportComplete -> True
  V4ReportUnsupported -> True
  V4ReportUnknown -> True
  V4ReportStatusUnknown _ -> False

omittedFieldHasStableShape :: V4OmittedPreciseAccountingField -> Bool
omittedFieldHasStableShape field = case v4OmittedPreciseField field of
  V4PreciseAccountingFieldUnknown _ -> False
  _ -> True

testInferredAndPolicyCreate :: NativeLibrary -> IO ()
testInferredAndPolicyCreate native = do
  let inferredPath = ".test-output" </> "inferred-f64.tio"
      policyPath = ".test-output" </> "policy-f64.tio"
  cleanup inferredPath
  inferred <- unwrap "createInferred" =<< createInferred native inferredPath F64 [dim AxisTime 0, dim AxisChannel 2] 0 defaultCreateInferredOptions
  _ <- unwrap "append inferred" =<< appendDenseF64 inferred [1, 2] (VS.fromList [21.0, 22.0])
  inferredTensor <- unwrap "read inferred" =<< readAllF64 inferred
  assertTensor "inferred" [1, 2] [21.0, 22.0] inferredTensor
  close inferred
  cleanup inferredPath

  cleanup policyPath
  policy <- unwrap "createWithPolicy" =<< createWithPolicy native policyPath F64 [dim AxisTime 0, dim AxisChannel 2] 0 defaultCreatePolicyOptions
  _ <- unwrap "append policy" =<< appendDenseF64 policy [1, 2] (VS.fromList [31.0, 32.0])
  policyTensor <- unwrap "read policy" =<< readAllF64 policy
  assertTensor "policy" [1, 2] [31.0, 32.0] policyTensor
  close policy
  cleanup policyPath

testMetadataRichCreateSettersAndScalar :: NativeLibrary -> IO ()
testMetadataRichCreateSettersAndScalar native = do
  let path = ".test-output" </> "metadata-rich.tio"
      metadata =
        emptyCreateMetadata
          { createDimNames = [Just "time", Just "symbol", Just "channel"]
          , createSymbols = ["sym-a", "sym-b"]
          , createChannels = ["bid", "ask"]
          , createUserKv = [("source", "haskell-test")]
          }
  cleanup path
  file <- unwrap "createStreamingWithMetadata" =<< createStreamingWithMetadata native path F64 [dim AxisTime 0, dim AxisSymbol 2, dim AxisChannel 2] 0 metadata
  _ <- unwrap "appendDenseF64 metadata-rich" =<< appendDenseF64 file [1, 2, 2] (VS.fromList [10.5, 11.5, 12.5, 13.5])
  scalar <- unwrap "readScalar" =<< readScalar file [0, 1, 0]
  assertEqual "scalar dtype" F64 (scalarDType scalar)
  assertEqual "scalar value" 12.5 (scalarValue scalar)
  close file

  meta <- unwrap "loadMeta metadata-rich" =<< loadMeta native path
  assertEqual "metadata rich dim names" [Just "time", Just "symbol", Just "channel"] (map dimMetaName (fileMetaDims meta))
  assertEqual "metadata rich symbols" ["sym-a", "sym-b"] (map axisLabelName (fileMetaSymbols meta))
  assertEqual "metadata rich channels" ["bid", "ask"] (map axisLabelName (fileMetaChannels meta))
  assertEqual "metadata rich user kv" [("source", "haskell-test")] (map (\item -> (userKvKey item, userKvValue item)) (fileMetaUserKv meta))
  cleanup path


testCoordinateMetadataValueReads :: NativeLibrary -> IO ()
testCoordinateMetadataValueReads native = do
  assertEqual "coordinate kind timestamp raw" CoordinateTimestamp (coordinateKindFromRaw 3)
  assertEqual "coordinate encoding epoch ns raw" CoordinateEncodingEpochNanoseconds (coordinateEncodingFromRaw 6)
  assertEqual "coordinate monotonicity raw" CoordinateStrictlyIncreasing (coordinateMonotonicityFromRaw 2)
  assertEqual "coordinate availability unavailable raw" CoordinateUnavailableV2 (coordinateAvailabilityV2FromRaw 4)
  assertEqual "coordinate status unsupported-domain raw" CoordinateStatusUnsupportedDomainV2 (coordinateStatusCategoryV2FromRaw 2)
  let path = ".test-output" </> "coordinate-v2-metadata-values.tio"
  cleanup path
  file <- unwrap "createStreamingWithCoordinatesV2" =<< createStreamingWithCoordinatesV2 native path F32 [dim AxisTime 0, dim AxisChannel 2] 0 emptyCreateMetadata [channelCoordinate] defaultCoordinateV2Options{coordinateIncludeIndexSummaries = True}

  metaV2 <- unwrap "coordinateMetaV2" =<< coordinateMetaV2 file defaultCoordinateV2Options{coordinateIncludeIndexSummaries = True}
  assertEqual "coordinate meta v2 len" 1 (length metaV2)
  let firstMeta = head metaV2
  assertEqual "coordinate meta v2 axis" 1 (axisCoordinateMetaV2Axis firstMeta)
  assertEqual "coordinate meta v2 descriptor" (Just "channel-v2") (axisCoordinateMetaV2DescriptorId firstMeta)
  assertEqual "coordinate meta v2 length" 2 (axisCoordinateMetaV2Length firstMeta)
  assertEqual "coordinate meta v2 dtype" CoordinateI32 (axisCoordinateMetaV2NumericDType firstMeta)
  assertEqual "coordinate meta v2 availability" CoordinateAvailableV2 (axisCoordinateMetaV2Availability firstMeta)

  loadedMetaV2 <- unwrap "loadCoordinateMetaV2" =<< loadCoordinateMetaV2 native path
  assertEqual "load coordinate meta v2 descriptor" (map axisCoordinateMetaV2DescriptorId metaV2) (map axisCoordinateMetaV2DescriptorId loadedMetaV2)

  valuesV2 <- unwrap "readAxisCoordinatesV2" =<< readAxisCoordinatesV2 file 1 defaultCoordinateV2Options
  assertEqual "coordinate values v2 len" 2 (coordinateValueSliceLen valuesV2)
  assertEqual "coordinate values v2 element size" 4 (coordinateValueSliceElementSize valuesV2)
  assertEqual "coordinate values v2 decoded" [10, 20] (decodeI32LE (coordinateValueSliceBytes valuesV2))

  dictionary <- unwrap "coordinateDictionaryV2" =<< coordinateDictionaryV2 file 1 defaultCoordinateV2Options{coordinateIncludeDictionaryEntries = True}
  assertEqual "coordinate dictionary status is visible" CoordinateStatusUnsupportedDomainV2 (coordinateDictionaryStatusCategory dictionary)

  close file

  let emptyAxisPath = ".test-output" </> "coordinate-v2-empty-axis.tio"
  cleanup emptyAxisPath
  assertErrorCode "coordinate append-axis storage deferred" ErrorInvalidArgument =<< createStreamingWithCoordinatesV2 native emptyAxisPath F32 [dim AxisTime 0, dim AxisChannel 2] 0 emptyCreateMetadata [emptyAxisCoordinate] defaultCoordinateV2Options

  let pathV1 = ".test-output" </> "coordinate-v1-values.tio"
  cleanup pathV1
  fileV1 <- unwrap "createStreamingWithCoordinates" =<< createStreamingWithCoordinates native pathV1 F32 [dim AxisTime 0, dim AxisChannel 2] 0 emptyCreateMetadata [channelCoordinate]
  metaV1 <- unwrap "coordinateMeta" =<< coordinateMeta fileV1
  assertEqual "coordinate meta v1 len" 1 (length metaV1)
  loadedMetaV1 <- unwrap "loadCoordinateMeta" =<< loadCoordinateMeta native pathV1
  assertEqual "load coordinate meta v1 name" (map axisCoordinateMetaName metaV1) (map axisCoordinateMetaName loadedMetaV1)
  v1Tensor <- unwrapSomeI32 "readAxisCoordinates v1 tensor" =<< readAxisCoordinates fileV1 1
  assertEqual "coordinate values v1 shape" [2] (tensorShape v1Tensor)
  assertEqual "coordinate values v1" (VS.fromList [10, 20]) (tensorValues v1Tensor)
  close fileV1

  cleanup path
  cleanup pathV1
 where
  channelCoordinate =
    AxisCoordinateInputV2
      { axisCoordinateInputV2Axis = 1
      , axisCoordinateInputV2DescriptorId = "channel-v2"
      , axisCoordinateInputV2Name = "channel"
      , axisCoordinateInputV2Kind = CoordinateLabelId
      , axisCoordinateInputV2Values = CoordinateV2I32 [10, 20]
      , axisCoordinateInputV2Encoding = CoordinateEncodingPlain
      , axisCoordinateInputV2Sorted = CoordinateSortedAscending
      , axisCoordinateInputV2Monotonicity = CoordinateStrictlyIncreasing
      , axisCoordinateInputV2Uniqueness = CoordinateUnique
      , axisCoordinateInputV2Required = True
      }
  emptyAxisCoordinate =
    AxisCoordinateInputV2
      { axisCoordinateInputV2Axis = 0
      , axisCoordinateInputV2DescriptorId = "time-empty-v2"
      , axisCoordinateInputV2Name = "time"
      , axisCoordinateInputV2Kind = CoordinateTimestamp
      , axisCoordinateInputV2Values = CoordinateV2I64 []
      , axisCoordinateInputV2Encoding = CoordinateEncodingEpochNanoseconds
      , axisCoordinateInputV2Sorted = CoordinateSortedAscending
      , axisCoordinateInputV2Monotonicity = CoordinateStrictlyIncreasing
      , axisCoordinateInputV2Uniqueness = CoordinateUnique
      , axisCoordinateInputV2Required = True
      }

testCoordinateCreateValidationAndVariants :: NativeLibrary -> IO ()
testCoordinateCreateValidationAndVariants native = do
  let dims2 = [dim AxisTime 1, dim AxisChannel 2]
      coord = channelCoordinateStep2 "channel-create" "channel" [10, 20]

  let randomPath = ".test-output" </> "coordinate-v2-random-create.tio"
  cleanup randomPath
  randomFile <- unwrap "createRandomAccessWithCoordinatesV2" =<< createRandomAccessWithCoordinatesV2 native randomPath F32 dims2 0 emptyCreateMetadata [coord] defaultCoordinateV2Options
  randomValues <- unwrap "random coordinate values" =<< readAxisCoordinatesV2 randomFile 1 defaultCoordinateV2Options
  assertEqual "random coordinate values" [10, 20] (decodeI32LE (coordinateValueSliceBytes randomValues))
  exactLookup <- unwrap "coordinate exact lookup" =<< coordinateLookupV2 randomFile 1 (CoordinateLookupKeyI32 20) defaultCoordinateV2Options{coordinateAllowAuthoritativeScan = True}
  assertEqual "coordinate exact lookup status" CoordinateLookupUniqueV2 (coordinateLookupStatus exactLookup)
  assertEqual "coordinate exact lookup position" (Just 1) (coordinateLookupUniquePosition exactLookup)
  missingLookup <- unwrap "coordinate missing lookup" =<< coordinateLookupV2 randomFile 1 (CoordinateLookupKeyI32 99) defaultCoordinateV2Options{coordinateAllowAuthoritativeScan = True}
  assertEqual "coordinate missing lookup status" CoordinateLookupMissingV2 (coordinateLookupStatus missingLookup)
  rangeLookup <- unwrap "coordinate range lookup" =<< coordinateLookupRangeV2 randomFile 1 (CoordinateLookupKeyI32 10) (CoordinateLookupKeyI32 21) defaultCoordinateV2Options{coordinateAllowAuthoritativeScan = True}
  assertEqual "coordinate range lookup status" CoordinateLookupRangeV2 (coordinateLookupStatus rangeLookup)
  assertEqual "coordinate range lookup range" (Just (0, 2)) (coordinateLookupRange rangeLookup)
  close randomFile

  let inferredPath = ".test-output" </> "coordinate-v2-inferred-create.tio"
  cleanup inferredPath
  inferredFile <- unwrap "createInferredWithCoordinatesV2" =<< createInferredWithCoordinatesV2 native inferredPath F32 dims2 0 emptyCreateMetadata defaultCreateInferredOptions [coord{axisCoordinateInputV2DescriptorId = "channel-inferred"}] defaultCoordinateV2Options
  inferredMeta <- unwrap "inferred coordinate metadata" =<< coordinateMetaV2 inferredFile defaultCoordinateV2Options
  assertEqual "inferred coordinate descriptor" [Just "channel-inferred"] (map axisCoordinateMetaV2DescriptorId inferredMeta)
  close inferredFile

  let policyPath = ".test-output" </> "coordinate-v2-policy-create.tio"
  cleanup policyPath
  policyFile <- unwrap "createWithPolicyWithCoordinatesV2" =<< createWithPolicyWithCoordinatesV2 native policyPath F32 dims2 0 emptyCreateMetadata defaultCreatePolicyOptions [coord{axisCoordinateInputV2DescriptorId = "channel-policy"}] defaultCoordinateV2Options
  policyMeta <- unwrap "policy coordinate metadata" =<< coordinateMetaV2 policyFile defaultCoordinateV2Options
  assertEqual "policy coordinate descriptor" [Just "channel-policy"] (map axisCoordinateMetaV2DescriptorId policyMeta)
  close policyFile

  let v1Path = ".test-output" </> "coordinate-v1-random-create.tio"
  cleanup v1Path
  v1File <- unwrap "createRandomAccessWithCoordinates" =<< createRandomAccessWithCoordinates native v1Path F32 dims2 0 emptyCreateMetadata [coord{axisCoordinateInputV2Name = "channel-v1"}]
  v1Meta <- unwrap "v1 random coordinate metadata" =<< coordinateMeta v1File
  assertEqual "v1 random coordinate name" [Just "channel-v1"] (map axisCoordinateMetaName v1Meta)
  legacyIndex <- unwrap "coordinate index i32" =<< coordinateIndexI32 v1File 1 20
  assertEqual "coordinate index i32 result" 1 legacyIndex
  legacyRange <- unwrap "coordinate range i32" =<< coordinateRangeI32 v1File 1 10 20
  assertEqual "coordinate range i32 result" (0, 2) legacyRange
  assertErrorCode "coordinate index wrong dtype" ErrorInvalidArgument =<< coordinateIndexI64 v1File 1 20
  assertErrorCode "coordinate range invalid bounds" ErrorInvalidArgument =<< coordinateRangeI32 v1File 1 30 10
  close v1File

  let i64Path = ".test-output" </> "coordinate-v1-i64-index-range.tio"
  cleanup i64Path
  i64File <- unwrap "createRandomAccessWithCoordinates i64" =<< createRandomAccessWithCoordinates native i64Path F32 dims2 0 emptyCreateMetadata [coord{axisCoordinateInputV2Name = "channel-i64", axisCoordinateInputV2Values = CoordinateV2I64 [100, 200], axisCoordinateInputV2Encoding = CoordinateEncodingEpochNanoseconds}]
  legacyIndex64 <- unwrap "coordinate index i64" =<< coordinateIndexI64 i64File 1 200
  assertEqual "coordinate index i64 result" 1 legacyIndex64
  legacyRange64 <- unwrap "coordinate range i64" =<< coordinateRangeI64 i64File 1 100 200
  assertEqual "coordinate range i64 result" (0, 2) legacyRange64
  close i64File

  let invalidPath tag = ".test-output" </> ("coordinate-invalid-" <> tag <> ".tio")
  assertErrorCode "coordinate rank validation" ErrorInvalidArgument =<< createStreamingWithCoordinatesV2 native (invalidPath "rank") F32 [] 0 emptyCreateMetadata [coord] defaultCoordinateV2Options
  assertErrorCode "coordinate axis bounds validation" ErrorInvalidArgument =<< createStreamingWithCoordinatesV2 native (invalidPath "axis") F32 dims2 0 emptyCreateMetadata [coord{axisCoordinateInputV2Axis = 2}] defaultCoordinateV2Options
  assertErrorCode "coordinate unique axes validation" ErrorInvalidArgument =<< createStreamingWithCoordinatesV2 native (invalidPath "duplicate") F32 dims2 0 emptyCreateMetadata [coord, coord{axisCoordinateInputV2DescriptorId = "dup"}] defaultCoordinateV2Options
  assertErrorCode "coordinate append-axis exclusion" ErrorInvalidArgument =<< createStreamingWithCoordinatesV2 native (invalidPath "append") F32 dims2 0 emptyCreateMetadata [coord{axisCoordinateInputV2Axis = 0, axisCoordinateInputV2DescriptorId = "time", axisCoordinateInputV2Name = "time", axisCoordinateInputV2Values = CoordinateV2I64 [1]}] defaultCoordinateV2Options
  assertErrorCode "coordinate inline length validation" ErrorInvalidArgument =<< createStreamingWithCoordinatesV2 native (invalidPath "len") F32 dims2 0 emptyCreateMetadata [coord{axisCoordinateInputV2Values = CoordinateV2I32 [10]}] defaultCoordinateV2Options
  assertErrorCode "coordinate descriptor required" ErrorInvalidArgument =<< createStreamingWithCoordinatesV2 native (invalidPath "descriptor") F32 dims2 0 emptyCreateMetadata [coord{axisCoordinateInputV2DescriptorId = ""}] defaultCoordinateV2Options
  assertErrorCode "coordinate name required" ErrorInvalidArgument =<< createStreamingWithCoordinatesV2 native (invalidPath "name") F32 dims2 0 emptyCreateMetadata [coord{axisCoordinateInputV2Name = ""}] defaultCoordinateV2Options
  assertErrorCode "coordinate interior nul validation" ErrorInvalidArgument =<< createStreamingWithCoordinatesV2 native (invalidPath "nul") F32 dims2 0 emptyCreateMetadata [coord{axisCoordinateInputV2Name = "bad\0name"}] defaultCoordinateV2Options
 where
  channelCoordinateStep2 descriptor name values =
    AxisCoordinateInputV2
      { axisCoordinateInputV2Axis = 1
      , axisCoordinateInputV2DescriptorId = descriptor
      , axisCoordinateInputV2Name = name
      , axisCoordinateInputV2Kind = CoordinateLabelId
      , axisCoordinateInputV2Values = CoordinateV2I32 values
      , axisCoordinateInputV2Encoding = CoordinateEncodingPlain
      , axisCoordinateInputV2Sorted = CoordinateSortedAscending
      , axisCoordinateInputV2Monotonicity = CoordinateStrictlyIncreasing
      , axisCoordinateInputV2Uniqueness = CoordinateUnique
      , axisCoordinateInputV2Required = True
      }

testAppendAxisCoordinateBatches :: NativeLibrary -> IO ()
testAppendAxisCoordinateBatches native = do
  let path = ".test-output" </> "coordinate-v2-append-axis.tio"
  cleanup path
  file <- unwrap "createStreaming append coordinates" =<< createStreamingWithCoordinatesV2 native path F32 [dim AxisTime 0, dim AxisChannel 2] 0 emptyCreateMetadata [appendTimeDescriptor] defaultCoordinateV2Options
  appended <- unwrap "appendDenseF32WithCoordinatesV2" =<< appendDenseF32WithCoordinatesV2 file [2, 2] (VS.fromList [1.0, 2.0, 3.0, 4.0]) [appendTimeCoordinate [1000, 2000]]
  assertEqual "append coordinate assigned range" (AppendRange 0 2) appended
  values <- unwrap "read appended axis coordinates" =<< readAxisCoordinatesV2 file 0 defaultCoordinateV2Options
  assertEqual "append coordinate value domain" CoordinateV2AppendSequence (coordinateValueSliceDomain values)
  assertEqual "append coordinate values deferred" 0 (coordinateValueSliceLen values)
  assertEqual "append coordinate read status" CoordinateStatusUnsupportedDomainV2 (coordinateValueSliceStatusCategory values)
  exact <- unwrap "lookup appended coordinate" =<< coordinateLookupV2 file 0 (CoordinateLookupKeyI64 2000) defaultCoordinateV2Options{coordinateAllowAuthoritativeScan = True}
  assertEqual "lookup appended numeric coordinate status" CoordinateLookupErrorV2 (coordinateLookupStatus exact)
  close file

  smokeAppend "f64" F64 appendDenseF64WithCoordinatesV2 (VS.fromList [1.0, 2.0, 3.0, 4.0] :: VS.Vector Double)
  smokeAppend "i32" I32 appendDenseI32WithCoordinatesV2 (VS.fromList ([1, 2, 3, 4] :: [Int32]))
  smokeAppend "i64" I64 appendDenseI64WithCoordinatesV2 (VS.fromList ([10, 20, 30, 40] :: [Int64]))
 where
  appendTimeDescriptor =
    AxisCoordinateInputV2
      { axisCoordinateInputV2Axis = 0
      , axisCoordinateInputV2DescriptorId = "time-append"
      , axisCoordinateInputV2Name = "time"
      , axisCoordinateInputV2Kind = CoordinateTimestamp
      , axisCoordinateInputV2Values = CoordinateV2AppendSequenceValues CoordinateI64
      , axisCoordinateInputV2Encoding = CoordinateEncodingEpochNanoseconds
      , axisCoordinateInputV2Sorted = CoordinateSortedAscending
      , axisCoordinateInputV2Monotonicity = CoordinateStrictlyIncreasing
      , axisCoordinateInputV2Uniqueness = CoordinateUnique
      , axisCoordinateInputV2Required = True
      }
  appendTimeCoordinate values =
    AppendCoordinateEntryV2
      { appendCoordinateEntryAxis = 0
      , appendCoordinateEntryDescriptorId = "time-append"
      , appendCoordinateEntryName = "time"
      , appendCoordinateEntryValues = CoordinateV2I64 values
      , appendCoordinateEntryEncoding = CoordinateEncodingEpochNanoseconds
      }
  smokeAppend label payloadDType appendFn payload = do
    let smokePath = ".test-output" </> ("coordinate-v2-append-axis-" <> label <> ".tio")
    cleanup smokePath
    smokeFile <- unwrap ("createStreaming append coordinates " <> label) =<< createStreamingWithCoordinatesV2 native smokePath payloadDType [dim AxisTime 0, dim AxisChannel 2] 0 emptyCreateMetadata [appendTimeDescriptor] defaultCoordinateV2Options
    smokeRange <- unwrap ("append with coordinates " <> label) =<< appendFn smokeFile [2, 2] payload [appendTimeCoordinate [11, 22]]
    assertEqual ("append coordinate range " <> label) (AppendRange 0 2) smokeRange
    smokeLookup <- unwrap ("lookup appended coordinate " <> label) =<< coordinateLookupV2 smokeFile 0 (CoordinateLookupKeyI64 22) defaultCoordinateV2Options{coordinateAllowAuthoritativeScan = True}
    assertEqual ("lookup appended numeric coordinate status " <> label) CoordinateLookupErrorV2 (coordinateLookupStatus smokeLookup)
    close smokeFile

testUniverseAuthoringAndReads :: NativeLibrary -> IO ()
testUniverseAuthoringAndReads native = do
  let family = TioUuid [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
      version = TioUuid [16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31]
      createOptions = CreateWithUniverseOptions [AxisIdentityInput 1 AxisIdentityUniverseAware]
      slot = SlotUniverseBindingInput [UniverseBindingInput 1 family version 2]
      appendOptions = AppendWithUniverseOptions [slot, slot] []
      explicitPolicy = ReadShapeExplicitUniverse [ExplicitUniverseAxisTarget 1 family version 2]

  let streamPath = ".test-output" </> "universe-streaming.tio"
  cleanup streamPath
  streamFile <- unwrap "createStreamingWithUniverse" =<< createStreamingWithUniverse native streamPath F32 [dim AxisTime 0, dim AxisChannel 2] 0 emptyCreateMetadata createOptions
  streamRange <- unwrap "appendDenseF32WithUniverse" =<< appendDenseF32WithUniverse streamFile [2, 2] (VS.fromList [1.0, 2.0, 3.0, 4.0]) appendOptions
  assertEqual "universe append range" (AppendRange 0 2) streamRange
  universeRead <- unwrapSomeF32 "readWithShapePolicy explicit universe" =<< fmap fst <$> readWithShapePolicy streamFile [] defaultReadOptions explicitPolicy
  assertEqual "explicit universe read shape" [2, 2] (tensorShape universeRead)
  assertEqual "explicit universe read values" (VS.fromList [1.0, 2.0, 3.0, 4.0]) (tensorValues universeRead)
  assertErrorCode "explicit universe malformed uuid validation" ErrorInvalidArgument =<< readWithShapePolicy streamFile [] defaultReadOptions (ReadShapeExplicitUniverse [ExplicitUniverseAxisTarget 1 (TioUuid [1, 2, 3]) version 2])
  close streamFile

  let randomPath = ".test-output" </> "universe-random.tio"
  cleanup randomPath
  randomFile <- unwrap "createRandomAccessWithUniverse" =<< createRandomAccessWithUniverse native randomPath F64 [dim AxisTime 0, dim AxisChannel 2] 0 emptyCreateMetadata createOptions
  randomRange <- unwrap "appendDenseF64WithUniverse" =<< appendDenseF64WithUniverse randomFile [1, 2] (VS.fromList [5.0, 6.0]) (AppendWithUniverseOptions [slot] [])
  assertEqual "random universe append range" (AppendRange 0 1) randomRange
  close randomFile

  let policyPath = ".test-output" </> "universe-policy.tio"
  cleanup policyPath
  policyFile <- unwrap "createWithPolicyWithUniverse" =<< createWithPolicyWithUniverse native policyPath I32 [dim AxisTime 0, dim AxisChannel 2] 0 emptyCreateMetadata defaultCreatePolicyOptions createOptions
  policyRange <- unwrap "appendDenseI32WithUniverse" =<< appendDenseI32WithUniverse policyFile [1, 2] (VS.fromList ([7, 8] :: [Int32])) (AppendWithUniverseOptions [slot] [])
  assertEqual "policy universe append range" (AppendRange 0 1) policyRange
  close policyFile

  assertErrorCode "universe uuid validation" ErrorInvalidArgument =<< createStreamingWithUniverse native (".test-output" </> "universe-invalid.tio") F32 [dim AxisTime 0] 0 emptyCreateMetadata (CreateWithUniverseOptions [AxisIdentityInput 1 AxisIdentityUniverseAware])

testOcbReadBatchesAndAttribution :: NativeLibrary -> IO ()
testOcbReadBatchesAndAttribution native = do
  assertEqual "OCB read request size" 104 (sizeOf C.emptyCArcadiaTioOcbReadRequest)
  assertEqual "OCB row-group predicate size" 208 (sizeOf C.emptyCArcadiaTioOcbRowGroupPredicate)
  assertEqual "OCB read report size" 96 (sizeOf C.emptyCArcadiaTioOcbReadReport)
  assertEqual "OCB read attribution size" 208 (sizeOf C.emptyCArcadiaTioOcbReadAttribution)
  assertEqual "OCB read outcome size" 160 (sizeOf C.emptyCArcadiaTioOcbReadOutcome)
  assertEqual "OCB cursor options size" 96 (sizeOf C.emptyCArcadiaTioOcbReadCursorOptions)
  assertEqual "OCB cursor report size" 168 (sizeOf C.emptyCArcadiaTioOcbReadCursorReport)
  assertEqual "OCB fill buffer size" 160 (sizeOf C.emptyCArcadiaTioOcbColumnFillBuffer)
  assertEqual "OCB row-group fill request size" 112 (sizeOf C.emptyCArcadiaTioOcbRowGroupFillRequest)
  assertEqual "OCB read fill report size" 112 (sizeOf C.emptyCArcadiaTioOcbReadFillReport)
  let fixedBinaryColumn =
        C.CArcadiaTioOcbColumnArray
          1
          216
          0
          nullPtr
          4
          0
          0
          0
          C.emptyCArcadiaTioOcbPrimitiveValues
          0
          C.emptyCArcadiaTioOcbValidityBitmap
          7
          0
          0
          0
  fixedWidth <- withArray [fixedBinaryColumn] $ \columnPtr -> C.capiOcbColumnArrayFixedBinaryWidth native columnPtr
  assertEqual "OCB fixed-binary column array width preservation" 7 fixedWidth
  alloca $ \optionsPtr -> do
    C.capiOcbOpenOptionsInit native optionsPtr
    options <- peek optionsPtr
    assertEqual "OCB open options init struct size" 56 (fromIntegral (C.cOcbOpenOptionsStructSize options) :: Int)
    assertEqual "OCB open options init validation" 0 (fromIntegral (C.cOcbOpenOptionsValidation options) :: Int)
  alloca $ \predicateValuePtr -> do
    C.capiOcbPredicateValueInit native predicateValuePtr
    predicateValue <- peek predicateValuePtr
    assertEqual "OCB predicate value init struct size" 72 (fromIntegral (C.cOcbPredicateValueStructSize predicateValue) :: Int)
    assertEqual "OCB predicate value init physical" 0 (fromIntegral (C.cOcbPredicateValuePhysicalType predicateValue) :: Int)
  alloca $ \predicatePtr -> do
    C.capiOcbRowGroupPredicateInit native predicatePtr
    predicate <- peek predicatePtr
    assertEqual "OCB row-group predicate init struct size" 208 (fromIntegral (C.cOcbRowGroupPredicateStructSize predicate) :: Int)
    assertEqual "OCB row-group predicate init lower" 0 (fromIntegral (C.cOcbRowGroupPredicateHasLower predicate) :: Int)
    assertEqual "OCB row-group predicate init upper" 0 (fromIntegral (C.cOcbRowGroupPredicateHasUpper predicate) :: Int)
  alloca $ \descriptorPtr -> do
    poke descriptorPtr (C.CArcadiaTioOcbColumnDescriptor 1 80 0 nullPtr 0 0 0 0 0 0)
    descriptorWidth <- C.capiOcbColumnDescriptorFixedBinaryWidth native descriptorPtr
    assertEqual "OCB non-fixed descriptor width" 0 descriptorWidth
  alloca $ \requestPtr -> do
    C.capiOcbReadRequestInit native requestPtr
    request <- peek requestPtr
    assertEqual "OCB read request init struct size" 104 (fromIntegral (C.cOcbReadRequestStructSize request) :: Int)
    assertEqual "OCB read request init max threads" 1 (fromIntegral (C.cOcbReadRequestMaxThreads request) :: Int)
  alloca $ \reportPtr -> do
    C.capiOcbReadReportInit native reportPtr
    report <- peek reportPtr
    assertEqual "OCB read report init struct size" 96 (fromIntegral (C.cOcbReadReportStructSize report) :: Int)
    C.capiOcbReadReportFree native reportPtr
  alloca $ \attributionPtr -> do
    C.capiOcbReadAttributionInit native attributionPtr
    attribution <- peek attributionPtr
    assertEqual "OCB read attribution init struct size" 208 (fromIntegral (C.cOcbReadAttributionStructSize attribution) :: Int)
    C.capiOcbReadAttributionFree native attributionPtr
  alloca $ \outcomePtr -> do
    C.capiOcbReadOutcomeInit native outcomePtr
    outcome <- peek outcomePtr
    assertEqual "OCB read outcome init struct size" 160 (fromIntegral (C.cOcbReadOutcomeStructSize outcome) :: Int)
    C.capiOcbReadOutcomeFree native outcomePtr
  alloca $ \cursorOptionsPtr -> do
    C.capiOcbReadCursorOptionsInit native cursorOptionsPtr
    cursorOptions <- peek cursorOptionsPtr
    assertEqual "OCB cursor options init struct size" 96 (fromIntegral (C.cOcbReadCursorOptionsStructSize cursorOptions) :: Int)
  alloca $ \cursorReportPtr -> do
    C.capiOcbReadCursorReportInit native cursorReportPtr
    cursorReport <- peek cursorReportPtr
    assertEqual "OCB cursor report init struct size" 168 (fromIntegral (C.cOcbReadCursorReportStructSize cursorReport) :: Int)
    C.capiOcbReadCursorReportFree native cursorReportPtr
  alloca $ \fillBufferPtr -> do
    C.capiOcbColumnFillBufferInit native fillBufferPtr
    C.capiOcbColumnFillBufferSetFixedBinaryWidth native fillBufferPtr 9
    fillBuffer <- peek fillBufferPtr
    fillWidth <- C.capiOcbColumnFillBufferFixedBinaryWidth native fillBufferPtr
    assertEqual "OCB fill buffer init struct size" 160 (fromIntegral (C.cOcbColumnFillBufferStructSize fillBuffer) :: Int)
    assertEqual "OCB fill buffer fixed width helper" 9 fillWidth
  alloca $ \fillRequestPtr -> do
    C.capiOcbRowGroupFillRequestInit native fillRequestPtr
    fillRequest <- peek fillRequestPtr
    assertEqual "OCB row-group fill request init struct size" 112 (fromIntegral (C.cOcbRowGroupFillRequestStructSize fillRequest) :: Int)
  alloca $ \fillReportPtr -> do
    C.capiOcbReadFillReportInit native fillReportPtr
    fillReport <- peek fillReportPtr
    assertEqual "OCB read fill report init struct size" 112 (fromIntegral (C.cOcbReadFillReportStructSize fillReport) :: Int)
  fixture <- discoverOcbFixture
  case fixture of
    Nothing -> putStrLn "SKIP: OCB projection-predicate fixture not found for read/attribution smoke"
    Just path -> do
      file <- unwrap "OCB open projection-predicate fixture" =<< Ocb.openWithOptions native path Ocb.defaultOcbOpenOptions
      cloned <- unwrap "OCB reader clone" =<< Ocb.clone file
      Ocb.close cloned
      let request =
            Ocb.defaultOcbReadRequest
              { Ocb.ocbReadProjection = Ocb.OcbProjectionNames ["metric"]
              , Ocb.ocbReadPredicates =
                  [ Ocb.OcbRowGroupPredicate
                      { Ocb.ocbPredicateColumn = "partition_key"
                      , Ocb.ocbPredicateLower = Just (Ocb.OcbPredicateI32 32)
                      , Ocb.ocbPredicateUpper = Just (Ocb.OcbPredicateI32 32)
                      }
                  ]
              , Ocb.ocbReadMaxThreads = 2
              }
      assertErrorCode "OCB readBatches negative maxThreads" ErrorInvalidArgument =<< Ocb.readBatches file request{Ocb.ocbReadMaxThreads = -1}
      assertErrorCode "OCB readBatchesWithAttribution negative maxThreads" ErrorInvalidArgument =<< Ocb.readBatchesWithAttribution file request{Ocb.ocbReadMaxThreads = -1}
      outcome <- unwrap "OCB readBatches" =<< Ocb.readBatches file request
      assertOcbProjectionPredicateOutcome "OCB readBatches" outcome
      attributed <- unwrap "OCB readBatchesWithAttribution" =<< Ocb.readBatchesWithAttribution file request
      assertOcbProjectionPredicateOutcome "OCB attributed outcome" (Ocb.ocbAttributedOutcome attributed)
      let attribution = Ocb.ocbReadAttribution attributed
      assertEqual "OCB attribution selected row groups" 1 (Ocb.ocbAttributionSelectedRowGroups attribution)
      assertEqual "OCB attribution pruned row groups" 2 (Ocb.ocbAttributionPrunedRowGroups attribution)
      assertEqual "OCB attribution selected chunks" 1 (Ocb.ocbAttributionSelectedColumnChunks attribution)
      assertEqual "OCB attribution fallback" (Just "too_few_row_groups") (Ocb.ocbAttributionFallbackReason attribution)
      plan <- unwrap "OCB planRead" =<< Ocb.planRead file request
      planReport <- unwrap "OCB readPlanReport" =<< Ocb.readPlanReport plan
      assertEqual "OCB plan report selected row groups" 1 (Ocb.ocbReadSelectedRowGroups planReport)
      projectedIds <- unwrap "OCB readPlanProjectedColumnIds" =<< Ocb.readPlanProjectedColumnIds plan
      assertEqual "OCB plan projected column count" 1 (length projectedIds)
      rowGroupIds <- unwrap "OCB readPlanRowGroupIds" =<< Ocb.readPlanRowGroupIds plan
      assertEqual "OCB plan row-group count" 1 (length rowGroupIds)
      plannedOutcome <- unwrap "OCB readBatchesFromPlan" =<< Ocb.readBatchesFromPlan file plan []
      assertOcbProjectionPredicateOutcome "OCB readBatchesFromPlan" plannedOutcome
      summaries <- unwrap "OCB rowGroupSummaries" =<< Ocb.rowGroupSummaries file
      assertEqual "OCB row-group summaries non-empty" True (not (null (Ocb.ocbRowGroupSummaries summaries)))
      planSummaries <- unwrap "OCB readPlanRowGroupSummaries" =<< Ocb.readPlanRowGroupSummaries file plan
      assertEqual "OCB plan summaries selected count" 1 (length (Ocb.ocbRowGroupSummaries planSummaries))
      Ocb.closeReadPlan plan
      Ocb.close file


testOcbCreateAppendSmoke :: NativeLibrary -> IO ()
testOcbCreateAppendSmoke native = do
  let plainPath = ".test-output" </> "ocb-create-append-smoke.ocb"
      optionsPath = ".test-output" </> "ocb-create-options-smoke.ocb"
      dictionaryPath = ".test-output" </> "ocb-dictionary-smoke.ocb"
      fixedPath = ".test-output" </> "ocb-fixed-binary-smoke.ocb"
      cleanupBoth = cleanup plainPath >> cleanup optionsPath >> cleanup dictionaryPath >> cleanup fixedPath
  cleanupBoth
  (`finally` cleanupBoth) $ do

    unwrap "OCB create" =<< Ocb.create native plainPath (i32WriteSpec [1, 2, 3])
    plainFile <- unwrap "OCB open created" =<< Ocb.open native plainPath
    plainMeta <- unwrap "OCB metadata created" =<< Ocb.metadata plainFile
    assertEqual "OCB created row count" 3 (Ocb.ocbRowCount plainMeta)
    case Ocb.ocbColumns plainMeta of
      [column] -> do
        assertEqual "OCB metadata physical raw" 0 (Ocb.ocbPhysicalTypeToRaw (Ocb.ocbColumnPhysicalType column))
        assertEqual "OCB metadata logical raw" 0 (Ocb.ocbLogicalKindToRaw (Ocb.ocbColumnLogicalKind column))
      other -> error ("OCB metadata expected one column, got " <> show (length other))
    case Ocb.ocbOrderingKeys plainMeta of
      [ordering] -> do
        assertEqual "OCB metadata ordering raw" 0 (Ocb.ocbOrderingDirectionToRaw (Ocb.ocbOrderingDirection ordering))
        assertEqual "OCB metadata null-order raw" 2 (Ocb.ocbNullOrderToRaw (Ocb.ocbOrderingNullOrder ordering))
      other -> error ("OCB metadata expected one ordering key, got " <> show (length other))
    assertOcbReadI32 "OCB created read" [1, 2, 3] plainFile
    Ocb.close plainFile

    unwrap "OCB appendWithOptions" =<< Ocb.appendWithOptions native plainPath (i32WriteSpec [4, 5]) Ocb.defaultOcbWriteOptions{Ocb.ocbWriteChunkCodec = Ocb.OcbWriteChunkCodecNone}
    appendedFile <- unwrap "OCB open appended" =<< Ocb.open native plainPath
    appendedMeta <- unwrap "OCB metadata appended" =<< Ocb.metadata appendedFile
    assertEqual "OCB appended row count" 5 (Ocb.ocbRowCount appendedMeta)
    assertEqual "OCB appended previous generation" True (maybe False (const True) (Ocb.ocbPreviousRootGeneration appendedMeta))
    assertOcbReadI32 "OCB appended read" [1, 2, 3, 4, 5] appendedFile
    Ocb.close appendedFile

    unwrap "OCB createWithOptions" =<< Ocb.createWithOptions native optionsPath (i32WriteSpec [10, 11]) Ocb.defaultOcbWriteOptions{Ocb.ocbWriteThreads = 1}
    unwrap "OCB append" =<< Ocb.append native optionsPath (i32WriteSpec [12])
    optionsFile <- unwrap "OCB open options appended" =<< Ocb.open native optionsPath
    assertOcbReadI32 "OCB createWithOptions/append read" [10, 11, 12] optionsFile
    Ocb.close optionsFile

    unwrap "OCB dictionary create" =<< Ocb.create native dictionaryPath dictionaryWriteSpec
    dictionaryFile <- unwrap "OCB open dictionary" =<< Ocb.open native dictionaryPath
    dictionaryMeta <- unwrap "OCB dictionary metadata" =<< Ocb.metadata dictionaryFile
    assertEqual "OCB dictionary descriptor count" 1 (length (Ocb.ocbDictionaries dictionaryMeta))
    case Ocb.ocbDictionaries dictionaryMeta of
      [dictionary] -> assertEqual "OCB dictionary metadata value kind raw" 0 (Ocb.ocbDictionaryValueKindToRaw (Ocb.ocbDictionaryValueKind dictionary))
      other -> error ("OCB dictionary metadata expected one dictionary, got " <> show (length other))
    values <- unwrap "OCB dictionary values" =<< Ocb.dictionaryValues dictionaryFile 1
    assertEqual "OCB dictionary value entries" ["low", "high"] (Ocb.ocbDictionaryStringValues values)
    assertOcbReadI32 "OCB dictionary code read" [0, 0, 1] dictionaryFile
    summaries <- unwrap "OCB dictionary summaries" =<< Ocb.rowGroupSummaries dictionaryFile
    assertEqual "OCB dictionary summary count" 1 (length (Ocb.ocbRowGroupSummaries summaries))
    let chunks = concatMap Ocb.ocbSummaryChunks (Ocb.ocbRowGroupSummaries summaries)
    assertEqual "OCB dictionary summary chunks" True (not (null chunks))
    case chunks of
      (chunk:_) -> do
        assertEqual "OCB chunk summary physical raw" 0 (Ocb.ocbPhysicalTypeToRaw (Ocb.ocbChunkPhysicalType chunk))
        assertEqual "OCB chunk summary logical raw" 3 (Ocb.ocbLogicalKindToRaw (Ocb.ocbChunkLogicalKind chunk))
        assertEqual "OCB chunk summary codec raw known" True (Ocb.ocbChunkSummaryCodecToRaw (Ocb.ocbChunkCodec chunk) >= 0)
        assertEqual "OCB chunk summary value body raw known" True (Ocb.ocbBodyKindToRaw (Ocb.ocbBodyRefKind (Ocb.ocbChunkValueRef chunk)) >= 0)
        assertEqual "OCB chunk summary checksum raw known" True (Ocb.ocbChecksumKindToRaw (Ocb.ocbBodyRefChecksumKind (Ocb.ocbChunkValueRef chunk)) >= 0)
      [] -> error "OCB dictionary summaries expected at least one chunk"
    Ocb.close dictionaryFile

    unwrap "OCB fixed-binary create" =<< Ocb.create native fixedPath fixedBinaryWriteSpec
    fixedFile <- unwrap "OCB fixed-binary open" =<< Ocb.openWithOptions native fixedPath Ocb.defaultOcbOpenOptions{Ocb.ocbOpenValidation = Ocb.OcbOpenValidationFullPayload}
    fixedMeta <- unwrap "OCB fixed-binary metadata" =<< Ocb.metadata fixedFile
    case Ocb.ocbColumns fixedMeta of
      [column] -> do
        assertEqual "OCB fixed-binary metadata physical" Ocb.OcbPhysicalFixedBinary (Ocb.ocbColumnPhysicalType column)
        assertEqual "OCB fixed-binary metadata width" 3 (Ocb.ocbColumnFixedBinaryWidth column)
      other -> error ("OCB fixed-binary metadata expected one column, got " <> show (length other))
    fixedOutcome <- unwrap "OCB fixed-binary read" =<< Ocb.readBatches fixedFile Ocb.defaultOcbReadRequest
    case concatMap Ocb.ocbBatchColumns (Ocb.ocbOutcomeBatches fixedOutcome) of
      [column] -> assertEqual "OCB fixed-binary read bytes" (Ocb.OcbValuesFixedBinary 3 [1,2,3,4,5,6]) (Ocb.ocbArrayValues column)
      other -> error ("OCB fixed-binary read expected one column, got " <> show (length other))
    Ocb.close fixedFile

    assertErrorCode "OCB openWithOptions rejects NUL path" ErrorInvalidArgument =<< Ocb.openWithOptions native "bad\0path" Ocb.defaultOcbOpenOptions

    withBinaryFile plainPath AppendMode $ \handle -> hPutStr handle "deterministic orphan tail"
    truncated <- unwrap "OCB cleanup orphan tail" =<< Ocb.cleanupOrphanTail native plainPath
    assertEqual "OCB cleanup truncated" True (Ocb.ocbCleanupTruncated truncated)
    cleanedFile <- unwrap "OCB open cleaned" =<< Ocb.open native plainPath
    assertOcbReadI32 "OCB cleaned read" [1, 2, 3, 4, 5] cleanedFile
    Ocb.close cleanedFile
    cleanNoop <- unwrap "OCB cleanup clean no-op" =<< Ocb.cleanupOrphanTail native plainPath
    assertEqual "OCB cleanup no-op" False (Ocb.ocbCleanupTruncated cleanNoop)

testOcbRowGroupFill :: NativeLibrary -> IO ()
testOcbRowGroupFill native = do
  let fillPath = ".test-output" </> "ocb-row-group-fill-smoke.ocb"
      fixedFillPath = ".test-output" </> "ocb-row-group-fill-fixed.ocb"
      cleanupBoth = cleanup fillPath >> cleanup fixedFillPath
  cleanupBoth
  (`finally` cleanupBoth) $ do
    unwrap "OCB fill create" =<< Ocb.create native fillPath (nullableI32WriteSpec [7, 8, 9] (Ocb.OcbValidityBitmap [0x05] 3))
    fillFile <- unwrap "OCB fill open" =<< Ocb.open native fillPath
    filled <- unwrap "OCB readRowGroupInto i32" =<< Ocb.readRowGroupInto fillFile (fillRequest (Ocb.OcbValuesI32 [0, 0, 0, 99]) (Just (Ocb.OcbValidityBitmap [0x00] 8)))
    assertEqual "OCB fill report row count" 3 (Ocb.ocbFillReportRowCount (Ocb.ocbFillResultReport filled))
    case Ocb.ocbFillResultColumns filled of
      [column] -> do
        assertEqual "OCB fill rows" 3 (Ocb.ocbFilledRows column)
        assertEqual "OCB fill values" (Ocb.OcbValuesI32 [7, 8, 9]) (Ocb.ocbFilledColumnValues column)
        assertEqual "OCB fill resolved id" 0 (Ocb.ocbFilledColumnId column)
        assertEqual "OCB fill validity" (Just (Ocb.OcbValidityBitmap [0x05] 3)) (Ocb.ocbFilledColumnValidity column)
      other -> error ("OCB fill expected one column, got " <> show (length other))
    assertErrorCode "OCB fill capacity validation" ErrorInvalidArgument =<< Ocb.readRowGroupInto fillFile (fillRequest (Ocb.OcbValuesI32 [0, 0]) Nothing)
    assertErrorCode "OCB fill validity capacity validation" ErrorInvalidArgument =<< Ocb.readRowGroupInto fillFile (fillRequest (Ocb.OcbValuesI32 [0, 0, 0]) (Just (Ocb.OcbValidityBitmap [] 0)))
    assertErrorCode "OCB fill missing row group validation" ErrorInvalidArgument =<< Ocb.readRowGroupInto fillFile (fillRequest (Ocb.OcbValuesI32 [0, 0, 0]) Nothing){Ocb.ocbFillRowGroupId = 99}
    Ocb.close fillFile

    unwrap "OCB fixed fill create" =<< Ocb.create native fixedFillPath fixedBinaryWriteSpec
    fixedFile <- unwrap "OCB fixed fill open" =<< Ocb.open native fixedFillPath
    fixedFilled <- unwrap "OCB readRowGroupInto fixed" =<< Ocb.readRowGroupInto fixedFile (fixedFillRequest (Ocb.OcbValuesFixedBinary 3 [0,0,0,0,0,0,0,0,0]))
    case Ocb.ocbFillResultColumns fixedFilled of
      [column] -> assertEqual "OCB fixed fill bytes" (Ocb.OcbValuesFixedBinary 3 [1,2,3,4,5,6]) (Ocb.ocbFilledColumnValues column)
      other -> error ("OCB fixed fill expected one column, got " <> show (length other))
    assertErrorCode "OCB fixed fill width validation" ErrorInvalidArgument =<< Ocb.readRowGroupInto fixedFile (fixedFillRequest (Ocb.OcbValuesFixedBinary 2 [0,0,0,0,0,0]))
    assertErrorCode "OCB fixed fill byte divisibility validation" ErrorInvalidArgument =<< Ocb.readRowGroupInto fixedFile (fixedFillRequest (Ocb.OcbValuesFixedBinary 3 [0,0,0,0]))
    Ocb.close fixedFile
 where
  fillRequest values validity =
    Ocb.OcbRowGroupFillRequest
      { Ocb.ocbFillRowGroupId = 0
      , Ocb.ocbFillColumns = [Ocb.OcbFillColumn (Just "value") Nothing values validity]
      , Ocb.ocbFillValidateChecksums = True
      }
  fixedFillRequest values =
    Ocb.OcbRowGroupFillRequest
      { Ocb.ocbFillRowGroupId = 0
      , Ocb.ocbFillColumns = [Ocb.OcbFillColumn (Just "blob") Nothing values Nothing]
      , Ocb.ocbFillValidateChecksums = True
      }

testOcbVisitBatches :: NativeLibrary -> IO ()
testOcbVisitBatches native = do
  let visitPath = ".test-output" </> "ocb-visit-batches-smoke.ocb"
  cleanup visitPath
  (`finally` cleanup visitPath) $ do
    unwrap "OCB visit create" =<< Ocb.create native visitPath multiRowI32WriteSpec
    file <- unwrap "OCB visit open" =<< Ocb.open native visitPath

    seenRef <- newIORef []
    report <- unwrap "OCB visitBatches success" =<< Ocb.visitBatches file Ocb.defaultOcbReadRequest Ocb.defaultOcbReadCursorOptions (\batch -> do
      modifyIORef' seenRef (batch :)
      pure (Right Ocb.OcbVisitContinue))
    seen <- readIORef seenRef
    assertEqual "OCB visit success batches" 2 (length seen)
    assertEqual "OCB visit report batches" 2 (Ocb.ocbCursorBatchesYielded report)
    assertEqual "OCB visit report rows" 4 (Ocb.ocbCursorRowsYielded report)
    assertEqual "OCB visit report cancelled" False (Ocb.ocbCursorCancelled report)

    stopRef <- newIORef (0 :: Int)
    stopReport <- unwrap "OCB visitBatches early stop" =<< Ocb.visitBatches file Ocb.defaultOcbReadRequest Ocb.defaultOcbReadCursorOptions (\_batch -> do
      modifyIORef' stopRef (+ 1)
      pure (Right Ocb.OcbVisitStop))
    stopCount <- readIORef stopRef
    assertEqual "OCB visit early stop count" 1 stopCount
    assertEqual "OCB visit early stop batches" 1 (Ocb.ocbCursorBatchesYielded stopReport)

    assertErrorCode "OCB visit callback error" ErrorInvalidArgument =<< Ocb.visitBatches file Ocb.defaultOcbReadRequest Ocb.defaultOcbReadCursorOptions (\_batch -> pure (Left (invalidArgument "visitor requested failure")))
    retryReport <- unwrap "OCB visitBatches retry after error" =<< Ocb.visitBatches file Ocb.defaultOcbReadRequest Ocb.defaultOcbReadCursorOptions (\_batch -> pure (Right Ocb.OcbVisitContinue))
    assertEqual "OCB visit retry batches" 2 (Ocb.ocbCursorBatchesYielded retryReport)
    Ocb.close file

fixedBinaryWriteSpec :: Ocb.OcbWriteSpec
fixedBinaryWriteSpec =
  Ocb.OcbWriteSpec
    { Ocb.ocbWriteColumns =
        [ Ocb.OcbWriteColumn
            { Ocb.ocbWriteColumnName = "blob"
            , Ocb.ocbWriteColumnPhysicalType = Ocb.OcbPhysicalFixedBinary
            , Ocb.ocbWriteColumnLogicalKind = Ocb.OcbLogicalOpaqueKey
            , Ocb.ocbWriteColumnDictionaryId = Nothing
            , Ocb.ocbWriteColumnScale = 0
            , Ocb.ocbWriteColumnNullable = False
            , Ocb.ocbWriteColumnFixedBinaryWidth = Just 3
            }
        ]
    , Ocb.ocbWriteDictionaries = []
    , Ocb.ocbWriteRowGroups = [Ocb.OcbWriteRowGroup [Ocb.OcbWriteColumnChunk 0 (Ocb.OcbValuesFixedBinary 3 [1,2,3,4,5,6]) Nothing]]
    , Ocb.ocbWriteOrderingKeys = []
    }

dictionaryWriteSpec :: Ocb.OcbWriteSpec
dictionaryWriteSpec =
  Ocb.OcbWriteSpec
    { Ocb.ocbWriteColumns =
        [ Ocb.OcbWriteColumn
            { Ocb.ocbWriteColumnName = "value"
            , Ocb.ocbWriteColumnPhysicalType = Ocb.OcbPhysicalI32
            , Ocb.ocbWriteColumnLogicalKind = Ocb.OcbLogicalDictionaryCode
            , Ocb.ocbWriteColumnDictionaryId = Just 1
            , Ocb.ocbWriteColumnScale = 0
            , Ocb.ocbWriteColumnNullable = False
            , Ocb.ocbWriteColumnFixedBinaryWidth = Nothing
            }
        ]
    , Ocb.ocbWriteDictionaries =
        [ Ocb.OcbWriteDictionary
            { Ocb.ocbWriteDictionaryId = 1
            , Ocb.ocbWriteDictionaryName = "kind"
            , Ocb.ocbWriteDictionaryCodePhysicalType = Ocb.OcbPhysicalI32
            , Ocb.ocbWriteDictionaryValueKind = Ocb.OcbDictionaryUtf8
            , Ocb.ocbWriteDictionaryFixedWidth = 0
            , Ocb.ocbWriteDictionaryEntries = [Ocb.OcbDictionaryEntryUtf8 "low", Ocb.OcbDictionaryEntryUtf8 "high"]
            }
        ]
    , Ocb.ocbWriteRowGroups = [Ocb.OcbWriteRowGroup [Ocb.OcbWriteColumnChunk 0 (Ocb.OcbValuesI32 [0, 0, 1]) Nothing]]
    , Ocb.ocbWriteOrderingKeys = [Ocb.OcbWriteOrderingKey 0 Ocb.OcbOrderingAscending Ocb.OcbNoNulls]
    }

multiRowI32WriteSpec :: Ocb.OcbWriteSpec
multiRowI32WriteSpec =
  Ocb.OcbWriteSpec
    { Ocb.ocbWriteColumns = Ocb.ocbWriteColumns (i32WriteSpec [1, 2])
    , Ocb.ocbWriteDictionaries = []
    , Ocb.ocbWriteRowGroups =
        [ Ocb.OcbWriteRowGroup [Ocb.OcbWriteColumnChunk 0 (Ocb.OcbValuesI32 [1, 2]) Nothing]
        , Ocb.OcbWriteRowGroup [Ocb.OcbWriteColumnChunk 0 (Ocb.OcbValuesI32 [3, 4]) Nothing]
        ]
    , Ocb.ocbWriteOrderingKeys = []
    }

nullableI32WriteSpec :: [Int32] -> Ocb.OcbValidityBitmap -> Ocb.OcbWriteSpec
nullableI32WriteSpec values validity =
  Ocb.OcbWriteSpec
    { Ocb.ocbWriteColumns =
        [ Ocb.OcbWriteColumn
            { Ocb.ocbWriteColumnName = "value"
            , Ocb.ocbWriteColumnPhysicalType = Ocb.OcbPhysicalI32
            , Ocb.ocbWriteColumnLogicalKind = Ocb.OcbLogicalPlain
            , Ocb.ocbWriteColumnDictionaryId = Nothing
            , Ocb.ocbWriteColumnScale = 0
            , Ocb.ocbWriteColumnNullable = True
            , Ocb.ocbWriteColumnFixedBinaryWidth = Nothing
            }
        ]
    , Ocb.ocbWriteDictionaries = []
    , Ocb.ocbWriteRowGroups = [Ocb.OcbWriteRowGroup [Ocb.OcbWriteColumnChunk 0 (Ocb.OcbValuesI32 values) (Just validity)]]
    , Ocb.ocbWriteOrderingKeys = []
    }

i32WriteSpec :: [Int32] -> Ocb.OcbWriteSpec
i32WriteSpec values =
  Ocb.OcbWriteSpec
    { Ocb.ocbWriteColumns =
        [ Ocb.OcbWriteColumn
            { Ocb.ocbWriteColumnName = "value"
            , Ocb.ocbWriteColumnPhysicalType = Ocb.OcbPhysicalI32
            , Ocb.ocbWriteColumnLogicalKind = Ocb.OcbLogicalPlain
            , Ocb.ocbWriteColumnDictionaryId = Nothing
            , Ocb.ocbWriteColumnScale = 0
            , Ocb.ocbWriteColumnNullable = False
            , Ocb.ocbWriteColumnFixedBinaryWidth = Nothing
            }
        ]
    , Ocb.ocbWriteDictionaries = []
    , Ocb.ocbWriteRowGroups = [Ocb.OcbWriteRowGroup [Ocb.OcbWriteColumnChunk 0 (Ocb.OcbValuesI32 values) Nothing]]
    , Ocb.ocbWriteOrderingKeys = [Ocb.OcbWriteOrderingKey 0 Ocb.OcbOrderingAscending Ocb.OcbNoNulls]
    }

assertOcbReadI32 :: String -> [Int32] -> Ocb.OcbFile -> IO ()
assertOcbReadI32 label expected file = do
  outcome <- unwrap label =<< Ocb.readBatches file Ocb.defaultOcbReadRequest{Ocb.ocbReadProjection = Ocb.OcbProjectionNames ["value"]}
  let actual = concatMap batchValues (Ocb.ocbOutcomeBatches outcome)
  assertEqual label expected actual
 where
  batchValues batch = concatMap columnValues (Ocb.ocbBatchColumns batch)
  columnValues column = case Ocb.ocbArrayValues column of
    Ocb.OcbValuesI32 values -> values
    other -> error (label <> ": expected i32 values, got " <> show other)

assertOcbProjectionPredicateOutcome :: String -> Ocb.OcbReadOutcome -> IO ()
assertOcbProjectionPredicateOutcome label outcome = do
  let report = Ocb.ocbOutcomeReport outcome
  assertEqual (label <> " selected row groups") 1 (Ocb.ocbReadSelectedRowGroups report)
  assertEqual (label <> " pruned row groups") 2 (Ocb.ocbReadPrunedRowGroups report)
  assertEqual (label <> " selected chunks") 1 (Ocb.ocbReadSelectedColumnChunks report)
  assertEqual (label <> " fallback") (Just "too_few_row_groups") (Ocb.ocbReadFallbackReason report)
  case Ocb.ocbOutcomeBatches outcome of
    [batch] -> do
      assertEqual (label <> " row count") 2 (Ocb.ocbBatchRowCount batch)
      case Ocb.ocbBatchColumns batch of
        [column] -> do
          assertEqual (label <> " column name") "metric" (Ocb.ocbArrayName column)
          assertEqual (label <> " values") (Ocb.OcbValuesI64 [5100, 5101]) (Ocb.ocbArrayValues column)
        other -> failTest (label <> ": expected one projected column, got " <> show (length other))
    other -> failTest (label <> ": expected one selected row group, got " <> show (length other))

discoverOcbFixture :: IO (Maybe FilePath)
discoverOcbFixture = do
  envFixture <- lookupEnv "ARCADIA_TIO_OCB_FIXTURE"
  case envFixture of
    Just path -> do
      exists <- doesFileExist path
      if exists then pure (Just path) else searchFromCwd
    Nothing -> searchFromCwd
  where
    searchFromCwd = getCurrentDirectory >>= go
    go dir = do
      let candidate = dir </> "crates" </> "arcadia-tio" </> "tests" </> "fixtures" </> "ocb" </> "projection-predicate.ocb"
      exists <- doesFileExist candidate
      if exists
        then pure (Just candidate)
        else do
          let parent = takeDirectory dir
          if parent == dir then pure Nothing else go parent

decodeI32LE :: [Word8] -> [Int32]
decodeI32LE [] = []
decodeI32LE (a:b:c:d:rest) = fromIntegral (fromIntegral a .|. shiftL (fromIntegral b) 8 .|. shiftL (fromIntegral c) 16 .|. shiftL (fromIntegral d) 24 :: Word64) : decodeI32LE rest
decodeI32LE _ = []

decodeI64LE :: [Word8] -> [Int64]
decodeI64LE [] = []
decodeI64LE (a:b:c:d:e:f:g:h:rest) = fromIntegral word : decodeI64LE rest
 where
  word = fromIntegral a .|. shiftL (fromIntegral b) 8 .|. shiftL (fromIntegral c) 16 .|. shiftL (fromIntegral d) 24 .|. shiftL (fromIntegral e) 32 .|. shiftL (fromIntegral f) 40 .|. shiftL (fromIntegral g) 48 .|. shiftL (fromIntegral h) 56 :: Word64
decodeI64LE _ = []

unwrapSomeF32 :: String -> Result SomeTensor -> IO (Tensor Float)
unwrapSomeF32 label result = unwrap label result >>= expectSomeF32 label

expectSomeF32 :: String -> SomeTensor -> IO (Tensor Float)
expectSomeF32 label tensor = case tensor of
  SomeTensorF32 value -> pure value
  other -> failTest (label <> ": expected f32 tensor, got " <> show (someTensorDType other))

unwrapSomeF64 :: String -> Result SomeTensor -> IO (Tensor Double)
unwrapSomeF64 label result = unwrap label result >>= expectSomeF64 label

expectSomeF64 :: String -> SomeTensor -> IO (Tensor Double)
expectSomeF64 label tensor = case tensor of
  SomeTensorF64 value -> pure value
  other -> failTest (label <> ": expected f64 tensor, got " <> show (someTensorDType other))


unwrapSomeI32 :: String -> Result SomeTensor -> IO (Tensor Int32)
unwrapSomeI32 label result = unwrap label result >>= expectSomeI32 label

expectSomeI32 :: String -> SomeTensor -> IO (Tensor Int32)
expectSomeI32 label tensor = case tensor of
  SomeTensorI32 value -> pure value
  other -> failTest (label <> ": expected i32 tensor, got " <> show (someTensorDType other))

unwrapSomeDenseF64 :: String -> Result SomeDenseRead -> IO (DenseRead Double)
unwrapSomeDenseF64 label result = unwrap label result >>= expectSomeDenseF64 label

expectSomeDenseF64 :: String -> SomeDenseRead -> IO (DenseRead Double)
expectSomeDenseF64 label dense = case dense of
  SomeDenseReadF64 value -> pure value
  other -> failTest (label <> ": expected f64 dense read, got " <> show (someDenseReadDType other))

assertTensor :: String -> [Word64] -> [Double] -> Tensor Double -> IO ()
assertTensor label expectedShape expectedValues tensor = do
  assertEqual (label <> " shape") expectedShape (tensorShape tensor)
  assertEqual (label <> " values") (VS.fromList expectedValues) (tensorValues tensor)

safeHead :: [a] -> Maybe a
safeHead [] = Nothing
safeHead (x : _) = Just x

nativeLibraryConfigured :: IO Bool
nativeLibraryConfigured = do
  exact <- lookupEnv "ARCADIA_TIO_CAPI_LIB"
  dir <- lookupEnv "ARCADIA_TIO_CAPI_LIB_DIR"
  pure (nonEmpty exact || nonEmpty dir)
 where
  nonEmpty = maybe False (not . null)

cleanup :: FilePath -> IO ()
cleanup path = do
  removeFileIfExists path
  removeFileIfExists (path <> ".lock")

removeFileIfExists :: FilePath -> IO ()
removeFileIfExists path = do
  exists <- doesFileExist path
  if exists then removeFile path else pure ()

assertEqualResult :: (Eq a, Show a) => String -> a -> Result a -> IO ()
assertEqualResult label expected result = do
  actual <- unwrap label result
  assertEqual label expected actual

assertInvalid :: String -> Maybe TioError -> IO ()
assertInvalid label result = case result of
  Just err -> assertEqual label ErrorInvalidArgument (tioErrorCode err)
  Nothing -> failTest (label <> ": expected validation failure")

assertErrorCode :: String -> ErrorCode -> Result a -> IO ()
assertErrorCode label expected result = case result of
  Left err -> assertEqual label expected (tioErrorCode err)
  Right _ -> failTest (label <> ": expected error " <> show expected <> ", got success")

assertEqual :: (Eq a, Show a) => String -> a -> a -> IO ()
assertEqual label expected actual =
  unless (expected == actual) $
    failTest (label <> ": expected " <> show expected <> ", got " <> show actual)

unwrap :: String -> Result a -> IO a
unwrap label result = case result of
  Left err -> failTest (label <> " failed: " <> show err)
  Right value -> pure value

failTest :: String -> IO a
failTest message = do
  putStrLn ("FAIL: " <> message)
  exitFailure
