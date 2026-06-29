module Arcadia.Tio.Error
  ( ErrorCode(..)
  , TioError(..)
  , Result
  , nativeErrorCodeFromInt
  , libraryLoadError
  , invalidArgument
  ) where

import Data.Int (Int32)

-- | Result type used by this wrapper.
type Result a = Either TioError a

-- | Error code surfaced by the C ABI, plus wrapper-local load failures.
data ErrorCode
  = ErrorOk
  | ErrorInvalidArgument
  | ErrorUnimplemented
  | ErrorIo
  | ErrorFlatbuffers
  | ErrorLibraryLoad
  | ErrorUnknown Int32
  deriving (Eq, Show)

-- | Owned Haskell error value.
data TioError = TioError
  { tioErrorCode :: ErrorCode
  , tioErrorMessage :: String
  }
  deriving (Eq, Show)

-- | Convert a raw C ABI status code into a Haskell value.
nativeErrorCodeFromInt :: Int32 -> ErrorCode
nativeErrorCodeFromInt value = case value of
  0 -> ErrorOk
  1 -> ErrorInvalidArgument
  2 -> ErrorUnimplemented
  3 -> ErrorIo
  4 -> ErrorFlatbuffers
  other -> ErrorUnknown other

-- | Build a wrapper-local native-library load error.
libraryLoadError :: String -> TioError
libraryLoadError = TioError ErrorLibraryLoad

-- | Build a wrapper-local invalid-argument error.
invalidArgument :: String -> TioError
invalidArgument = TioError ErrorInvalidArgument
