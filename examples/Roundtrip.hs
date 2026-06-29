module Main (main) where

import qualified Data.Vector.Storable as VS
import System.Directory (createDirectoryIfMissing)
import System.Environment (getArgs)
import System.FilePath ((</>))

import Arcadia.Tio

main :: IO ()
main = do
  args <- getArgs
  let path = case args of
        [explicit] -> explicit
        _ -> ".test-output" </> "example-roundtrip.tio"
  createDirectoryIfMissing True ".test-output"

  nativeResult <- loadNativeLibrary
  native <- either dieShow pure nativeResult

  created <- createStreaming native path F64 [dim AxisTime 0, dim AxisChannel 2] 0
  file <- either dieShow pure created
  _ <- either dieShow pure =<< appendDenseF64 file [1, 2] (VS.fromList [10.0, 20.0])
  close file

  reopened <- either dieShow pure =<< open native path
  tensor <- either dieShow pure =<< readAllF64 reopened
  print (tensorShape tensor, VS.toList (tensorValues tensor))
  close reopened

dieShow :: Show e => e -> IO a
dieShow err = fail (show err)
