# Jovay Examples

Open-source example projects, smart contract templates, and tutorials for building on **Jovay Network**.

## Overview

This repository hosts small, focused examples that you can copy, modify, and run locally. Each example is intended to be self-contained and includes its own README with prerequisites and step-by-step instructions.

## Repository layout

```
.
├── chainlink_examples/          # Chainlink-related examples
│   └── ccip_example/            # CCIP (Foundry): messaging + token transfer
└── LICENSE
```

## Getting started

This repo uses **git submodules** for some examples (e.g. Foundry dependencies). For the smoothest first-time setup:

```bash
git clone --recurse-submodules https://github.com/jovaynetwork/jovay-examples.git
cd jovay-examples
```

If you already cloned the repo:

```bash
git submodule update --init --recursive
```

## Examples

### Chainlink

- **CCIP (Foundry)**: `chainlink_examples/ccip_example`
  - Cross-chain messaging and token transfers between **Ethereum Sepolia** and **Jovay Testnet**
  - See: `chainlink_examples/ccip_example/README.md`

## Documentation

- Jovay docs: `https://docs.jovay.io`

## Contributing

See `CONTRIBUTING.md`.

## Security

See `SECURITY.md`.

## License

MIT — see `LICENSE`.

## CI and examples registry

This repo uses `examples.yaml` as the single source of truth for examples metadata and CI.

- Add a new example by adding a new entry to `examples.yaml` (unique `path`, plus `type` and `description`).
- CI runs basic checks per example type:
  - **solidity**: Foundry `forge fmt --check`, `forge build`, `forge test` (optionally `--offline`).
