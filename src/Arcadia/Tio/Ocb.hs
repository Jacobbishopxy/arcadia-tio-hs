{-# LANGUAGE NamedFieldPuns #-}

module Arcadia.Tio.Ocb
  ( OcbFile
  , OcbMetadata(..)
  , open
  , close
  , metadata
  ) where

import Control.Exception (finally)
import Data.Word (Word32, Word64)
import Foreign.C.String (peekCString, withCString)
import Foreign.ForeignPtr (ForeignPtr, finalizeForeignPtr, withForeignPtr)
import qualified Foreign.Concurrent as FC
import Foreign.Marshal.Alloc (alloca)
import Foreign.Ptr (Ptr, nullPtr)
import Foreign.Storable (peek, poke)

import Arcadia.Tio.Error (Result, invalidArgument)
import Arcadia.Tio.Internal.CApi
  ( CArcadiaTioOcbMetadata(..)
  , COcbFile
  , NativeLibrary
  , capiOcbClose
  , capiOcbMetadata
  , capiOcbMetadataFree
  , capiOcbOpen
  , emptyCArcadiaTioOcbMetadata
  , lastError
  , okStatus
  )

-- | Selected-snapshot OCB file handle. Reopen the path to observe later appends.
data OcbFile = OcbFile
  { ocbNative :: NativeLibrary
  , ocbHandle :: ForeignPtr COcbFile
  }

-- | Minimal selected-snapshot OCB metadata copied into Haskell-owned values.
data OcbMetadata = OcbMetadata
  { ocbFormatName :: String
  , ocbAppendable :: Bool
  , ocbRootGeneration :: Word64
  , ocbPreviousRootGeneration :: Maybe Word64
  , ocbRowCount :: Word64
  , ocbRowGroupCount :: Word32
  , ocbColumnChunkCount :: Word32
  , ocbColumnCount :: Int
  , ocbDictionaryCount :: Int
  , ocbOrderingKeyCount :: Int
  }
  deriving (Eq, Show)

-- | Open an OCB selected-snapshot handle through the C ABI.
open :: NativeLibrary -> FilePath -> IO (Result OcbFile)
open native path
  | '\0' `elem` path = pure (Left (invalidArgument "path contains an interior NUL byte"))
  | otherwise = withCString path $ \cPath -> do
      handle <- capiOcbOpen native cPath
      if handle == nullPtr
        then Left <$> lastError native
        else Right <$> wrapOcb native handle

wrapOcb :: NativeLibrary -> Ptr COcbFile -> IO OcbFile
wrapOcb native handle = do
  fp <- FC.newForeignPtr handle (capiOcbClose native handle)
  pure OcbFile{ocbNative = native, ocbHandle = fp}

-- | Eagerly close an OCB handle. Do not use the value after closing it.
close :: OcbFile -> IO ()
close OcbFile{ocbHandle} = finalizeForeignPtr ocbHandle

-- | Read selected-snapshot metadata and copy it into Haskell-owned values.
metadata :: OcbFile -> IO (Result OcbMetadata)
metadata OcbFile{ocbNative, ocbHandle} =
  withForeignPtr ocbHandle $ \handle ->
    alloca $ \outPtr -> do
      poke outPtr emptyCArcadiaTioOcbMetadata
      status <- capiOcbMetadata ocbNative handle outPtr
      if status == okStatus
        then (peek outPtr >>= copyOcbMetadata) `finally` capiOcbMetadataFree ocbNative outPtr
        else do
          err <- lastError ocbNative
          capiOcbMetadataFree ocbNative outPtr
          pure (Left err)

copyOcbMetadata :: CArcadiaTioOcbMetadata -> IO (Result OcbMetadata)
copyOcbMetadata raw@CArcadiaTioOcbMetadata{cOcbMetadataFormatName}
  | cOcbMetadataFormatName == nullPtr = pure (Left (invalidArgument "OCB metadata format_name is null"))
  | otherwise = do
      formatName <- peekCString cOcbMetadataFormatName
      pure
        ( Right
            OcbMetadata
              { ocbFormatName = formatName
              , ocbAppendable = cOcbMetadataAppendable raw /= 0
              , ocbRootGeneration = cOcbMetadataRootGeneration raw
              , ocbPreviousRootGeneration =
                  if cOcbMetadataHasPreviousRootGeneration raw == 0
                    then Nothing
                    else Just (cOcbMetadataPreviousRootGeneration raw)
              , ocbRowCount = cOcbMetadataRowCount raw
              , ocbRowGroupCount = cOcbMetadataRowGroupCount raw
              , ocbColumnChunkCount = cOcbMetadataColumnChunkCount raw
              , ocbColumnCount = fromIntegral (cOcbMetadataColumnsLen raw)
              , ocbDictionaryCount = fromIntegral (cOcbMetadataDictionariesLen raw)
              , ocbOrderingKeyCount = fromIntegral (cOcbMetadataOrderingKeysLen raw)
              }
        )
