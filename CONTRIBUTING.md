# Contributing to Jovay Examples

Thanks for your interest in contributing!

## What belongs in this repo?

This repository is for **small, runnable examples** that help developers build on Jovay Network.

Good contributions:
- A new example directory with a clear goal and minimal dependencies
- Fixes to existing examples (docs, tooling, scripts, tests)
- Improvements that make examples easier to reproduce from a fresh clone

Out of scope:
- Large product codebases
- Secrets or private infrastructure configuration

## Repository conventions

- **English only**: code comments and documentation should be written in English.
- **Self-contained examples**: each example should have its own `README.md` with:
  - prerequisites
  - install steps
  - how to build/test
  - how to run (if applicable)
- **No secrets**:
  - never commit real private keys, API keys, RPC URLs tied to private infra, etc.
  - if env vars are needed, add a `.env.example` template and keep `.env` gitignored
- **Pinned dependencies**:
  - if using Foundry, prefer pinned versions (tags/commits) and document them
  - if using git submodules, ensure `git clone --recurse-submodules` works

## Adding a new example

1. Create a new directory under the appropriate category (e.g. `chainlink_examples/<example_name>`).
2. Add a focused `README.md` that explains the example end-to-end.
3. Add a minimal test suite when feasible (unit tests / smoke tests).
4. Ensure the example runs from a fresh clone using only documented steps.

## Development workflow

- Create a feature branch:

```bash
git checkout -b feat/<short_name>
```

- Keep commits small and descriptive.
- If you introduce new dependencies, document why and how to install them.

## Code of Conduct

See `CODE_OF_CONDUCT.md`.

