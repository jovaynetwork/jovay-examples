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
    exec bash "${ROOT_DIR}/ci/solidity_foundry.sh" "${ABS_PATH}"
    ;;
  *)
    echo "Unsupported example type: ${EXAMPLE_TYPE}" >&2
    echo "Supported types: solidity" >&2
    exit 2
    ;;
esac

