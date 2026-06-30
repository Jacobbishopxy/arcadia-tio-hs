module Main (main) where

import Control.Monad (unless)
import Data.Maybe (catMaybes, listToMaybe)
import System.Directory (doesDirectoryExist, doesFileExist, getCurrentDirectory)
import System.Environment (lookupEnv)
import System.Exit (ExitCode(..), exitFailure)
import System.FilePath ((</>))
import System.Process (readCreateProcessWithExitCode, proc)

main :: IO ()
main = do
  repoRoot <- getCurrentDirectory
  includeRoot <- discoverIncludeRoot repoRoot
  case includeRoot of
    Nothing -> putStrLn "SKIP: set ARCADIA_TIO_CAPI_INCLUDE_ROOT to run the parity inventory gate"
    Just root -> do
      let script = repoRoot </> "scripts" </> "parity_inventory.py"
      scriptExists <- doesFileExist script
      unless scriptExists $ do
        putStrLn ("missing parity inventory script: " <> script)
        exitFailure
      (code, out, err) <- readCreateProcessWithExitCode
        (proc "python3" [script, "--include-root", root, "--hs-root", repoRoot])
        ""
      putStr out
      putStr err
      case code of
        ExitSuccess -> pure ()
        ExitFailure _ -> exitFailure

discoverIncludeRoot :: FilePath -> IO (Maybe FilePath)
discoverIncludeRoot repoRoot = do
  envRoot <- lookupEnv "ARCADIA_TIO_CAPI_INCLUDE_ROOT"
  let candidates = catMaybes
        [ envRoot
        , Just (repoRoot </> "include")
        , Just (repoRoot </> ".." </> "crates" </> "arcadia-tio-capi" </> "include")
        , Just (repoRoot </> ".." </> ".." </> "crates" </> "arcadia-tio-capi" </> "include")
        , Just (repoRoot </> ".." </> ".." </> ".." </> "crates" </> "arcadia-tio-capi" </> "include")
        ]
  existing <- filterM includeRootExists candidates
  pure (listToMaybe existing)

includeRootExists :: FilePath -> IO Bool
includeRootExists root = doesDirectoryExist (root </> "arcadia" </> "tio")

filterM :: Monad m => (a -> m Bool) -> [a] -> m [a]
filterM predicate = go
  where
    go [] = pure []
    go (item:rest) = do
      keep <- predicate item
      kept <- go rest
      pure ([item | keep] <> kept)
