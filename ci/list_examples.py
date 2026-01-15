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


def load_yaml(yaml_path: Path) -> Dict[str, Any]:
    try:
        return _load_yaml_with_pyyaml(yaml_path)
    except Exception:
        return _load_yaml_with_ruby(yaml_path)


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
                    "lint": bool(hardhat_lint) if hardhat_lint is not None else True,
                },
            }
        )

    return validated


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--file", default="examples.yaml", help="Path to examples registry YAML")
    ap.add_argument(
        "--format",
        default="json",
        choices=["json", "gha-matrix"],
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

    raise AssertionError("unreachable")


if __name__ == "__main__":
    raise SystemExit(main())

