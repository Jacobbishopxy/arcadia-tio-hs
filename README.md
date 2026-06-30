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

See [docs/parity.md](docs/parity.md) for the current parity map against the original Arcadia TIO Rust surface and recommended next slices. The generated C ABI item inventory is checked in at [docs/parity-inventory.generated.md](docs/parity-inventory.generated.md).

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

Regenerate the checked-in inventory after changing wrapper coverage or when auditing a new header snapshot:

```sh
python3 scripts/parity_inventory.py \
  --include-root /path/to/arcadia-tio/crates/arcadia-tio-capi/include \
  --markdown > docs/parity-inventory.generated.md
```

The inventory fails on unknown/unmapped C ABI items by default and leaves known
deferred blockers visible for follow-up wrapper slices. The current audited snapshot reports 336 wrapped items, 24 intentionally not-applicable items, 44 deferred blockers, and 0 unknown/unmapped items; those deferred blockers prevent any broad 100% parity claim.

## Current scope

Implemented:

- runtime dynamic loading of `libarcadia_tio_capi.so`;
- ABI version check through `arcadia_tio_abi_version`;
- copied access to `arcadia_tio_last_error_code` and
  `arcadia_tio_last_error_message`;
- create streaming, random-access, inferred, and policy-selected `.tio` files,
  including optional dim names, symbols, channels, user key/value metadata, and
  coordinate descriptors on supported create paths;
- create streaming, random-access, and policy-selected `.tio` files with
  universe-aware axis identity options;
- open `.tio` files;
- close native handles through a `ForeignPtr` finalizer, with explicit `close`;
- query/set write-forward compression configuration;
- query basic open-file metadata: rank, dtype, append axis, dimension lengths,
  chunk plan, and native handle path;
- load basic path metadata into Haskell-owned values;
- expose metadata setter wrappers that return the native C ABI status (currently
  unsupported by the V4-only runtime where the native library says so);
- append dense `f32`, `f64`, `i32`, and `i64` tensors;
- append dense `f32`, `f64`, `i32`, and `i64` tensors with Coordinate v2
  append-axis batches and with universe slot bindings/remaps;
- analyze and append sparse-intent `f32`, `f64`, `i32`, and `i64` payloads,
  including exact integer sparse predicates through the C ABI V2 sparse rule;
  direct no-range sparse V2 C append helpers are intentionally superseded by
  the Haskell range-returning wrappers;
- read all values into Haskell-owned `Vector.Storable` buffers;
- read all values with a copied validity mask;
- read axis ranges/takes/one-index slices, append-entry ranges/takes, and scalar values;
- read full and selector-bearing retained commit snapshots, including dense
  materialization with mask;
- read with execution options, shape policies (including explicit-universe
  targets), copied read execution reports, attributed query-trace JSON,
  historical option reports, and Python-style read-index lowering reports;
- read Coordinate v1/v2 metadata and values, Coordinate v2 dictionaries, and
  Coordinate v2 exact/range lookup result carriers;
- query/set index-checkpoint cadence, surfacing native unsupported status where
  the V4 runtime does not implement it;
- inspect head/list commits and shallow plus detailed V4 compaction/diagnostic
  accounting reports;
- run copy-live compaction helpers (`compactTo`, `maybeCompact`), retained-history
  compaction helpers with copied reports, and query auto-compaction config/state;
- call pop/revert helpers and surface the native status;
- call rewrite/rewrite-slice/clear-block helpers for supported native dtypes and
  surface native unsupported/invalid status for current runtime/layout gaps;
- reform visible data into fresh destinations with target-layout options and
  copied reform diagnostic metadata;
- export values through an explicit Arrow C Data ownership wrapper that releases
  Arrow callbacks without exposing raw release functions;
- open OCB selected-snapshot handles with validation options, clone readers,
  inspect structured OCB errors, copy full metadata/dictionaries, read batches
  with reports/attribution, inspect/execute read plans, and copy generic
  row-group summaries;
- create and append appendable OCB files from validated write specs, including
  primitive/fixed-binary column chunks, validity bitmaps, dictionaries, ordering
  keys, write options, fixed-binary schema helpers, cleanup-orphan-tail results,
  and generated fixture read/dictionary/summary cross-checks;
- free C-owned tensors, masks, strings, chunk plans, commit lists, OCB metadata,
  OCB read outcomes/reports/attribution/plans/summaries, and file metadata with
  the matching C ABI free functions after copying.

Not yet supported:

- parsing `.tio` or `.ocb` in Haskell;
- OCB read cursor callbacks and row-group fill APIs until safe Haskell callback
  and caller-owned buffer lifetimes are represented;
- richer coordinate fixed-text/dictionary authoring ergonomics, Python/NumPy
  interop, or C++ helpers;
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
roundtrips, random-access create, sparse-intent append, diagnostics/precise
accounting, retained-history compaction, reform helpers, metadata queries,
selector reads, option/report reads, read-index, mutation and Arrow ownership
wrappers, dense-mask reads, coordinate create/read/lookup/append smokes,
universe create/append/explicit-read smokes, OCB create/append/cleanup and
read/dictionary/summary smokes, and removes generated files:

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
- `readAll`, selector, option/report, read-index, historical, and mutation test
  reads copy native `ArcadiaTioTensor` data and shape into Haskell-owned
  vectors/lists before freeing the native tensor.
- Dense reads also copy `ArcadiaTioMask` before freeing the native mask.
- Raw C-owned tensor buffers are never exposed from the public safe API.
- Append calls borrow Haskell vector memory only for the duration of one FFI
  call.
- OCB create/append calls borrow write-spec strings, arrays, primitive buffers,
  dictionary entries, and validity bitmaps only for the duration of one FFI call;
  native read/cleanup results are copied before returning.

## Development boundaries

Keep generated `.tio` / `.ocb` files, native libraries, Cabal build outputs,
private source paths, benchmark artifacts, package archives, tags, release
assets, and publishing actions out of this public wrapper repo unless a later
explicit release task approves them.
