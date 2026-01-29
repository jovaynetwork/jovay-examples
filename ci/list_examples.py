#!/usr/bin/env python3
"""
Read `examples.yaml` (repo root), validate a minimal schema, and output either:
- JSON list (default)
- GitHub Actions matrix JSON (with --format gha-matrix)

We intentionally avoid adding Python dependencies.
If PyYAML is not available, we fall back to Ruby's stdlib YAML parser (Psych),
which is available on GitHub Actions runners.
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path
from typing import Any, Dict, List, Tuple


def _repo_root() -> Path:
    # Assumes this script lives in <repo>/ci/
    return Path(__file__).resolve().parent.parent


def _load_yaml_with_pyyaml(yaml_path: Path) -> Dict[str, Any]:
    import yaml  # type: ignore

    with yaml_path.open("r", encoding="utf-8") as f:
        data = yaml.safe_load(f)
    if not isinstance(data, dict):
        raise ValueError("Root YAML document must be a mapping")
    return data


def _load_yaml_with_ruby(yaml_path: Path) -> Dict[str, Any]:
    # Ruby is present on GitHub Actions ubuntu-latest, and includes YAML via Psych.
    ruby = os.environ.get("RUBY", "ruby")
    script = (
        "require 'yaml'; require 'json'; "
        "data = YAML.load_file(ARGV[0]); "
        "puts JSON.generate(data)"
    )
    proc = subprocess.run(
        [ruby, "-e", script, str(yaml_path)],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        check=False,
    )
    if proc.returncode != 0:
        raise RuntimeError(f"Failed to parse YAML via Ruby: {proc.stderr.strip()}")
    data = json.loads(proc.stdout)
    if not isinstance(data, dict):
        raise ValueError("Root YAML document must be a mapping")
    return data


def _get_nested(d: Dict[str, Any], path: Tuple[str, ...]) -> Any:
    cur: Any = d
    for k in path:
        if not isinstance(cur, dict) or k not in cur:
            return None
        cur = cur[k]
    return cur


def validate_registry(registry: Dict[str, Any], repo_root: Path) -> List[Dict[str, Any]]:
    version = registry.get("version")
    if version != 1:
        raise ValueError("examples.yaml: `version` must be 1")

    examples = registry.get("examples")
    if not isinstance(examples, list) or not examples:
        raise ValueError("examples.yaml: `examples` must be a non-empty list")

    seen_paths = set()
    validated: List[Dict[str, Any]] = []

    for idx, ex in enumerate(examples):
        if not isinstance(ex, dict):
            raise ValueError(f"examples.yaml: examples[{idx}] must be a mapping")

        ex_path = ex.get("path")
        ex_type = ex.get("type")
        ex_desc = ex.get("description")

        if not isinstance(ex_path, str) or not ex_path.strip():
            raise ValueError(f"examples.yaml: examples[{idx}].path must be a non-empty string")

        if ex_path in seen_paths:
            raise ValueError(f"examples.yaml: duplicate path: {ex_path}")
        seen_paths.add(ex_path)

        abs_path = (repo_root / ex_path).resolve()
        if not abs_path.exists() or not abs_path.is_dir():
            raise ValueError(f"examples.yaml: examples[{idx}].path does not exist: {ex_path}")

        if not isinstance(ex_type, str) or not ex_type.strip():
            raise ValueError(f"examples.yaml: examples[{idx}].type must be a non-empty string")

        if not isinstance(ex_desc, str) or not ex_desc.strip():
            raise ValueError(f"examples.yaml: examples[{idx}].description must be a non-empty string")

        # Validate type is one of the allowed types
        allowed_types = ["solidity", "frontend"]
        if ex_type not in allowed_types:
            raise ValueError(
                f"examples.yaml: examples[{idx}].type must be one of: {', '.join(allowed_types)}"
            )

        # Normalize minimal flags for known types
        foundry_offline = bool(
            _get_nested(ex, ("test", "solidity", "foundry", "test", "offline")) is True
        )
        foundry_fmt = _get_nested(ex, ("test", "solidity", "foundry", "fmt"))
        foundry_build = _get_nested(ex, ("test", "solidity", "foundry", "build"))
        foundry_test = _get_nested(ex, ("test", "solidity", "foundry", "test"))
        foundry_lint = _get_nested(ex, ("test", "solidity", "foundry", "lint"))

        # Check for Hardhat config
        hardhat_compile = _get_nested(ex, ("test", "solidity", "hardhat", "compile"))
        hardhat_test = _get_nested(ex, ("test", "solidity", "hardhat", "test"))
        hardhat_lint = _get_nested(ex, ("test", "solidity", "hardhat", "lint"))

        validated.append(
            {
                "path": ex_path,
                "type": ex_type,
                "description": ex_desc,
                "foundry": {
                    "fmt": bool(foundry_fmt) if foundry_fmt is not None else True,
                    "build": bool(foundry_build) if foundry_build is not None else True,
                    "test": True if foundry_test is not None else True,
                    "lint": bool(foundry_lint) if foundry_lint is not None else True,
                    "offline": foundry_offline,
                },
                "hardhat": {
                    "compile": bool(hardhat_compile) if hardhat_compile is not None else False,
                    "test": bool(hardhat_test) if hardhat_test is not None else False,
                    "lint": bool(hardhat_lint) if hardhat_lint is not None else False,
                },
            }
        )

    return validated


def load_yaml(yaml_path: Path) -> Dict[str, Any]:
    try:
        return _load_yaml_with_pyyaml(yaml_path)
    except Exception:
        return _load_yaml_with_ruby(yaml_path)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--file", default="examples.yaml", help="Path to examples registry YAML")
    ap.add_argument(
        "--format",
        default="json",
        choices=["json", "gha-matrix", "gha-matrix-grouped", "paths"],
        help="Output format",
    )
    args = ap.parse_args()

    root = _repo_root()
    yaml_path = (root / args.file).resolve()
    registry = load_yaml(yaml_path)
    examples = validate_registry(registry, root)

    if args.format == "json":
        sys.stdout.write(json.dumps(examples, indent=2))
        sys.stdout.write("\n")
        return 0

    if args.format == "gha-matrix":
        matrix = {"include": []}
        for ex in examples:
            entry = {
                "path": ex["path"],
                "type": ex["type"],
                "foundry_offline": ex["foundry"]["offline"],
            }
            matrix["include"].append(entry)

        sys.stdout.write(json.dumps(matrix))
        sys.stdout.write("\n")
        return 0

    if args.format == "gha-matrix-grouped":
        # Group examples by their top-level directory (e.g., foundry_examples, hardhat_examples)
        groups: Dict[str, List[Dict[str, Any]]] = {}
        for ex in examples:
            # Extract top-level directory from path (e.g., "foundry_examples/token_example" -> "foundry_examples")
            top_dir = ex["path"].split("/")[0]
            if top_dir not in groups:
                groups[top_dir] = []
            groups[top_dir].append(ex)

        # Build matrix with one entry per group
        matrix = {"include": []}
        for group_name, group_examples in sorted(groups.items()):
            # Collect paths and types for this group
            paths = [ex["path"] for ex in group_examples]
            # All examples in a group should have the same type, but we'll use the first one
            types = {ex["type"] for ex in group_examples}
            if len(types) > 1:
                # Only warn if mixed types in a group, but don't fail
                print(f"Warning: Group {group_name} has mixed types: {types}", file=sys.stderr)
            example_type = group_examples[0]["type"]

            # For foundry examples, check if any requires offline mode
            foundry_offline = any(ex["foundry"]["offline"] for ex in group_examples if example_type == "solidity")

            entry = {
                "group": group_name,
                "paths": " ".join(paths),  # Space-separated list of paths
                "type": example_type,
                "foundry_offline": foundry_offline,
            }
            matrix["include"].append(entry)

        sys.stdout.write(json.dumps(matrix))
        sys.stdout.write("\n")
        return 0

    if args.format == "paths":
        # Output all paths as space-separated string, plus type and foundry_offline info
        all_paths = [ex["path"] for ex in examples]
        # Check types - all should be same, but we'll use the first one
        types = {ex["type"] for ex in examples}
        if len(types) > 1:
            # Only warn if mixed types, but don't fail
            print(f"Warning: Mixed types found: {types}", file=sys.stderr)
        example_type = examples[0]["type"]

        # For foundry examples, check if any requires offline mode
        foundry_offline = any(ex["foundry"]["offline"] for ex in examples if example_type == "solidity")

        result = {
            "paths": " ".join(all_paths),
            "type": example_type,
            "foundry_offline": foundry_offline,
        }
        sys.stdout.write(json.dumps(result))
        sys.stdout.write("\n")
        return 0

    raise AssertionError("unreachable")


if __name__ == "__main__":
    raise SystemExit(main())
