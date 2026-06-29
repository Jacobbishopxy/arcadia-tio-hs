# Rust / Haskell parity map

This page compares the original Arcadia TIO 0.2.0 Rust surface with the current
`arcadia-tio-hs` Haskell wrapper slice.

`arcadia-tio-hs` is intentionally a wrapper over the frozen Arcadia TIO 0.2.0 C
ABI surface. It does not implement or parse the `.tio` / `.ocb` formats itself.
Private Rust internals that are not exposed through the C ABI remain out of
scope for Haskell parity.

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
| Selector reads / axis ranges / entry ranges | ✅ | ⚠️ partial | Axis range/take/one and entry range/take are exposed; richer selector ADTs/read options remain missing. |
| Scalar reads | ✅ | ✅ | `readScalar` returns dtype plus native double-valued scalar carrier. |
| File metadata load/query | ✅ `load_meta`, metadata accessors | ⚠️ partial | `rank`, `dtype`, `appendAxis`, `dimLens`, `chunkPlan`, `filePath`, and basic `loadMeta` are exposed; richer coordinate/universe metadata remains missing. |
| Tensor helper operations | ✅ Rust tensor ops | ❌ | Could add Haskell-owned tensor helpers independent of native ABI. |
| Sparse-intent append/analyze | ✅ | ✅ | `SparseRule` ADTs plus `analyzeSparseAppend*` / `appendSparse*` wrappers use the C ABI V2 sparse rule and copy native analysis reasons. |
| Signed integer sparse exact predicates | ✅ | ✅ | `SparsePredicateEqualI32` / `SparsePredicateEqualI64` are exposed and tested through V2 sparse rule calls. |
| Coordinate metadata/create/read/lookup | ✅ | ❌ | Large surface; should be later than basic metadata/selectors. |
| Universe-aware authoring/reads | ✅ | ❌ | Deferred. |
| Commit history: head/list/read-at-commit | ✅ | ⚠️ partial | `headCommit`, `listCommits`, full and selector-bearing `readAtCommit`/dense variants are exposed; historical read options/report variants remain missing. |
| Revert/pop rollback markers | ✅ | ⚠️ partial | `pop`, `popBatched`, and `revertCommit` wrappers surface native status; broader tests for supported/unsupported layout states remain missing. |
| Rewrite / rewrite-slice | ✅ | ❌ | Requires selector ADTs and dtype-specific write validation. |
| Compaction / retained-history compaction | ✅ | ⚠️ partial | Shallow `analyzeCompaction`, `compactTo`, `maybeCompact`, auto-compaction config/state, and `maybeCompactAuto` are exposed; retained-history and detailed report families remain missing. |
| Reform | ✅ | ❌ | Requires report/option ownership wrappers. |
| Diagnostics / precise accounting | ✅ | ❌ | Requires report structs and free functions. |
| Arrow C Data export | ✅ via C ABI/C++ | ❌ | Possible later; Haskell ownership/release API must be explicit. |
| OCB open/metadata/read/write | ✅ Rust `format-ocb`, C/C++/Python/public Rust surfaces | ⚠️ partial | `Arcadia.Tio.Ocb` exposes selected-snapshot open/close and minimal metadata row/root counts. OCB create/append/dictionary/read/summary APIs remain missing. |
| OCB direct Rust-core reader path | ✅ public Rust `arcadia-tio-ocb-core` | ❌ | Haskell should still use C ABI unless a separate pure Haskell/Rust-core bridge is approved. |
| Tests without native library | N/A | ✅ skips gracefully | `cabal test all` skips when env vars are absent. |
| Native `.tio` roundtrip test | ✅ Rust tests | ✅ f32/f64/i32/i64 + sparse + metadata/selectors/dense-mask | Still a focused smoke, not exhaustive parity evidence. |
| Public package hygiene | ✅ existing Rust public wrapper has mature checks | ⚠️ basic | Need dependency-boundary docs/checks and CI before release/publish decisions. |
| macOS/Windows support | ✅ Rust/C ABI can be built cross-platform in principle | ❌ Linux `.so` first slice only | Add `.dylib`/`.dll` path logic and validation later. |

## Recommended next slices

1. Add read-options/shape-policy reports for current and historical reads.
2. Add retained-history compaction, reform, and detailed diagnostics/accounting report wrappers.
3. Add coordinate metadata/read/lookup wrappers.
4. Add rewrite/rewrite-slice/clear-block mutation wrappers after selector ADTs exist.
5. Expand OCB beyond minimal open/metadata/close: create/append, dictionaries,
   row-group summaries, read requests/outcomes, cleanup, and structured OCB errors.
6. Add CI/hygiene checks once the public repo is ready: `cabal build all`,
   `cabal test all` without native env, and an optional native-library job gated
   by secrets/artifacts.
