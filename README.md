# arcadia-tio-hs

`arcadia-tio-hs` is a Haskell wrapper over the Arcadia TIO C ABI.
It does not implement the .tio/.ocb formats itself.

Rust owns the `.tio` / `.ocb` implementation. The stable native boundary is the
Arcadia TIO C ABI exposed by `libarcadia_tio_capi.so`. This package provides a
small, source-visible Haskell layer that dynamically loads that shared library
at runtime and copies native tensor outputs into Haskell-owned
`Data.Vector.Storable` values.

This work targets the frozen Arcadia TIO 0.2.0 native C ABI surface. It is an
initial Linux-focused slice, not a Hackage release, GitHub release, binary
distribution, performance claim, production-readiness claim, or broad
API-parity claim.

## Rust / Haskell parity

See [docs/parity.md](docs/parity.md) for the current parity map against the original Arcadia TIO Rust surface and recommended next slices.

A static inventory gate can compare the Haskell wrapper surface with the native
C ABI headers without loading a native shared library:

```sh
python3 scripts/parity_inventory.py \
  --include-root /path/to/arcadia-tio/crates/arcadia-tio-capi/include
```

The same check is available as a Cabal test target when the include root is
provided explicitly:

```sh
ARCADIA_TIO_CAPI_INCLUDE_ROOT=/path/to/arcadia-tio/crates/arcadia-tio-capi/include \
  cabal test arcadia-tio-hs-parity-inventory --test-show-details=direct
```

The inventory fails on unknown/unmapped C ABI items by default and leaves known
deferred blockers visible for follow-up wrapper slices.

## Current scope

Implemented:

- runtime dynamic loading of `libarcadia_tio_capi.so`;
- ABI version check through `arcadia_tio_abi_version`;
- copied access to `arcadia_tio_last_error_code` and
  `arcadia_tio_last_error_message`;
- create streaming, random-access, inferred, and policy-selected `.tio` files,
  including optional dim names, symbols, channels, and user key/value metadata on
  supported create paths;
- open `.tio` files;
- close native handles through a `ForeignPtr` finalizer, with explicit `close`;
- query/set write-forward compression configuration;
- query basic open-file metadata: rank, dtype, append axis, dimension lengths,
  chunk plan, and native handle path;
- load basic path metadata into Haskell-owned values;
- expose metadata setter wrappers that return the native C ABI status (currently
  unsupported by the V4-only runtime where the native library says so);
- append dense `f32`, `f64`, `i32`, and `i64` tensors;
- analyze and append sparse-intent `f32`, `f64`, `i32`, and `i64` payloads,
  including exact integer sparse predicates through the C ABI V2 sparse rule;
- read all values into Haskell-owned `Vector.Storable` buffers;
- read all values with a copied validity mask;
- read axis ranges/takes/one-index slices, append-entry ranges/takes, and scalar values;
- read full and selector-bearing retained commit snapshots, including dense
  materialization with mask;
- inspect head/list commits and shallow compaction stats;
- run copy-live compaction helpers (`compactTo`, `maybeCompact`) and query
  auto-compaction config/state;
- call pop/revert helpers and surface the native status;
- open OCB selected-snapshot handles and read minimal row/root metadata;
- free C-owned tensors, masks, strings, chunk plans, commit lists, OCB metadata,
  and file metadata with the matching C ABI free functions after copying.

Not yet supported:

- parsing `.tio` or `.ocb` in Haskell;
- OCB write/read-batch/dictionary/summary APIs beyond minimal open/metadata/close;
- coordinate APIs, advanced index reads, retained-history/detailed
  compaction/reform/diagnostic report families, Arrow,
  Python/NumPy interop, or C++ helpers;
- macOS/Windows native-library lookup;
- native library vendoring, publishing, signing, or release assets.

## Native library setup

Build or obtain an operator-approved Arcadia TIO C ABI shared library for
your platform. For a local source checkout, that usually means building the
`arcadia-tio-capi` package in release mode:

```sh
cd /path/to/arcadia-tio
cargo build -p arcadia-tio-capi --release
```

Then point the Haskell wrapper at the shared object:

```sh
cd /path/to/arcadia-tio-hs
export ARCADIA_TIO_CAPI_LIB=/path/to/arcadia-tio/target/release/libarcadia_tio_capi.so
# Usually useful for tools or child processes that use platform loader lookup:
export LD_LIBRARY_PATH="$(dirname "$ARCADIA_TIO_CAPI_LIB")${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
```

Alternatively, set a directory fallback:

```sh
export ARCADIA_TIO_CAPI_LIB_DIR=/path/to/arcadia-tio/target/release
```

The loader checks `ARCADIA_TIO_CAPI_LIB` first, then
`ARCADIA_TIO_CAPI_LIB_DIR/libarcadia_tio_capi.so`.

## Build and test

The package builds without the native library present because symbols are loaded
at runtime:

```sh
cabal update
cabal build all
```

The test suite skips when neither `ARCADIA_TIO_CAPI_LIB` nor
`ARCADIA_TIO_CAPI_LIB_DIR` is set. With the native library configured, it creates
project-local `.test-output/*.tio` files, checks dense `f32`/`f64`/`i32`/`i64`
roundtrips, random-access create, sparse-intent append, compaction helpers,
metadata queries, selector reads, dense-mask reads, and removes generated files:

```sh
cabal test all
```

## Minimal example

```haskell
import qualified Data.Vector.Storable as VS
import Arcadia.Tio

main :: IO ()
main = do
  native <- either (fail . show) pure =<< loadNativeLibrary

  created <- createStreaming native "example.tio" F64
    [dim AxisTime 0, dim AxisChannel 2]
    0
  file <- either (fail . show) pure created

  _ <- either (fail . show) pure =<<
    appendDenseF64 file [1, 2] (VS.fromList [10.0, 20.0])
  close file

  reopened <- either (fail . show) pure =<< open native "example.tio"
  tensor <- either (fail . show) pure =<< readAllF64 reopened
  print (tensorShape tensor, VS.toList (tensorValues tensor))
  close reopened
```

A compilable version lives at `examples/Roundtrip.hs` and is built by
`cabal build all`.

## Ownership model

- `TensorFile` wraps the opaque `ArcadiaTioHandle*` in a `ForeignPtr`.
- The finalizer calls `arcadia_tio_close`; `close` can be used for eager cleanup.
- `readAll` and selector reads copy native `ArcadiaTioTensor` data and shape
  into Haskell-owned vectors/lists before freeing the native tensor.
- `readAllDense` also copies `ArcadiaTioMask` before freeing the native mask.
- Raw C-owned tensor buffers are never exposed from the public safe API.
- Append calls borrow Haskell vector memory only for the duration of one FFI
  call.

## Development boundaries

Keep generated `.tio` / `.ocb` files, native libraries, Cabal build outputs,
private source paths, benchmark artifacts, package archives, tags, release
assets, and publishing actions out of this public wrapper repo unless a later
explicit release task approves them.
