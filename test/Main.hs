module Main (main) where

import Control.Monad (unless)
import Data.Int (Int32, Int64)
import Data.Word (Word64)
import qualified Data.Vector.Storable as VS
import System.Directory (createDirectoryIfMissing, doesFileExist, removeFile)
import System.Environment (lookupEnv)
import System.Exit (exitFailure, exitSuccess)
import System.FilePath ((</>))

import Arcadia.Tio

main :: IO ()
main = do
  configured <- nativeLibraryConfigured
  unless configured $ do
    putStrLn "SKIP: ARCADIA_TIO_CAPI_LIB or ARCADIA_TIO_CAPI_LIB_DIR is not set"
    exitSuccess

  native <- unwrap "loadNativeLibrary" =<< loadNativeLibrary
  createDirectoryIfMissing True ".test-output"

  testStreamingF64MetadataSelectorsDense native
  testReadOptionsReportsIndex native
  testMutationAndArrow native
  testStreamingF32 native
  testStreamingI32 native
  testStreamingI64 native
  testRandomAccessF64 native
  testSparseAppend native
  testCompactionHelpers native
  testInferredAndPolicyCreate native
  testMetadataRichCreateSettersAndScalar native

  putStrLn "PASS: dense .tio lifecycle/read parity smoke through libarcadia_tio_capi.so"

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
      i32Path = ".test-output" </> "sparse-i32.tio"
      sparseRule = predicateSubtensorRule [1] SparsePredicateZero
  cleanup f32Path
  f32File <- unwrap "createRandomAccess sparse f32" =<< createRandomAccess native f32Path F32 [dim AxisTime 0, dim AxisSymbol 4, dim AxisChannel 2] 0
  f32Analysis <- unwrap "analyzeSparseAppendF32" =<< analyzeSparseAppendF32 f32File [1, 4, 2] (VS.fromList [21.0, 22.0, 0.0, 0.0, 25.0, 26.0, 27.0, 28.0]) sparseRule
  assertEqual "f32 sparse outcome" SparseAppendSparseChunkTree (sparseAppendOutcome f32Analysis)
  assertEqual "f32 sparse absent" 1 (sparseAppendAbsentSubtensorCount f32Analysis)
  f32Range <- unwrap "appendSparseF32" =<< appendSparseF32 f32File [1, 4, 2] (VS.fromList [21.0, 22.0, 0.0, 0.0, 25.0, 26.0, 27.0, 28.0]) sparseRule
  assertEqual "f32 sparse append range" (AppendRange 0 1) f32Range
  f32Dense <- unwrap "readAllDenseF32 sparse" =<< readAllDenseF32 f32File (-1.0)
  assertEqual "f32 sparse dense shape" [1, 4, 2] (tensorShape (denseReadTensor f32Dense))
  assertEqual "f32 sparse dense values" (VS.fromList [21.0, 22.0, -1.0, -1.0, 25.0, 26.0, 27.0, 28.0]) (tensorValues (denseReadTensor f32Dense))
  assertEqual "f32 sparse validity" (VS.fromList [1, 1, 0, 0, 1, 1, 1, 1]) (denseReadValidity f32Dense)
  close f32File
  cleanup f32Path

  cleanup i32Path
  i32File <- unwrap "createRandomAccess sparse i32" =<< createRandomAccess native i32Path I32 [dim AxisTime 0, dim AxisSymbol 4] 0
  let exactRule = predicateSubtensorRule [1] (SparsePredicateEqualI32 (-7))
      exactValues = VS.fromList ([21, -7, 23, -7] :: [Int32])
  i32Analysis <- unwrap "analyzeSparseAppendI32 exact" =<< analyzeSparseAppendI32 i32File [1, 4] exactValues exactRule
  assertEqual "i32 exact sparse outcome" SparseAppendSparseChunkTree (sparseAppendOutcome i32Analysis)
  assertEqual "i32 exact sparse absent" 2 (sparseAppendAbsentSubtensorCount i32Analysis)
  i32Range <- unwrap "appendSparseI32 exact" =<< appendSparseI32 i32File [1, 4] exactValues exactRule
  assertEqual "i32 exact sparse append range" (AppendRange 0 1) i32Range
  i32Dense <- unwrap "readAllDenseI32 sparse" =<< readAllDenseI32 i32File 0.0
  assertEqual "i32 sparse dense shape" [1, 4] (tensorShape (denseReadTensor i32Dense))
  assertEqual "i32 sparse dense values" (VS.fromList ([21, 0, 23, 0] :: [Int32])) (tensorValues (denseReadTensor i32Dense))
  assertEqual "i32 sparse validity" (VS.fromList [1, 0, 1, 0]) (denseReadValidity i32Dense)
  close i32File
  cleanup i32Path

testCompactionHelpers :: NativeLibrary -> IO ()
testCompactionHelpers native = do
  let path = ".test-output" </> "compaction-source.tio"
      compactPath = ".test-output" </> "compaction-compact.tio"
      maybeSkipPath = ".test-output" </> "compaction-skip.tio"
      maybeRunPath = ".test-output" </> "compaction-run.tio"
  mapM_ cleanup [path, compactPath, maybeSkipPath, maybeRunPath]
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
  mapM_ cleanup [path, compactPath, maybeSkipPath, maybeRunPath]

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

unwrapSomeF64 :: String -> Result SomeTensor -> IO (Tensor Double)
unwrapSomeF64 label result = unwrap label result >>= expectSomeF64 label

expectSomeF64 :: String -> SomeTensor -> IO (Tensor Double)
expectSomeF64 label tensor = case tensor of
  SomeTensorF64 value -> pure value
  other -> failTest (label <> ": expected f64 tensor, got " <> show (someTensorDType other))

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
