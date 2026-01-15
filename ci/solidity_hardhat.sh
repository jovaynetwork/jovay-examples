#!/usr/bin/env bash
set -euo pipefail

# Hardhat example runner
# Usage: ci/solidity_hardhat.sh <example_path>
#
# Runs:
# - npm install
# - npx hardhat compile
# - npx hardhat test

EXAMPLE_PATH="${1:-}"

if [[ -z "${EXAMPLE_PATH}" ]]; then
  echo "Usage: $0 <example_path>" >&2
  exit 2
fi

if [[ ! -d "${EXAMPLE_PATH}" ]]; then
  echo "Example path not found: ${EXAMPLE_PATH}" >&2
  exit 2
fi

cd "${EXAMPLE_PATH}"

HARDHAT_COMPILE="${HARDHAT_COMPILE:-true}"
HARDHAT_TEST="${HARDHAT_TEST:-true}"
HARDHAT_LINT="${HARDHAT_LINT:-true}"

echo "==> Hardhat checks in: ${EXAMPLE_PATH}"
echo "HARDHAT_COMPILE=${HARDHAT_COMPILE}"
echo "HARDHAT_TEST=${HARDHAT_TEST}"
echo "HARDHAT_LINT=${HARDHAT_LINT}"
echo

echo "==> Installing dependencies"
if ! npm install --silent; then
  echo "Failed to install npm dependencies" >&2
  exit 1
fi

if [[ "${HARDHAT_COMPILE}" == "true" ]]; then
  echo "==> Compiling contracts"
  if ! npx hardhat compile; then
    echo "Hardhat compile failed" >&2
    exit 1
  fi
  echo
fi

if [[ "${HARDHAT_LINT}" == "true" ]]; then
  echo "==> Running lint check (using forge lint)"
  # Use forge lint for Solidity files if Foundry is available
  # This checks Solidity code style and best practices
  if command -v forge &> /dev/null; then
    if ! forge lint; then
      echo "Lint check failed" >&2
      exit 1
    fi
  else
    echo "Warning: forge not found, skipping lint check" >&2
  fi
  echo
fi

if [[ "${HARDHAT_TEST}" == "true" ]]; then
  echo "==> Running tests"
  if ! npx hardhat test; then
    echo "Hardhat test failed" >&2
    exit 1
  fi
  echo
fi

echo "==> All Hardhat checks passed"
