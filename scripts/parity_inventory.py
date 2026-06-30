#!/usr/bin/env python3
"""Inventory the Arcadia TIO C ABI against the Haskell wrapper surface.

The tool is intentionally static: it reads C headers and Haskell source files, not
libarcadia_tio_capi.so.  The include/header locations are configurable so the
public Haskell checkout does not need private native artifacts or absolute paths.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Sequence

CATEGORY_WRAPPED = "wrapped"
CATEGORY_NOT_APPLICABLE = "not-applicable"
CATEGORY_DEFERRED = "deferred-blocker"
CATEGORY_UNKNOWN = "unknown-unmapped"

FUNCTION_RE = re.compile(r"\barcadia_tio_[A-Za-z0-9_]+\s*\(")
DLSYM_RE = re.compile(r'dlsym\s+dl\s+"(arcadia_tio_[A-Za-z0-9_]+)"')
TYPEDEF_RE = re.compile(
    r"typedef\s+(?:struct|enum)\s+(ArcadiaTio[A-Za-z0-9_]+)\b|"
    r"typedef\s+ArcadiaTioErrorCode\s+\(\*\s*(ArcadiaTio[A-Za-z0-9_]+)\)"
)
HASKELL_C_TYPE_RE = re.compile(r"\bC(ArcadiaTio[A-Za-z0-9_]+)\b")

WRAPPED_FUNCTIONS = {
    # Resolved through helpers rather than direct calls in user-facing modules.
    "arcadia_tio_last_error_message",
    "arcadia_tio_last_error_code",
    "arcadia_tio_abi_version",
}

WRAPPED_TYPES = {
    "ArcadiaTioHandle",
    "ArcadiaTioOcbFile",
    "ArcadiaTioErrorCode",
    "ArcadiaTioDType",
    "ArcadiaTioAxisKind",
    "ArcadiaTioHeaderProfile",
    "ArcadiaTioStorageProfile",
    "ArcadiaTioStorageAccessKind",
    "ArcadiaTioOpenPattern",
    "ArcadiaTioFilePopulation",
    "ArcadiaTioMetadataStability",
    "ArcadiaTioCompressionMode",
    "ArcadiaTioCompressionCodec",
    "ArcadiaTioCompactionModeTag",
    "ArcadiaTioEntrySelectorTag",
    "ArcadiaTioSparseDetectorKind",
    "ArcadiaTioSparseValuePredicateKindV2",
    "ArcadiaTioSparseFallbackPolicy",
    "ArcadiaTioSparseAppendOutcome",
    "ArcadiaTioSparseAppendReason",
}

# Native ABI entrypoints that are intentionally superseded by richer Haskell
# wrappers rather than hidden gaps.  For example, append helpers use the C ABI
# *_with_range variants so callers receive the append range.
NOT_APPLICABLE_FUNCTIONS = {
    "arcadia_tio_append_f32",
    "arcadia_tio_append_f64",
    "arcadia_tio_append_i32",
    "arcadia_tio_append_i64",
    "arcadia_tio_append_sparse_f32",
    "arcadia_tio_append_sparse_f64",
    "arcadia_tio_append_sparse_i32",
    "arcadia_tio_append_sparse_i64",
    "arcadia_tio_append_sparse_f32_with_range",
    "arcadia_tio_append_sparse_f64_with_range",
    "arcadia_tio_append_sparse_i32_with_range",
    "arcadia_tio_append_sparse_i64_with_range",
    "arcadia_tio_append_sparse_f32_v2",
    "arcadia_tio_append_sparse_f64_v2",
    "arcadia_tio_append_sparse_i32_v2",
    "arcadia_tio_append_sparse_i64_v2",
    "arcadia_tio_analyze_sparse_append_f32",
    "arcadia_tio_analyze_sparse_append_f64",
    "arcadia_tio_analyze_sparse_append_i32",
    "arcadia_tio_analyze_sparse_append_i64",
}

NOT_APPLICABLE_FUNCTION_REASONS = {
    name: "superseded by append_sparse_*_with_range_v2 Haskell wrappers; same inputs plus returned append range"
    for name in {
        "arcadia_tio_append_sparse_f32_v2",
        "arcadia_tio_append_sparse_f64_v2",
        "arcadia_tio_append_sparse_i32_v2",
        "arcadia_tio_append_sparse_i64_v2",
    }
}

NOT_APPLICABLE_TYPES = {
    # Callback-only visitor shape is not a stable, safe Haskell wrapper boundary;
    # batch reads remain deferred and will choose their own ownership model.
    "ArcadiaTioOcbBatchVisitor",
    "ArcadiaTioSparseRule",
    "ArcadiaTioSparseValuePredicate",
    "ArcadiaTioSparseValuePredicateKind",
}

DEFERRED_FUNCTION_PREFIXES = (
    "arcadia_tio_coordinate_",
    "arcadia_tio_load_coordinate_",
    "arcadia_tio_axis_coordinate_",
    "arcadia_tio_read_axis_coordinates",
    "arcadia_tio_create_random_access_with_coordinates",
    "arcadia_tio_create_streaming_with_coordinates",
    "arcadia_tio_create_inferred_with_coordinates",
    "arcadia_tio_create_with_policy_with_coordinates",
    "arcadia_tio_append_f32_with_coordinates",
    "arcadia_tio_append_f64_with_coordinates",
    "arcadia_tio_append_i32_with_coordinates",
    "arcadia_tio_append_i64_with_coordinates",
    "arcadia_tio_create_random_access_with_universe",
    "arcadia_tio_create_streaming_with_universe",
    "arcadia_tio_create_with_policy_with_universe",
    "arcadia_tio_append_f32_with_universe",
    "arcadia_tio_append_f64_with_universe",
    "arcadia_tio_append_i32_with_universe",
    "arcadia_tio_append_i64_with_universe",
    "arcadia_tio_ocb_",
    "arcadia_tio_read_index",
    "arcadia_tio_read_with_",
    "arcadia_tio_read_at_commit_with_",
    "arcadia_tio_rewrite_",
    "arcadia_tio_clear_blocks",
    "arcadia_tio_v4_",
    "arcadia_tio_analyze_v4_",
    "arcadia_tio_compact_v4_retained_history",
    "arcadia_tio_reform_",
)

DEFERRED_FUNCTIONS = {
    "arcadia_tio_get_index_checkpoint_every_commits",
    "arcadia_tio_set_index_checkpoint_every_commits",
    "arcadia_tio_read_values_arrow",
    "arcadia_tio_read_execution_report_free",
    "arcadia_tio_query_trace_json_free",
    "arcadia_tio_historical_read_execution_report_free",
    "arcadia_tio_read_index_report_free",
}

WRAPPED_OCB_FUNCTIONS = {
    "arcadia_tio_ocb_open",
    "arcadia_tio_ocb_close",
    "arcadia_tio_ocb_metadata",
    "arcadia_tio_ocb_metadata_free",
}

DEFERRED_TYPE_PREFIXES = (
    "ArcadiaTioCoordinate",
    "ArcadiaTioAxisCoordinate",
    "ArcadiaTioAppendCoordinate",
    "ArcadiaTioAxisIdentity",
    "ArcadiaTioExplicitExtentAxisTarget",
    "ArcadiaTioHistorical",
    "ArcadiaTioRead",
    "ArcadiaTioQueryTrace",
    "ArcadiaTioReform",
    "ArcadiaTioV4",
    "ArcadiaTioOcb",
)

DEFERRED_TYPE_FRAGMENTS = (
    "Universe",
    "ReadOptions",
    "ReadExecutionReport",
    "HistoricalReadExecutionReport",
    "ReadIndexReport",
    "QueryTraceJson",
    "ReadShapePolicy",
    "V4Diagnostics",
    "V4Compaction",
    "RetainedHistoryCompaction",
    "ReformReport",
    "Rewrite",
    "Arrow",
    "ChunkKey",
)

WRAPPED_OCB_TYPES = {
    "ArcadiaTioOcbFile",
    "ArcadiaTioOcbMetadata",
    "ArcadiaTioOcbBodyKind",
    "ArcadiaTioOcbChecksumKind",
    "ArcadiaTioOcbColumnChunkSummaryCodec",
    "ArcadiaTioOcbDictionaryValueKind",
    "ArcadiaTioOcbErrorKind",
    "ArcadiaTioOcbFailureCause",
    "ArcadiaTioOcbLogicalKind",
    "ArcadiaTioOcbNullOrder",
    "ArcadiaTioOcbOpenValidation",
    "ArcadiaTioOcbOrderingDirection",
    "ArcadiaTioOcbPhysicalType",
    "ArcadiaTioOcbProjectionKind",
    "ArcadiaTioOcbWriteChunkCodec",
}

@dataclass(frozen=True)
class InventoryItem:
    name: str
    kind: str
    category: str
    reason: str


def strip_comments(text: str) -> str:
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    return re.sub(r"//.*", "", text)


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except FileNotFoundError as exc:
        raise SystemExit(f"missing required file: {path}") from exc


def find_repo_root(start: Path) -> Path:
    current = start.resolve()
    for candidate in (current, *current.parents):
        if (candidate / "arcadia-tio-hs.cabal").is_file():
            return candidate
    return start.resolve()


def default_include_root(repo_root: Path) -> Path | None:
    env = os.environ.get("ARCADIA_TIO_CAPI_INCLUDE_ROOT")
    if env:
        return Path(env)
    for candidate in [
        repo_root / "include",
        repo_root.parent / "crates" / "arcadia-tio-capi" / "include",
        repo_root.parent.parent / "crates" / "arcadia-tio-capi" / "include",
        repo_root.parent.parent.parent / "crates" / "arcadia-tio-capi" / "include",
    ]:
        if (candidate / "arcadia" / "tio" / "functions.h").is_file():
            return candidate
    return None


def header_path(include_root: Path, relative: str) -> Path:
    return include_root / "arcadia" / "tio" / relative


def parse_functions(functions_header: Path) -> set[str]:
    text = strip_comments(read_text(functions_header))
    return {match.group(0)[:-1].strip() for match in FUNCTION_RE.finditer(text)}


def parse_types(types_header: Path) -> set[str]:
    text = strip_comments(read_text(types_header))
    names: set[str] = set()
    for match in TYPEDEF_RE.finditer(text):
        names.add(next(group for group in match.groups() if group))
    return names


def haskell_sources(hs_root: Path) -> list[Path]:
    roots = [hs_root / "src", hs_root / "test"]
    files: list[Path] = []
    for root in roots:
        if root.is_dir():
            files.extend(sorted(root.rglob("*.hs")))
    return files


def parsed_wrapped_functions(hs_root: Path) -> set[str]:
    found = set(WRAPPED_FUNCTIONS)
    for path in haskell_sources(hs_root):
        found.update(DLSYM_RE.findall(read_text(path)))
    return found


def parsed_wrapped_types(hs_root: Path) -> set[str]:
    found = set(WRAPPED_TYPES)
    for path in haskell_sources(hs_root):
        found.update(HASKELL_C_TYPE_RE.findall(read_text(path)))
    return found


def classify_function(name: str, wrapped: set[str]) -> tuple[str, str]:
    if name in wrapped or name in WRAPPED_OCB_FUNCTIONS:
        return CATEGORY_WRAPPED, "resolved by Haskell dynamic-loader surface"
    if name in NOT_APPLICABLE_FUNCTIONS:
        return CATEGORY_NOT_APPLICABLE, NOT_APPLICABLE_FUNCTION_REASONS.get(name, "superseded by range-returning or V2 Haskell wrapper")
    if name in DEFERRED_FUNCTIONS:
        return CATEGORY_DEFERRED, "known C ABI area deferred in parity docs"
    if name.startswith("arcadia_tio_ocb_") and name not in WRAPPED_OCB_FUNCTIONS:
        return CATEGORY_DEFERRED, "OCB read/write/dictionary/plan surface deferred"
    if any(name.startswith(prefix) for prefix in DEFERRED_FUNCTION_PREFIXES):
        return CATEGORY_DEFERRED, "known C ABI family deferred in parity docs"
    return CATEGORY_UNKNOWN, "no wrapper, non-applicable rule, or deferred family matched"


def classify_type(name: str, wrapped: set[str]) -> tuple[str, str]:
    if name in wrapped or name in WRAPPED_OCB_TYPES:
        return CATEGORY_WRAPPED, "represented by Haskell public or raw C wrapper type"
    if name in NOT_APPLICABLE_TYPES:
        return CATEGORY_NOT_APPLICABLE, "callback-only native shape not exposed as safe API"
    if name.startswith("ArcadiaTioOcb") and name not in WRAPPED_OCB_TYPES:
        return CATEGORY_DEFERRED, "OCB read/write/dictionary/plan type surface deferred"
    if any(name.startswith(prefix) for prefix in DEFERRED_TYPE_PREFIXES):
        return CATEGORY_DEFERRED, "known C ABI type family deferred in parity docs"
    if any(fragment in name for fragment in DEFERRED_TYPE_FRAGMENTS):
        return CATEGORY_DEFERRED, "known report/options/advanced type family deferred in parity docs"
    return CATEGORY_UNKNOWN, "no wrapper, non-applicable rule, or deferred family matched"


def build_inventory(functions_header: Path, types_header: Path, hs_root: Path) -> list[InventoryItem]:
    wrapped_functions = parsed_wrapped_functions(hs_root)
    wrapped_types = parsed_wrapped_types(hs_root)
    items: list[InventoryItem] = []
    for name in sorted(parse_functions(functions_header)):
        category, reason = classify_function(name, wrapped_functions)
        items.append(InventoryItem(name, "function", category, reason))
    for name in sorted(parse_types(types_header)):
        category, reason = classify_type(name, wrapped_types)
        items.append(InventoryItem(name, "type", category, reason))
    return items


def grouped_counts(items: Sequence[InventoryItem]) -> dict[str, int]:
    counts = {CATEGORY_WRAPPED: 0, CATEGORY_NOT_APPLICABLE: 0, CATEGORY_DEFERRED: 0, CATEGORY_UNKNOWN: 0}
    for item in items:
        counts[item.category] += 1
    return counts


def print_markdown(items: Sequence[InventoryItem]) -> None:
    counts = grouped_counts(items)
    print("# Arcadia TIO Haskell parity inventory")
    print()
    print("<!-- Generated by scripts/parity_inventory.py --markdown; do not hand-edit. -->")
    print()
    print("This inventory compares the current Haskell wrapper surface with the Arcadia TIO C ABI headers supplied at generation time.")
    print()
    print("## Summary")
    print()
    print("| Category | Count |")
    print("| --- | ---: |")
    for category in [CATEGORY_WRAPPED, CATEGORY_NOT_APPLICABLE, CATEGORY_DEFERRED, CATEGORY_UNKNOWN]:
        print(f"| {category} | {counts[category]} |")
    print(f"| total | {len(items)} |")
    print()
    print("A default inventory run fails when `unknown-unmapped` is non-zero. Deferred blockers remain visible and can be promoted to a hard failure with `--fail-on-deferred`.")
    print()
    for category in [CATEGORY_WRAPPED, CATEGORY_NOT_APPLICABLE, CATEGORY_DEFERRED, CATEGORY_UNKNOWN]:
        selected = [item for item in items if item.category == category]
        print(f"## {category} items")
        print()
        if not selected:
            print("None.")
        else:
            for item in selected:
                print(f"- `{item.kind}` `{item.name}` — {item.reason}")
        print()


def print_report(items: Sequence[InventoryItem], *, show_all: bool, json_output: bool, markdown_output: bool) -> None:
    counts = grouped_counts(items)
    if markdown_output:
        print_markdown(items)
        return
    if json_output:
        print(json.dumps({"counts": counts, "items": [item.__dict__ for item in items]}, indent=2, sort_keys=True))
        return
    print("Arcadia TIO Haskell parity inventory")
    print("====================================")
    for category in [CATEGORY_WRAPPED, CATEGORY_NOT_APPLICABLE, CATEGORY_DEFERRED, CATEGORY_UNKNOWN]:
        print(f"{category}: {counts[category]}")
    print(f"total: {len(items)}")
    print()
    for category in [CATEGORY_UNKNOWN, CATEGORY_DEFERRED] if not show_all else [CATEGORY_WRAPPED, CATEGORY_NOT_APPLICABLE, CATEGORY_DEFERRED, CATEGORY_UNKNOWN]:
        selected = [item for item in items if item.category == category]
        if not selected:
            continue
        print(f"{category} items:")
        for item in selected:
            print(f"  - {item.kind}: {item.name} ({item.reason})")
        print()


def run_self_test() -> None:
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        include = root / "include" / "arcadia" / "tio"
        src = root / "src" / "Arcadia" / "Tio" / "Internal"
        include.mkdir(parents=True)
        src.mkdir(parents=True)
        (include / "functions.h").write_text(
            """
            uint32_t arcadia_tio_abi_version(void);
            int32_t arcadia_tio_append_f32(void);
            int32_t arcadia_tio_coordinate_lookup_v2(void);
            int32_t arcadia_tio_append_sparse_i64_v2(void);
            int32_t arcadia_tio_new_gap(void);
            """,
            encoding="utf-8",
        )
        (include / "types.h").write_text(
            """
            typedef enum ArcadiaTioDType { ARCADIA_TIO_F32 = 1 } ArcadiaTioDType;
            typedef struct ArcadiaTioCoordinateDictionaryV2 ArcadiaTioCoordinateDictionaryV2;
            typedef struct ArcadiaTioNewGap ArcadiaTioNewGap;
            """,
            encoding="utf-8",
        )
        (src / "CApi.hs").write_text(
            'x = dlsym dl "arcadia_tio_abi_version"\n'
            'data CArcadiaTioDType = CArcadiaTioDType\n',
            encoding="utf-8",
        )
        items = build_inventory(include / "functions.h", include / "types.h", root)
        by_name = {item.name: item.category for item in items}
        expected = {
            "arcadia_tio_abi_version": CATEGORY_WRAPPED,
            "arcadia_tio_append_f32": CATEGORY_NOT_APPLICABLE,
            "arcadia_tio_coordinate_lookup_v2": CATEGORY_DEFERRED,
            "arcadia_tio_append_sparse_i64_v2": CATEGORY_NOT_APPLICABLE,
            "arcadia_tio_new_gap": CATEGORY_UNKNOWN,
            "ArcadiaTioDType": CATEGORY_WRAPPED,
            "ArcadiaTioCoordinateDictionaryV2": CATEGORY_DEFERRED,
            "ArcadiaTioNewGap": CATEGORY_UNKNOWN,
        }
        if by_name != expected:
            raise SystemExit(f"self-test failed: expected {expected}, got {by_name}")
    print("parity_inventory.py self-test: PASS")


def parse_args(argv: Sequence[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--include-root", type=Path, help="C ABI include root containing arcadia/tio/*.h")
    parser.add_argument("--functions-header", type=Path, help="explicit functions.h path")
    parser.add_argument("--types-header", type=Path, help="explicit types.h path")
    parser.add_argument("--hs-root", type=Path, default=Path.cwd(), help="arcadia-tio-hs repo root (default: cwd)")
    parser.add_argument("--show-all", action="store_true", help="print all categories, not just deferred/unknown")
    parser.add_argument("--json", action="store_true", help="emit JSON report")
    parser.add_argument("--markdown", action="store_true", help="emit generated Markdown inventory")
    parser.add_argument("--fail-on-deferred", action="store_true", help="also fail while known deferred blockers remain")
    parser.add_argument("--allow-unknown", action="store_true", help="report but do not fail on unknown/unmapped items")
    parser.add_argument("--self-test", action="store_true", help="run parser/classification self-tests")
    return parser.parse_args(argv)


def main(argv: Sequence[str]) -> int:
    args = parse_args(argv)
    if args.self_test:
        run_self_test()
        return 0

    hs_root = find_repo_root(args.hs_root)
    include_root = args.include_root or default_include_root(hs_root)
    functions_header = args.functions_header or (header_path(include_root, "functions.h") if include_root else None)
    types_header = args.types_header or (header_path(include_root, "types.h") if include_root else None)
    if functions_header is None or types_header is None:
        print(
            "error: provide --include-root (or ARCADIA_TIO_CAPI_INCLUDE_ROOT) pointing at the C ABI include directory",
            file=sys.stderr,
        )
        return 2

    items = build_inventory(functions_header, types_header, hs_root)
    print_report(items, show_all=args.show_all, json_output=args.json, markdown_output=args.markdown)
    counts = grouped_counts(items)
    if counts[CATEGORY_UNKNOWN] and not args.allow_unknown:
        print(f"error: {counts[CATEGORY_UNKNOWN]} unknown/unmapped C ABI items", file=sys.stderr)
        return 1
    if counts[CATEGORY_DEFERRED] and args.fail_on_deferred:
        print(f"error: {counts[CATEGORY_DEFERRED]} deferred C ABI blockers", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
