#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

EXAMPLE_PATH="${EXAMPLE_PATH:-}"
EXAMPLE_TYPE="${EXAMPLE_TYPE:-}"

if [[ -z "${EXAMPLE_PATH}" || -z "${EXAMPLE_TYPE}" ]]; then
  echo "Usage: EXAMPLE_PATH=... EXAMPLE_TYPE=... [EXAMPLE_ID=...] $0" >&2
  exit 2
fi

ABS_PATH="${ROOT_DIR}/${EXAMPLE_PATH}"
if [[ ! -d "${ABS_PATH}" ]]; then
  echo "Example path not found: ${EXAMPLE_PATH}" >&2
  exit 2
fi

echo "==> Running example"
echo "path: ${EXAMPLE_PATH}"
echo "type: ${EXAMPLE_TYPE}"
echo

case "${EXAMPLE_TYPE}" in
  solidity)
    # Check if this is a Hardhat or Foundry example
    if [[ -f "${ABS_PATH}/hardhat.config.js" ]] || [[ -f "${ABS_PATH}/package.json" ]]; then
      exec bash "${ROOT_DIR}/ci/solidity_hardhat.sh" "${ABS_PATH}"
    else
      exec bash "${ROOT_DIR}/ci/solidity_foundry.sh" "${ABS_PATH}"
    fi
    ;;
  *)
    echo "Unsupported example type: ${EXAMPLE_TYPE}" >&2
    echo "Supported types: solidity" >&2
    exit 2
    ;;
esac

