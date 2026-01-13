#!/usr/bin/env bash
set -euo pipefail

EXAMPLE_DIR="${1:-}"
if [[ -z "${EXAMPLE_DIR}" || ! -d "${EXAMPLE_DIR}" ]]; then
  echo "Usage: $0 <example_dir>" >&2
  exit 2
fi

# Avoid clashing with Foundry's own env vars. We only want "offline" for tests, not for build.
FOUNDRY_TEST_OFFLINE="${FOUNDRY_TEST_OFFLINE:-false}"

# If someone exports FOUNDRY_OFFLINE in the environment, it affects *all* forge commands (including build).
unset FOUNDRY_OFFLINE || true
FOUNDRY_FMT="${FOUNDRY_FMT:-true}"
FOUNDRY_BUILD="${FOUNDRY_BUILD:-true}"
FOUNDRY_TEST="${FOUNDRY_TEST:-true}"

cd "${EXAMPLE_DIR}"

echo "==> Foundry checks in: ${EXAMPLE_DIR}"
echo "FOUNDRY_FMT=${FOUNDRY_FMT}"
echo "FOUNDRY_BUILD=${FOUNDRY_BUILD}"
echo "FOUNDRY_TEST=${FOUNDRY_TEST}"
echo "FOUNDRY_TEST_OFFLINE=${FOUNDRY_TEST_OFFLINE}"
echo

if [[ "${FOUNDRY_FMT}" == "true" ]]; then
  echo "==> forge fmt --check"
  forge fmt --check
  echo
fi

if [[ "${FOUNDRY_BUILD}" == "true" ]]; then
  echo "==> forge build"
  forge build
  echo
fi

if [[ "${FOUNDRY_TEST}" == "true" ]]; then
  echo "==> forge test"
  if [[ "${FOUNDRY_TEST_OFFLINE}" == "true" ]]; then
    forge test --force --offline
  else
    forge test --force
  fi
  echo
fi

