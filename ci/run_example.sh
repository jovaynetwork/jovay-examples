#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

EXAMPLE_PATH="${EXAMPLE_PATH:-}"
EXAMPLE_PATHS="${EXAMPLE_PATHS:-}"
EXAMPLE_TYPE="${EXAMPLE_TYPE:-}"

# Support both single path (EXAMPLE_PATH) and multiple paths (EXAMPLE_PATHS)
# EXAMPLE_PATHS takes precedence if both are set
if [[ -n "${EXAMPLE_PATHS}" ]]; then
  # Multiple paths: space-separated list
  PATHS_ARRAY=(${EXAMPLE_PATHS})
elif [[ -n "${EXAMPLE_PATH}" ]]; then
  # Single path: backward compatibility
  PATHS_ARRAY=("${EXAMPLE_PATH}")
else
  echo "Usage: EXAMPLE_PATH=... or EXAMPLE_PATHS='...' EXAMPLE_TYPE=... $0" >&2
  exit 2
fi

if [[ -z "${EXAMPLE_TYPE}" ]]; then
  echo "Usage: EXAMPLE_PATH=... or EXAMPLE_PATHS='...' EXAMPLE_TYPE=... $0" >&2
  exit 2
fi

# Validate all paths exist
for path in "${PATHS_ARRAY[@]}"; do
  ABS_PATH="${ROOT_DIR}/${path}"
  if [[ ! -d "${ABS_PATH}" ]]; then
    echo "Example path not found: ${path}" >&2
    exit 2
  fi
done

echo "==> Running examples"
if [[ ${#PATHS_ARRAY[@]} -eq 1 ]]; then
  echo "path: ${PATHS_ARRAY[0]}"
else
  echo "paths: ${EXAMPLE_PATHS}"
  echo "count: ${#PATHS_ARRAY[@]}"
fi
echo "type: ${EXAMPLE_TYPE}"
echo

# Function to run a single example
run_single_example() {
  local example_path="$1"
  local abs_path="${ROOT_DIR}/${example_path}"
  
  echo "=========================================="
  echo "==> Processing: ${example_path}"
  echo "=========================================="
  
  case "${EXAMPLE_TYPE}" in
    solidity)
      # Check if this is a Hardhat or Foundry example
      if [[ -f "${abs_path}/hardhat.config.js" ]] || [[ -f "${abs_path}/package.json" ]]; then
        bash "${ROOT_DIR}/ci/solidity_hardhat.sh" "${abs_path}"
      else
        bash "${ROOT_DIR}/ci/solidity_foundry.sh" "${abs_path}"
      fi
      ;;
    *)
      echo "Unsupported example type: ${EXAMPLE_TYPE}" >&2
      echo "Supported types: solidity" >&2
      exit 2
      ;;
  esac
}

# Run all examples
FAILED=0
for path in "${PATHS_ARRAY[@]}"; do
  if ! run_single_example "${path}"; then
    echo "ERROR: Example ${path} failed" >&2
    FAILED=1
  fi
  echo
done

if [[ ${FAILED} -eq 1 ]]; then
  echo "ERROR: One or more examples failed" >&2
  exit 1
fi

echo "==> All examples passed"

