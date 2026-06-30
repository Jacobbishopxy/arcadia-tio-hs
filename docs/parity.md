# Rust / Haskell parity map

This page compares the original Arcadia TIO 0.2.0 Rust surface with the current
`arcadia-tio-hs` Haskell wrapper slice.

`arcadia-tio-hs` is intentionally a wrapper over the frozen Arcadia TIO 0.2.0 C
ABI surface. It does not implement or parse the `.tio` / `.ocb` formats itself.
Private Rust internals that are not exposed through the C ABI remain out of
scope for Haskell parity.

## Machine inventory gate

The Haskell repo includes a static inventory gate at
`scripts/parity_inventory.py`. It reads the frozen C ABI headers from a
configurable include root and compares their functions/types with the Haskell
wrapper's dynamic-loader surface and raw/public wrapper types. The gate runs
without `libarcadia_tio_capi.so`; it only needs the headers.

From this repo, run:

```sh
python3 scripts/parity_inventory.py \
  --include-root /path/to/arcadia-tio/crates/arcadia-tio-capi/include
```

or, through Cabal's no-native-library test target:

```sh
ARCADIA_TIO_CAPI_INCLUDE_ROOT=/path/to/arcadia-tio/crates/arcadia-tio-capi/include \
  cabal test arcadia-tio-hs-parity-inventory --test-show-details=direct
```

The current machine inventory reports wrapped items, intentionally
not-applicable ABI conveniences, deferred blockers, and unknown/unmapped items.
A passing default run means there are no unknown/unmapped C ABI items; deferred
blockers remain visible and can be promoted to a hard failure with
`--fail-on-deferred` when later parity slices are ready for that stricter gate.

Current local header snapshot used while adding this gate:

- wrapped: 236
- intentionally not applicable: 20
- deferred blockers: 148
- unknown/unmapped: 0

These counts are an inventory baseline, not a packaging, support, or deployment statement.

Legend:

- ✅ supported in current Haskell wrapper
- ⚠️ partial or placeholder
- ❌ not yet exposed in current Haskell wrapper
- N/A intentionally not applicable to a source-visible wrapper

| Capability | Original Rust `arcadia-tio` | Current Haskell `arcadia-tio-hs` | Notes / missing work |
| --- | --- | --- | --- |
| Owns `.tio` storage implementation | ✅ V4 runtime implementation | N/A | Haskell must keep using Rust through the C ABI. |
| Parses `.tio` directly | ✅ internally | N/A | Explicit non-goal for Haskell. |
| Runtime dynamic loading | N/A | ✅ `ARCADIA_TIO_CAPI_LIB`, `ARCADIA_TIO_CAPI_LIB_DIR` | Rust links directly as the implementation crate; Haskell loads `libarcadia_tio_capi.so`. |
| ABI version check | N/A | ✅ `abiVersion`, checked during `loadNativeLibrary` | Current C ABI expected version is 3. |
| Last error code/message | N/A | ✅ copied from C ABI | Exposed as `TioError`. |
| Safe handle ownership | ✅ Rust ownership/RAII | ✅ `ForeignPtr` finalizer + `close` | Haskell wraps `ArcadiaTioHandle*`. |
| Create streaming `.tio` | ✅ `TensorFile::create_streaming` | ✅ `createStreaming` | Basic dtype/dim/append-axis path only. |
| Create random-access `.tio` | ✅ `create_random_access` | ✅ `createRandomAccess` | Basic dtype/dim/append-axis path only. |
| Policy/inferred create | ✅ bounded `create_with_policy`, inferred helpers | ✅ | Basic and metadata-rich inferred/policy create wrappers are exposed; bounded native envelope still applies. |
| Create metadata: dim names, symbols, channels, user kv | ✅ | ⚠️ partial | Metadata-rich streaming/random-access/policy/inferred create is exposed. Setter wrappers are exposed but native V4 may return `Unimplemented`. |
| Compression controls | ✅ | ✅ | `setCompressionConfig` / `getCompressionConfig`; uncompressed config covered by native smoke. |
| Dense append `f32` | ✅ | ✅ | Covered by native roundtrip smoke. |
| Dense append `f64` | ✅ | ✅ | Covered by native roundtrip smoke. |
| Dense append `i32` | ✅ | ✅ | Covered by native roundtrip smoke. |
| Dense append `i64` | ✅ | ✅ | Covered by native roundtrip smoke. |
| Append range return | ✅ C/C++/public wrapper expose range helpers | ✅ | Haskell uses `*_with_range` and returns `AppendRange`. |
| Dense read-all `f32/f64/i32/i64` | ✅ | ✅ | Copies native tensor into Haskell-owned `Vector.Storable`. |
| Null-aware dense read with mask | ✅ | ✅ | `readAllDense*` copies `ArcadiaTioMask` into Haskell-owned vector. |
| Selector reads / axis ranges / entry ranges | ✅ | ✅ | Axis range/take/one, entry range/take, selector-bearing option reads, and read-index wrappers are exposed with copied reports. |
| Scalar reads | ✅ | ✅ | `readScalar` returns dtype plus native double-valued scalar carrier. |
| File metadata load/query | ✅ `load_meta`, metadata accessors | ⚠️ partial | `rank`, `dtype`, `appendAxis`, `dimLens`, `chunkPlan`, `filePath`, and basic `loadMeta` are exposed; richer coordinate/universe metadata remains missing. |
| Tensor helper operations | ✅ Rust tensor ops | ❌ | Could add Haskell-owned tensor helpers independent of native ABI. |
| Sparse-intent append/analyze | ✅ | ✅ | `SparseRule` ADTs plus `analyzeSparseAppend*` / `appendSparse*` wrappers use the C ABI V2 sparse rule and copy native analysis reasons. |
| Signed integer sparse exact predicates | ✅ | ✅ | `SparsePredicateEqualI32` / `SparsePredicateEqualI64` are exposed and tested through V2 sparse rule calls. |
| Coordinate metadata/create/read/lookup | ✅ | ⚠️ partial | Coordinate v1/v2 metadata/read/dictionary, v2 lookup/range lookup, coordinate-aware create variants, and append-axis v2 dense append bindings are exposed. Native append-sequence numeric value reads currently report unsupported-domain status; legacy coordinate index/range helpers and richer fixed-text/dictionary authoring remain deferred. |
| Universe-aware authoring/reads | ✅ | ⚠️ partial | Streaming/random-access/policy create with universe axis identities, dense append with universe slot bindings/remaps, UUID/binding/remap ADTs, and explicit-universe shape-policy reads are exposed. No inferred-with-universe C ABI exists. |
| Commit history: head/list/read-at-commit | ✅ | ✅ | `headCommit`, `listCommits`, full/selector-bearing historical reads, dense variants, and historical option/report variants are exposed. |
| Revert/pop rollback markers | ✅ | ⚠️ partial | `pop`, `popBatched`, and `revertCommit` wrappers surface native status; broader tests for supported/unsupported layout states remain missing. |
| Rewrite / rewrite-slice / clear-block | ✅ | ⚠️ partial | `rewriteF32`/`rewriteF64`, slice variants, and `clearBlocks` are exposed with Haskell validation; native V4 may still report unsupported/invalid for current runtime layouts. |
| Compaction / retained-history compaction | ✅ | ✅ | Shallow `analyzeCompaction`, detailed `analyzeV4Compaction{,Precise}` reports, `compactTo`, retained-history compaction destinations with reports, `maybeCompact`, and auto-compaction config/state helpers are exposed. Native V4 may still report unsupported for some policy/config paths. |
| Reform | ✅ | ✅ | `reformTo` and `reformToEx` expose target-layout options, regular-chunked block-shape validation, copied report reason metadata, and native report cleanup. |
| Diagnostics / precise accounting | ✅ | ✅ | `v4Diagnostics` and `v4DiagnosticsPrecise` expose status-aware report ADTs, byte families, precise-accounting validity/omitted-field details, owned strings, and matching native report frees. |
| Arrow C Data export | ✅ via C ABI/C++ | ✅ | `readValuesArrow` returns an explicit owned `ArrowCData`; callbacks are released by `releaseArrowCData`/finalizers without exposing raw release functions. |
| OCB open/metadata/read/write | ✅ Rust `format-ocb`, C/C++/Python/public Rust surfaces | ⚠️ partial | `Arcadia.Tio.Ocb` exposes selected-snapshot open/close and minimal metadata row/root counts. OCB create/append/dictionary/read/summary APIs remain missing. |
| OCB direct Rust-core reader path | ✅ public Rust `arcadia-tio-ocb-core` | ❌ | Haskell should still use C ABI unless a separate pure Haskell/Rust-core bridge is approved. |
| Tests without native library | N/A | ✅ skips gracefully | `cabal test all` skips when env vars are absent. |
| Native `.tio` roundtrip test | ✅ Rust tests | ✅ f32/f64/i32/i64 + sparse + metadata/selectors/dense-mask | Still a focused smoke, not exhaustive parity evidence. |
| Public package hygiene | ✅ existing Rust public wrapper has mature checks | ⚠️ basic | Need dependency-boundary docs/checks and CI before release/publish decisions. |
| macOS/Windows support | ✅ Rust/C ABI can be built cross-platform in principle | ❌ Linux `.so` first slice only | Add `.dylib`/`.dll` path logic and validation later. |

## Recommended next slices

Before closing a later parity slice, run the machine inventory with
`--fail-on-deferred` against the same C ABI headers and resolve any remaining
deferred blockers by either adding wrappers or documenting why they are truly
not applicable to the Haskell C-ABI wrapper boundary.

1. Expand coordinate parity beyond the current partial surface: legacy coordinate index/range helpers, fixed-text/dictionary append authoring ergonomics, and richer index status typing.
2. Expand OCB beyond minimal open/metadata/close: create/append, dictionaries,
   row-group summaries, read requests/outcomes, cleanup, and structured OCB errors.
3. Add CI/hygiene checks once the public repo is ready: `cabal build all`,
   `cabal test all` without native env, and an optional native-library job gated
   by secrets/artifacts.
